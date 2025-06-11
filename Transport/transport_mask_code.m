classdef transport_mask_code
    methods(Static)
        
        function setupopt(~)
           transport_mask_code.filter_dialog_render();
           flowoption = get_param(gcb, 'flowDirec');
           transport_mask_code.configurePorts(flowoption);
        end
        
        function Transporttype(~)
            maskObj = Simulink.Mask.get(gcb);
            dialogControls = maskObj.Parameters;
            
            visibilityMap = containers.Map;
            for i = 1:length(dialogControls)
                visibilityMap(dialogControls(i).Name) = i;
            end

            Visibilities = get_param(gcb, 'MaskVisibilities');
        
            transport = get_param(gcb, 'Transporttype');

            if strcmp(transport, 'Pipeline')
                Visibilities{visibilityMap('elevation')} = 'on';
                Visibilities{visibilityMap('Dist')} = 'on';
                Visibilities{visibilityMap('width')} = 'off';
                Visibilities{visibilityMap('depth')} = 'off';
                Visibilities{visibilityMap('diameter')} = 'on';
                Visibilities{visibilityMap('dP')} = 'on';
                Visibilities{visibilityMap('customflow')} = 'off';
                Visibilities{visibilityMap('flowDirec')} = 'on';
                
                set_param(gcb, 'MaskVisibilities', Visibilities); 
                flowoption = get_param(gcb, 'flowDirec');
                if strcmp(flowoption, 'Bidirectional')
                    Visibilities{visibilityMap('max_flow_result2')} = 'on';
                else
                    Visibilities{visibilityMap('max_flow_result2')} = 'off';
                end
            
            elseif strcmp(transport, 'Channel')
                Visibilities{visibilityMap('elevation')} = 'on';
                Visibilities{visibilityMap('Dist')} = 'on';
                Visibilities{visibilityMap('width')} = 'on';
                Visibilities{visibilityMap('depth')} = 'on';
                Visibilities{visibilityMap('diameter')} = 'off';
                Visibilities{visibilityMap('dP')} = 'off';
                Visibilities{visibilityMap('customflow')} = 'off';
                Visibilities{visibilityMap('flowDirec')} = 'off';
                Visibilities{visibilityMap('max_flow_result2')} = 'off';

                set_param(gcb, 'flowDirec', 'Unidirectional');
                transport_mask_code.configurePorts('Unidirectional');
            elseif strcmp(transport, 'Custom')
                Visibilities{visibilityMap('elevation')} = 'off';
                Visibilities{visibilityMap('Dist')} = 'off';
                Visibilities{visibilityMap('width')} = 'off';
                Visibilities{visibilityMap('depth')} = 'off';
                Visibilities{visibilityMap('diameter')} = 'off';
                Visibilities{visibilityMap('dP')} = 'off';
                Visibilities{visibilityMap('customflow')} = 'on';
                Visibilities{visibilityMap('flowDirec')} = 'on';
                Visibilities{visibilityMap('max_flow_result2')} = 'on';
            end       
            set_param(gcb, 'MaskVisibilities', Visibilities);
        end

        function Control1(~)
            setup_chosen = get_param(gcb, 'setupopt');
            transport = get_param(gcb, 'Transporttype');
            flowoption = get_param(gcb, 'flowDirec');

            if strcmp(setup_chosen, 'Transport + filter')
                Nfilter = str2double(get_param(gcb, 'filterparallel'));
                if Nfilter < 1
                        error("Number of filters to low");
                end

                filteroption = get_param(gcb, 'filteroption');
                if strcmp(filteroption, 'Common filter')
                    filtertype = get_param(gcb, 'selectedfilter');
                    switch filtertype
                        case 'Sand [90 m3/h (UDI 4U4604)]'
                            maxV_1F = 90;
                            dPfilter = -0.2;
                        case 'Multimedia [18 m3/h (UDI K46042)]' 
                            maxV_1F = 18;
                            dPfilter = -0.5;
                        case 'Cyclone [360 m3/h (UDI 53080)]'
                            maxV_1F = 360;
                            dPfilter = -0.5;
                        case 'UV [501 m3/h (PureAqua  SUV-2206)]'
                            maxV_1F = 501;
                            dPfilter = -0;
                        case 'Reverse Osmosis [27 m3/h (PureAqua TW-173K-4680)]'
                            maxV_1F = 27;
                            dPfilter = -1;
                        case 'Cyclone-sand-UV [90 m3/h]'
                            maxV_1F = 90;
                            dPfilter = -0.7;
                        case 'Cyclone-sand [90 m3/h ]'
                            maxV_1F = 90;
                            dPfilter = -0.7;
                        case 'Cyclone-multimedia-UV [18m3/h]'
                            maxV_1F = 18;
                            dPfilter = -1;
                        case 'Cyclone-multimedia  [18m3/h]'
                            maxV_1F = 18;
                            dPfilter = -1;
                    end
                else
                    dPfilter = -abs(str2double(get_param(gcb, 'dPfilter')));
                    maxV_1F = str2double(get_param(gcb, 'Fflowmax'));
                end
            else
                dPfilter = 0;
                maxV_1F = 0;
                Nfilter = 0;
            end

            maxFlowFilter = maxV_1F*Nfilter;
            dPfilter = dPfilter*10^5; %Bar to Pa

            if strcmp(transport, 'Pipeline')
                elevation = str2double(get_param(gcb, 'elevation'));
                dist = str2double(get_param(gcb, 'Dist'));
                diameter = str2double(get_param(gcb, 'diameter'));
                dP = str2double(get_param(gcb, 'dP'));

                if any(isnan([elevation, dist, diameter, dP]))
                    error('Invalid input: Pipeline parameters must be numeric.');
                end
        
                if dist == 0
                    error('Invalid input: Distance cannot be zero.');
                end
                
                rho = 1000;
                mu = 1e-3;
                g = 9.81;
                dPelev = elevation*g*rho;
                dPtot = dP*10^5 + dPelev + dPfilter;

                if dPtot < 0
                    error("Pressure too low for selected elevation");
                end

                V = 1;          % Initial velocity (m/s)
                tol = 1e-6;     % Convergence tolerance (m/s)
                maxIter = 100;  % Maximum iterations

                for i = 1:maxIter
                    V_old = V;
                    Re = rho * diameter * V / mu;
                    
                    if Re < 2300
                        f = 64 / Re
                    elseif Re < 1e5
                        f = 0.316 * Re^(-0.25) 
                    else
                        f = 0.186 * Re^(-0.2) 
                    end
                   
                    V = sqrt(2 * diameter * dPtot / (f * dist * rho));
      
                    if abs(V - V_old) < tol
                        break;
                    end
                end
                
                if i == maxIter
                    warning('Maximum iterations reached. Solution may not have converged.');
                end

                Qmax = (0.5*diameter)^2 *pi*V*60*60;

                if strcmp(flowoption, 'Bidirectional')
                    dPelev_reverse = -elevation * g * rho; % Opposite elevation
                    dPtot_reverse = dP * 10^5 + dPelev_reverse + dPfilter;

                    if dPtot_reverse < 0
                        Qmax2 = 0; % No flow possible in reverse direction
                    else
                        V = 1; % Reset initial velocity
                        for i = 1:maxIter
                            V_old = V;
                            Re = rho * diameter * V / mu;
                            
                            if Re < 2300
                                f = 64 / Re; 
                            elseif Re < 1e5
                                f = 0.316 * Re^(-0.25); 
                            else
                                f = 0.186 * Re^(-0.2); 
                            end
                           
                            V = sqrt(2 * diameter * dPtot_reverse / (f * dist * rho));
                            
                            if abs(V - V_old) < tol
                                break;
                            end
                        end
                        
                        if i == maxIter
                            warning('Maximum iterations reached for reverse direction. Solution may not have converged.');
                        end

                        Qmax2 = (0.5 * diameter)^2 * pi * V * 60 * 60;
                    end
                else
                    Qmax2 = 0;
                end
                
            elseif strcmp(transport, 'Channel')
                elevation = str2double(get_param(gcb, 'elevation'));
                dist = str2double(get_param(gcb, 'Dist'));
                width = str2double(get_param(gcb, 'width'));
                depth = str2double(get_param(gcb, 'depth'));
        
                if any(isnan([elevation, dist, width, depth]))
                    error('Invalid input: Channel parameters must be numeric.');
                end
        
                if dist == 0
                    error('Invalid input: Distance cannot be zero.');
                end

                slope = elevation/dist;
                Dh = 4*width*depth/(width+2*depth);
                g = 9.81;
                n = 0.03;

                v = (1/n)*(slope^(1/2))*(Dh/4)^(2/3); % Chezy-Manning
                Qmax = width*depth*v*60*60;
                Qmax2 = 0;
                
            elseif strcmp(transport, 'Custom')
                Qmax = str2double(get_param(gcb, 'customflow'));
                Qmax2 = Qmax;
            end

            if maxFlowFilter > 0 
                Qmax = min(Qmax, maxFlowFilter);
                if strcmp(flowoption, 'Bidirectional')
                    Qmax2 = min(Qmax2, maxFlowFilter);
                end
            end
            set_param(gcb, 'max_flow_result1', num2str(Qmax));
            set_param(gcb, 'max_flow_result2', num2str(Qmax2));
        end

        function flowDirec(~)
            flowoption = get_param(gcb, 'flowDirec');
            transport = get_param(gcb, 'Transporttype');
            transport_mask_code.configurePorts(flowoption);

            maskObj = Simulink.Mask.get(gcb);
            dialogControls = maskObj.Parameters; 
            
            visibilityMap = containers.Map;
            for i = 1:length(dialogControls)
                visibilityMap(dialogControls(i).Name) = i;
            end

            Visibilities = get_param(gcb, 'MaskVisibilities');

            if strcmp(flowoption, 'Bidirectional')
                if strcmp(transport, 'Pipeline') || strcmp(transport, 'Custom')
                    Visibilities{visibilityMap('max_flow_result2')} = 'on';
                else
                    Visibilities{visibilityMap('max_flow_result2')} = 'off';
                end
            else
                Visibilities{visibilityMap('max_flow_result2')} = 'off';
            end
            set_param(gcb, 'MaskVisibilities', Visibilities);

        end

        function configurePorts(flowoption)
            setup_chosen = get_param(gcb, 'setupopt');
            if strcmp(setup_chosen, 'Transport + filter')
                displayTitle = 'Transport + Filter';
            else
                displayTitle = 'Transport';
            end

            drawingCommands = {
                sprintf('disp(''%s'')', displayTitle);
                'port_label(''input'', 1, ''Inflow'')';
                'port_label(''output'', 1, ''Outflow'')';
                'port_label(''output'', 2, ''Maxflow'')'
            };

            if strcmp(flowoption, 'Bidirectional')
                drawingCommands = {
                    sprintf('disp(''%s'')', displayTitle);
                    'port_label(''input'', 1, ''Inflow 1'')';
                    'port_label(''output'', 1, ''Outflow 1'')';
                    'port_label(''output'', 2, ''Maxflow 1'')';
                    'port_label(''input'', 2, ''Inflow 2'')';
                    'port_label(''output'', 3, ''Outflow 2'')';
                    'port_label(''output'', 4, ''Maxflow 2'')'
                };
            end

            drawingCommandsStr = sprintf('%s\n', drawingCommands{:});
            set_param(gcb, 'MaskDisplay', drawingCommandsStr);
        end


        function filteroption(~)
            transport_mask_code.filter_dialog_render();
        end

        function filter_dialog_render()
            maskObj = Simulink.Mask.get(gcb);
            dialogControls = maskObj.Parameters; 
            
            visibilityMap = containers.Map;
            for i = 1:length(dialogControls)
                visibilityMap(dialogControls(i).Name) = i;
            end

            Visibilities = get_param(gcb, 'MaskVisibilities');
            setup_chosen = get_param(gcb, 'setupopt');
            
            if strcmp(setup_chosen, 'Transport + filter')
                Visibilities{visibilityMap('filteroption')} = 'on';
                set_param(gcb, 'MaskVisibilities', Visibilities);
                option = get_param(gcb, 'filteroption');
                if strcmp(option, 'Common filter')
                    Visibilities{visibilityMap('Fflowmax')} = 'off';
                    Visibilities{visibilityMap('dPfilter')} = 'off';
                    Visibilities{visibilityMap('selectedfilter')} = 'on';
                    Visibilities{visibilityMap('filterparallel')} = 'on';
                else
                    Visibilities{visibilityMap('Fflowmax')} = 'on';
                    Visibilities{visibilityMap('dPfilter')} = 'on';
                    Visibilities{visibilityMap('selectedfilter')} = 'off';
                    Visibilities{visibilityMap('filterparallel')} = 'on';
                end
            else
                Visibilities{visibilityMap('filteroption')} = 'off';
                Visibilities{visibilityMap('Fflowmax')} = 'off';
                Visibilities{visibilityMap('dPfilter')} = 'off';
                Visibilities{visibilityMap('selectedfilter')} = 'off';
                Visibilities{visibilityMap('filterparallel')} = 'off';
            end

            set_param(gcb, 'MaskVisibilities', Visibilities);

        end

    end
end