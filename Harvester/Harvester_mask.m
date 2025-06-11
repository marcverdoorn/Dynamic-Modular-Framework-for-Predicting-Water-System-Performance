classdef Harvester_mask

    methods(Static)

        % Following properties of 'maskInitContext' are available to use:
        %  - BlockHandle 
        %  - MaskObject 
        %  - MaskWorkspace: Use get/set APIs to work with mask workspace.
        function MaskInitialization(maskInitContext)
        end


        


        function Type_harvester(callbackContext)
            Harvester_type = get_param(gcb, 'Type_harvester');
            Visibilities = {"on","on","on"};
            switch Harvester_type
                case "Independant on ground water (resevoir, road ect.)"
                    Visibilities = {"on","off","on"};

                case "Dependant on ground water (tunnel)"    
                    Visibilities = {"on","on","on"};
            end

            set_param(gcb, 'MaskVisibilities', Visibilities);
        end

        
            
    end
end