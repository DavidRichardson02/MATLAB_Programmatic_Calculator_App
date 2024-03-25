%{ 
RelationalSymbols class:
      RelationalSymbols manages buttons for relational and comparison symbols
      such as <, >, <=, and >=. It allows users to include these symbols in their
      expressions, facilitating the construction of comparison operations within the calculator.


        Hardcoding used for:
                - The text and name for each relational symbol button
                - Assigning the callback function of each relational symbol button 
                - The positioning of each relational symbol button
%}
classdef RelationalSymbols
        properties
                ParentContainer        % Parent container for the relational symbols buttons
                InputExpression        % Reference to the input expression edit field
                DropdownButton      % Dropdown button to access relational symbols
                SymbolsPanel        % Panel to hold the relational symbols buttons
        end
    





        methods
                function obj = RelationalSymbols(parent, inputExpr)
                        %{                              
                                Constructor for RelationalSymbols class. Initializes comparison symbols buttons. 
                        %}
                        

                        obj.ParentContainer = parent;
                        obj.InputExpression = inputExpr;



                        % Create a panel to hold the relational symbols buttons
                        obj.SymbolsPanel = uipanel(parent, 'Position', [60, 155, 75, 75], 'Visible', 'off', 'BackgroundColor', [0.75 0.75 0.75]);

                        % Create a dropdown button with styling
                        obj.DropdownButton = uibutton(parent, 'Text', '▼=', ...
                                'Position', [10, 155, 50, 30], 'ButtonPushedFcn', @(btn,event) obj.toggleSymbolsPanel(), ...
                                'BackgroundColor', [0.8 0.8 0.8]);


                        % Create buttons for relational symbols and add them to the panel
                        obj.createButtons();
                end
        







                function createButtons(obj)
                        %{                              
                                Creates buttons for each relational symbol.
                        %}                        
            
            
                        % Symbols and their positions
                        symbols = {'>', '<', '>=', '<='};
                        positions = [5, 40, 30, 30; 40, 40, 30, 30; 5, 5, 30, 30; 40, 5, 30, 30];
   
                        
                        % Iterate through symbols to create buttons
                        for i = 1:length(symbols)
                                symbol = symbols{i};
                                pos = positions(i, :);


                                % Button creation with callback to append symbol
                                uibutton(obj.SymbolsPanel, 'Text', symbol, 'Position', pos, ...
                                        'ButtonPushedFcn', @(btn,event) obj.appendToExpression(symbol));
                        end
                end








                function toggleSymbolsPanel(obj)
                         % Check if SymbolsPanel is a valid UI component
                        if isa(obj.SymbolsPanel, 'matlab.ui.container.Panel')
                        
                                % Toggle the visibility of the symbols panel
                                if strcmp(obj.SymbolsPanel.Visible, 'off')
                                        obj.SymbolsPanel.Visible = 'on';
                                else
                                        obj.SymbolsPanel.Visible = 'off';
                                end
                        else
                                disp('Error: SymbolsPanel is not a valid UI panel.');
                        end

                end

        





                
                function appendToExpression(obj, symbol)
                        %{                              
                                Appends the selected relational symbol to the input expression.
                        %}                          
                        

                        currentExpr = obj.InputExpression.Value;
                        obj.InputExpression.Value = [currentExpr, symbol];
                end








    end
end










