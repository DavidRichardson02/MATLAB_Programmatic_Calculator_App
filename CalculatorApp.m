% ===============================
% CalculatorApp (fully grid-based)
% ===============================
classdef CalculatorApp
    % CalculatorApp
    %   Top-level application shell that:
    %     • Creates the main uifigure
    %     • Builds a 4x3 top-level uigridlayout
    %     • Instantiates the display and all input widgets
    %     • Wires each widget to a shared InputExpression (from CalculationDisplay)
    %
    % Interaction contract
    %   - All input widgets append text into CalculationDisplay.InputExpression.
    %   - Many widgets also call CalculationDisplay.updateInput(...) to mirror
    %     the live text into the highlighted "current" history line.
    %   - The ActionButtons widget evaluates expressions and commits results.

    properties
        MainFigure
        CalculationDisplay     % Owns the history panel + input edit field
        ActionButtons          % clear / enter / del / menu row
        NumberPad              % 0–9 . -
        ArithmeticOperators    % + - • ÷ (or ASCII * /)
        TrigonometricFunctions % sin/cos/tan with inv/hyp toggles
        ExponentialLogarithm   % exp / ln / log / log10
        MathematicalConstants  % π e √2 φ i
        RelationalSymbols      % > < ≥ ≤
        CommonDelimiters       % , : () [] {}
        AlphaPad               % A–F (hex)
    end

    methods
        function app = CalculatorApp()
            % ---- Create host figure ----
            app.MainFigure = uifigure('Name','MATLAB Scientific Calculator',...
                'Position',[100 100 520 640]);
            movegui(app.MainFigure,'center');



            
            % ────────────────────────────────────────────────────────────
            % Top-level grid
            % Rows: Display, Input, Controls, Footer
            % Cols: Left rail, Center, Right rail
            % ────────────────────────────────────────────────────────────
            g = uigridlayout(app.MainFigure,[4 3], ...
                'RowHeight', {220, 40, '1x', 24}, ...
                'ColumnWidth', {100, '1x', 170}, ...
                'Scrollable','on', ...
                'RowSpacing',10, 'ColumnSpacing',10, 'Padding',10);




            % ---- Zones as panels so children can use Layout cleanly ----
            dispCell   = uipanel(g,'BorderType','line');  dispCell.Layout.Row=1; dispCell.Layout.Column=[1 3];
            inputCell  = uipanel(g,'BorderType','none');  inputCell.Layout.Row=2; inputCell.Layout.Column=[1 3];
            leftCell   = uipanel(g,'BorderType','none');  leftCell.Layout.Row=3; leftCell.Layout.Column=1;
            centerCell = uipanel(g,'BorderType','none');  centerCell.Layout.Row=3; centerCell.Layout.Column=2;
            rightCell  = uipanel(g,'BorderType','none');  rightCell.Layout.Row=3; rightCell.Layout.Column=3;
            footerCell = uipanel(g,'BorderType','none');  footerCell.Layout.Row=4; footerCell.Layout.Column=[1 3];



            % ────────────────────────────────────────────────────────────
            % Display (history + input)
            %   CalculationDisplay builds its own internal grids and is
            %   already fully responsive.
            % ────────────────────────────────────────────────────────────
            app.CalculationDisplay = CalculationDisplay(dispCell, inputCell);




            % ────────────────────────────────────────────────────────────
            % Left rail (stack of expandable groups)
            %   Each sub-class should create its own mini grid/panel and
            %   place its dropdown button + panel inside the given parent.
            % ────────────────────────────────────────────────────────────
            leftRail = uigridlayout(leftCell,[5 1], ...
                'RowHeight',{'fit','fit','fit','fit','fit'}, ...
                'ColumnWidth',{'1x'}, ...
                'RowSpacing',10, 'Padding',0);

            % If your class ctors accept (parent, inputExpr, rowIndex):
            app.TrigonometricFunctions = TrigonometricFunctions( ...
                leftRail, app.CalculationDisplay.InputExpression, 1, ...
                'CalcDisplay', app.CalculationDisplay);   % optional live mirroring


         
            app.MathematicalConstants = MathematicalConstants( ...
                leftRail, app.CalculationDisplay.InputExpression, 2, ...
                'CalcDisplay', app.CalculationDisplay);   % optional live mirroring



            
            app.CommonDelimiters       = CommonDelimiters(      leftRail, app.CalculationDisplay.InputExpression, 3);
            app.RelationalSymbols      = RelationalSymbols(     leftRail, app.CalculationDisplay.InputExpression, 4);
            %app.ExponentialLogarithm   = ExponentialLogarithm(  leftRail, app.CalculationDisplay.InputExpression, 5);

            
            app.ExponentialLogarithm = ExponentialLogarithm( ...
                leftRail, app.CalculationDisplay.InputExpression, 5, ...
                'CalcDisplay', app.CalculationDisplay);   % optional live mirroring




            
            % ────────────────────────────────────────────────────────────
            % Center: Action row + Number pad
            % ────────────────────────────────────────────────────────────
            % Center: Action row + NumberPad + AlphaPad stacked
            centerGrid = uigridlayout(centerCell,[3 1], ...
                'RowHeight', {40, '3x', '2x'}, ...   % 40 px for actions, 3:2 split for pads
                'ColumnWidth', {'1x'}, ...
                'RowSpacing', 10, 'Padding', 0);
                

            % Action row(row 1)
            actionRow = uigridlayout(centerGrid,[1 4], ...
                'ColumnWidth', {'1x','1x','1x','1x'}, ...
                'RowHeight', {40}, 'ColumnSpacing', 10, 'Padding', 0);
            actionRow.Layout.Row = 1;
            app.ActionButtons = ActionButtons(actionRow, app.CalculationDisplay);
                 


            % NumberPad (row 2) – grid is 4x3, so give 4 row heights & 3 column widths
            numPadGrid = uigridlayout(centerGrid,[4 3], ...
                'RowHeight', {'fit','fit','fit','fit'}, ...
                'ColumnWidth', {'fit','fit','fit'}, ...
                'RowSpacing', 10, 'ColumnSpacing', 10, 'Padding', 0);
            numPadGrid.Layout.Row = 2;
            app.NumberPad = NumberPad(numPadGrid, app.CalculationDisplay.InputExpression);
                
            

            % AlphaPad (row 3) – grid is 2x3, so give 2 row heights & 3 column widths
            alphaBelow = uigridlayout(centerGrid,[2 3], ...
                'RowHeight', {'1x','1x'}, ...
                'ColumnWidth', {'1x','1x','1x'}, ...
                'RowSpacing', 10, 'ColumnSpacing', 10, 'Padding', 0);
            alphaBelow.Layout.Row = 3;
            app.AlphaPad = AlphaPad(alphaBelow, app.CalculationDisplay.InputExpression, ...
                'CalcDisplay', app.CalculationDisplay, 'Uppercase', true, 'Enabled', true);
            










            % ────────────────────────────────────────────────────────────
            % Right: Operators (2x2) — use '1x' so it scales with column
            % ────────────────────────────────────────────────────────────
            opsGrid = uigridlayout(rightCell,[2 2], ...
                'RowHeight',{'1x','1x'}, ...
                'ColumnWidth',{'1x','1x'}, ...
                'RowSpacing',10, 'ColumnSpacing',10, 'Padding',0);
            %app.ArithmeticOperators = ArithmeticOperators(opsGrid, app.CalculationDisplay.InputExpression);
            app.ArithmeticOperators = ArithmeticOperators( ...
                opsGrid, app.CalculationDisplay.InputExpression, ...
                'CalcDisplay', app.CalculationDisplay, ...   % optional live mirroring
                'UseASCII', false, ...                       % use pretty • and ÷
                'Enabled',  true);




            % ────────────────────────────────────────────────────────────
            % Footer link (grid-native; no Position; stretches on resize)
            % ────────────────────────────────────────────────────────────
            footerGrid = uigridlayout(footerCell,[1 3], ...
                'ColumnWidth',{'1x','fit','1x'}, 'RowHeight',{'1x'}, ...
                'ColumnSpacing',0, 'Padding',[0 0 0 0]);

            spacerL = uilabel(footerGrid,'Text',''); spacerL.Layout.Row=1; spacerL.Layout.Column=1; %#ok<NASGU>
            link    = uihyperlink(footerGrid,'Text','Project Git', ...
                        'URL','https://github.com/DavidRichardson02/MATLAB_Calculator_Project/tree/main');
            link.Layout.Row = 1; link.Layout.Column = 2;
            spacerR = uilabel(footerGrid,'Text',''); spacerR.Layout.Row=1; spacerR.Layout.Column=3; %#ok<NASGU>


            
            % Toolbar (fine as-is; lives on the figure, not in the grid)
            tb = uitoolbar(app.MainFigure);
            pt = uipushtool(tb);
            [img,map] = imread(fullfile(matlabroot,'toolbox','matlab','icons','matlabicon.gif'));
            pt.CData = ind2rgb(img,map);
        end
    end
end
