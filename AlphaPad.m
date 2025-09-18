% ===========================
% AlphaPad (responsive 2x3 grid)
% ===========================
classdef AlphaPad < handle
    % AlphaPad
    %   Hex alphabet pad (A–F) for your calculator UI.
    %
    % Usage:
    %   pad = AlphaPad(parentContainer, inputEditField, ...
    %                  'CalcDisplay', calcDisplay, ...
    %                  'Uppercase', true, ...
    %                  'Enabled',   true);
    %
    % Notes:
    %   - If you pass CalcDisplay, button presses will live-mirror into the
    %     display via calcDisplay.updateInput(editField.Value).
    %   - Layout is fully managed by an internal 2x3 uigridlayout.

    properties
        % Containers / handles
        Parent                 % parent panel or grid cell
        Grid                   % internal uigridlayout (2 x 3)
        InputExpression        % uieditfield (typically CalculationDisplay.InputExpression)
        Buttons                % 2x3 array of button handles

        % Optional hook back into the display (for live mirroring)
        CalcDisplay            % [] or a CalculationDisplay handle

        % Behavior
        Uppercase (1,1) logical = true;  % show A–F vs a–f
        Enabled   (1,1) logical = true;  % quick on/off toggle

        % Styling (tweak as desired)
        ButtonBG   (1,3) double = [0 0.3470 0.6410];
        ButtonFG   (1,3) double = [1 1 1];
        FontSize   (1,1) double = 14;
        RowSpacing (1,1) double = 5;
        ColSpacing (1,1) double = 5;
        Padding    (1,4) double = [0 0 0 0];
    end

    methods
        function obj = AlphaPad(parentContainer, inputExpr, varargin)
            % AlphaPad(parentContainer, inputExpr, Name,Value,...)
            % Name-Value:
            %   'CalcDisplay' : CalculationDisplay handle (optional)
            %   'Uppercase'   : logical
            %   'Enabled'     : logical
            %   plus simple styling overrides seen in properties.

            arguments
                parentContainer
                inputExpr {mustBeA(inputExpr, 'matlab.ui.control.EditField')}
            end
            arguments (Repeating)
                varargin
            end

            obj.Parent          = parentContainer;
            obj.InputExpression = inputExpr;

            % Parse NV pairs into matching properties (quietly skip unknowns)
            for k = 1:2:numel(varargin)
                name = string(varargin{k});
                if isprop(obj, name)
                    obj.(name) = varargin{k+1};
                end
            end

            % Internal grid (fills parent cell/panel)
            obj.Grid = uigridlayout(parentContainer, [2 3], ...
                'RowHeight', {'1x','1x'}, ...
                'ColumnWidth', {'1x','1x','1x'}, ...
                'RowSpacing', obj.RowSpacing, ...
                'ColumnSpacing', obj.ColSpacing, ...
                'Padding', obj.Padding);

            % Build six buttons A–F
            chars = 'ABCDEF';
            obj.Buttons = gobjects(2,3);
            idx = 1;
            for r = 1:2
                for c = 1:3
                    ch = chars(idx); idx = idx + 1;
                    obj.Buttons(r,c) = uibutton(obj.Grid, ...
                        'Text', ch, ...
                        'BackgroundColor', obj.ButtonBG, ...
                        'FontColor',       obj.ButtonFG, ...
                        'FontSize',        obj.FontSize, ...
                        'ButtonPushedFcn', @(~,~) obj.appendChar(ch));
                    obj.Buttons(r,c).Layout.Row    = r;
                    obj.Buttons(r,c).Layout.Column = c;
                end
            end

            % Apply behavior flags
            obj.applyCase();
            obj.applyEnabled();
        end

        % ===== Public toggles =====
        function set.Uppercase(obj, tf)
            obj.Uppercase = logical(tf);
            obj.applyCase();
        end

        function set.Enabled(obj, tf)
            obj.Enabled = logical(tf);
            obj.applyEnabled();
        end

        % ===== Internal helpers =====
        function applyCase(obj)
            if isempty(obj.Buttons) || ~all(isvalid(obj.Buttons(:))), return; end
            for k = 1:numel(obj.Buttons)
                if obj.Uppercase
                    obj.Buttons(k).Text = upper(obj.Buttons(k).Text);
                else
                    obj.Buttons(k).Text = lower(obj.Buttons(k).Text);
                end
            end
        end

        function applyEnabled(obj)
            if isempty(obj.Buttons) || ~all(isvalid(obj.Buttons(:))), return; end
            state = matlab.lang.OnOffSwitchState(obj.Enabled);
            for k = 1:numel(obj.Buttons)
                obj.Buttons(k).Enable = state;
            end
        end

        % ===== Action =====
        function appendChar(obj, ch)
            if ~obj.Enabled, return; end
            if ~obj.Uppercase, ch = lower(ch); end

            % Update the edit field
            obj.InputExpression.Value = [obj.InputExpression.Value, ch];

            % Optionally mirror into the live history line
            if ~isempty(obj.CalcDisplay) && isvalid(obj.CalcDisplay)
                try
                    obj.CalcDisplay.updateInput(obj.InputExpression.Value);
                catch
                    % Safe no-op if CalcDisplay API changes.
                end
            end
        end
    end
end





