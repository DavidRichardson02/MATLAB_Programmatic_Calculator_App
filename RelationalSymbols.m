classdef RelationalSymbols
    % RelationalSymbols manages buttons for relational and comparison symbols
    % such as <, >, <=, and >=. It allows users to include these symbols in their
    % expressions, facilitating the construction of comparison operations within the calculator.

    properties
        Parent      % Parent container for the relational symbols buttons
        InputExpr   % Reference to the input expression edit field
    end
    
    methods
        function obj = RelationalSymbols(parent, inputExpr)
            % Constructor for RelationalSymbols class. Initializes comparison symbols buttons.
            obj.Parent = parent;
            obj.InputExpr = inputExpr;
            %% Create buttons for relational symbols
            obj.createButtons();
        end
        
        function createButtons(obj)
            % Creates buttons for each relational symbol.
            %% Symbols and their positions
            symbols = {'<', '>', '<=', '>='};
            positions = [10, 195, 50, 30; 10, 155, 50, 30; 10, 115, 50, 30; 10, 75, 50, 30];
            %% Iterate through symbols to create buttons
            for i = 1:length(symbols)
                symbol = symbols{i};
                pos = positions(i, :);
                %% Button creation with callback to append symbol
                uibutton(obj.Parent, 'Text', symbol, 'Position', pos, ...
                         'ButtonPushedFcn', @(btn,event) obj.appendToExpression(symbol));
            end
        end
        
        function appendToExpression(obj, symbol)
            % Appends the selected relational symbol to the input expression.
            %% Append symbol to input field
            currentExpr = obj.InputExpr.Value;
            obj.InputExpr.Value = [currentExpr, symbol];
        end
    end
end


















