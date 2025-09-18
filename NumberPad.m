% ===========================
% NumberPad (responsive 4 x 3)
% ===========================
classdef NumberPad < handle
    % NumberPad
    %   4x3 numeric keypad that appends its character to the shared EditField.
    %   If the EditField has a ValueChangedFcn (CalculationDisplay wiring),
    %   we trigger it so the live line mirrors immediately.
    properties
        Parent                 % parent container (panel or a grid cell)
        Grid                   % internal uigridlayout (4 x 3)
        InputExpression        % handle to CalculationDisplay.InputExpression
        Buttons                % 4x3 array of button handles
        Keys char = ['7','8','9', ...
                     '4','5','6', ...
                     '1','2','3', ...
                     '0','.', '-'];   % default calculator layout
        Enabled (1,1) logical = true
    end

    methods
        function obj = NumberPad(parentContainer, inputExpr, varargin)
            % NumberPad(parentContainer, inputExpr, 'Keys',char(12), 'Enabled',true/false)
            obj.Parent          = parentContainer;
            obj.InputExpression = inputExpr;

            % Parse name-value args
            if ~isempty(varargin)
                for k = 1:2:numel(varargin)
                    obj.(varargin{k}) = varargin{k+1};
                end
            end

            % Build internal grid so this widget is self-contained
            obj.Grid = uigridlayout(parentContainer,[4 3], ...
                'RowHeight',   {'1x','1x','1x','1x'}, ...
                'ColumnWidth', {'1x','1x','1x'}, ...
                'RowSpacing',10,'ColumnSpacing',10,'Padding',0);

            % Create buttons
            obj.Buttons = gobjects(4,3);
            idx = 1;
            for r = 1:4
                for c = 1:3
                    ch = obj.Keys(idx); idx = idx+1;
                    btn = uibutton(obj.Grid, ...
                        'Text', ch, ...
                        'BackgroundColor',[0 0.3470 0.6410], ...
                        'FontColor','white', ...
                        'FontSize',14, ...
                        'ButtonPushedFcn', @(~,~) obj.appendChar(ch));
                    btn.Layout.Row = r; btn.Layout.Column = c;
                    obj.Buttons(r,c) = btn;
                end
            end

            obj.applyEnabled();
        end

        function set.Keys(obj, newKeys)
            % Change layout on the fly (must be 12 chars)
            validateattributes(newKeys, {'char','string'}, {'vector'});
            newKeys = char(newKeys);
            if numel(newKeys) ~= 12
                error('Keys must contain exactly 12 characters.');
            end
            obj.Keys = newKeys;
            % Update button captions to match
            idx = 1;
            for r = 1:4
                for c = 1:3
                    obj.Buttons(r,c).Text = obj.Keys(idx);
                    idx = idx + 1;
                end
            end
        end

        function set.Enabled(obj, tf)
            obj.Enabled = logical(tf);
            obj.applyEnabled();
        end

        function applyEnabled(obj)
            state = matlab.lang.OnOffSwitchState(obj.Enabled);
            for k = 1:numel(obj.Buttons)
                obj.Buttons(k).Enable = state;
            end
        end

        function appendChar(obj, ch)
            if ~obj.Enabled, return; end
            obj.InputExpression.Value = [obj.InputExpression.Value, ch];

            % If your CalculationDisplay relies on ValueChangedFcn to mirror
            % the input into the highlighted history line, trigger it safely.
            try
                fcn = obj.InputExpression.ValueChangedFcn;
                if ~isempty(fcn)
                    fcn(obj.InputExpression, []);
                end
            catch
                % ignore if user code replaced/removed the callback
            end
        end
    end
end
