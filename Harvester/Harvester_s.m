function Harvester_s(block)

setup(block);

end

function setup(block)

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

block.NumDialogPrms     = 3;

block.SampleTimes = [-1 0];

block.SimStateCompliance = 'DefaultSimState';

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required

end


function DoPostPropSetup(block)
block.NumDworks = 2;
  
  block.Dwork(1).Name            = 'Area';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;

  block.Dwork(2).Name            = 'Inflow_groundwater';
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;      % double
  block.Dwork(2).Complexity      = 'Real'; % real
  block.Dwork(2).UsedAsDiscState = true;
end

function Start(block)

    % Save the area of the Harvester
    block.Dwork(1).Data = block.DialogPrm(3).Data;
    
    % Check if the Harvest gains rain water and save that value
    if block.DialogPrm(1).Data == 0
        block.Dwork(2).Data = 0;
    else
        block.Dwork(2).Data = block.DialogPrm(2).Data;
    end
end


function Outputs(block)
area = block.Dwork(1).Data;
V_groundwater = block.Dwork(2).Data;

block.OutputPort(1).Data = block.InputPort(1).Data * area / 1000 + V_groundwater;
end

function Terminate(block)
    area = block.Dwork(1).Data;
    type = block.DialogPrm(1).Data;
    groundwater = block.Dwork(2).Data;
    HarvesterMetaData = [type, area, groundwater];

    block_name = get_param(block.BlockHandle, 'Name');
    block_name = matlab.lang.makeValidName(block_name);
    assignin('base', [block_name 'Hmeta'], HarvesterMetaData);
end

