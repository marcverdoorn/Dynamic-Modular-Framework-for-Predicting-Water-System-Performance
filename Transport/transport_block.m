function transport_block(block)
    setup(block);
end

function setup(block)
    flowdirection = block.DialogPrm(2).Data;
    transtype = block.DialogPrm(4).Data;

    if flowdirection == 1 || transtype == 2
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
    else
        block.NumInputPorts  = 2;  
        block.NumOutputPorts = 4;  
    
        block.InputPort(1).DatatypeID  = 0;  % double
        block.InputPort(1).Complexity  = 'Real';
        block.InputPort(1).Dimensions  = 1;
        block.InputPort(1).DirectFeedthrough = false;
        
        block.InputPort(2).DatatypeID  = 0;  % double
        block.InputPort(2).Complexity  = 'Real';
        block.InputPort(2).Dimensions  = 1;
        block.InputPort(2).DirectFeedthrough = false;
        
        block.OutputPort(1).DatatypeID  = 0;  % double
        block.OutputPort(1).Complexity  = 'Real';
        block.OutputPort(1).Dimensions  = 1;
    
        block.OutputPort(2).DatatypeID  = 0;  % double
        block.OutputPort(2).Complexity  = 'Real';
        block.OutputPort(2).Dimensions  = 1;

        block.OutputPort(3).DatatypeID  = 0;  % double
        block.OutputPort(3).Complexity  = 'Real';
        block.OutputPort(3).Dimensions  = 1;
    
        block.OutputPort(4).DatatypeID  = 0;  % double
        block.OutputPort(4).Complexity  = 'Real';
        block.OutputPort(4).Dimensions  = 1;
    end
    
    block.NumDialogPrms = 17;
    block.DialogPrmsTunable = {'Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable','Tunable'};  % Correct syntax

    block.NumContStates = 0;  

    block.SampleTimes = [0 0];
    
    block.RegBlockMethod('InitializeConditions', @Init);
    block.RegBlockMethod('Outputs', @Outputs);
    block.RegBlockMethod('Derivatives', @Derivatives);
    block.RegBlockMethod('Terminate', @Terminate);
end

function Init(block)
end

function Derivatives(block)

end

function Outputs(block)
    maxflow1 = block.DialogPrm(1).Data;
    maxflow2 = block.DialogPrm(13).Data;
    
    flowdirection = block.DialogPrm(2).Data;
    transtype = block.DialogPrm(4).Data;
    
    if flowdirection == 1 || transtype == 2
        inflow1 = block.InputPort(1).Data;

        block.OutputPort(1).Data = inflow1; %outflow 1
        block.OutputPort(2).Data = maxflow1; %maxflow 1
    else
        inflow1 = block.InputPort(1).Data;
        inflow2 = block.InputPort(2).Data;
        block.OutputPort(1).Data = min(inflow1, maxflow1); %outflow 1
        block.OutputPort(2).Data = maxflow1; %maxflow 1
        block.OutputPort(3).Data = min(inflow2, maxflow2); %outflow 2
        block.OutputPort(4).Data = maxflow2; %maxflow 2
    end
end

function Terminate(block)
    block_name = get_param(block.BlockHandle, 'Name');
    block_name = matlab.lang.makeValidName(block_name);
    
    maxflow1 = block.DialogPrm(1).Data;
    maxflow2 = block.DialogPrm(13).Data;    
    flowdirection = block.DialogPrm(2).Data;
    transtype = block.DialogPrm(4).Data;

    TMetaData = [maxflow1, maxflow2, flowdirection, transtype];
    assignin('base', [block_name 'Tmeta'], TMetaData);
end