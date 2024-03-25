%{
ExponentialLogarithm class:
      ExponentialLogarithm manages buttons for exponential and logarithmic functions
      such as exp, log, and ln. Allows users to include these functions in their
      expressions, facilitating the construction of exponential and logarithmic operations
      within the calculator.

        Hardcoding used for:
                - The text and name for each exponential and logarithm function button
                - Assigning the callback function of each function button
                - The positioning of each function button
%}
classdef ExponentialLogarithm
        properties
                ParentContainer    % Parent container for the function buttons
                InputExpression    % Reference to the input expression edit field
                DropdownButton     % Dropdown button to access exponential and logarithm functions
                FunctionsPanel     % Panel to hold the exponential and logarithm function buttons
        end

        methods
                function obj = ExponentialLogarithm(parent, inputExpr)
                        obj.ParentContainer = parent;
                        obj.InputExpression = inputExpr;

                        % Create a panel to hold the function buttons
                        obj.FunctionsPanel = uipanel(parent, 'Position', [60, 115, 75, 75], 'Visible', 'off', 'BackgroundColor', [0.75 0.75 0.75]);

                        % Create a dropdown button with styling
                        obj.DropdownButton = uibutton(parent, 'Text', '▼Exp/Log', ...
                                'Position', [10, 115, 50, 30], 'ButtonPushedFcn', @(btn,event) obj.toggleFunctionsPanel(), ...
                                'BackgroundColor', [0.8 0.8 0.8]);

                        % Create buttons for exponential and logarithm functions and add them to the panel
                        obj.createButtons();
                end

                function createButtons(obj)
                        % Define functions and their positions
                        functions = {'exp', 'log', 'ln'};
                        positions = [5, 40, 30, 30; 40, 40, 30, 30; 22.5, 5, 30, 30];

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
