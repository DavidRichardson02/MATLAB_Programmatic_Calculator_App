% ===================================================
% RelationalSymbols 
% ===================================================
classdef RelationalSymbols < RailItem
    % RelationalSymbols
    %   Rail item with quick-insert buttons for comparison operators.
    %
    % Buttons (label → payload appended to the input box)
    %   >  → '>'
    %   <  → '<'
    %   ≥  → '>='   (ExpressionEngine already normalizes)
    %   ≤  → '<='
    %
    % Usage:
    %   r = RelationalSymbols(parentRail, inputExpr, railRow, ...
    %         'CalcDisplay', calcDisplay, 'Enabled', true, ...
    %         'ButtonBG',[0 0.3470 0.6410], 'ButtonFG',[1 1 1], 'ButtonFS',14);

    properties
        % Optional live mirroring into CalculationDisplay
        CalcDisplay = []

        % Behavior
        Enabled   (1,1) logical = true

        % Styling
        ButtonBG   (1,3) double = [0 0.3470 0.6410];
        ButtonFG   (1,3) double = [1 1 1];
        ButtonFS   (1,1) double = 14;
        RowSpacing (1,1) double = 5;
        ColSpacing (1,1) double = 5;
        Padding    (1,4) double = [5 5 5 5];
    end

    properties (Access=private)
        Grid     matlab.ui.container.GridLayout
        Labels   cell
        Payloads cell
    end

    methods
        function obj = RelationalSymbols(parentRail, inputExpr, railRow, varargin)
            % Collapsible rail header/panel
            obj@RailItem(parentRail, inputExpr, railRow, '▼ =');

            % Apply Name/Value options
            for k = 1:2:numel(varargin)
                name = string(varargin{k});
                if isprop(obj, name)
                    obj.(name) = varargin{k+1};
                end
            end

            % Button faces and payloads (use ASCII payloads so eval is clean)
            obj.Labels   = {'>','<','≥','≤'};
            obj.Payloads = {'>','<','>=','<='};

            % Internal grid (2 x 2)
            obj.Grid = uigridlayout(obj.Panel,[2 2], ...
                'RowHeight',   {30,30}, ...
                'ColumnWidth', {'1x','1x'}, ...
                'RowSpacing',  obj.RowSpacing, ...
                'ColumnSpacing', obj.ColSpacing, ...
                'Padding',     obj.Padding);

            % Create buttons
            idx = 1;
            for r = 1:2
                for c = 1:2
                    face = obj.Labels{idx};
                    pay  = obj.Payloads{idx};
                    b = uibutton(obj.Grid,'Text',face, ...
                        'BackgroundColor',obj.ButtonBG, ...
                        'FontColor',obj.ButtonFG, ...
                        'FontSize',obj.ButtonFS, ...
                        'Tooltip',sprintf('Insert %s',face), ...
                        'ButtonPushedFcn', @(~,~) obj.append(pay));
                    b.Layout.Row = r; b.Layout.Column = c;
                    idx = idx + 1;
                end
            end

            obj.applyEnabled();
        end

        % Public toggle
        function set.Enabled(obj, tf)
            obj.Enabled = logical(tf);
            obj.applyEnabled();
        end
    end

    methods (Access=private)
        function applyEnabled(obj)
            st = matlab.lang.OnOffSwitchState(obj.Enabled);
            kids = obj.Grid.Children;
            for k = 1:numel(kids)
                if isa(kids(k),'matlab.ui.control.Button')
                    kids(k).Enable = st;
                end
            end
        end

        function append(obj, payload)
            obj.InputExpression.Value = [obj.InputExpression.Value, payload];
            % Optional live mirroring into CalculationDisplay
            if ~isempty(obj.CalcDisplay) && isvalid(obj.CalcDisplay)
                try
                    obj.CalcDisplay.updateInput(obj.InputExpression.Value);
                catch
                    % safe no-op if display API differs
                end
            end
        end
    end
end
