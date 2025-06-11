function filter_block(block)
    setup(block);
end

function setup(block)
    block.NumInputPorts  = 1;  
    block.NumOutputPorts = 2; 
 
    block.InputPort(1).DatatypeID  = 0;  % double
    block.InputPort(1).Complexity  = 'Real';
    block.InputPort(1).Dimensions  = 1;
    block.InputPort(1).DirectFeedthrough = false;
    
    block.OutputPort(1).DatatypeID  = 0;  % double
    block.OutputPort(1).Complexity  = 'Real';
    block.OutputPort(1).Dimensions  = 1;

    block.OutputPort(2).DatatypeID  = 0;  % double
    block.OutputPort(2).Complexity  = 'Real';
    block.OutputPort(2).Dimensions  = 1;

    block.NumDialogPrms = 4;
    block.DialogPrmsTunable = {'Tunable', 'Tunable','Tunable', 'Tunable'};  


    block.NumContStates = 0; 

    block.SampleTimes = [0 0];
    
    % Register methods
    block.RegBlockMethod('InitializeConditions', @Init);
    block.RegBlockMethod('PostPropagationSetup', @PostPropSetup);
    block.RegBlockMethod('Outputs', @Outputs);
    block.RegBlockMethod('Derivatives', @Derivatives);
    block.RegBlockMethod('Terminate', @Terminate);
end

function PostPropSetup(block)
    block.NumDworks = 3;
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
end

function Derivatives(block)
end

function Init(block)
    option = block.DialogPrm(3).Data;

    if option == 2
        maxV_1F = block.DialogPrm(1).Data;
        block.Dwork(2).Data = 0;
        filtertype = 0;
    else
        filtertype = block.DialogPrm(4).Data;
        switch filtertype
            case 1 %sand UDI 4U4604
                maxV_1F = 90;
            case 2 %multimedia UDI K46042 
                maxV_1F = 18;
            case 3 %cyclone UDI 53080
                maxV_1F = 360;
            case 4 %UV SUV-2206
                maxV_1F = 501;
            case 5 %Reverse osmosis
                maxV_1F = 27;
            case 6 %Cyclone sand UV
                maxV_1F = 90;
            case 7 %cyclone sand
                maxV_1F = 90;
            case 8 %Cyclone multimedia UV
                maxV_1F = 18;
            case 9 %Cyclone multimedia
                maxV_1F = 18;
        end
    end

    Npar = max(1, block.DialogPrm(2).Data);
    maxflow = maxV_1F*Npar;
    block.Dwork(1).Data = maxflow;
    block.Dwork(2).Data = filtertype;
    block.Dwork(3).Data = Npar;
end

function Outputs(block)
    maxflow = block.Dwork(1).Data;
    from_buffer = block.InputPort(1).Data;
    to_storage = min(from_buffer, maxflow);

    block.OutputPort(1).Data = maxflow;
    block.OutputPort(2).Data = to_storage;
end

function Terminate(block)
    block_name = get_param(block.BlockHandle, 'Name');
    block_name = matlab.lang.makeValidName(block_name);
    
    maxflow = block.Dwork(1).Data;
    filtertype_num = block.Dwork(2).Data; 
    Npar = block.Dwork(3).Data;

    switch filtertype_num
        case 0
            filtertype_str = 'Custom';
        case 1
            filtertype_str = 'Sand';
        case 2
            filtertype_str = 'Multimedia';
        case 3
            filtertype_str = 'Cyclone';
        case 4
            filtertype_str = 'UV';
        case 5
            filtertype_str = 'Reverse Osmosis';
        case 6
            filtertype_str = 'Cyclone sand UV';
        case 7
            filtertype_str = 'Cyclone sand';
        case 8
            filtertype_str = 'Cyclone multimedia UV';
        case 9
            filtertype_str = 'Cyclone multimedia';
        otherwise
            filtertype_str = 'Unknown';
    end

    FMetaData = struct('MaxFlow', maxflow, 'FilterType', filtertype_str, 'Npar', Npar);
    assignin('base', [block_name 'Fmeta'], FMetaData);
end