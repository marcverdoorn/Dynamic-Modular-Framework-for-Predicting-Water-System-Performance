function buffer_block(block)
    setup(block);
end

function setup(block)
    block.NumInputPorts  = 3;  % inflow, consumption, maxflow
    block.NumOutputPorts = 3;  % outflow, storage leve, storage size
    
    block.InputPort(1).DatatypeID  = 0;  % double
    block.InputPort(1).Complexity  = 'Real';
    block.InputPort(1).Dimensions  = 1;
    block.InputPort(1).DirectFeedthrough = false;
    
    block.InputPort(2).DatatypeID  = 0;  % double
    block.InputPort(2).Complexity  = 'Real';
    block.InputPort(2).Dimensions  = 1;
    block.InputPort(2).DirectFeedthrough = false;

    block.InputPort(3).DatatypeID  = 0;  % double
    block.InputPort(3).Complexity  = 'Real';
    block.InputPort(3).Dimensions  = 1;
    block.InputPort(3).DirectFeedthrough = false;
    
    block.OutputPort(1).DatatypeID  = 0;  % double
    block.OutputPort(1).Complexity  = 'Real';
    block.OutputPort(1).Dimensions  = 1;

    block.OutputPort(2).DatatypeID  = 0;  % double
    block.OutputPort(2).Complexity  = 'Real';
    block.OutputPort(2).Dimensions  = 1;

    block.OutputPort(3).DatatypeID  = 0;  % double
    block.OutputPort(3).Complexity  = 'Real';
    block.OutputPort(3).Dimensions  = 1;
    
    block.NumDialogPrms = 1;
    block.DialogPrmsTunable = {'Tunable'};  

    block.NumContStates = 1; 

    block.SampleTimes = [0 0];
    
    block.RegBlockMethod('PostPropagationSetup', @PostPropSetup);
    block.RegBlockMethod('InitializeConditions', @Init);
    block.RegBlockMethod('Outputs', @Outputs);
    block.RegBlockMethod('Derivatives', @Derivatives);
    block.RegBlockMethod('Terminate', @Terminate);
end

function PostPropSetup(block)
    % Configure DWork vectors
    block.NumDworks = 8;
    block.Dwork(1).Name            = 'Vbf';
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;  % double
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = false;
    
    block.Dwork(2).Name            = 'Vbo';
    block.Dwork(2).Dimensions      = 1;
    block.Dwork(2).DatatypeID      = 0;  % double
    block.Dwork(2).Complexity      = 'Real';
    block.Dwork(2).UsedAsDiscState = false;
    
    block.Dwork(3).Name            = 'buffer_level';
    block.Dwork(3).Dimensions      = 1;
    block.Dwork(3).DatatypeID      = 0;  % double
    block.Dwork(3).Complexity      = 'Real';
    block.Dwork(3).UsedAsDiscState = false;

    stop_time_str = get_param(bdroot, 'StopTime');
    stop_time = evalin('base', stop_time_str);
    step_size = str2double(get_param(bdroot, 'FixedStep'));
    minlength = stop_time/step_size;

    block.Dwork(4).Name = 'log_time';
    block.Dwork(4).Dimensions = minlength+10; 
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
    block.Dwork(7).Name = 'log_overflow';
    block.Dwork(7).Dimensions = minlength+10; 
    block.Dwork(7).DatatypeID = 0;
    block.Dwork(7).Complexity = 'Real';
    block.Dwork(8).Name = 'log_outflow';
    block.Dwork(8).Dimensions = minlength+10; 
    block.Dwork(8).DatatypeID = 0;
    block.Dwork(8).Complexity = 'Real';
end

function Init(block)
    block.ContStates.Data = 0;
    block.Dwork(1).Data = 0;  % Vbf
    block.Dwork(2).Data = 0;  % Vbo
    block.Dwork(3).Data = 0;  % buffer_level
    block.Dwork(6).Data = 0;
end

function Derivatives(block)

    buffer_size = block.DialogPrm(1).Data;
    
    inflow = max(0, block.InputPort(1).Data);
    storage_level = block.InputPort(2).Data;
    maxflow = block.InputPort(3).Data;

    buffered_volume = block.ContStates.Data;
    L0 = 0.98; % Threshold where significant effect begins
    k = 200;   % Steepness parameter
    L = storage_level;
    f_L = 1-(1/(1 + exp(-k * (L - L0))));

    Vbf = maxflow*(buffered_volume/buffer_size)*f_L;

    if (buffered_volume/buffer_size) < 0
        Vbo = 0;
    elseif (buffered_volume/buffer_size) >=1 && (inflow - Vbf) > 0
        Vbo = inflow - Vbf;
    else
        Vbo = 0;
    end

    block.Dwork(1).Data = Vbf;          % Store Vbf
    block.Dwork(2).Data = Vbo;          % Store Vbo
    block.Dwork(3).Data = buffered_volume; % Store buffer_level

    dVdt = inflow - Vbf - Vbo;   
    block.Derivatives.Data = dVdt;
end

function Outputs(block)
    buffer_size = block.DialogPrm(1).Data;
    bufferlevel = block.ContStates.Data/buffer_size;
    block.OutputPort(1).Data = block.Dwork(1).Data;  % Vbf
    block.OutputPort(2).Data = block.Dwork(2).Data;  % Vbo
    block.OutputPort(3).Data = bufferlevel;  % buffer_level

    counter = block.Dwork(6).Data + 1;
    if counter <= block.Dwork(4).Dimensions
        block.Dwork(4).Data(counter) = block.CurrentTime;
        block.Dwork(5).Data(counter) = bufferlevel;
        block.Dwork(7).Data(counter) = block.Dwork(2).Data;
        block.Dwork(8).Data(counter) = block.Dwork(1).Data;
        block.Dwork(6).Data = counter;
    end
end

function Terminate(block)
    counter = block.Dwork(6).Data;
    % Get block name for variable naming
    block_name = get_param(block.BlockHandle, 'Name');
    block_name = matlab.lang.makeValidName(block_name);
    if counter > 0
        ts_level = timeseries(block.Dwork(5).Data(1:counter), block.Dwork(4).Data(1:counter));
        ts_overflow = timeseries(block.Dwork(7).Data(1:counter), block.Dwork(4).Data(1:counter));
        ts_outflow = timeseries(block.Dwork(8).Data(1:counter), block.Dwork(4).Data(1:counter));
        assignin('base', [block_name 'Blevel'], ts_level);
        assignin('base', [block_name 'Boverflow'], ts_overflow);
        assignin('base', [block_name 'Boutflow'], ts_outflow);
    end

    buffer_size = block.DialogPrm(1).Data;
    maxflow = block.InputPort(3).Data;
    bufferMetaData = [buffer_size, maxflow];
    assignin('base', [block_name 'Bmeta'], bufferMetaData);
end