classdef filterselection

    methods(Static)
        function filteroption(callbackContext)
            filteroption = get_param(gcb, 'filteroption');
            Visibilities = {"on", "on", "on", "on"};
            switch filteroption
                case "Common filter"
                    Visibilities = {"on", "on", "off", "on"};
                case "Custom filter"
                    Visibilities = {"on", "off", "on", "on"};
            end
            set_param(gcb, 'MaskVisibilities', Visibilities);
        end

    end
end