function Demand_s(block)

setup(block);


function setup(block)
block.NumDialogPrms     = 7;
block.DialogPrmsTunable = {'Tunable', 'Tunable', 'Tunable', 'Tunable', 'Tunable', 'Tunable', 'Tunable'};

% Register number of ports
if block.DialogPrm(1).Data == 1
    block.NumInputPorts  = 1;
elseif block.DialogPrm(1).Data == 2
    block.NumInputPorts  = 3 + 2*block.DialogPrm(6).Data;
end

block.NumOutputPorts = 1 + block.DialogPrm(6).Data;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
for i = 1:block.NumInputPorts
    block.InputPort(i).Dimensions        = 1;
    block.InputPort(i).DatatypeID  = 0;  % double
    block.InputPort(i).Complexity  = 'Real';
    block.InputPort(i).DirectFeedthrough = true;
end

prediction_time = block.DialogPrm(7).Data;

if block.NumInputPorts == 5
    i = 4;
    block.InputPort(i).Dimensions        = prediction_time;
    block.InputPort(i).DatatypeID  = 0;  % double
    block.InputPort(i).Complexity  = 'Real';
    block.InputPort(i).DirectFeedthrough = true;
    
    i = 5;
    block.InputPort(i).Dimensions        = prediction_time;
    block.InputPort(i).DatatypeID  = 0;  % double
    block.InputPort(i).Complexity  = 'Real';
    block.InputPort(i).DirectFeedthrough = true;

    block.OutputPort(2).Dimensions  = prediction_time;
    block.OutputPort(2).DatatypeID  = 0; % double
    block.OutputPort(2).Complexity  = 'Real';
end

block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

if block.NumOutputPorts == 2 && block.DialogPrm(1).Data == 1
    block.OutputPort(2).Dimensions  = 1;
    block.OutputPort(2).DatatypeID  = 0; % double
    block.OutputPort(2).Complexity  = 'Real';
end

% Register sample times
block.SampleTimes = [-1 0];

% Specify the block simStateCompliance. The allowed values are:
block.SimStateCompliance = 'DefaultSimState';


block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required


function DoPostPropSetup(block)
block.NumDworks = 8;
  
  block.Dwork(1).Name            = 'Type_demand';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;

  block.Dwork(2).Name            = 'Constant_demand';
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;      % double
  block.Dwork(2).Complexity      = 'Real'; % real
  block.Dwork(2).UsedAsDiscState = true;

  block.Dwork(3).Name            = 'Kc_list';
  block.Dwork(3).Dimensions      = 4;
  block.Dwork(3).DatatypeID      = 0;      % double
  block.Dwork(3).Complexity      = 'Real'; % real
  block.Dwork(3).UsedAsDiscState = true;

  block.Dwork(4).Name            = 'Growth_days_list';
  block.Dwork(4).Dimensions      = 5;
  block.Dwork(4).DatatypeID      = 0;      % double
  block.Dwork(4).Complexity      = 'Real'; % real
  block.Dwork(4).UsedAsDiscState = true;

  block.Dwork(5).Name            = 'Area';
  block.Dwork(5).Dimensions      = 1;
  block.Dwork(5).DatatypeID      = 0;      % double
  block.Dwork(5).Complexity      = 'Real'; % real
  block.Dwork(5).UsedAsDiscState = true;

  block.Dwork(6).Name            = 'Stored_water';
  block.Dwork(6).Dimensions      = 1;
  block.Dwork(6).DatatypeID      = 0;      % double
  block.Dwork(6).Complexity      = 'Real'; % real
  block.Dwork(6).UsedAsDiscState = true;

  block.Dwork(7).Name            = 'PERC'; % Dependand on ground type
  block.Dwork(7).Dimensions      = 1;
  block.Dwork(7).DatatypeID      = 0;      % double
  block.Dwork(7).Complexity      = 'Real'; % real
  block.Dwork(7).UsedAsDiscState = true;

  block.Dwork(8).Name            = 'Control_type'; % 0=normal, 1=predictive
  block.Dwork(8).Dimensions      = 1;
  block.Dwork(8).DatatypeID      = 0;      % double
  block.Dwork(8).Complexity      = 'Real'; % real
  block.Dwork(8).UsedAsDiscState = true;



function Start(block)

% Save the demand and control type
block.Dwork(1).Data = block.DialogPrm(1).Data;
block.Dwork(8).Data = block.DialogPrm(6).Data;

% Save crop type
Crop = block.DialogPrm(3).Data;

% Save values for water demand
if block.Dwork(1).Data == 1	                        % Constant demand
    block.Dwork(2).Data = block.DialogPrm(2).Data/365/24;

elseif block.Dwork(1).Data == 2                     % Agriculture    
    Kc_crops = [
        0.35	0.75	1.15	0.45
        0.35	0.70	1.10	0.90
        0.35	0.70	1.10	0.30
        0.45	0.75	1.05	0.90
        0.45	0.75	1.05	0.90
        0.45	0.75	1.15	0.75
        0.45	0.70	0.90	0.75
        0.45	0.75	1.15	0.80
        0.35	0.75	1.10	0.65
        0.45	0.75	1.10	0.50
        0.45	0.60	1.00	0.90
        0.40	0.80	1.15	1.00
        0.40	0.80	1.15	0.70
        0.45	0.75	1.00	0.75
        0.35	0.70	1.10	0.65
        0.50	0.70	1.00	1.00
        0.50	0.75	1.05	0.85
        0.45	0.75	1.05	0.70
        0.45	0.80	1.15	1.05
        0.35	0.70	1.05	0.90
        0.45	0.75	1.15	0.85
        0.45	0.60	0.90	0.90
        0.35	0.75	1.10	0.65
        0.35	0.75	1.10	0.60
        0.45	0.60	1.00	0.90
        0.45	0.70	0.90	0.75
        0.45	0.80	1.15	0.80
        0.35	0.75	1.15	0.55
        0.45	0.75	1.15	0.80
];

    block.Dwork(3).Data = Kc_crops(Crop,:);

    Growth_stage_crops = [
        0	15	43	100	135
        0	18	45	73	83
        0	18	45	83	103
        0	23	50	113	130
        0	23	55	105	125
        0	30	80	140	188
        0	23	55	100	118
        0	30	70	113	135
        0	23	55	118	158
        0	23	55	120	160
        0	28	68	98	108
        0	20	48	85	95
        0	25	68	118	153
        0	28	68	120	140
        0	18	45	93	123
        0	25	60	75	83
        0	18	48	138	180
        0	28	65	110	135
        0	18	45	80	95
        0	28	65	140	165
        0	28	60	100	125
        0	8	18	33	38
        0	20	53	95	125
        0	20	50	115	143
        0	20	45	73	80
        0	23	55	88	108
        0	35	85	155	195
        0	23	58	103	128
        0	33	75	130	158
    ];

    Plant_day_crops = [75 120 120 75 75 135 135 135 75 75 45 135 135 135 135 75 75 135 45 135 75 45 135 135 45 135 75 135 135];

    block.Dwork(4).Data = Growth_stage_crops(Crop,:) + Plant_day_crops(Crop);

    block.Dwork(5).Data = block.DialogPrm(4).Data;

    block.Dwork(7).Data = block.DialogPrm(5).Data/24;

else
    error('Error: unkown index for Type_demand. :(')
end
%end Start


function Outputs(block)

if block.Dwork(1).Data == 1                         % Constant demand
    Constant_demand = block.Dwork(2).Data;
    block.OutputPort(1).Data = Constant_demand;
    if block.Dwork(8).Data == 1
        block.OutputPort(2).Data = Constant_demand;
    end

elseif block.Dwork(1).Data == 2                     % Agriculture
    Area = block.Dwork(5).Data;

    % Find the day
    t_day = floor(block.CurrentTime/24);

    % Select Kc
    Kc_list = block.Dwork(3).Data;
    Growth_stage_days = block.Dwork(4).Data;

    if t_day < Growth_stage_days(1)
        Kc = 0;
    elseif t_day >= Growth_stage_days(1) && t_day < Growth_stage_days(end)
        Kc = Kc_list(find(t_day < Growth_stage_days, 1) - 1);
    else
        Kc = 0;
    end

    if Kc == 0
        block.OutputPort(1).Data = 0;

    else
        % Find the month
        month_list = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];

        if t_day < 0
            month = 0;
        elseif t_day >= 0 && t_day <= month_list(end)
            month = find(t_day <= month_list, 1);
        else
            month = 0;
        end

        % Find the precentage of daylight
        p_daylight_list = [0.17, 0.21, 0.26, 0.32, 0.36, 0.39, 0.38, 0.33, 0.28, 0.23, 0.18, 0.16];
        p_daylight = p_daylight_list(month);


        % Temperature [C]
        T = block.InputPort(3).Data;

        % Calculate reference water needs [mm/day]
        y_needs_ref = p_daylight * (0.46*T + 8);

        % Calculate crop water needs [mm/day] and [mm/h]
        y_needs_per_day = Kc * y_needs_ref;
        y_needs = y_needs_per_day / 24;

        % Effective rainfall [mm/month] and [mm/h]
        P_month = block.InputPort(2).Data * (24*30);

        if P_month > 75
            Pe_month = 0.8 * P_month - 25;
        else
            Pe_month = max(0, 0.6 * P_month -10);
        end

        Pe = Pe_month / (24*30);

        % Losses [mm/h]
        if y_needs <= 0
            PERC = 0;
        else
            PERC = block.Dwork(7).Data;
        end

        % Calculate total water demand [mm]
        y_stored = block.Dwork(6).Data;
        y_demand = (y_needs + PERC - Pe - y_stored);


        if y_demand < 0
            y_stored = -1*y_demand;
            V_demand = 0;
            block.Dwork(6).Data = y_stored;
        else
            % Calculate total water demand [m^3/h]
            V_demand = y_demand / 1000 * Area;
            block.Dwork(6).Data = 0;
        end

        block.OutputPort(1).Data = V_demand;
    end

    % Predictive control
    if block.Dwork(8).Data == 1
        y_stored_predict = block.Dwork(6).Data;

        V_predict = zeros(1,length(block.InputPort(5).Data));
        for i = 1:length(block.InputPort(5).Data)
            % Find the day
            t_day = floor((block.CurrentTime + (i-1))/24);

            % Select Kc
            if t_day < Growth_stage_days(1)
                Kc = 0;
            elseif t_day >= Growth_stage_days(1) && t_day < Growth_stage_days(end)
                Kc = Kc_list(find(t_day < Growth_stage_days, 1) - 1);
            else
                Kc = 0;
            end

            if Kc == 0
                V_predict(i) = 0;

            else
                % Find the month
                month_list = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];
                if t_day < 0
                    month = 0;
                elseif t_day >= 0 && t_day <= month_list(end)
                    month = find(t_day <= month_list, 1);
                else
                    month = 0;
                end

                % Find the precentage of daylight
                p_daylight_list = [0.17, 0.21, 0.26, 0.32, 0.36, 0.39, 0.38, 0.33, 0.28, 0.23, 0.18, 0.16];
                p_daylight = p_daylight_list(month);

                % Temperature [C]
                T = block.InputPort(5).Data(i);

                % Calculate reference water needs [mm/day]
                y_needs_ref = p_daylight * (0.46*T + 8);

                % Calculate crop water needs [mm/day] and [mm/h]
                y_needs_per_day = Kc * y_needs_ref;
                y_needs = y_needs_per_day / 24;

                % Effective rainfall [mm/month] and [mm/h]
                P_month = block.InputPort(4).Data(i) * (24*30);

                if P_month > 75
                    Pe_month = 0.8 * P_month - 25;
                else
                    Pe_month = max(0, 0.6 * P_month -10);
                end

                Pe = Pe_month / (24*30);

                % Losses [mm/h]
                if y_needs <= 0
                    PERC = 0;
                else
                    PERC = block.Dwork(7).Data;
                end

                % Calculate total water demand [mm]
                y_demand = (y_needs + PERC - Pe - y_stored_predict);


                if y_demand < 0
                    y_stored_predict = -1*y_demand;
                    V_predict(i) = 0;
                else
                    % Calculate total water demand [m^3/h]
                    V_predict(i) = y_demand / 1000 * Area;
                end
            end
        end

        block.OutputPort(2).Data =  V_predict;
    end
end

%end Outputs



%%
function Terminate(block)

%end Terminate

