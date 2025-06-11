function storage_block(block)
    setup(block);
end

function setup(block)
    block.NumDialogPrms = 3;
    block.DialogPrmsTunable = {'Tunable', 'Tunable', 'Tunable'};  % Correct syntax
    
    
    storage_interconnect = block.DialogPrm(3).Data;

    baseInputs = 3;
    baseOutputs = 3;

    if storage_interconnect == 2
        block.NumInputPorts  = baseInputs + 3;  
        block.NumOutputPorts = baseOutputs + 1; 
    elseif storage_interconnect == 3
        block.NumInputPorts  = baseInputs + 6;  
        block.NumOutputPorts = baseOutputs + 2; 
    else
        block.NumInputPorts  = baseInputs;  
        block.NumOutputPorts = baseOutputs; 
    end
    
    for i = 1:block.NumInputPorts
        block.InputPort(i).DatatypeID  = 0;  % double
        block.InputPort(i).Complexity  = 'Real';
        block.InputPort(i).Dimensions  = 1;
        block.InputPort(i).DirectFeedthrough = false;  
    end 

    for i = 1:block.NumOutputPorts
        block.OutputPort(i).DatatypeID  = 0;  % double
        block.OutputPort(i).Complexity  = 'Real';
        block.OutputPort(i).Dimensions  = 1; 
    end

    % Register continuous state for stored volume
    block.NumContStates = 1;  % Stored volume as a state

    block.SampleTimes = [-1 0];
    
    % Register methods
    block.RegBlockMethod('PostPropagationSetup', @PostPropSetup); 
    block.RegBlockMethod('InitializeConditions', @Init);
    block.RegBlockMethod('Derivatives', @Derivatives);
    block.RegBlockMethod('Outputs', @Outputs);
    block.RegBlockMethod('Terminate', @Terminate);
end



function PostPropSetup(block)
    storage_interconnect = block.DialogPrm(3).Data;

    if storage_interconnect == 1
        block.NumDworks = 8; % For consumption_main, consumptionSIC1, consumptionSIC2
    elseif storage_interconnect == 2
        block.NumDworks = 10;
    else
        block.NumDworks = 12;
    end
    
    block.Dwork(1).Name = 'consumption_main';
    block.Dwork(1).Dimensions = 1;
    block.Dwork(1).DatatypeID = 0; % double
    block.Dwork(1).Complexity = 'Real';
    block.Dwork(2).Name = 'consumptionSIC1';
    block.Dwork(2).Dimensions = 1;
    block.Dwork(2).DatatypeID = 0;
    block.Dwork(2).Complexity = 'Real';
    block.Dwork(3).Name = 'consumptionSIC2';
    block.Dwork(3).Dimensions = 1;
    block.Dwork(3).DatatypeID = 0;
    block.Dwork(3).Complexity = 'Real';

    stop_time_str = get_param(bdroot, 'StopTime');
    stop_time = evalin('base', stop_time_str);
    step_size = str2double(get_param(bdroot, 'FixedStep'));
    minlength = stop_time/step_size;

    block.Dwork(4).Name = 'log_time';
    block.Dwork(4).Dimensions = minlength+10; % Adjust size based on needs
    block.Dwork(4).DatatypeID = 0;
    block.Dwork(4).Complexity = 'Real';
    block.Dwork(5).Name = 'log_level';
    block.Dwork(5).Dimensions = minlength+10; 
    block.Dwork(5).DatatypeID = 0;
    block.Dwork(5).Complexity = 'Real';
    block.Dwork(6).Name = 'log_counter';
    block.Dwork(6).Dimensions = 1;
    block.Dwork(6).DatatypeID = 0;
    block.Dwork(6).Complexity = 'Real';
    block.Dwork(7).Name = 'log_outflow';
    block.Dwork(7).Dimensions = minlength+10; 
    block.Dwork(7).DatatypeID = 0;
    block.Dwork(7).Complexity = 'Real';
    block.Dwork(8).Name = 'log_demand';
    block.Dwork(8).Dimensions = minlength+10; 
    block.Dwork(8).DatatypeID = 0;
    block.Dwork(8).Complexity = 'Real';

    if storage_interconnect == 2
        block.Dwork(9).Name = 'log_SIC1flow';
        block.Dwork(9).Dimensions = minlength+10; 
        block.Dwork(9).DatatypeID = 0;
        block.Dwork(9).Complexity = 'Real';
        block.Dwork(10).Name = 'log_SIC1control';
        block.Dwork(10).Dimensions = minlength+10; 
        block.Dwork(10).DatatypeID = 0;
        block.Dwork(10).Complexity = 'Real';
    elseif storage_interconnect == 3
        block.Dwork(9).Name = 'log_SIC1flow';
        block.Dwork(9).Dimensions = minlength+10; 
        block.Dwork(9).DatatypeID = 0;
        block.Dwork(9).Complexity = 'Real';
        block.Dwork(10).Name = 'log_SIC1control';
        block.Dwork(10).Dimensions = minlength+10; 
        block.Dwork(10).DatatypeID = 0;
        block.Dwork(10).Complexity = 'Real';
        block.Dwork(11).Name = 'log_SIC2flow';
        block.Dwork(11).Dimensions = minlength+10; 
        block.Dwork(11).DatatypeID = 0;
        block.Dwork(11).Complexity = 'Real';
        block.Dwork(12).Name = 'log_SIC2control';
        block.Dwork(12).Dimensions = minlength+10; 
        block.Dwork(12).DatatypeID = 0;
        block.Dwork(12).Complexity = 'Real';
    end

end

function Init(block)
    init_level = block.DialogPrm(2).Data;
    storage_size = block.DialogPrm(1).Data;
    init_volume = init_level * storage_size;
    % Clamp initial volume between 0 and storage_size
    init_volume = max(0, min(storage_size, init_volume));
    block.ContStates.Data = init_volume;

    block.Dwork(1).Data = 0; % consumption_main
    block.Dwork(2).Data = 0; % consumptionSIC1
    block.Dwork(3).Data = 0; % consumptionSIC2

    block.Dwork(6).Data = 0;
    
end

function Derivatives(block)    
    Ts = str2double(get_param(bdroot, 'FixedStep'));
  
    inflow_main         = max(0, block.InputPort(1).Data);
    consumption_request = max(0, block.InputPort(2).Data);
    maxflow             = max(0, block.InputPort(3).Data);

    storage_interconnect = block.DialogPrm(3).Data;

    consumption_main = min(consumption_request, maxflow);
    consumptionSIC1 = 0;
    consumptionSIC2 = 0;
    inflow = inflow_main;

    if storage_interconnect == 2
        consumptionSIC1_request = max(0, block.InputPort(4).Data);
        maxflowSIC1 = max(0, block.InputPort(5).Data);
        consumptionSIC1 = min(consumptionSIC1_request, maxflowSIC1);
        inflowSIC1 = max(0, block.InputPort(6).Data);
        inflow = inflow_main + inflowSIC1;
    elseif storage_interconnect == 3
        consumptionSIC1_request = max(0, block.InputPort(4).Data);
        maxflowSIC1 = max(0, block.InputPort(5).Data);
        consumptionSIC1 = min(consumptionSIC1_request, maxflowSIC1);
        consumptionSIC2_request = max(0, block.InputPort(7).Data);
        maxflowSIC2 = max(0, block.InputPort(8).Data);
        consumptionSIC2 = min(consumptionSIC2_request, maxflowSIC2);
        inflowSIC1 = max(0, block.InputPort(6).Data);
        inflowSIC2 = max(0, block.InputPort(9).Data);
        inflow = inflow_main + inflowSIC1 + inflowSIC2;
    end

    stored_volume = block.ContStates.Data;

    total_consumption = consumption_main + consumptionSIC1 + consumptionSIC2;
    volume_requested = total_consumption * Ts;                          % Volume needed for the time step

    if stored_volume < volume_requested && stored_volume > 0
        available_consumption = stored_volume / Ts; 
        scaling_factor = available_consumption / total_consumption;
        consumption_main = consumption_main * scaling_factor;
        consumptionSIC1 = consumptionSIC1 * scaling_factor;
        consumptionSIC2 = consumptionSIC2 * scaling_factor;      
    end

    if stored_volume <= 0
        consumption_main = 0;
        consumptionSIC1 = 0;
        consumptionSIC2 = 0;
    end
    
    block.Dwork(1).Data = consumption_main;
    block.Dwork(2).Data = consumptionSIC1;
    block.Dwork(3).Data = consumptionSIC2;

    % Compute derivative
    total_consumption = consumption_main + consumptionSIC1 + consumptionSIC2;
    dVdt = inflow - total_consumption;

    % Clamp derivative to prevent negative volume
    if stored_volume <= 0 && dVdt < 0
        dVdt = inflow;  
    end
    
    block.Derivatives.Data = dVdt;

    %% Data logging
    storage_size = block.DialogPrm(1).Data;
    counter = block.Dwork(6).Data + 1;
    if counter <= block.Dwork(4).Dimensions
        block.Dwork(4).Data(counter) = block.CurrentTime;
        block.Dwork(5).Data(counter) = min(1, stored_volume/storage_size);
        block.Dwork(6).Data = counter;
        block.Dwork(7).Data(counter) = consumption_main;
        block.Dwork(8).Data(counter) = consumption_request;                         %main demand
        
        storage_interconnect = block.DialogPrm(3).Data;
        if storage_interconnect == 2
            block.Dwork(9).Data(counter) = consumptionSIC1 - max(0, block.InputPort(6).Data);      %net outflow (- for inflow)
            block.Dwork(10).Data(counter) = consumptionSIC1_request;                            %consumption request from control
        elseif storage_interconnect == 3
            block.Dwork(9).Data(counter) = consumptionSIC1 - max(0, block.InputPort(6).Data);      %net outflow (- for inflow)
            block.Dwork(10).Data(counter) = consumptionSIC1_request;                            %consumption request from control 
            block.Dwork(11).Data(counter) = consumptionSIC2 - max(0, block.InputPort(9).Data);     %net outflow sic2
            block.Dwork(12).Data(counter) = consumptionSIC2_request;                            %sic2 consum req from controller
        end
    end
end

function Outputs(block)
    counter = max(1, block.Dwork(6).Data);
    storage_level = block.Dwork(5).Data(counter);       %storage level, zoals geregistreerd in derivative function
    storage_size = block.DialogPrm(1).Data;             %deze manier verzekerd correct stored volume, voordat de dvdt is toegepast
    stored_volume = storage_level*storage_size;
    storage_size = block.DialogPrm(1).Data;

    stored_volume = max(0, min(storage_size, stored_volume));

    consumption_main = block.Dwork(1).Data;
    consumptionSIC1  = block.Dwork(2).Data;
    consumptionSIC2  = block.Dwork(3).Data;

    % Clamp inputs to non-negative values
   if stored_volume > 0
        outflow_main = consumption_main;
        outflow_SIC1 = consumptionSIC1;
        outflow_SIC2 = consumptionSIC2;
    else
        outflow_main = 0;
        outflow_SIC1 = 0;
        outflow_SIC2 = 0;
    end

    storage_interconnect = block.DialogPrm(3).Data;

    if storage_interconnect >= 2
        block.OutputPort(4).Data = outflow_SIC1;
    end
    if storage_interconnect == 3
        block.OutputPort(5).Data = outflow_SIC2;
    end
    
    storage_level = stored_volume / storage_size;

    block.OutputPort(1).Data = outflow_main;
    block.OutputPort(2).Data = stored_volume;
    block.OutputPort(3).Data = storage_level;
  
end


function Terminate(block)
    counter = block.Dwork(6).Data;
    storage_interconnect = block.DialogPrm(3).Data;

    block_name = get_param(block.BlockHandle, 'Name');
    block_name = matlab.lang.makeValidName(block_name);
    if counter > 0
        if storage_interconnect == 1
            ts_level = timeseries(block.Dwork(5).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_outmain = timeseries(block.Dwork(7).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_maindem = timeseries(block.Dwork(8).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_level.Name = "level";
            ts_outmain.Name = "outflow_main";
            ts_maindem.Name = "demand_main";

            tsc = tscollection({ts_level, ts_outmain, ts_maindem});
        elseif storage_interconnect == 2
            ts_level = timeseries(block.Dwork(5).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_outmain = timeseries(block.Dwork(7).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_maindem = timeseries(block.Dwork(8).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_outsic1 = timeseries(block.Dwork(9).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_consic1 = timeseries(block.Dwork(10).Data(1:counter), block.Dwork(4).Data(1:counter));
            
            ts_level.Name = "level";
            ts_outmain.Name = "outflow_main";
            ts_maindem.Name = "demand_main";
            ts_outsic1.Name = "out_net_sic1";
            ts_consic1.Name = "control_sic1";
            
            tsc = tscollection({ts_level, ts_outmain, ts_maindem, ts_outsic1, ts_consic1});
        else
            ts_level = timeseries(block.Dwork(5).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_outmain = timeseries(block.Dwork(7).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_maindem = timeseries(block.Dwork(8).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_outsic1 = timeseries(block.Dwork(9).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_consic1 = timeseries(block.Dwork(10).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_outsic2 = timeseries(block.Dwork(11).Data(1:counter), block.Dwork(4).Data(1:counter));
            ts_consic2 = timeseries(block.Dwork(12).Data(1:counter), block.Dwork(4).Data(1:counter));
            
            ts_level.Name = "level";
            ts_outmain.Name = "outflow_main";
            ts_maindem.Name = "demand_main";
            ts_outsic1.Name = "out_net_sic1";
            ts_consic1.Name = "control_sic1";
            ts_outsic1.Name = "out_net_sic2";
            ts_consic1.Name = "control_sic2";
            
            tsc = tscollection({ts_level, ts_outmain, ts_maindem, ts_outsic1, ts_consic1, ts_outsic2, ts_consic2});
        end
        assignin('base', [block_name 'Slogdata'], tsc);
    end

    storage_size = block.DialogPrm(1).Data;
    init_level = block.DialogPrm(2).Data;
    storageMetaData = [storage_size, init_level, storage_interconnect];
    assignin('base', [block_name 'Smeta'], storageMetaData);
end


