% ===========================
% ActionButtons (grid-based)
% ===========================
classdef ActionButtons < handle
    % ActionButtons
    %   Hosts Clear / Enter / Del / Menu.
    %   Responsibilities:
    %     • Keep buttons enabled/disabled based on input contents
    %     • Evaluate on Enter: sanitize → eval → commit via CalculationDisplay.addEntry
    %     • Mirror typing via onInputChanged → CalculationDisplay.updateInput

    properties
        Parent                 % Panel or Grid cell provided by caller
        Grid                   % Internal grid that holds buttons
        CalculatorDisplay      % Handle to unified CalculationDisplay
        BtnClear               matlab.ui.control.Button
        BtnEnter               matlab.ui.control.Button
        BtnDel                 matlab.ui.control.Button
        BtnMenu                matlab.ui.control.Button
    end

    methods
        function obj = ActionButtons(parentContainer, calcDisplay)
            % parentContainer: a uigridlayout cell OR a uipanel
            % calcDisplay:     your CalculationDisplay instance
            obj.Parent            = parentContainer;
            obj.CalculatorDisplay = calcDisplay;

            % Create an internal grid if the parent isn't already a grid cell
            if isa(parentContainer,'matlab.ui.container.GridLayout')
                g = parentContainer;   % use the caller's grid directly
            else
                g = uigridlayout(parentContainer,[1 4], ...
                    'RowHeight', {'fit'}, ...
                    'ColumnWidth', {'1x','1x','1x','fit'}, ...
                    'ColumnSpacing', 8, 'RowSpacing', 0, 'Padding', [0 0 0 0]);
            end
            obj.Grid = g;

            % --- Buttons (order: clear | enter | del | menu)
            obj.BtnClear = uibutton(g,'Text','clear', ...
                'ButtonPushedFcn', @(src,evt)obj.clearExpression());
            obj.BtnClear.Layout.Row = 1; obj.BtnClear.Layout.Column = 1;

            obj.BtnEnter = uibutton(g,'Text','enter', ...
                'ButtonPushedFcn', @(src,evt)obj.calculateExpression());
            obj.BtnEnter.Layout.Row = 1; obj.BtnEnter.Layout.Column = 2;

            obj.BtnDel = uibutton(g,'Text','del', ...
                'ButtonPushedFcn', @(src,evt)obj.deleteLastCharacter());
            obj.BtnDel.Layout.Row = 1; obj.BtnDel.Layout.Column = 3;

            obj.BtnMenu = uibutton(g,'Text','menu', ...
                'ButtonPushedFcn', @(src,evt)obj.showMenu());
            obj.BtnMenu.Layout.Row = 1; obj.BtnMenu.Layout.Column = 4;

            % Initial enable/disable state and reactive wiring
            obj.syncButtonEnable();
            obj.CalculatorDisplay.InputExpression.ValueChangedFcn = @(src,~) ...
                obj.onInputChanged(src.Value);

            % Keyboard shortcuts on the host figure (Enter / Backspace / Esc)
            fig = ancestor(obj.Grid,'figure');
            if ~isempty(fig) && isempty(fig.KeyPressFcn)
                fig.KeyPressFcn = @(~,e)obj.onKey(e);
            end
        end

        % ---------- UI reactions ----------
        function onInputChanged(obj, newValue)
            % keep CalculationDisplay behavior
            obj.CalculatorDisplay.updateInput(newValue);
            obj.syncButtonEnable();
        end

        function syncButtonEnable(obj)
            hasText = ~isempty(obj.CalculatorDisplay.InputExpression.Value);
            obj.BtnEnter.Enable = matlab.lang.OnOffSwitchState(hasText);
            obj.BtnDel.Enable   = matlab.lang.OnOffSwitchState(hasText);
            obj.BtnClear.Enable = matlab.lang.OnOffSwitchState(hasText);
        end

        function onKey(obj, e)
            switch lower(e.Key)
                case {'return','enter'}
                    if strcmp(obj.BtnEnter.Enable,'on'), obj.calculateExpression(); end
                case 'backspace'
                    if strcmp(obj.BtnDel.Enable,'on'), obj.deleteLastCharacter(); end
                case 'escape'
                    if strcmp(obj.BtnClear.Enable,'on'), obj.clearExpression(); end
            end
        end

        % ---------- Button actions ----------
        function deleteLastCharacter(obj)
            s = obj.CalculatorDisplay.InputExpression.Value;
            if ~isempty(s)
                obj.CalculatorDisplay.InputExpression.Value = s(1:end-1);
                % mirror to display line & refresh enable state
                obj.CalculatorDisplay.updateInput(obj.CalculatorDisplay.InputExpression.Value);
                obj.syncButtonEnable();
            end
        end

        function clearExpression(obj)
            obj.CalculatorDisplay.InputExpression.Value = '';
            obj.CalculatorDisplay.updateInput('');
            obj.syncButtonEnable();
        end

        function calculateExpression(obj)
            raw = obj.CalculatorDisplay.InputExpression.Value;
            if isempty(raw), return; end

            eng = ExpressionEngine();
            [ok, evalStr, msg] = eng.sanitize(raw);
            if ~ok
                uialert(ancestor(obj.Grid,'figure'), msg, 'Error', 'Icon','error');
                return;
            end

            try
                val = eval(evalStr);                 % use your evaluator
                obj.CalculatorDisplay.addEntry(val); % commits and keeps history
                obj.CalculatorDisplay.InputExpression.Value = '';  % redundant but explicit
                obj.CalculatorDisplay.updateInput('');             % start fresh live line
                obj.syncButtonEnable();
            catch ME
                uialert(ancestor(obj.Grid,'figure'), ME.message, 'Evaluation error', 'Icon','error');
            end
        end

        function showMenu(~)
            % Placeholder – wire to your menu later
        end
    end
end
