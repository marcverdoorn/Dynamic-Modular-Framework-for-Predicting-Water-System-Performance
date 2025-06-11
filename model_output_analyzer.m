close all;
clear storageLevel storageOutflowMain storageDemandMain storageOutNetSic1 storageControlSic1 ...
      storageOutNetSic2 storageControlSic2 bufferLevel bufferOF bufferOUTF ...
      storageMeta bufferMeta transMeta filterMeta harvMeta;

ws_vars = who;
slogdata_vars = ws_vars(endsWith(ws_vars, 'Slogdata'));
smeta_vars = ws_vars(endsWith(ws_vars, 'Smeta'));
blevel_vars = ws_vars(endsWith(ws_vars, 'Blevel'));
boverflow_vars = ws_vars(endsWith(ws_vars, 'Boverflow'));
boutflow_vars = ws_vars(endsWith(ws_vars, 'Boutflow'));
bmeta_vars = ws_vars(endsWith(ws_vars, 'Bmeta'));
tmeta_vars = ws_vars(endsWith(ws_vars, 'Tmeta'));
fmeta_vars = ws_vars(endsWith(ws_vars, 'Fmeta'));
hmeta_vars = ws_vars(endsWith(ws_vars, 'Hmeta'));

if ~exist('startDate', 'var') || ~isdatetime(startDate)
    startDate = datetime(2025, 1, 1);
end

if ~isempty(slogdata_vars)
    for i = 1:length(slogdata_vars)
        tsc = evalin('base', slogdata_vars{i});
        storageLevel{i} = tsc.level; 
        storageOutflowMain{i} = tsc.outflow_main;
        storageDemandMain{i} = tsc.demand_main; 

        if ismember('out_net_sic1', tsc.gettimeseriesnames)
            storageOutNetSic1{i} = tsc.out_net_sic1;
            storageControlSic1{i} = tsc.control_sic1;
        else
            storageOutNetSic1{i} = -1;
            storageControlSic1{i} = -1;
        end
        if ismember('out_net_sic2', tsc.gettimeseriesnames)
            storageOutNetSic2{i} = tsc.out_net_sic2;
            storageControlSic2{i} = tsc.control_sic2;
        else
            storageOutNetSic2{i} = -1;
            storageControlSic2{i} = -1;
        end
    end
else
    storageLevel = -1;
    storageOutflowMain = -1;
    storageDemandMain = -1;
    storageOutNetSic1 = -1;
    storageControlSic1 = -1;
    storageOutNetSic2 = -1;
    storageControlSic2 = -1;
end

if ~isempty(blevel_vars)
    for i = 1:length(blevel_vars)
        bufferLevel{i} = evalin('base', blevel_vars{i});
    end
else
    bufferLevel = -1;
end

if ~isempty(boverflow_vars)
    for i = 1:length(boverflow_vars)
        bufferOF{i} = evalin('base', boverflow_vars{i});
    end
else
    bufferOF = -1;
end

if ~isempty(boutflow_vars)
    for i = 1:length(boutflow_vars)
        bufferOUTF{i} = evalin('base', boutflow_vars{i});
    end
else
    bufferOUTF = -1;
end

if ~isempty(smeta_vars)
    for i = 1:length(smeta_vars)
        storageMeta(i, :) = evalin('base', smeta_vars{i});
    end
else
    storageMeta = -1;
end

if ~isempty(bmeta_vars)
    for i = 1:length(bmeta_vars)
        bufferMeta(i, :) = evalin('base', bmeta_vars{i});
    end
else
    bufferMeta = -1;
end

if ~isempty(tmeta_vars)
    for i = 1:length(tmeta_vars)
        transMeta(i,:) = evalin('base', tmeta_vars{i});
    end
else
    transMeta = -1;
end

if ~isempty(fmeta_vars)
    for i = 1:length(fmeta_vars)
        meta_struct = evalin('base', fmeta_vars{i});
        filterMeta(i,:) = {meta_struct.MaxFlow, meta_struct.FilterType, meta_struct.Npar};
    end
else
    filterMeta = -1;
end

if ~isempty(hmeta_vars)
    for i = 1:length(hmeta_vars)
        harvMeta(i,:) = evalin('base', hmeta_vars{i});
    end
else
    harvMeta = -1;
end

%% UI code
%% text section UI
fig = uifigure('Name', 'Model output Data', 'NumberTitle', 'off');

gl_figure = uigridlayout(fig, [2, 2], ...
    'RowHeight', {'1.5x', '1x'}, ...
    'ColumnWidth', {'1x', '1x'}, ...
    'Padding', [10 10 10 10], ...
    'RowSpacing', 10, ...
    'ColumnSpacing', 10);

text_panel = uipanel(gl_figure, 'Scrollable', 'on', 'Title', 'Parameters', ...
    'BackgroundColor', [0.95 0.95 0.95]);
text_panel.Layout.Row = 1;
text_panel.Layout.Column = 1;

gl_text = uigridlayout(text_panel, [13, 1], ... 
    'RowHeight', {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit','fit', 'fit', 'fit', 'fit', 'fit', 'fit'}, ... 
    'Padding', [10 10 10 10], ... 
    'RowSpacing', 5);
gl_text.Scrollable = "on";

uilabel(gl_text, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'Text', 'Storage parameters');
uilabel(gl_text, ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left', ...
    'Text', getStorageText(smeta_vars, storageMeta));
uilabel(gl_text, ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left', ...
    'Text', getDeficit(slogdata_vars, storageDemandMain, storageOutflowMain));

uilabel(gl_text, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'Text', 'Buffer parameters');
uilabel(gl_text, ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left', ...
    'Text', getBufferVolumeText(bmeta_vars, bufferMeta));

uilabel(gl_text, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'Text', 'Buffer overflow');
uilabel(gl_text, ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left', ...
    'Text', getBufferOverflowText(boverflow_vars, bufferOF));

uilabel(gl_text, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'Text', 'Transport parameters');
uilabel(gl_text, ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left', ...
    'Text', getTransportText(tmeta_vars, transMeta));

uilabel(gl_text, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'Text', 'Filter parameters');
uilabel(gl_text, ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left', ...
    'Text', getFilterText(fmeta_vars, filterMeta));

uilabel(gl_text, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'Text', 'Harvester parameters');
uilabel(gl_text, ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left', ...
    'Text', getHarvText(hmeta_vars, harvMeta, rain_data));

uilabel(gl_text, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'Text', 'Rain data');
uilabel(gl_text, ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left', ...
    'Text', getAccumulatedRain(rain_data));

save_button = uibutton(gl_text, 'push', ...
    'Text', 'Save Text Output', ...
    'FontSize', 12, ...
    'Position', [10 10 120 30], ...
    'ButtonPushedFcn', @(src, event) saveTextOutput(gl_text));

function saveTextOutput(gl_text)
    [file, path] = uiputfile('output.txt', 'Save Text Output');
    if file == 0 % User canceled
        return;
    end
    filepath = fullfile(path, file);
    labels = gl_text.Children; 
    text_lines = strings(length(labels), 1);
    for i = 1:length(labels)
        text_lines(i) = labels(i).Text;
    end
    writelines(text_lines, filepath);
    disp(['Text output saved to ' filepath]);
end

%% plotting section UI

button_panel = uipanel(gl_figure, 'Title', 'Plotting', ...
    'BackgroundColor', [0.95 0.95 0.95]);
button_panel.Layout.Row = 2;
button_panel.Layout.Column = [1 2]; % Span both columns

button_gl = uigridlayout(button_panel, [7, 3], ... 
    'ColumnWidth', {'1x', '1x', '1x'}, ...
    'RowHeight', repelem({30}, 7), ...
    'Padding', [0 0 0 0], ...
    'ColumnSpacing', 10); 
button_gl.Scrollable = "on";

%% Storage plot buttons
dropdown_items_storage = [{'All storages'}, arrayfun(@(x) sprintf('Storage %d', x), 1:length(slogdata_vars), 'UniformOutput', false)];
storage_dropdown = uidropdown(button_gl, ...
    'Items', dropdown_items_storage, ...
    'Value', 'All storages', ... 
    'Tooltip', 'Select "All" or a storage to plot storage data');
storage_dropdown.Layout.Column = 1;
storage_dropdown.Layout.Row = 1;

btn_storage_levels = uibutton(button_gl, 'push', ...
    'Text', 'Plot Storage Levels', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotStorageLevels(slogdata_vars, storageLevel, ...
    src.Parent.Children(1).Value, ...
    fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), ...
    startDate, fig)); 
btn_storage_levels.Layout.Column = 1;
btn_storage_levels.Layout.Row = 2;

btn_outflow_main = uibutton(button_gl, 'push', ...
    'Text', 'Plot Outflow Main', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotStorageOutflowMain(slogdata_vars, storageOutflowMain, ...
    src.Parent.Children(1).Value, fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_outflow_main.Layout.Column = 1;
btn_outflow_main.Layout.Row = 3;

btn_demand_main = uibutton(button_gl, 'push', ...
    'Text', 'Plot Demand Main', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotStorageDemandMain(slogdata_vars, storageDemandMain, ...
    src.Parent.Children(1).Value, fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_demand_main.Layout.Column = 1;
btn_demand_main.Layout.Row = 4;

btn_deficit_delivered = uibutton(button_gl, 'push', ...
    'Text', 'Plot Deficit', ... 
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotStorageDeficit(slogdata_vars, storageDemandMain, storageOutflowMain, ...
    src.Parent.Children(1).Value, fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_deficit_delivered.Layout.Column = 1;
btn_deficit_delivered.Layout.Row = 5;

btn_interconnect = uibutton(button_gl, 'push', ...
    'Text', 'Plot Interconnect Flow', ... 
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotStorageInterconnectFlow(slogdata_vars, storageOutNetSic1, storageOutNetSic2, ...
    storageMeta, src.Parent.Children(1).Value, fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_interconnect.Layout.Column = 1;
btn_interconnect.Layout.Row = 6;

btn_deficit_delivered = uibutton(button_gl, 'push', ...
    'Text', 'Plot Delivered + Deficit', ... 
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotStorageDeficitWDelivered(slogdata_vars, storageDemandMain, storageOutflowMain, ...
    src.Parent.Children(1).Value, fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_deficit_delivered.Layout.Column = 1;
btn_deficit_delivered.Layout.Row = 7;


%% Buffer plot buttons
dropdown_items_buffer = [{'All buffers'}, arrayfun(@(x) sprintf('Buffer %d', x), 1:length(blevel_vars), 'UniformOutput', false)];
buffer_dropdown = uidropdown(button_gl, ...
    'Items', dropdown_items_buffer, ...
    'Value', 'All buffers', ... 
    'Tooltip', 'Select "All" or a buffer to plot buffer data');
buffer_dropdown.Layout.Column = 2;
buffer_dropdown.Layout.Row = 1;

btn_buffer_levels = uibutton(button_gl, 'push', ...
    'Text', 'Plot Buffer Levels', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotBufferLevels(blevel_vars, bufferLevel, src.Parent.Children(8).Value, ...
    fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_buffer_levels.Layout.Column = 2;
btn_buffer_levels.Layout.Row = 2;

btn_buffer_overflows = uibutton(button_gl, 'push', ...
    'Text', 'Plot Buffer Overflows', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotBufferOverflows(boverflow_vars, bufferOF, src.Parent.Children(8).Value, ...
    fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_buffer_overflows.Layout.Column = 2;
btn_buffer_overflows.Layout.Row = 3;

btn_buffer_outflows = uibutton(button_gl, 'push', ...
    'Text', 'Plot Buffer Outflows', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotBufferOutflows(boutflow_vars, bufferOUTF, src.Parent.Children(8).Value, ...
    fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_buffer_outflows.Layout.Column = 2;
btn_buffer_outflows.Layout.Row = 4;

btn_buffer_outflows = uibutton(button_gl, 'push', ...
    'Text', 'Plot overflow + harvested', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotHarvestOutOverflow(boverflow_vars, bufferOF, ... 
hmeta_vars, harvMeta, rain_data, src.Parent.Children(8).Value, ...
fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_buffer_outflows.Layout.Column = 2;
btn_buffer_outflows.Layout.Row = 5;


%% Harvester and rain Plotting
dropdown_items_harvester = [{'All Harvesters'}, arrayfun(@(x) sprintf('Harvester %d', x), 1:length(hmeta_vars), 'UniformOutput', false)];
harvester_dropdown = uidropdown(button_gl, ...
    'Items', dropdown_items_harvester, ...
    'Value', 'All Harvesters', ... 
    'Tooltip', 'Select All or a single harvester to view output');
harvester_dropdown.Layout.Column = 3;
harvester_dropdown.Layout.Row = 1;

btn_harv_outflows = uibutton(button_gl, 'push', ...
    'Text', 'Plot Harvester Outflows', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotHarvesterOutput(hmeta_vars, harvMeta, rain_data, ...
    src.Parent.Children(13).Value, fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_harv_outflows.Layout.Column = 3;
btn_harv_outflows.Layout.Row = 2;

btn_harv_cumu_outflows = uibutton(button_gl, 'push', ...
    'Text', 'Plot Harvester cumulative Outflows', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotHarvesterCumulativeOutput(hmeta_vars, harvMeta, rain_data, ...
    src.Parent.Children(13).Value, fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_harv_cumu_outflows.Layout.Column = 3;
btn_harv_cumu_outflows.Layout.Row = 3;

btn_rainplot = uibutton(button_gl, 'push', ...
    'Text', 'Plot Rainfall', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event) plotRawRain(rain_data, ...
    fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_rainplot.Layout.Column = 3;
btn_rainplot.Layout.Row = 4;

btn_rainplot_cumu = uibutton(button_gl, 'push', ...
    'Text', 'Plot cumulative Rainfall', ...
    'FontSize', 10, ...
    'ButtonPushedFcn', @(src, event)plotAccumulatedRawRain(rain_data, ...
    fig.UserData.timescale_map(fig.UserData.timescale_dropdown.Value), startDate, fig)); 
btn_rainplot_cumu.Layout.Column = 3;
btn_rainplot_cumu.Layout.Row = 5;

%% Timescale selection UI
timescale_panel = uipanel(gl_figure, 'Scrollable', 'on', ...
    'Title', 'Plot Settings', ...
    'BackgroundColor', [0.95 0.95 0.95]);
timescale_panel.Layout.Row = 1;
timescale_panel.Layout.Column = 2;

gl_timescale = uigridlayout(timescale_panel, [7, 1], ... 
    'RowHeight', {'fit', 'fit', 'fit','fit', 'fit','fit', 'fit'}, ...
    'Padding', [10 10 10 10], ... 
    'RowSpacing', 5);
gl_timescale.Scrollable = "on";

uilabel(gl_timescale, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'Text', 'Timescale');
timescale_dropdown = uidropdown(gl_timescale, ...
    'Items', {'Hours', 'Days', 'Date-based', 'Date range'}, ...
    'Value', 'Date-based', ... % Default to match previous timescale=3
    'Tooltip', 'Select timescale for plots');
timescale_dropdown.Layout.Row = 2;
timescale_dropdown.Layout.Column = 1;
fig.UserData.timescale_dropdown = timescale_dropdown;
fig.UserData.timescale_map = containers.Map({'Hours', 'Days', 'Date-based', 'Date range'}, {1, 2, 3, 4});

uilabel(gl_timescale, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'Text', 'Plot Date Range');
date_start_picker = uidatepicker(gl_timescale, ...
    'Value', startDate, ... % Default to simulation start
    'Tooltip', 'Select start date for plots');
date_start_picker.Layout.Row = 4;
date_start_picker.Layout.Column = 1;
date_end_picker = uidatepicker(gl_timescale, ...
    'Value', startDate + hours(8760), ... % Default to simulation end (1 year)
    'Tooltip', 'Select end date for plots');
date_end_picker.Layout.Row = 5;
date_end_picker.Layout.Column = 1;

% Store date picker handles in fig.UserData
fig.UserData.date_start_picker = date_start_picker;
fig.UserData.date_end_picker = date_end_picker;

%% storage plotting related function

function plotStorageLevels(slog_vars, storageLevel, selectedValue, timescale, dataStartDate, fig) 
    if ~isequal(storageLevel, -1)
        if strcmp(selectedValue, 'All storages')
            indices = 1:length(slog_vars);
            figName = 'Storage Level Plots';
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            indices = selectedIndex;
            figName = sprintf('Storage Level for Storage %d', selectedIndex);
        end
        figure('Name', figName, 'NumberTitle', 'off');
        hold on;
        for i = indices
            ts = storageLevel{i};
            shortName = replace(slog_vars{i}, 'Slogdata', '');
            if timescale == 4 % Date-range
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = ts.Time >= tStartHours & ts.Time <= tEndHours;
                filtered_ts = timeseries(ts.Data(mask), ts.Time(mask));
                if isempty(filtered_ts.Data)
                    warning('No data for %s in the selected date range.', shortName);
                    continue;
                end
                timeDates = dataStartDate + hours(filtered_ts.Time);
                plot(timeDates, filtered_ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            elseif timescale == 1 % Hours
                plot(ts.Time, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (hours)');
            elseif timescale == 2 % Days
                plot(ts.Time/24, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (days)');
            else % Date-based
                timeDates = dataStartDate + hours(ts.Time);
                plot(timeDates, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            end
        end
        ylabel('Storage Level [0-1]');
        title('Storage Levels Over Time');
        grid on;
        legend('show', 'Location', 'best');
        hold off;
        disp(['Plotted storage level timeseries for ' selectedValue '.']);
    else
        disp('No storage level timeseries (Slevel) found.');
    end
end

function plotStorageOutflowMain(slogdata_vars, storageOutflowMain, selectedValue, timescale, dataStartDate, fig)
    if ~isequal(storageOutflowMain, -1)
        if strcmp(selectedValue, 'All storages')
            indices = 1:length(slogdata_vars);
            figName = 'Storage Outflow Main Plots';
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            indices = selectedIndex;
            figName = sprintf('Main Outflow for Storage %d', selectedIndex);
        end
        figure('Name', figName, 'NumberTitle', 'off');
        hold on;
        for i = indices
            ts = storageOutflowMain{i};
            shortName = replace(slogdata_vars{i}, 'Slogdata', '');
            if timescale == 4 % Date-range
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = ts.Time >= tStartHours & ts.Time <= tEndHours;
                filtered_ts = timeseries(ts.Data(mask), ts.Time(mask));
                if isempty(filtered_ts.Data)
                    warning('No data for %s in the selected date range.', shortName);
                    continue;
                end
                timeDates = dataStartDate + hours(filtered_ts.Time);
                plot(timeDates, filtered_ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            elseif timescale == 1 % Hours
                plot(ts.Time, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (hours)');
            elseif timescale == 2 % Days
                plot(ts.Time/24, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (days)');
            else % Date-based
                timeDates = dataStartDate + hours(ts.Time);
                plot(timeDates, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            end
        end
        ylabel('Outflow Main (m^3/h)');
        title('Storage Outflow Main Over Time');
        grid on;
        legend('show', 'Location', 'best');
        hold off;
        disp(['Plotted main outflow timeseries for ' selectedValue '.']);
    else
        disp('No outflow main timeseries (Slogdata) found.');
    end
end

function plotStorageDemandMain(slogdata_vars, storageDemandMain, selectedValue, timescale, dataStartDate, fig)
    if ~isequal(storageDemandMain, -1)
        if strcmp(selectedValue, 'All storages')
            indices = 1:length(slogdata_vars);
            figName = 'Storage Demand Main Plots';
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            indices = selectedIndex;
            figName = sprintf('Demand Main for Storage %d', selectedIndex);
        end
        figure('Name', figName, 'NumberTitle', 'off');
        hold on;
        for i = indices
            ts = storageDemandMain{i};
            shortName = replace(slogdata_vars{i}, 'Slogdata', ' Demand');
            if timescale == 4 % Date-range
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = ts.Time >= tStartHours & ts.Time <= tEndHours;
                filtered_ts = timeseries(ts.Data(mask), ts.Time(mask));
                if isempty(filtered_ts.Data)
                    warning('No data for %s in the selected date range.', shortName);
                    continue;
                end
                timeDates = dataStartDate + hours(filtered_ts.Time);
                plot(timeDates, filtered_ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            elseif timescale == 1 % Hours
                plot(ts.Time, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (hours)');
            elseif timescale == 2 % Days
                plot(ts.Time/24, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (days)');
            else % Date-based
                timeDates = dataStartDate + hours(ts.Time);
                plot(timeDates, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            end
        end
        ylabel('Demand Main (m^3/h)');
        title('Storage Demand Main Over Time');
        grid on;
        legend('show', 'Location', 'best');
        hold off;
        disp(['Plotted demand main timeseries for ' selectedValue '.']);
    else
        disp('No demand main timeseries (Slogdata) found.');
    end
end

function plotStorageDeficit(slogdata_vars, storageDemandMain, storageOutflowMain, selectedValue, timescale, dataStartDate, fig)
    if ~isequal(storageDemandMain, -1) && ~isequal(storageOutflowMain, -1)
        if strcmp(selectedValue, 'All storages')
            indices = 1:length(slogdata_vars);
            figName = 'Storage Deficit Plots';
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            if selectedIndex < 1 || selectedIndex > length(slogdata_vars)
                disp(['Invalid storage index: ' num2str(selectedIndex) '. Must be between 1 and ' num2str(length(slogdata_vars)) '.']);
                return;
            end
            indices = selectedIndex;
            figName = sprintf('Deficit for Storage %d', selectedIndex);
        end
        figure('Name', figName, 'NumberTitle', 'off');
        hold on;
        for i = indices
            ts_demand = storageDemandMain{i};
            ts_outflow = storageOutflowMain{i};
            deficit_data = ts_demand.Data - ts_outflow.Data;
            shortName = replace(slogdata_vars{i}, 'Slogdata', '');
            if timescale == 4 % Date-range
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = ts_demand.Time >= tStartHours & ts_demand.Time <= tEndHours;
                filtered_deficit = deficit_data(mask);
                filtered_time = ts_demand.Time(mask);
                if isempty(filtered_deficit)
                    warning('No data for %s in the selected date range.', shortName);
                    continue;
                end
                timeDates = dataStartDate + hours(filtered_time);
                plot(timeDates, filtered_deficit, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            elseif timescale == 1 % Hours
                plot(ts_demand.Time, deficit_data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (hours)');
            elseif timescale == 2 % Days
                plot(ts_demand.Time/24, deficit_data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (days)');
            else % Date-based
                timeDates = dataStartDate + hours(ts_demand.Time);
                plot(timeDates, deficit_data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            end
        end
        ylabel('Deficit (Demand - Outflow) (m^3/h)');
        title('Storage Deficit Over Time');
        grid on;
        legend('show', 'Location', 'best');
        hold off;
        disp(['Plotted deficit timeseries for ' selectedValue '.']);
    else
        disp('No demand_main or outflow_main timeseries (Slogdata) found.');
    end
end

function plotStorageInterconnectFlow(slogdata_vars, storageOutNetSic1, storageOutNetSic2, storageMeta, selectedValue, timescale, dataStartDate, fig)
    if ~isequal(storageOutNetSic1, -1)
        if strcmp(selectedValue, 'All storages')
            indices = 1:length(slogdata_vars);
            figName = 'Storage Interconnect Net Outflow Plots';
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            indices = selectedIndex;
            figName = sprintf('Interconnect Net Outflow for Storage %d', selectedIndex);
        end
        figure('Name', figName, 'NumberTitle', 'off');
        hold on;
        for i = indices
            interconnect_count = storageMeta(i, 3);
            shortName = replace(slogdata_vars{i}, 'Slogdata', '');
            if interconnect_count >= 1 && ~isequal(storageOutNetSic1{i}, -1)
                ts_sic1 = storageOutNetSic1{i};
                if timescale == 4 % Date-range
                    dateStart = fig.UserData.date_start_picker.Value;
                    dateEnd = fig.UserData.date_end_picker.Value;
                    tStartHours = hours(dateStart - dataStartDate);
                    tEndHours = hours(dateEnd - dataStartDate);
                    if tStartHours < 0, tStartHours = 0; end
                    if tEndHours > 8760, tEndHours = 8760; end
                    if tEndHours < tStartHours, tEndHours = tStartHours; end
                    mask = ts_sic1.Time >= tStartHours & ts_sic1.Time <= tEndHours;
                    filtered_ts = timeseries(ts_sic1.Data(mask), ts_sic1.Time(mask));
                    if isempty(filtered_ts.Data)
                        warning('No IC1 data for %s in the selected date range.', shortName);
                        continue;
                    end
                    timeDates = dataStartDate + hours(filtered_ts.Time);
                    plot(timeDates, filtered_ts.Data, 'LineWidth', 1.5, 'DisplayName', sprintf('%s IC1', shortName));
                    xlabel('Date');
                elseif timescale == 1 % Hours
                    plot(ts_sic1.Time, ts_sic1.Data, 'LineWidth', 1.5, 'DisplayName', sprintf('%s IC1', shortName));
                    xlabel('Time (hours)');
                elseif timescale == 2 % Days
                    plot(ts_sic1.Time/24, ts_sic1.Data, 'LineWidth', 1.5, 'DisplayName', sprintf('%s IC1', shortName));
                    xlabel('Time (days)');
                else % Date-based
                    timeDates = dataStartDate + hours(ts_sic1.Time);
                    plot(timeDates, ts_sic1.Data, 'LineWidth', 1.5, 'DisplayName', sprintf('%s IC1', shortName));
                    xlabel('Date');
                end
            end
            if interconnect_count == 2 && ~isequal(storageOutNetSic2{i}, -1)
                ts_sic2 = storageOutNetSic2{i};
                if timescale == 4 % Date-range
                    dateStart = fig.UserData.date_start_picker.Value;
                    dateEnd = fig.UserData.date_end_picker.Value;
                    tStartHours = hours(dateStart - dataStartDate);
                    tEndHours = hours(dateEnd - dataStartDate);
                    if tStartHours < 0, tStartHours = 0; end
                    if tEndHours > 8760, tEndHours = 8760; end
                    if tEndHours < tStartHours, tEndHours = tStartHours; end
                    mask = ts_sic2.Time >= tStartHours & ts_sic2 <= tEndHours;
                    filtered_ts = timeseries(ts_sic2.Data(mask), ts_sic2.Time(mask));
                    if isempty(filtered_ts.Data)
                        warning('No IC2 data for %s in the selected date range.', shortName);
                        continue;
                    end
                    timeDates = dataStartDate + hours(filtered_ts.Time);
                    plot(timeDates, filtered_ts.Data, 'LineWidth', 1.5, 'DisplayName', sprintf('%s IC2', shortName));
                    xlabel('Date');
                elseif timescale == 1 % Hours
                    plot(ts_sic2.Time, ts_sic2.Data, 'LineWidth', 1.5, 'DisplayName', sprintf('%s IC2', shortName));
                    xlabel('Time (hours)');
                elseif timescale == 2 % Days
                    plot(ts_sic2.Time/24, ts_sic2.Data, 'LineWidth', 1.5, 'DisplayName', sprintf('%s IC2', shortName));
                    xlabel('Time (days)');
                else % Date-based
                    timeDates = dataStartDate + hours(ts_sic2.Time);
                    plot(timeDates, ts_sic2.Data, 'LineWidth', 1.5, 'DisplayName', sprintf('%s IC2', shortName));
                    xlabel('Date');
                end
            end
        end
        ylabel('Net Outflow (m^3/h)');
        title('Storage Interconnect Net Outflows Over Time');
        grid on;
        legend('show', 'Location', 'best');
        hold off;
        disp(['Plotted interconnect net outflow timeseries for ' selectedValue '.']);
    else
        disp('No interconnect net outflow timeseries (out_net_sic1 or out_net_sic2) found.');
    end
end

function plotStorageDeficitWDelivered(slogdata_vars, storageDemandMain, storageOutflowMain, selectedValue, timescale, dataStartDate, fig)
    if ~isequal(storageDemandMain, -1) && ~isequal(storageOutflowMain, -1)
        if strcmp(selectedValue, 'All storages')
            ts_demand_first = storageDemandMain{1};
            time_data = ts_demand_first.Time;
            
            total_outflow = zeros(size(time_data));
            total_deficit = zeros(size(time_data));
            
            for i = 1:length(slogdata_vars)
                ts_demand = storageDemandMain{i};
                ts_outflow = storageOutflowMain{i};
                deficit_data = max(0, ts_demand.Data - ts_outflow.Data);
                total_outflow = total_outflow + ts_outflow.Data;
                total_deficit = total_deficit + deficit_data;
            end
            
            if timescale == 4
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = time_data >= tStartHours & time_data <= tEndHours;
                time_data = time_data(mask);
                total_outflow = total_outflow(mask);
                total_deficit = total_deficit(mask);
                if isempty(time_data)
                    warning('No data in the selected date range for All storages.');
                    return;
                end
            end
            
            figure('Name', 'Total Outflow and Deficit for All Storages', 'NumberTitle', 'off');
            bar_data = [total_outflow, total_deficit];
            if timescale == 1
                h = bar(time_data, bar_data, 'stacked');
                xlabel('Time (hours)');
            elseif timescale == 2
                h = bar(time_data/24, bar_data, 'stacked');
                xlabel('Time (days)');
            else
                timeDates = dataStartDate + hours(time_data);
                h = bar(timeDates, bar_data, 'stacked');
                xlabel('Date');
            end
            ylabel('Demand Components (m³/h)');
            title('Total Outflow and Deficit for All Storages');
            legend(h, {'Total Outflow', 'Total Deficit'}, 'Location', 'best');
            grid on;
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            ts_demand = storageDemandMain{selectedIndex};
            ts_outflow = storageOutflowMain{selectedIndex};
            deficit_data = max(0, ts_demand.Data - ts_outflow.Data);
            shortName = replace(slogdata_vars{selectedIndex}, 'Slogdata', '');
            time_data = ts_demand.Time;
            outflow = ts_outflow.Data;
            deficit = deficit_data;
            
            if timescale == 4
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = time_data >= tStartHours & time_data <= tEndHours;
                time_data = time_data(mask);
                outflow = outflow(mask);
                deficit = deficit(mask);
                if isempty(time_data)
                    warning('No data for Storage %s in the selected date range.', shortName);
                    return;
                end
            end
            
            figure('Name', sprintf('Outflow and Deficit for Storage %s', shortName), 'NumberTitle', 'off');
            bar_data = [outflow, deficit];
            if timescale == 1
                h = bar(time_data, bar_data, 'stacked');
                xlabel('Time (hours)');
            elseif timescale == 2
                h = bar(time_data/24, bar_data, 'stacked');
                xlabel('Time (days)');
            else
                timeDates = dataStartDate + hours(time_data);
                h = bar(timeDates, bar_data, 'stacked');
                xlabel('Date');
            end
            ylabel('Demand Components (m³/h)');
            title(sprintf('Outflow and Deficit for Storage %s', shortName));
            legend(h, {'Outflow', 'Deficit'}, 'Location', 'best');
            grid on;
        end
        disp(['Plotted hourly outflow and deficit bar charts for ' selectedValue '.']);
    else
        disp('No demand_main or outflow_main timeseries (Slogdata) found.');
    end
end

%% buffer plotting related functions
function plotBufferLevels(blevel_vars, bufferLevel, selectedValue, timescale, dataStartDate, fig)
    if ~isequal(bufferLevel, -1)
        if strcmp(selectedValue, 'All buffers')
            indices = 1:length(blevel_vars);
            figName = 'Buffer Level Plots';
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            indices = selectedIndex;
            figName = sprintf('Buffer Level for Buffer %d', selectedIndex);
        end
        figure('Name', figName, 'NumberTitle', 'off');
        hold on;
        for i = indices
            ts = bufferLevel{i};
            shortName = replace(blevel_vars{i}, 'Blevel', '');
            if timescale == 4 % Date-range
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = ts.Time >= tStartHours & ts.Time <= tEndHours;
                filtered_ts = timeseries(ts.Data(mask), ts.Time(mask));
                if isempty(filtered_ts.Data)
                    warning('No data for %s in the selected date range.', shortName);
                    continue;
                end
                timeDates = dataStartDate + hours(filtered_ts.Time);
                plot(timeDates, filtered_ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            elseif timescale == 1 % Hours
                plot(ts.Time, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (hours)');
            elseif timescale == 2 % Days
                plot(ts.Time/24, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (days)');
            else % Date-based
                timeDates = dataStartDate + hours(ts.Time);
                plot(timeDates, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            end
        end
        ylabel('Buffer Level [0-1]');
        title('Buffer Levels Over Time');
        grid on;
        legend('show', 'Location', 'best');
        hold off;
        disp(['Plotted buffer level timeseries for ' selectedValue '.']);
    else
        disp('No buffer level timeseries (Blevel) found.');
    end
end

function plotBufferOverflows(boverflow_vars, bufferOF, selectedValue, timescale, dataStartDate, fig)
    if ~isequal(bufferOF, -1)
        if strcmp(selectedValue, 'All buffers')
            indices = 1:length(boverflow_vars);
            figName = 'Buffer Overflow Plots';
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            indices = selectedIndex;
            figName = sprintf('Buffer Overflow for Buffer %d', selectedIndex);
        end
        figure('Name', figName, 'NumberTitle', 'off');
        hold on;
        for i = indices
            ts = bufferOF{i};
            shortName = replace(boverflow_vars{i}, 'Boverflow', '');
            if timescale == 4 % Date-range
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = ts.Time >= tStartHours & ts.Time <= tEndHours;
                filtered_ts = timeseries(ts.Data(mask), ts.Time(mask));
                if isempty(filtered_ts.Data)
                    warning('No data for %s in the selected date range.', shortName);
                    continue;
                end
                timeDates = dataStartDate + hours(filtered_ts.Time);
                plot(timeDates, filtered_ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            elseif timescale == 1 % Hours
                plot(ts.Time, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (hours)');
            elseif timescale == 2 % Days
                plot(ts.Time/24, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (days)');
            else % Date-based
                timeDates = dataStartDate + hours(ts.Time);
                plot(timeDates, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            end
        end
        ylabel('Buffer Overflow m^3/h');
        title('Buffer Overflows Over Time');
        grid on;
        legend('show', 'Location', 'best');
        hold off;
        disp(['Plotted buffer overflow timeseries for ' selectedValue '.']);
    else
        disp('No buffer overflow timeseries (Boverflow) found.');
    end
end

function plotBufferOutflows(boutflow_vars, bufferOUTF, selectedValue, timescale, dataStartDate, fig)
    if ~isequal(bufferOUTF, -1)
        if strcmp(selectedValue, 'All buffers')
            indices = 1:length(boutflow_vars);
            figName = 'Buffer Outflow Plots';
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            indices = selectedIndex;
            figName = sprintf('Buffer Outflow for Buffer %d', selectedIndex);
        end
        figure('Name', figName, 'NumberTitle', 'off');
        hold on;
        for i = indices
            ts = bufferOUTF{i};
            shortName = replace(boutflow_vars{i}, 'Boutflow', '');
            if timescale == 4 % Date-range
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = ts.Time >= tStartHours & ts.Time <= tEndHours;
                filtered_ts = timeseries(ts.Data(mask), ts.Time(mask));
                if isempty(filtered_ts.Data)
                    warning('No data for %s in the selected date range.', shortName);
                    continue;
                end
                timeDates = dataStartDate + hours(filtered_ts.Time);
                plot(timeDates, filtered_ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            elseif timescale == 1 % Hours
                plot(ts.Time, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (hours)');
            elseif timescale == 2 % Days
                plot(ts.Time/24, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Time (days)');
            else % Date-based
                timeDates = dataStartDate + hours(ts.Time);
                plot(timeDates, ts.Data, 'LineWidth', 1.5, 'DisplayName', shortName);
                xlabel('Date');
            end
        end
        ylabel('Buffer Outflow m^3/h');
        title('Buffer Outflows Over Time');
        grid on;
        legend('show', 'Location', 'best');
        hold off;
        disp(['Plotted buffer outflow timeseries for ' selectedValue '.']);
    else
        disp('No buffer outflow timeseries (Boutflow) found.');
    end
end

function plotHarvestOutOverflow(boverflow_vars, bufferOF, hmeta_vars, harvMeta, rain_data, selectedValue, timescale, dataStartDate, fig)
    if ~isequal(boverflow_vars, -1) && ~isequal(hmeta_vars, -1)
        
        ts_OF_first = bufferOF{1};
        time_data = ts_OF_first.Time;
        
        rain_time = rain_data(:,1); 
        rain_values = rain_data(:,2);  
        
        rain_values_interp = interp1(rain_time, rain_values, time_data, 'previous');
        
        for i = 1:length(hmeta_vars)
            Area = harvMeta(i,2); 
            GW = harvMeta(i,3);   
            Houtflow{i} = rain_values_interp .* (Area/1000) + GW;  
        end
    
        if strcmp(selectedValue, 'All buffers')
            total_outflow = zeros(size(time_data));
            total_overflow = zeros(size(time_data));
            
            for i = 1:length(boverflow_vars)
                ts_overflow = bufferOF{i};
                ts_outflow = Houtflow{i}; 
                total_outflow = total_outflow + ts_outflow;
                total_overflow = total_overflow + ts_overflow.Data;
            end
            
            if timescale == 4
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = time_data >= tStartHours & time_data <= tEndHours;
                time_data = time_data(mask);
                total_outflow = total_outflow(mask);
                total_overflow = total_overflow(mask);
                if isempty(time_data)
                    warning('No data in the selected date range for All buffers.');
                    return;
                end
            end
            
            figure('Name', 'Total Harvester Outflow and Buffer Overflow for All Buffers', 'NumberTitle', 'off');
            bar_data = [total_outflow, total_overflow];
            if timescale == 1
                h = bar(time_data, bar_data, 'stacked');
                xlabel('Time (hours)');
            elseif timescale == 2
                h = bar(time_data/24, bar_data, 'stacked');
                xlabel('Time (days)');
            else
                timeDates = dataStartDate + hours(time_data);
                h = bar(timeDates, bar_data, 'stacked');
                xlabel('Date');
            end
            ylabel('Flow Components (m³/h)');
            title('Total Harvester Outflow and Buffer Overflow for All Buffers');
            legend(h, {'Total Outflow', 'Total Overflow'}, 'Location', 'best');
            grid on;
        else
            selectedIndex = str2double(regexp(selectedValue, '\d+', 'match', 'once'));
            ts_overflow = bufferOF{selectedIndex};
            outflow_data = Houtflow{selectedIndex};  
            overflow_data = ts_overflow.Data;
            time_data = ts_overflow.Time;
            
            if timescale == 4
                dateStart = fig.UserData.date_start_picker.Value;
                dateEnd = fig.UserData.date_end_picker.Value;
                tStartHours = hours(dateStart - dataStartDate);
                tEndHours = hours(dateEnd - dataStartDate);
                if tStartHours < 0, tStartHours = 0; end
                if tEndHours > 8760, tEndHours = 8760; end
                if tEndHours < tStartHours, tEndHours = tStartHours; end
                mask = time_data >= tStartHours & time_data <= tEndHours;
                time_data = time_data(mask);
                outflow_data = outflow_data(mask);
                overflow_data = overflow_data(mask);
                if isempty(time_data)
                    warning('No data for %s in the selected date range.', selectedValue);
                    return;
                end
            end
            
            figure('Name', sprintf('Havester Outflow and Buffer Overflow for %s', selectedValue), 'NumberTitle', 'off');
            bar_data = [outflow_data, overflow_data];
            if timescale == 1
                h = bar(time_data, bar_data, 'stacked');
                xlabel('Time (hours)');
            elseif timescale == 2
                h = bar(time_data/24, bar_data, 'stacked');
                xlabel('Time (days)');
            else
                timeDates = dataStartDate + hours(time_data);
                h = bar(timeDates, bar_data, 'stacked');
                xlabel('Date');
            end
            ylabel('Flow Components (m³/h)');
            title(sprintf('Havester Outflow and Buffer Overflow for %s', selectedValue));
            legend(h, {'Outflow', 'Overflow'}, 'Location', 'best');
            grid on;
        end
        disp(['Plotted hourly outflow and overflow bar charts for ' selectedValue '.']);
    else
        disp('No buffer overflow or harvester metadata found.');
    end
end
%% Harvester/rain plotting functions
function plotHarvesterOutput(hmeta_vars, harvMeta, rain_data, selectedH, timescale, dataStartDate, fig)
    if strcmp(selectedH, 'All Harvesters')
        indices = 1:length(hmeta_vars);
        figName = 'Harvester Outflow Plots';
    else
        selectedIndex = str2double(regexp(selectedH, '\d+', 'match', 'once'));
        indices = selectedIndex;
        figName = sprintf('Harvester Outflow for Harvester %d', selectedIndex);
    end
    figure('Name', figName, 'NumberTitle', 'off');
    hold on;
    for i = indices
        Area = harvMeta(i,2);
        GW = harvMeta(i,3);
        shortName = replace(hmeta_vars{i}, 'Hmeta', '');
        if timescale == 4 % Date-range
            dateStart = fig.UserData.date_start_picker.Value;
            dateEnd = fig.UserData.date_end_picker.Value;
            tStartHours = hours(dateStart - dataStartDate);
            tEndHours = hours(dateEnd - dataStartDate);
            if tStartHours < 0, tStartHours = 0; end
            if tEndHours > 8760, tEndHours = 8760; end
            if tEndHours < tStartHours, tEndHours = tStartHours; end
            mask = rain_data(:,1) >= tStartHours & rain_data(:,1) <= tEndHours;
            filtered_rain_data = rain_data(mask, :);
            if isempty(filtered_rain_data)
                warning('No data for %s in the selected date range.', shortName);
                continue;
            end
            outflow = filtered_rain_data(:,2).*(Area/1000) + GW;
            timeDates = dataStartDate + hours(filtered_rain_data(:,1));
            plot(timeDates, outflow, 'LineWidth', 1.5, 'DisplayName', shortName);
            xlabel('Date');
        elseif timescale == 1 % Hours
            outflow = rain_data(:,2).*(Area/1000) + GW;
            plot(rain_data(:,1), outflow, 'LineWidth', 1.5, 'DisplayName', shortName);
            xlabel('Time (hours)');
        elseif timescale == 2 % Days
            outflow = rain_data(:,2).*(Area/1000) + GW;
            plot(rain_data(:,1)/24, outflow, 'LineWidth', 1.5, 'DisplayName', shortName);
            xlabel('Time (days)');
        else % Date-based
            outflow = rain_data(:,2).*(Area/1000) + GW;
            timeDates = dataStartDate + hours(rain_data(:,1));
            plot(timeDates, outflow, 'LineWidth', 1.5, 'DisplayName', shortName);
            xlabel('Date');
        end
    end
    ylabel('Buffer Outflow m^3/h');
    title('Harvester Outflows Over Time');
    grid on;
    legend('show', 'Location', 'best');
    hold off;
    disp(['Plotted harvester outflow for ' selectedH '.']);
end

function plotHarvesterCumulativeOutput(hmeta_vars, harvMeta, rain_data, selectedH, timescale, dataStartDate, fig)
    if strcmp(selectedH, 'All Harvesters')
        indices = 1:length(hmeta_vars);
        figName = 'Harvester Accumulated Outflow Plots';
    else
        selectedIndex = str2double(regexp(selectedH, '\d+', 'match', 'once'));
        indices = selectedIndex;
        figName = sprintf('Harvester Accumulated Outflow for Harvester %d', selectedIndex);
    end
    figure('Name', figName, 'NumberTitle', 'off');
    hold on;
    for i = indices
        Area = harvMeta(i,2);
        GW = harvMeta(i,3);
        shortName = replace(hmeta_vars{i}, 'Hmeta', '');
        if timescale == 4 % Date-range
            dateStart = fig.UserData.date_start_picker.Value;
            dateEnd = fig.UserData.date_end_picker.Value;
            tStartHours = hours(dateStart - dataStartDate);
            tEndHours = hours(dateEnd - dataStartDate);
            if tStartHours < 0, tStartHours = 0; end
            if tEndHours > 8760, tEndHours = 8760; end
            if tEndHours < tStartHours, tEndHours = tStartHours; end
            mask = rain_data(:,1) >= tStartHours & rain_data(:,1) <= tEndHours;
            filtered_rain_data = rain_data(mask, :);
            if isempty(filtered_rain_data)
                warning('No data for %s in the selected date range.', shortName);
                continue;
            end
            outflow = filtered_rain_data(:,2).*(Area/1000) + GW;
            accumulated_outflow = cumtrapz(filtered_rain_data(:,1), outflow);
            timeDates = dataStartDate + hours(filtered_rain_data(:,1));
            plot(timeDates, accumulated_outflow, 'LineWidth', 1.5, 'DisplayName', shortName);
            xlabel('Date');
        elseif timescale == 1 % Hours
            outflow = rain_data(:,2).*(Area/1000) + GW;
            accumulated_outflow = cumtrapz(rain_data(:,1), outflow);
            plot(rain_data(:,1), accumulated_outflow, 'LineWidth', 1.5, 'DisplayName', shortName);
            xlabel('Time (hours)');
        elseif timescale == 2 % Days
            outflow = rain_data(:,2).*(Area/1000) + GW;
            accumulated_outflow = cumtrapz(rain_data(:,1), outflow);
            plot(rain_data(:,1)/24, accumulated_outflow, 'LineWidth', 1.5, 'DisplayName', shortName);
            xlabel('Time (days)');
        else % Date-based
            outflow = rain_data(:,2).*(Area/1000) + GW;
            accumulated_outflow = cumtrapz(rain_data(:,1), outflow);
            timeDates = dataStartDate + hours(rain_data(:,1));
            plot(timeDates, accumulated_outflow, 'LineWidth', 1.5, 'DisplayName', shortName);
            xlabel('Date');
        end
    end
    ylabel('Accumulated Outflow (m^3)');
    title('Accumulated Harvester Outflows Over Time');
    grid on;
    legend('show', 'Location', 'best');
    hold off;
    disp(['Plotted accumulated harvester outflow for ' selectedH '.']);
end

function plotRawRain(rain_data, timescale, dataStartDate, fig)
    filtered_rain_data = rain_data;
    if timescale == 4 % Date-range
        dateStart = fig.UserData.date_start_picker.Value;
        dateEnd = fig.UserData.date_end_picker.Value;
        tStartHours = hours(dateStart - dataStartDate);
        tEndHours = hours(dateEnd - dataStartDate);
        if tStartHours < 0, tStartHours = 0; end
        if tEndHours > 8760, tEndHours = 8760; end
        if tEndHours < tStartHours, tEndHours = tStartHours; end
        mask = rain_data(:,1) >= tStartHours & rain_data(:,1) <= tEndHours;
        filtered_rain_data = rain_data(mask, :);
        if isempty(filtered_rain_data)
            warning('No rain data within the selected date range. Plotting empty figure.');
        end
    end
    figure('Name', 'Rainfall Plot', 'NumberTitle', 'off');
    hold on;
    if timescale == 1 % Hours
        plot(filtered_rain_data(:,1), filtered_rain_data(:,2), 'LineWidth', 1.5);
        xlabel('Time (hours)');
    elseif timescale == 2 % Days
        plot(filtered_rain_data(:,1)/24, filtered_rain_data(:,2), 'LineWidth', 1.5);
        xlabel('Time (days)');
    else % Date-based or Date-range
        timeDates = dataStartDate + hours(filtered_rain_data(:,1));
        plot(timeDates, filtered_rain_data(:,2), 'LineWidth', 1.5);
        xlabel('Date');
    end
    ylabel('Rainfall (mm)');
    title('Rainfall Over Time');
    grid on;
    hold off;
    if timescale == 4
        disp(['Plotted rainfall for date range ' datestr(dateStart) ' to ' datestr(dateEnd) '.']);
    else
        disp(['Plotted rainfall.']);
    end
end

function plotAccumulatedRawRain(rain_data, timescale, dataStartDate, fig)
    filtered_rain_data = rain_data;
    if timescale == 4 % Date-range
        dateStart = fig.UserData.date_start_picker.Value;
        dateEnd = fig.UserData.date_end_picker.Value;
        tStartHours = hours(dateStart - dataStartDate);
        tEndHours = hours(dateEnd - dataStartDate);
        if tStartHours < 0, tStartHours = 0; end
        if tEndHours > 8760, tEndHours = 8760; end
        if tEndHours < tStartHours, tEndHours = tStartHours; end
        mask = rain_data(:,1) >= tStartHours & rain_data(:,1) <= tEndHours;
        filtered_rain_data = rain_data(mask, :);
        if isempty(filtered_rain_data)
            warning('No rain data within the selected date range. Plotting empty figure.');
        end
    end
    rainaccum = cumtrapz(filtered_rain_data(:,1), filtered_rain_data(:,2));
    figure('Name', 'Accumulated Rainfall Plot', 'NumberTitle', 'off');
    hold on;
    if timescale == 1 % Hours
        plot(filtered_rain_data(:,1), rainaccum, 'LineWidth', 1.5);
        xlabel('Time (hours)');
    elseif timescale == 2 % Days
        plot(filtered_rain_data(:,1)/24, rainaccum, 'LineWidth', 1.5);
        xlabel('Time (days)');
    else % Date-based or Date-range
        timeDates = dataStartDate + hours(filtered_rain_data(:,1));
        plot(timeDates, rainaccum, 'LineWidth', 1.5);
        xlabel('Date');
    end
    ylabel('Accumulated Rainfall (mm)');
    title('Accumulated Rainfall Over Time');
    grid on;
    hold off;
    if timescale == 4
        disp(['Plotted accumulated rainfall for date range ' datestr(dateStart) ' to ' datestr(dateEnd) '.']);
    else
        disp(['Plotted accumulated rainfall.']);
    end
end
%% Text output related functions
function text = getStorageText(smeta_vars, storageMeta)
    text = {};
    if ~isequal(storageMeta, -1)
        for i = 1:length(smeta_vars)
            shortName = replace(smeta_vars{i}, 'Smeta', '');
            text{end+1} = sprintf('%s volume: %.2f m%s', shortName, storageMeta(i, 1), char(179));
            text{end+1} = sprintf('%s initial level: %.2f', shortName, storageMeta(i, 2));
            sic = storageMeta(i,3);
            if sic == 1
                text{end+1} = sprintf('%s interconnected: None', shortName);
            elseif sic == 2
                text{end+1} = sprintf('%s interconnected: 1 interconnection', shortName);
            else 
                text{end+1} = sprintf('%s interconnected: 2 interconnections', shortName);
            end
        end
    else
        text{end+1} = 'No storage metadata variables (Smeta) found.';
    end
    text = strjoin(text, newline);
end

function text = getBufferVolumeText(bmeta_vars, bufferMeta)
    text = {};
    if ~isequal(bufferMeta, -1)
        for i = 1:length(bmeta_vars)
            shortName = replace(bmeta_vars{i}, 'Bmeta', '');
            text{end+1} = sprintf('%s volume: %.2f m%s', shortName, bufferMeta(i, 1), char(179));
        end
    else
        text{end+1} = 'No buffer metadata variables (Bmeta) found.';
    end
    text = strjoin(text, newline);
end

function text = getBufferOverflowText(boverflow_vars, bufferOF)
    text = {};
    if ~isequal(bufferOF, -1)
        totalOverflow = 0;
        for i = 1:length(boverflow_vars)
            ts = bufferOF{i};
            overflow(i) = trapz(ts.Time, ts.Data);
            totalOverflow = totalOverflow + overflow(i);
        end
        text{end+1} = sprintf('Total Overflow: %.2f m%s', totalOverflow, char(179));
        for i = 1:length(boverflow_vars)
            shortName = replace(boverflow_vars{i}, 'Boverflow', '');
            text{end+1} = sprintf('%s: %.2f m%s', shortName, overflow(i), char(179));
        end
    else
        text{end+1} = 'No buffer overflow variables (Boverflow) found.';
    end
    text = strjoin(text, newline);
end

function text = getTransportText(tmeta_vars, transMeta)
    text = {};
    if ~isequal(transMeta, -1)
        for i = 1:length(tmeta_vars)
            shortName = replace(tmeta_vars{i}, 'Tmeta', '');
            switch transMeta(i,4)
                case 1
                    Ttype = "Pipeline";
                case 2 
                    Ttype = "Channel";
                case 3
                    Ttype = "Custom";
            end
            text{end+1} = sprintf('%s Max flow 1: %.2f m%s/h', shortName, transMeta(i, 1), char(179));
            if transMeta(i,3) == 2
                text{end+1} = sprintf('%s Max flow 2: %.2f m%s/h', shortName, transMeta(i, 2), char(179));
                text{end+1} = sprintf('%s Transport direction: Bidirectional', shortName);
            else
                text{end+1} = sprintf('%s Transport direction: Unidirectional', shortName);
            end
            text{end+1} = sprintf('%s Transport type: %s', shortName, Ttype);
            if i < length(tmeta_vars)
                text{end+1} = sprintf(' ');
            end
        end
    else
        text{end+1} = 'No transport metadata variables (Tmeta) found.';
        text{end+1} = sprintf(' ');
    end
    text = strjoin(text, newline);
end

function text = getFilterText(fmeta_vars, FilterMeta)
    text = {};
    if ~isequal(FilterMeta, -1)
        for i = 1:length(fmeta_vars)
            shortName = replace(fmeta_vars{i}, 'Fmeta', '');
            text{end+1} = sprintf('%s Max flow 1: %.2f m%s/h', shortName, FilterMeta{i, 1}, char(179));
            text{end+1} = sprintf('%s Filter type: %s', shortName, FilterMeta{i, 2});
            text{end+1} = sprintf('%s Parallel filters: %.2f', shortName, FilterMeta{i, 3});
            if i < length(fmeta_vars)
                text{end+1} = sprintf(' ');
            end
        end
    else
        text{end+1} = 'No filter metadata variables (Fmeta) found.';
        text{end+1} = sprintf(' ');
    end
    text{end+1} = sprintf(' ');
    text = strjoin(text, newline);
end

function text = getDeficit(slogdata_vars, storageDemandMain, storageOutflowMain)
    text = {};
    if ~isequal(storageDemandMain, -1) || ~isequal(storageOutflowMain, -1)
        for i = 1:length(slogdata_vars)
            ts_demand = storageDemandMain{i};
            ts_outflow = storageOutflowMain{i};
            deficit_data = ts_demand.Data - ts_outflow.Data;
            total_deficit = trapz(ts_demand.Time, deficit_data);
            total_demand = trapz(ts_demand.Time, ts_demand.Data);
            shortName = replace(slogdata_vars{i}, 'Slogdata', '');
            text{end+1} = sprintf('Total Demand %s: %.2f m%s', shortName, total_demand, char(179));
            text{end+1} = sprintf('Total Deficit %s: %.2f m%s', shortName, total_deficit, char(179));
        end
        text{end+1} = '';
    end
    text = strjoin(text, newline);
end

function text = getHarvText(hmeta_vars, harvMeta, rain_data)
    text = {};
    if ~isequal(harvMeta, -1)
        for i = 1:length(hmeta_vars)
            shortName = replace(hmeta_vars{i}, 'Hmeta', '');
            switch harvMeta(i,1)
                case 1
                    Htype = "Dependent on Groundwater";
                case 0 
                    Htype = "Independent off Groundwater";
            end
            text{end+1} = sprintf('%s Area: %.2f m%s', shortName, harvMeta(i, 2), char(178));
            text{end+1} = sprintf('%s %s', shortName, Htype);
            if harvMeta(i,1) == 1
                text{end+1} = sprintf('%s Groundwater flow: %.2f m%s/h', shortName, harvMeta(i,3), char(178));
            end
            Area = harvMeta(i,2); 
            GW = harvMeta(i,3);   
            outflow = rain_data(:,2).*(Area/1000) + GW;
            totall_outflow = trapz(rain_data(:,1), outflow);
            text{end+1} = sprintf('%s Totall outflow: %.2f m%s', shortName, totall_outflow, char(179));
            if i < length(hmeta_vars)
                text{end+1} = sprintf(' ');
            end
        end
    else
        text{end+1} = 'No harvester metadata variables (Hmeta) found.';
        text{end+1} = sprintf(' ');
    end
    text = strjoin(text, newline);
end

function text = getAccumulatedRain(rain_data)
    rain_totall = trapz(rain_data(:,1),rain_data(:,2));
    text = {};
    text{end+1} = sprintf('Total rainfall: %.2f mm', rain_totall);
    text{end+1} = '';
    text = strjoin(text, newline);
end


