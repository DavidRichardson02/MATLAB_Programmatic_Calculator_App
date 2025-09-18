% ===============================
% ArithmeticOperators (2x2 grid)
% ===============================
classdef ArithmeticOperators < handle
    % ArithmeticOperators
    %   Responsive 2x2 operator pad.
    %
    % Usage:
    %   ops = ArithmeticOperators(parentGrid, inputEditField, ...
    %           'CalcDisplay', calcDisplay, ...
    %           'UseASCII',    false, ...
    %           'Enabled',     true);
    %
    % Notes:
    %   - If UseASCII==false (default), UI shows +, -, •, ÷ and appends those
    %     glyphs to the input (your ExpressionEngine normalizes them).
    %   - If UseASCII==true, it shows +, -, *, / and appends ASCII directly.
    %   - If CalcDisplay is provided, presses also call
    %       calcDisplay.updateInput(editField.Value)
    %     for live mirroring in the history line.

    properties
        % Wiring
        Parent              % parent panel or grid cell
        Grid                % internal 2x2 uigridlayout
        InputExpression     % uieditfield (from CalculationDisplay)
        CalcDisplay = []    % optional CalculationDisplay handle

        % Buttons
        Buttons             % 2x2 array of uibutton
        Labels              % cellstr shown on the buttons
        Payloads            % cellstr actually appended to the input

        % Behavior
        UseASCII (1,1) logical = false;   % false => • ÷ ; true => * /
        Enabled  (1,1) logical = true;

        % Styling
        ButtonBG   (1,3) double = [0.88 0.95 1.00]; % light blue (matches screenshot)
        ButtonFG   (1,3) double = [0 0 0];
        FontSize   (1,1) double = 16;
        FontWeight             = 'bold';
        RowSpacing (1,1) double = 10;
        ColSpacing (1,1) double = 10;
        Padding    (1,4) double = [0 0 0 0];
    end

    methods
        function obj = ArithmeticOperators(parentContainer, inputExpr, varargin)
            % ArithmeticOperators(parentContainer, inputExpr, Name,Value,...)
            arguments
                parentContainer
                inputExpr {mustBeA(inputExpr,'matlab.ui.control.EditField')}
            end
            arguments (Repeating)
                varargin
            end

            obj.Parent          = parentContainer;
            obj.InputExpression = inputExpr;

            % Apply Name/Value options to matching properties
            for k = 1:2:numel(varargin)
                name = string(varargin{k});
                if isprop(obj, name)
                    obj.(name) = varargin{k+1};
                end
            end

            % Decide button faces & payloads
            if obj.UseASCII
                obj.Labels   = {'+','-','*','/'};
                obj.Payloads = {'+','-','*','/'};
            else
                obj.Labels   = {'+','-','•','÷'};
                obj.Payloads = {'+','-','•','÷'};  % your ExpressionEngine normalizes these
            end

            % Build internal grid
            obj.Grid = uigridlayout(parentContainer,[2 2], ...
                'RowHeight', {'1x','1x'}, ...
                'ColumnWidth', {'1x','1x'}, ...
                'RowSpacing', obj.RowSpacing, ...
                'ColumnSpacing', obj.ColSpacing, ...
                'Padding', obj.Padding);

            % Create buttons in row-major order: [+  - ;  •/*  ÷/]
            faces = reshape(obj.Labels, [2,2]);
            pays  = reshape(obj.Payloads,[2,2]);
            obj.Buttons = gobjects(2,2);

            for r = 1:2
                for c = 1:2
                    lbl = faces{r,c};
                    pay = pays{r,c};
                    obj.Buttons(r,c) = uibutton(obj.Grid, ...
                        'Text', lbl, ...
                        'FontSize', obj.FontSize, ...
                        'FontWeight', obj.FontWeight, ...
                        'FontColor', obj.ButtonFG, ...
                        'BackgroundColor', obj.ButtonBG, ...
                        'ButtonPushedFcn', @(~,~) obj.appendOp(pay));
                    obj.Buttons(r,c).Layout.Row    = r;
                    obj.Buttons(r,c).Layout.Column = c;
                end
            end

            obj.applyEnabled();
        end

        % ===== Public toggles =====
        function set.Enabled(obj, tf)
            obj.Enabled = logical(tf);
            obj.applyEnabled();
        end

        function set.UseASCII(obj, tf)
            % Switch faces/payloads on the fly
            obj.UseASCII = logical(tf);
            if obj.UseASCII
                obj.Labels   = {'+','-','*','/'};
                obj.Payloads = {'+','-','*','/'};
            else
                obj.Labels   = {'+','-','•','÷'};
                obj.Payloads = {'+','-','•','÷'};
            end
            if ~isempty(obj.Buttons) && all(isvalid(obj.Buttons(:)))
                faces = reshape(obj.Labels,[2,2]);
                for r = 1:2
                    for c = 1:2
                        obj.Buttons(r,c).Text = faces{r,c};
                    end
                end
            end
        end

        % ===== Internals =====
        function applyEnabled(obj)
            if isempty(obj.Buttons) || ~all(isvalid(obj.Buttons(:))), return; end
            state = matlab.lang.OnOffSwitchState(obj.Enabled);
            for k = 1:numel(obj.Buttons)
                obj.Buttons(k).Enable = state;
            end
        end

        function appendOp(obj, s)
            if ~obj.Enabled, return; end
            obj.InputExpression.Value = [obj.InputExpression.Value, s];

            % Optional live mirroring into the CalculationDisplay
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
