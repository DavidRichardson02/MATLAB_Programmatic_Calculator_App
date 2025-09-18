% ===================================================
% Rail Item base (button + collapsible panel in grid)
% ===================================================
classdef (Abstract) RailItem < handle
    % RailItem
    %   Base class for left-rail widgets. Provides:
    %     - A 2-row grid (row1: toggle button, row2: collapsible panel)
    %     - A shared InputExpression handle you can append to
    %     - toggle() to expand/collapse the panel

    properties
        RailGrid        % 2x1 grid: row1 button, row2 panel
        ToggleButton    % header button (e.g., '▼ trig')
        Panel           % collapsible area for the controls
        InputExpression % shared uieditfield from CalculationDisplay
        IsOpen logical = false;
    end
    methods
        function obj = RailItem(parentRail, inputExpr, railRow, btnText)
            obj.InputExpression = inputExpr;

            obj.RailGrid = uigridlayout(parentRail,[2 1], ...
                'RowHeight', {30, 0}, ...          % <-- start collapsed (row2 height = 0)
                'ColumnWidth', {'1x'}, ...
                'RowSpacing',5, 'Padding',0);
            obj.RailGrid.Layout.Row = railRow;
            obj.RailGrid.Layout.Column = 1;

            obj.ToggleButton = uibutton(obj.RailGrid,'Text',btnText, ...
                'BackgroundColor',[0.7 0.7 0.7], ...
                'ButtonPushedFcn', @(~,~) obj.toggle());
            obj.ToggleButton.Layout.Row=1; obj.ToggleButton.Layout.Column=1;

            obj.Panel = uipanel(obj.RailGrid,'BackgroundColor',[0.75 0.75 0.75], ...
                                 'Visible','off');
            obj.Panel.Layout.Row=2; obj.Panel.Layout.Column=1;
        end

        function toggle(obj)
            % Expand/collapse by switching row2 height between 'fit' and 0
            obj.IsOpen = ~obj.IsOpen;
            if obj.IsOpen
                obj.Panel.Visible = 'on';
                obj.RailGrid.RowHeight = {30, 'fit'};  % expand
            else
                obj.Panel.Visible = 'off';
                obj.RailGrid.RowHeight = {30, 0};      % collapse fully
            end
        end
    end
end
