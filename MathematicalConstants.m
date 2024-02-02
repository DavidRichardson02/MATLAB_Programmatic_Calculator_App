classdef MathematicalConstants
    % MathematicalConstants initializes buttons for mathematical constants such as π and e.
    % It appends the value of these constants to the input expression when the respective
    % button is clicked, facilitating easy inclusion of these constants in calculations.

    properties
        Parent      % Parent container for the constants buttons
        InputExpr   % Reference to the input expression edit field
    end
    
    methods
        function obj = MathematicalConstants(parent, inputExpr)
            % Constructor for MathematicalConstants class. Initializes constants buttons.
            obj.Parent = parent;
            obj.InputExpr = inputExpr;
            
            % Create buttons for mathematical constants
            obj.createButtons();
        end
        
        function createButtons(obj)
            % Creates buttons for π and e, with their respective values.
            constants = {'π', 'e'};
            values = {'pi', 'exp(1)'};


            % Constants and their positions
            positions = [10, 235, 50, 30; 10, 275, 50, 30]; % Right side, below operators

            % Iterate through constants to create buttons
            for i = 1:length(constants)
                const = constants{i};
                val = values{i};
                pos = positions(i, :);


                % Button creation with callback to append constant
                uibutton(obj.Parent, 'Text', const, 'Position', pos, ...
                         'ButtonPushedFcn', @(btn,event) obj.appendToExpression(val));
            end
        end
        
        function appendToExpression(obj, val)
            % Appends the value of the selected constant to the input expression.
            currentExpr = obj.InputExpr.Value;
            obj.InputExpr.Value = [currentExpr, val];
        end
    end
end





