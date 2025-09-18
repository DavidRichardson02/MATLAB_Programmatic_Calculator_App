% ==========================================
% TrigonometricFunctions  ⟶  Rail left item
% ==========================================
classdef TrigonometricFunctions < RailItem
    % TrigonometricFunctions  (Rail item)
    % -----------------------
    % RailItem lifecycle & semantics
    % ------------------------------
    % • Construction: the RailItem base builds a 2x1 grid where row1 is a
    %   toggle button (header) and row2 is a collapsible Panel (content).
    %   Row2 height is initially 0 and Panel.Visible='off' (collapsed).
    % • Toggle(): clicking the header flips IsOpen and:
    %     - sets Panel.Visible on/off
    %     - swaps Grid.RowHeight {30,'fit'} ↔ {30,0}
    % • Mirroring: when an insert button is pressed, we append to the
    %   shared InputExpression and (if CalcDisplay is provided) call
    %   calcDisplay.updateInput(...) for live preview in the history.
    %
    % This item exposes sin/cos/tan with optional inverse/hyperbolic modes
    % and an angle-mode dropdown (rad/deg) that *hints* only (payload stays
    % as function names; numerical degree→radian conversion could be added
    % at evaluation time if desired).


    properties
        % External wiring
        CalcDisplay = []      % optional; if set, call updateInput(...)

        % Mode state
        UseInverse    (1,1) logical = false
        UseHyperbolic (1,1) logical = false
        AngleMode     (1,:) char    = 'rad'   % 'rad' | 'deg'

        % Styling
        ButtonBG   (1,3) double = [0 0.3470 0.6410];
        ButtonFG   (1,3) double = [1 1 1];
        ButtonFS   (1,1) double = 14;
        RowSpacing (1,1) double = 5;
        ColSpacing (1,1) double = 5;
        Padding    (1,4) double = [5 5 5 5];

        
    end

    properties (Access=private)
        % Grids
        RootGrid   matlab.ui.container.GridLayout
        CtrlRow    matlab.ui.container.GridLayout
        BtnGrid    matlab.ui.container.GridLayout

        % Controls
        BtnInv     matlab.ui.control.StateButton
        BtnHyp     matlab.ui.control.StateButton
        DropAngle  matlab.ui.control.DropDown

        % Function buttons
        BtnSin     matlab.ui.control.Button
        BtnCos     matlab.ui.control.Button
        BtnTan     matlab.ui.control.Button
    end

    methods
        function obj = TrigonometricFunctions(parentRail, inputExpr, railRow, varargin)
            % Header & collapsible panel
            obj@RailItem(parentRail, inputExpr, railRow, '▼ trig');

            % NV parsing
            for k = 1:2:numel(varargin)
                name = string(varargin{k});
                if isprop(obj, name), obj.(name) = varargin{k+1}; end
            end

            % ======= Layout =======
            obj.RootGrid = uigridlayout(obj.Panel,[2 1], ...
                'RowHeight',{30,'fit'}, 'ColumnWidth',{'1x'}, ...
                'RowSpacing',obj.RowSpacing, 'ColumnSpacing',obj.ColSpacing, ...
                'Scrollable','on', ...
                'Padding',obj.Padding);

            % inv | hyp | angle
            obj.CtrlRow = uigridlayout(obj.RootGrid,[1 3], ...
                'ColumnWidth',{'fit','fit','1x'}, 'RowHeight',{30}, ...
                'ColumnSpacing',5, 'Padding',[0 0 0 0]);
            obj.CtrlRow.Layout.Row = 1;

            obj.BtnInv = uibutton(obj.CtrlRow,'state', ...
                'Text','inv', ...
                'Tooltip','Inverse (asin, acos, atan)', ...
                'ValueChangedFcn', @(~,~)obj.onToggle('inv'));
            obj.BtnInv.Layout.Column = 1;

            obj.BtnHyp = uibutton(obj.CtrlRow,'state', ...
                'Text','hyp', ...
                'Tooltip','Hyperbolic (sinh, cosh, tanh)', ...
                'ValueChangedFcn', @(~,~)obj.onToggle('hyp'));
            obj.BtnHyp.Layout.Column = 2;

            obj.DropAngle = uidropdown(obj.CtrlRow, ...
                'Items', {'rad','deg'}, 'Value', obj.AngleMode, ...
                'Tooltip','Angle mode (hint only; payload unchanged)', ...
                'ValueChangedFcn', @(src,~)obj.onAngle(src.Value));
            obj.DropAngle.Layout.Column = 3;

            % sin/cos/tan
            obj.BtnGrid = uigridlayout(obj.RootGrid,[3 1], ...
                'RowHeight',{30,30,30}, 'ColumnWidth',{'1x'}, ...
                'RowSpacing',5, 'Padding',[0 0 0 0]);
            obj.BtnGrid.Layout.Row = 2;

            obj.BtnSin = uibutton(obj.BtnGrid,'Text','sin', ...
                'BackgroundColor',obj.ButtonBG, ...
                'FontColor',obj.ButtonFG, ...
                'FontSize',obj.ButtonFS, ...
                'ButtonPushedFcn', @(~,~)obj.appendCurrent('sin'));
            obj.BtnCos = uibutton(obj.BtnGrid,'Text','cos', ...
                'BackgroundColor',obj.ButtonBG, ...
                'FontColor',obj.ButtonFG, ...
                'FontSize',obj.ButtonFS, ...
                'ButtonPushedFcn', @(~,~)obj.appendCurrent('cos'));
            obj.BtnTan = uibutton(obj.BtnGrid,'Text','tan', ...
                'BackgroundColor',obj.ButtonBG, ...
                'FontColor',obj.ButtonFG, ...
                'FontSize',obj.ButtonFS, ...
                'ButtonPushedFcn', @(~,~)obj.appendCurrent('tan'));

            % First pass
            obj.refreshFaces();
            obj.refreshTooltips();
        end

        % ---------- UI Callbacks ----------
        function onToggle(obj, which)
            switch which
                case 'inv', obj.UseInverse    = logical(obj.BtnInv.Value);
                case 'hyp', obj.UseHyperbolic = logical(obj.BtnHyp.Value);
            end
            obj.refreshFaces();
            obj.refreshTooltips();
        end

        function onAngle(obj, val)
            obj.AngleMode = char(val);   % 'rad' or 'deg'
            obj.refreshTooltips();       % hint only
        end

        % ---------- Append ----------
        function appendCurrent(obj, base)
            name    = obj.resolveName(base);       % sin/asin/sinh/asinh/...
            payload = sprintf('%s(', name);        % char, as expected by EditField
            obj.InputExpression.Value = [obj.InputExpression.Value, payload];

            % Optional live mirroring
            if ~isempty(obj.CalcDisplay) && isvalid(obj.CalcDisplay)
                try
                    obj.CalcDisplay.updateInput(obj.InputExpression.Value);
                catch
                end
            end
        end
    end

    methods (Access=private)
        function refreshFaces(obj)
            obj.BtnSin.Text = obj.resolveName('sin');
            obj.BtnCos.Text = obj.resolveName('cos');
            obj.BtnTan.Text = obj.resolveName('tan');
        end

        function refreshTooltips(obj)
            modeTxt = '(rad)';
            if strcmpi(obj.AngleMode,'deg'), modeTxt = '(deg)'; end

            % Build char tooltips via sprintf (no string scalars)
            obj.BtnSin.Tooltip = sprintf('Insert %s( %s', obj.BtnSin.Text, modeTxt);
            obj.BtnCos.Tooltip = sprintf('Insert %s( %s', obj.BtnCos.Text, modeTxt);
            obj.BtnTan.Tooltip = sprintf('Insert %s( %s', obj.BtnTan.Text, modeTxt);

            obj.BtnInv.Tooltip     = 'Toggle inverse (asin/acos/atan)';
            obj.BtnHyp.Tooltip     = 'Toggle hyperbolic (sinh/cosh/tanh)';
            obj.DropAngle.Tooltip  = sprintf('Angle mode hint %s (appends function as-is)', modeTxt);
        end

        function name = resolveName(obj, base)
            if obj.UseInverse && obj.UseHyperbolic
                name = ['a' base 'h'];     % asinh/acosh/atanh
            elseif obj.UseInverse
                name = ['a' base];         % asin/acos/atan
            elseif obj.UseHyperbolic
                name = [base 'h'];         % sinh/cosh/tanh
            else
                name = base;               % sin/cos/tan
            end
        end
    end
end
