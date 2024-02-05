%{ 
ActionButtons class:
      Manages action-oriented buttons such as "Calculate" and "Clear".
      This class defines functionality for clearing the display and calculating
      expressions, displaying results or error messages directly through the
      CalculatorDisplay component.
%}
classdef ActionButtons
        properties
                ParentContainer          % Parent container for the action buttons
                CalculatorDisplay % Updated to directly interact with CalculatorDisplay
        end
    





        methods
                function obj = ActionButtons(parent, calculatorDisplay)
                        % Constructor for ActionButtons class. Initializes action buttons.
                        obj.ParentContainer = parent;
                        obj.CalculatorDisplay = calculatorDisplay; % Use CalculatorDisplay for operations
                        % Create action buttons
                        obj.createButtons();
                end
        



                function createButtons(obj)
                        % Creates the "Clear" and "Calculate" buttons and sets their callbacks.
                        % Initializes directional pad buttons for navigation and editing.
                        %actions = {'del', 'Clear', 'Enter', 'Menu'};
                        %positions = {[380, 140, 30, 30], [380, 100, 30, 30], [350, 100, 30, 30], [410, 100, 30, 30]};
                        %for i = 1:4
                        %    uibutton(parent, 'Text', actions{i}, 'Position', positions{i}, ...
                        %             'ButtonPushedFcn', @(btn,event) obj.handleDirection(actions{i}));
                        %end


                        % Clear button
                        clearButton = uibutton(obj.ParentContainer, 'Text', 'Clear', 'Position', [75, 275, 80, 30], ...
                                   'ButtonPushedFcn', @(btn, event) obj.clearExpression());
                        % Enter button
                        enterButton = uibutton(obj.ParentContainer, 'Text', 'Enter', 'Position', [162.5, 275, 80, 30], ...
                                  'ButtonPushedFcn', @(btn, event) obj.calculateExpression());
                end
        



                function calculateExpression(obj)
                        % Evaluates the current expression in CalculatorDisplay and displays the result or an error.
                        expression = obj.CalculatorDisplay.InputExpr.Value; % Get current expression from CalculatorDisplay
                        try
                                result = eval(expression); % Evaluate expression
                                obj.CalculatorDisplay.addEntry(num2str(result)); % Display result
                        catch
                                obj.CalculatorDisplay.addEntry('Error: Invalid Expression'); % Display error
                        end
                end
        



                function clearExpression(obj)
                        % Clears the input and display in CalculatorDisplay.
                        obj.CalculatorDisplay.InputExpr.Value = ''; % Clear input field
                end








    end
end










