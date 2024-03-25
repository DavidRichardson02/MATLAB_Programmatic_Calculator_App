%{
CommonDelimiters class:
      CommonDelimiters manages buttons for commonly used delimiters such as comma, colon, parenthesis, brackets, and curly brackets.
      
        Hardcoding used for:
                - The text and name for each delimiter button
                - Assigning the callback function of each delimiter button
                - The positioning of each delimiter button
%}
classdef CommonDelimiters
        properties
                ParentContainer    % Parent container for the delimiter buttons
                InputExpression    % Reference to the input expression edit field
                DropdownButton     % Dropdown button to access common delimiters
                DelimitersPanel    % Panel to hold the delimiter buttons
        end

        methods
                function obj = CommonDelimiters(parent, inputExpr)
                        obj.ParentContainer = parent;
                        obj.InputExpression = inputExpr;

                        % Create a panel to hold the delimiter buttons
                        obj.DelimitersPanel = uipanel(parent, 'Position', [60, 195, 76.125, 140], 'Visible', 'off', 'BackgroundColor', [0.75 0.75 0.75]);

                        % Create a dropdown button with styling
                        obj.DropdownButton = uibutton(parent, 'Text', '▼Delims', ...
                                'Position', [10, 195, 50, 30], 'ButtonPushedFcn', @(btn,event) obj.toggleDelimitersPanel(), ...
                                'BackgroundColor', [0.8 0.8 0.8]);

                        % Create buttons for common delimiters and add them to the panel
                        obj.createButtons();
                end

                function createButtons(obj)
                        % Define common delimiters and their positions
                        delimiters = {',', ':', '(', ')', '[', ']', '{', '}'};
                        %positions = [5, 40, 30, 30; 40, 40, 30, 30; 5, 5, 30, 30; 40, 5, 30, 30; 5, -30, 30, 30; 40, -30, 30, 30; 5, -65, 30, 30; 40, -65, 30, 30];
                        positions = [5, 40, 30, 30; 40, 40, 30, 30; 5, 5, 30, 30; 40, 5, 30, 30; 5, 75, 30, 30; 40, 75, 30, 30; 5, 105, 30, 30; 40, 105, 30, 30];
                        % Iterate through delimiters to create buttons
                        for i = 1:length(delimiters)
                                delim = delimiters{i};
                                pos = positions(i, :);

                                % Button creation with callback to append delimiter
                                uibutton(obj.DelimitersPanel, 'Text', delim, 'Position', pos, ...
                                        'ButtonPushedFcn', @(btn,event) obj.appendToExpression(delim));
                        end
                end








                function toggleDelimitersPanel(obj)
                        % Toggle the visibility of the delimiters panel
                        if strcmp(obj.DelimitersPanel.Visible, 'off')
                                obj.DelimitersPanel.Visible = 'on';
                        else
                                obj.DelimitersPanel.Visible = 'off';
                        end
                end








                function appendToExpression(obj, delim)
                        % Append delimiter to input field
                        currentExpr = obj.InputExpression.Value;
                        obj.InputExpression.Value = [currentExpr, delim];
                end









        end
end

