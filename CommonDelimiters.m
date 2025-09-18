% ===================================================
% CommonDelimiters 
% ===================================================
classdef CommonDelimiters < RailItem
    % CommonDelimiters
    %   Rail item with quick-insert buttons for common delimiters.
    %
    % Buttons (label → payload appended)
    %   ,  → ','
    %   :  → ':'
    %   (  → '('   [or '()' if SmartPairs=true]
    %   )  → ')'
    %   [  → '['   [or '[]' if SmartPairs=true]
    %   ]  → ']'
    %   {  → '{'   [or '{}' if SmartPairs=true]
    %   }  → '}'
    %
    % Usage:
    %   d = CommonDelimiters(parentRail, inputEditField, railRow, ...
    %         'CalcDisplay', calcDisplay, ...
    %         'Enabled', true, 'SmartPairs', false, ...
    %         'ButtonBG',[0 0.3470 0.6410], 'ButtonFG',[1 1 1], 'ButtonFS',14);

    properties
        % Optional live mirroring into CalculationDisplay
        CalcDisplay = []

        % Behavior
        Enabled    (1,1) logical = true
        SmartPairs (1,1) logical = false   % when true, insert paired brackets: (), [], {}

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
        function obj = CommonDelimiters(parentRail, inputExpr, railRow, varargin)
            % Collapsible rail header/panel
            obj@RailItem(parentRail, inputExpr, railRow, '▼ delims');

            % Apply Name/Value options
            for k = 1:2:numel(varargin)
                name = string(varargin{k});
                if isprop(obj, name)
                    obj.(name) = varargin{k+1};
                end
            end

            % Faces and base payloads
            obj.Labels   = {',',':','(',')','[',']','{','}'};
            obj.Payloads = {',',':','(',')','[',']','{','}'};

            % Internal grid (4 x 2)
            obj.Grid = uigridlayout(obj.Panel,[4 2], ...
                'RowHeight',   {30,30,30,30}, ...
                'ColumnWidth', {'1x','1x'}, ...
                'RowSpacing',  obj.RowSpacing, ...
                'ColumnSpacing', obj.ColSpacing, ...
                'Padding',     obj.Padding);

            % Create buttons
            idx = 1;
            for r = 1:4
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

        % Public toggles
        function set.Enabled(obj, tf)
            obj.Enabled = logical(tf);
            obj.applyEnabled();
        end

        function set.SmartPairs(obj, tf)
            obj.SmartPairs = logical(tf);
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

        function append(obj, s)
            % Optionally expand opening delimiters into pairs
            if obj.SmartPairs
                switch s
                    case '('
                        s = '()';
                    case '['
                        s = '[]';
                    case '{'
                        s = '{}';
                end
            end

            obj.InputExpression.Value = [obj.InputExpression.Value, s];

            % Optional live mirroring into CalculationDisplay
            if ~isempty(obj.CalcDisplay) && isvalid(obj.CalcDisplay)
                try
                    obj.CalcDisplay.updateInput(obj.InputExpression.Value);
                catch
                    % safe no-op
                end
            end
        end
    end
end
