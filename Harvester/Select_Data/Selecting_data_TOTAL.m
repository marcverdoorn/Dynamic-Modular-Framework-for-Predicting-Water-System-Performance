year = input('Choose the year of the data (2000, 2020, or 2024): ');

switch year
    case 2000
        load 2000_2024.mat
        combined_data{:,4} = combined_data{:,4} / 10;
        data_2000_specific = combined_data(1:8784,[2,4,8]);
        weather_data_2000 = table2array(data_2000_specific);

        t = (1:max(size(weather_data_2000)))';
        rain_data = [t,weather_data_2000(:,3)];
        temperature_data = [t,weather_data_2000(:,2)];
        startDate = datetime(2000, 1,1);
    case 2020    
        load 2020_2024.mat
        combined_data{:,4} = combined_data{:,4} / 10;
        data_2020_specific = combined_data(1:8784,[2,4,8]);
        weather_data_2020 = table2array(data_2020_specific);

        t = (1:max(size(weather_data_2020)))';
        rain_data = [t,weather_data_2020(:,3)];
        temperature_data = [t,weather_data_2020(:,2)];
        startDate = datetime(2020, 1,1);
    case 2024
        load 2000_2024.mat
        combined_data{:,4} = combined_data{:,4} / 10;
        data_2024_specific = combined_data(8785:end,[2,4,8]);
        weather_data_2024 = table2array(data_2024_specific);

        t = (1:max(size(weather_data_2024)))';
        rain_data = [t,weather_data_2024(:,3)];
        temperature_data = [t,weather_data_2024(:,2)];
        startDate = datetime(2024, 1,1);
end
display("The data is from the year: " + num2str(year))
% sum(rain_data(:,2))
