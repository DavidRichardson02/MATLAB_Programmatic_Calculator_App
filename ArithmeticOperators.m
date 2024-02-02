classdef ArithmeticOperators
    % ArithmeticOperators manages the arithmetic operator buttons for the calculator.
    % This class is responsible for creating buttons for operations like addition,
    % subtraction, multiplication, and division. It handles the user interactions with
    % these buttons, appending the selected operator to the current input expression.

    properties
        Parent      % Parent container for the operator buttons
        InputExpr   % Reference to the input expression edit field
    end
    
    methods
        function obj = ArithmeticOperators(parent, inputExpr)
            % Constructor for ArithmeticOperators class. Initializes operator buttons.
            obj.Parent = parent;
            obj.InputExpr = inputExpr;
            %% Create operator buttons
            obj.createButtons();
        end
        
        function createButtons(obj)
            % Dynamically creates buttons for each arithmetic operator.
           
            %% Define operators and their positions
            operators = {'+', '-', '*', '/'};


            % Adjust positions to be right-aligned with the number pad
            positions = [250, 275, 50, 30; 250, 235, 50, 30; 250, 195, 50, 30; 250, 155, 50, 30];
            

            %% Iterate through operators to create buttons
            for i = 1:length(operators)
                op = operators{i};
                pos = positions(i, :);
                %% Button creation with callback to append operator
                uibutton(obj.Parent, 'Text', op, 'Position', pos, ...
                         'ButtonPushedFcn', @(btn,event) obj.appendToExpression(op));
            end
        end
        
        function appendToExpression(obj, char)
            % Appends the selected arithmetic operator to the input expression.
            %% Append operator to input field
            currentExpr = obj.InputExpr.Value;
            obj.InputExpr.Value = [currentExpr, char];
        end
    end
end






