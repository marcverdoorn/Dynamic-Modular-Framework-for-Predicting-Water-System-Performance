load 2000_2024.mat
load data_2020_2024.mat

year = input('Choose the year of the data (2000, 2020, or 2024): ');
%%
%data_2000 = data(1:8783,:);
%data_2000_specific = data(1:8783,[2,9]);
%data_2000_specific = data(1:8783,[2,8]);

%rain_data = weather_data(:,3);
%temperature_data = weather_data(:,2);

switch year
    case 2000
        combined_data{:,4} = combined_data{:,4} / 10;
        data_2000_specific = combined_data(1:8783,[2,4,8]);
        weather_data_2000 = table2array(data_2000_specific);

        t = (1:max(size(weather_data_2000)))';
        rain_data = [t,weather_data_2000(:,3)];
        temperature_data = [t,weather_data_2000(:,2)];
        startDate = datetime(2000, 1,1);
    case 2024
        combined_data{:,4} = combined_data{:,4} / 10;
        data_2024_specific = combined_data(8784:end,[2,4,8]);
        weather_data_2024 = table2array(data_2024_specific);

        t = (1:max(size(weather_data_2024)))';
        rain_data = [t,weather_data_2024(:,3)];
        temperature_data = [t,weather_data_2024(:,2)];
        startDate = datetime(2024, 1,1);
    case 2020

end
display("The data is from the year: " + num2str(year))

% rain_data = rain_data(1:10,:);
% rain_data2 =rain_data(1:2:8000,:);
