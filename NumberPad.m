%{ 
NumberPad class:
      Creates and manages the number pad for the calculator.
      It initializes buttons for digits and handles their event callbacks,
      allowing users to input numbers into the calculator by clicking buttons.
        

        Hardcoding used for:
                - The text and name for each digit button and each numeral button
                - Assigning the callback function of each button 
                - The positioning of each button
%}
classdef NumberPad
        properties
                ParentContainer        % Parent UI container
                InputExpression        % Reference to the input expression field
        end






        methods
                function obj = NumberPad(parent, inputExpr)
                        %{                              
                                Constructor for the NumberPad class. Initializes number buttons.
                        %}  
                        
                        
                        obj.ParentContainer = parent;
                        obj.InputExpression = inputExpr;
                        % Create number buttons
                        obj.createButtons();
                end








                function createButtons(obj)
                        %{                              
                                Dynamically creates buttons for digits 1-9, 0, '.', and '-' on the calculator UI.
                                Initial setup for button positioning, top to bottom, left to right
                                Assuming initPos is the bottom-left starting point for the first button
                                The position for each button is calculated based on its row and column in the grid. 
                        %}  
                        
                        
                        % Move initial button position up to be just below the display(hardcoded)
                        initPos = [75, 125, 55, 45];
                        

                        % The xOffset and yOffset are used to space the buttons apart.
                        xOffset = 57.5; % Horizontal offset between buttons
                        yOffset = 50; % Vertical offset between buttons
                        numbers = '7894561230.-'; % Arrange as on a calculator
                        
                        

                        % Create buttons in a 4x3 grid
                        % (3 - row) in the vertical position calculation ensures that the grid starts from the top row(since screen coordinates in MATLAB originate from the bottom left).
                        for row = 1:4
                                for col = 1:3 
                                num = numbers((row-1)*3 + col);
                                pos = [initPos(1) + (col - 1) * xOffset, ...
                                        initPos(2) + (3 - row) * yOffset, ...
                                        initPos(3), initPos(4)];
        
                                % Button creation with callback to append number
                                uibutton(obj.ParentContainer, 'Text', num, 'Position', pos, ...
                                       "BackgroundColor", [0 0.3470 0.6410], ... % [0.25 0.25 0.25]~dark_gray, [0 0.2470 0.4410]~navy, [0 0.3470 0.6410]~math_blue, [0 0.4470 0.7410]~medium_blue,  [0.3010 0.7450 0.9330]~light_blue
                                     "FontColor", "white", ... %"white" == [1.0 1.0 1.0]
                                      'ButtonPushedFcn', @(btn,event) obj.appendToExpression(num));
                                end
                        end
                end








                function appendToExpression(obj, char)
                        %{                              
                                Appends the clicked number or character to the calculator's input expression.
                        %}  
                          
                        
                        % Append character to input field
                        currentExpr = obj.InputExpression.Value;
                        obj.InputExpression.Value = [currentExpr, char];
                end








        end
end










