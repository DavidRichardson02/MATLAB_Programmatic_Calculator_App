% =======================================
% ExponentialLogarithm (rail item, 2x2)
% =======================================
classdef ExponentialLogarithm < RailItem
    % ExponentialLogarithm
    %   Rail item with buttons for exp / ln / log / log10.
    %
    % Usage:
    %   w = ExponentialLogarithm(parentRail, inputExpr, railRow, ...
    %           'CalcDisplay', calcDisplay, ...
    %           'Enabled', true, ...
    %           'ButtonBG', [0 0.3470 0.6410], 'ButtonFG', [1 1 1], 'ButtonFS', 14);
    %
    % Notes:
    %   - Buttons append 'exp(', 'ln(', 'log(', 'log10(' respectively.
    %   - If you pass CalcDisplay, presses also call
    %     calcDisplay.updateInput(editField.Value) for live mirroring.
    %   - Enable/disable toggles all buttons at once.

    properties
        % External wiring
        CalcDisplay = []                 % optional CalculationDisplay handle

        % Behavior
        Enabled   (1,1) logical = true   % quick on/off toggle

        % Styling
        ButtonBG   (1,3) double = [0 0.3470 0.6410];
        ButtonFG   (1,3) double = [1 1 1];
        ButtonFS   (1,1) double = 14;
        RowSpacing (1,1) double = 5;
        ColSpacing (1,1) double = 5;
        Padding    (1,4) double = [5 5 5 5];
    end

    properties (Access=private)
        Grid      matlab.ui.container.GridLayout
        BtnExp    matlab.ui.control.Button
        BtnLn     matlab.ui.control.Button
        BtnLog    matlab.ui.control.Button
        BtnLog10  matlab.ui.control.Button
    end

    methods
        function obj = ExponentialLogarithm(parentRail, inputExpr, railRow, varargin)
            % Header & collapsible panel via RailItem
            obj@RailItem(parentRail, inputExpr, railRow, '▼ Exp/L');

            % Parse name/value options into properties (ignore unknowns)
            for k = 1:2:numel(varargin)
                name = string(varargin{k});
                if isprop(obj, name)
                    obj.(name) = varargin{k+1};
                end
            end

            % Internal grid (2x2), fills the collapsible panel
            obj.Grid = uigridlayout(obj.Panel, [2 2], ...
                'RowHeight',   {30, 30}, ...
                'ColumnWidth', {'1x','1x'}, ...
                'RowSpacing',  obj.RowSpacing, ...
                'ColumnSpacing', obj.ColSpacing, ...
                'Padding',     obj.Padding);

            % Buttons
            obj.BtnExp = uibutton(obj.Grid, 'Text','exp', ...
                'BackgroundColor', obj.ButtonBG, 'FontColor', obj.ButtonFG, ...
                'FontSize', obj.ButtonFS, ...
                'Tooltip', 'Insert exp(', ...
                'ButtonPushedFcn', @(~,~) obj.append('exp('));
            obj.BtnExp.Layout.Row = 1; obj.BtnExp.Layout.Column = 1;

            obj.BtnLn = uibutton(obj.Grid, 'Text','ln', ...
                'BackgroundColor', obj.ButtonBG, 'FontColor', obj.ButtonFG, ...
                'FontSize', obj.ButtonFS, ...
                'Tooltip', 'Insert ln(', ...      % ExpressionEngine normalizes ln( → log(
                'ButtonPushedFcn', @(~,~) obj.append('ln('));
            obj.BtnLn.Layout.Row = 1; obj.BtnLn.Layout.Column = 2;

            obj.BtnLog = uibutton(obj.Grid, 'Text','log', ...
                'BackgroundColor', obj.ButtonBG, 'FontColor', obj.ButtonFG, ...
                'FontSize', obj.ButtonFS, ...
                'Tooltip', 'Insert log(', ...
                'ButtonPushedFcn', @(~,~) obj.append('log('));
            obj.BtnLog.Layout.Row = 2; obj.BtnLog.Layout.Column = 1;

            obj.BtnLog10 = uibutton(obj.Grid, 'Text','log10', ...
                'BackgroundColor', obj.ButtonBG, 'FontColor', obj.ButtonFG, ...
                'FontSize', obj.ButtonFS, ...
                'Tooltip', 'Insert log10(', ...
                'ButtonPushedFcn', @(~,~) obj.append('log10('));
            obj.BtnLog10.Layout.Row = 2; obj.BtnLog10.Layout.Column = 2;

            obj.applyEnabled();
        end

        % ===== Public toggles =====
        function set.Enabled(obj, tf)
            obj.Enabled = logical(tf);
            obj.applyEnabled();
        end
    end

    methods (Access=private)
        function applyEnabled(obj)
            st = matlab.lang.OnOffSwitchState(obj.Enabled);
            btns = [obj.BtnExp, obj.BtnLn, obj.BtnLog, obj.BtnLog10];
            for b = btns
                if ~isempty(b) && isvalid(b)
                    b.Enable = st;
                end
            end
        end

        function append(obj, payload)
            % Append the function call prefix and optionally mirror to display
            obj.InputExpression.Value = [obj.InputExpression.Value, payload];
            if ~isempty(obj.CalcDisplay) && isvalid(obj.CalcDisplay)
                try
                    obj.CalcDisplay.updateInput(obj.InputExpression.Value);
                catch
                    % safe no-op if CalcDisplay API differs
                end
            end
        end
    end
end
