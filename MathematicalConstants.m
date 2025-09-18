% ===================================================
% MathematicalConstants 
% ===================================================
classdef MathematicalConstants < RailItem
    % MathematicalConstants
    %   Rail item with quick-insert buttons for common constants.
    %
    % Buttons (label → payload appended to the input box)
    %   π   → 'π'         (ExpressionEngine normalizes to 'pi')
    %   e   → 'exp(1)'    (Euler's number)
    %   √2  → 'sqrt(2)'
    %   φ   → 'φ'         (ExpressionEngine normalizes to (1+sqrt(5))/2)
    %   i   → '1i'
    %
    % Usage:
    %   c = MathematicalConstants(parentRail, inputExpr, railRow, ...
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
        Buttons  matlab.ui.control.Button
        Labels   cell
        Payloads cell
    end

    methods
        function obj = MathematicalConstants(parentRail, inputExpr, railRow, varargin)
            % Collapsible rail header/panel
            obj@RailItem(parentRail, inputExpr, railRow, '▼ π');

            % Apply Name/Value options
            for k = 1:2:numel(varargin)
                name = string(varargin{k});
                if isprop(obj, name)
                    obj.(name) = varargin{k+1};
                end
            end

            % Labels shown on buttons and payloads appended to input
            obj.Labels   = {'π','e','√2','φ','i',''};       % last slot left empty
            obj.Payloads = {'π','exp(1)','sqrt(2)','φ','1i',''};

            % Internal grid (3 x 2)
            obj.Grid = uigridlayout(obj.Panel, [3 2], ...
                'RowHeight',   {30,30,30}, ...
                'ColumnWidth', {'1x','1x'}, ...
                'RowSpacing',  obj.RowSpacing, ...
                'ColumnSpacing', obj.ColSpacing, ...
                'Padding',     obj.Padding, ...
                'Scrollable',  'on');

            % Create buttons; skip empty filler
            idx = 1;
            for r = 1:3
                for c = 1:2
                    label = obj.Labels{idx};
                    if ~isempty(label)
                        payload = obj.Payloads{idx};
                        b = uibutton(obj.Grid, 'Text', label, ...
                            'BackgroundColor', obj.ButtonBG, ...
                            'FontColor',       obj.ButtonFG, ...
                            'FontSize',        obj.ButtonFS, ...
                            'Tooltip',         sprintf('Insert %s', label), ...
                            'ButtonPushedFcn', @(~,~) obj.append(payload));
                        b.Layout.Row = r; b.Layout.Column = c;
                    else
                        % spacer: keep layout tidy
                        uilabel(obj.Grid, 'Text','');
                    end
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
            % Find all buttons in the grid (labels are fine to ignore)
            kids = obj.Grid.Children;
            for k = 1:numel(kids)
                if isa(kids(k),'matlab.ui.control.Button')
                    kids(k).Enable = st;
                end
            end
        end

        function append(obj, payload)
            % Append payload and optionally mirror to CalculationDisplay
            obj.InputExpression.Value = [obj.InputExpression.Value, payload];
            if ~isempty(obj.CalcDisplay) && isvalid(obj.CalcDisplay)
                try
                    obj.CalcDisplay.updateInput(obj.InputExpression.Value);
                catch
                    % safe no-op if the display API changes
                end
            end
        end
    end
end
