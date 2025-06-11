classdef Demand_mask

    methods(Static)

        % Following properties of 'maskInitContext' are available to use:
        %  - BlockHandle
        %  - MaskObject
        %  - MaskWorkspace: Use get/set APIs to work with mask workspace.
        function MaskInitialization(maskInitContext)
            Demand_type = get_param(gcb, 'Type_demand');
            Control_type = get_param(gcb, 'Type_control');
            Visibilities = get_param(gcb, 'MaskVisibilities');
            switch Demand_type
                case "Constant demand"
                    [Visibilities{1:6}] = deal("on","on","off","off","off","on");
                case "Agriculture"
                    [Visibilities{1:6}] = deal("on","off","on","on","on","on");
            end

            switch Control_type
                case "Normal control"
                    [Visibilities{7}] = deal("off");
                case "Predictive control"
                    [Visibilities{7}] = deal("on");
            end

            set_param(gcb, 'MaskVisibilities', Visibilities);
        end





        function Type_demand(callbackContext)
            Demand_type = get_param(gcb, 'Type_demand');
            Visibilities = get_param(gcb, 'MaskVisibilities');
            switch Demand_type
                case "Constant demand"
                    [Visibilities{1:6}] = deal("on","on","off","off","off","on");
                case "Agriculture"
                    [Visibilities{1:6}] = deal("on","off","on","on","on","on");
            end

            set_param(gcb, 'MaskVisibilities', Visibilities);
        end

        function Type_control(callbackContext)
            Control_type = get_param(gcb, 'Type_control');
            Visibilities = get_param(gcb, 'MaskVisibilities');
            switch Control_type
                case "Normal control"
                    [Visibilities{7}] = deal("off");
                case "Predictive control"
                    [Visibilities{7}] = deal("on");
            end

            set_param(gcb, 'MaskVisibilities', Visibilities);
        end
    end
end