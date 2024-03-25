%{
TrigonometricFunctions class:
      TrigonometricFunctions manages buttons for trigonometric functions such as sin, cos, and tan.
      Accomodates the use of these functions in their(user) expressions, facilitating the construction
      of trigonometric operations within the calculator.
     
        Hardcoding used for:
                - The text and name for each trigonometric function button
                - Assigning the callback function of each trigonometric function button
                - The positioning of each trigonometric function button
%}
classdef TrigonometricFunctions
        properties
                ParentContainer        % Parent container for the trigonometric function buttons
                InputExpression        % Reference to the input expression edit field
                DropdownButton      % Dropdown button to access trigonometric functions
                FunctionsPanel        % Panel to hold the trigonometric function buttons
        end

        methods
                function obj = TrigonometricFunctions(parent, inputExpr)
                        obj.ParentContainer = parent;
                        obj.InputExpression = inputExpr;

                        % Create a panel to hold the trigonometric function buttons
                        obj.FunctionsPanel = uipanel(parent, 'Position', [60, 275, 75, 75], 'Visible', 'off', 'BackgroundColor', [0.75 0.75 0.75]);

                        % Create a dropdown button with styling
                        obj.DropdownButton = uibutton(parent, 'Text', '▼Trig', ...
                                'Position', [10, 275, 50, 30], 'ButtonPushedFcn', @(btn,event) obj.toggleFunctionsPanel(), ...
                                'BackgroundColor', [0.8 0.8 0.8]);

                        % Create buttons for trigonometric functions and add them to the panel
                        obj.createButtons();
                end








                function createButtons(obj)
                        % Define trigonometric functions and their positions
                        functions = {'sin', 'cos', 'tan'};
                        positions = [5, 40, 30, 30; 40, 40, 30, 30; 5, 5, 30, 30];

                        % Iterate through functions to create buttons
                        for i = 1:length(functions)
                                func = functions{i};
                                pos = positions(i, :);

                                % Button creation with callback to append function
                                uibutton(obj.FunctionsPanel, 'Text', func, 'Position', pos, ...
                                        'ButtonPushedFcn', @(btn,event) obj.appendToExpression([func, '(']));
                        end
                end








                function toggleFunctionsPanel(obj)
                        % Toggle the visibility of the functions panel
                        if strcmp(obj.FunctionsPanel.Visible, 'off')
                                obj.FunctionsPanel.Visible = 'on';
                        else
                                obj.FunctionsPanel.Visible = 'off';
                        end
                end








                function appendToExpression(obj, func)
                        % Append function to input field
                        currentExpr = obj.InputExpression.Value;
                        obj.InputExpression.Value = [currentExpr, func];
                end





        end
end