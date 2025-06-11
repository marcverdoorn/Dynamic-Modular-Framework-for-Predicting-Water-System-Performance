clear all; close all;

plotrainfall_all = true;
check_missing = true;

% Read all data files
data1 = readtable('2020.txt');
data2 = readtable('2024.txt');
% data3 = readtable('data/rain_data_201015_w_header.txt');
% data4 = readtable('data/rain_data_200510_w_header.txt');
% data5 = readtable('data/rain_data_200005_w_header.txt');

% Function to convert 20200510 to 2020 may 10th (proper date time format)
processDates = @(data) datetime(str2double(extractBetween(string(sprintfc('%08d', data.YYYYMMDD)), 1, 4)), ...
                               str2double(extractBetween(string(sprintfc('%08d', data.YYYYMMDD)), 5, 6)), ...
                               str2double(extractBetween(string(sprintfc('%08d', data.YYYYMMDD)), 7, 8)), ...
                               data.HH, 0, 0);

data1.DateTime = processDates(data1);
data2.DateTime = processDates(data2);
% data3.DateTime = processDates(data3);
% data4.DateTime = processDates(data4);
% data5.DateTime = processDates(data5);

% Combine all data in one big dataset
datasets = {data1, data2};
combined_data = vertcat(datasets{:});
combined_data = sortrows(combined_data, 'DateTime');

low_limit = 0.25;
combined_data.RH(combined_data.RH == -1) = low_limit;
combined_data.Rainfall = combined_data.RH ./ 10;

% Remove duplicates (keeping the most recent data in case of overlap)
[~, unique_idx] = unique(combined_data.DateTime, 'last');
combined_data = combined_data(unique_idx, :);

% Plot if requested
if plotrainfall_all
    plot(combined_data.DateTime, combined_data.Rainfall, '-b', 'LineWidth', 1.5);
    xlabel('Date and Time');
    ylabel('Rainfall (mm)');
    title('Hourly Rainfall Over Time (2000-2025)');
    grid on;
    datetick('x', 'yyyy-mm', 'keepticks');
    set(gca, 'XTickLabelRotation', 45);
end

% Check missing data if requested
if check_missing
    sum(ismissing(combined_data))
end

% Calculate statistics
mean_rh = mean(combined_data.Rainfall, 'omitnan');
median_rh = median(combined_data.Rainfall, 'omitnan');
max_rh = max(combined_data.Rainfall);
fprintf('Mean Rainfall: %.2f mm, Median: %.2f mm, Max: %.2f mm\n', mean_rh, median_rh, max_rh);

% Save the combined data
writetable(combined_data, 'combined_rain_data_2020_2024.txt');