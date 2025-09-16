%{
MathematicalConstants class:
      MathematicalConstants initializes buttons for mathematical constants such as π, e, √2, φ, and i.
      It appends the value of these constants to the input expression when the respective
      button is clicked, facilitating easy inclusion of these constants in calculations.


        Hardcoding used for:
                - The text and name for each mathematical constant button
                - Assigning the callback function of each mathematical constant button 
                - The positioning of each mathematical constant button
%}
classdef MathematicalConstants
        properties
                ParentContainer        % Parent container for the constants buttons
                InputExpression        % Reference to the input expression edit field
                DropdownButton     % Dropdown button to access mathematical constants
                ConstantsPanel     % Panel to hold the mathematical constants buttons
        end






        methods
                function obj = MathematicalConstants(parent, inputExpr)
                        %{
                                Constructor for MathematicalConstants class. Initializes constants buttons.
                        %}


                        obj.ParentContainer = parent;
                        obj.InputExpression = inputExpr;

                        % Create a panel to hold the mathematical constants buttons
                        obj.ConstantsPanel = uipanel(parent, 'Position', [60, 235, 75, 75], 'Visible', 'off', 'BackgroundColor', [0.75 0.75 0.75]);

                        % Create a dropdown button with styling
                        obj.DropdownButton = uibutton(parent, 'Text', '▼ π', ... % 
                                'Position', [10, 235, 50, 30], 'ButtonPushedFcn', @(btn,event) obj.toggleConstantsPanel(), ...
                                'BackgroundColor', [0.7 0.7 0.7]);

                        % Create buttons for mathematical constants and add them to the panel
                        obj.createButtons();
                end








                function createButtons(obj)
                        %{
                                Creates buttons for π and e, with their respective values.
                        %}


                        % Define mathematical constants and their positions
                        constants = {'π', 'e', '√2', 'φ', 'i'};
                        values = {'π', 'exp(1)', 'sqrt(2)', 'φ', '1i'};
                        positions = [5, 40, 30, 30; 40, 40, 30, 30; 5, 5, 30, 30; 40, 5, 30, 30; 5, -30, 30, 30; 40, -30, 30, 30; 5, -65, 30, 30; 40, -65, 30, 30];




                        % Iterate through constants to create buttons
                        for i = 1:length(constants)
                                const = constants{i};
                                val = values{i};
                                pos = positions(i, :);


                                % Button creation with callback to append constant
                                uibutton(obj.ConstantsPanel, 'Text', const, 'Position', pos, ...
                                        'ButtonPushedFcn', @(btn,event) obj.appendToExpression(val));
                        end
                end








                function toggleConstantsPanel(obj)
                        % Toggle the visibility of the constants panel
                        if strcmp(obj.ConstantsPanel.Visible, 'off')
                                obj.ConstantsPanel.Visible = 'on';
                        else
                                obj.ConstantsPanel.Visible = 'off';
                        end
                end








                function appendToExpression(obj, val)
                        %{
                                Appends the value of the selected constant to the input expression.
                        %}


                        currentExpr = obj.InputExpression.Value;
                        obj.InputExpression.Value = [currentExpr, val];
                end









                
        end
end





