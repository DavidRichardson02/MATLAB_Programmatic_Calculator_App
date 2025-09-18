% ===========================
% CalculationDisplay (grid-based)
% ===========================
classdef CalculationDisplay < handle
    % CalculationDisplay
    %   Owns the scrollable history panel + the input edit field and
    %   provides a tiny "model" (History, HistoryIndex) to manage the
    %   current line being edited and previously accepted entries.
    %
    % Conventions:
    %   • History is a cell array of char/strings. The last item is either:
    %       - the current live input being edited (typing), or
    %       - the last committed "expr    value" line (after addEntry).
    %   • HistoryIndex points to which item should be considered "current".
    %     Typically HistoryIndex == numel(History).
    %   • updateInput(newValue) mirrors the edit box into the current line.
    %   • addEntry(value) commits "expr    value" as a new line and clears input.
    %
    % Layout:
    %   [displayParent] → uipanel (Scrollable='on')
    %                   → HistoryGrid (MAX labels stacked in one column)
    %   [inputParent]   → uigridlayout(1x1)
    %                   → uieditfield 'text' (fills the cell)

    properties
        % UI containers
        DisplayPanel            % uipanel containing the history area (scrollable)
        HistoryGrid             % uigridlayout inside DisplayPanel for labels
        InputExpression         % uieditfield for typing the expression

        % Labels
        OutputLines             % vector<uilabel> sized MAXIMUM_DISPLAY_OUTPUT_LINES

        % State
        History                 % cellstr, rolling history (last item is "current line")
        HistoryIndex            % current index in History to display
        CursorPosition          % (reserved for future cursor features)
        MAXIMUM_DISPLAY_OUTPUT_LINES = 100;

        % (Optional) colors (customize here)
        RowColor        = [0.875 0.875 0.875];  % light gray rows
        HighlightColor  = [0.68 0.85 0.90];     % light blue
    end

    methods
        function obj = CalculationDisplay(varargin)
            % Support both ctor forms:
            %   CalculationDisplay(displayParent, inputParent)
            %   CalculationDisplay(parent) → builds a 2-row wrapper inside parent
            narginchk(1,2);

            if nargin == 2
                displayParent = varargin{1};
                inputParent   = varargin{2};
            else
                % Build a 2-row wrapper grid inside the single parent
                parent = varargin{1};
                wrapper = uigridlayout(parent, [2 1], ...
                    'RowHeight', { '1x', 40 }, ...
                    'ColumnWidth', { '1x' }, ...
                    'RowSpacing', 8, 'ColumnSpacing', 0, 'Padding', 0);
                displayParent = uipanel(wrapper);
                displayParent.Layout.Row = 1;
                displayParent.Layout.Column = 1;

                inputParent = uipanel(wrapper);
                inputParent.Layout.Row = 2;
                inputParent.Layout.Column = 1;
                set(inputParent, 'BorderType','none'); %#ok<*SETNU>
            end

        
        % === History container (scrollable panel + fixed row label grid)
        % If the parent we were given is already a panel, reuse it so we fill.
        if isa(displayParent,'matlab.ui.container.Panel')
            obj.DisplayPanel = displayParent;
            % apply desired look to the existing panel
            set(obj.DisplayPanel, ...
                'Title','Output Window', ...
                'Scrollable','on', ...
                'BackgroundColor','white', ...
                'BorderColor','black');
        else
            % if the parent is a grid (or figure), create a panel that fills
            obj.DisplayPanel = uipanel(displayParent, ...
                'Title','Output Window', ...
                'Scrollable','on', ...
                'BackgroundColor','white', ...
                'BorderColor','black');
            if isa(displayParent,'matlab.ui.container.GridLayout')
                obj.DisplayPanel.Layout.Row    = 1;
                obj.DisplayPanel.Layout.Column = 1;
            else
                % last resort: fill via normalized units
                obj.DisplayPanel.Units = 'normalized';
                obj.DisplayPanel.Position = [0 0 1 1];
            end
        end



            % >>> ADD: make the panel fill its grid cell
            if isa(displayParent,'matlab.ui.container.GridLayout')
                obj.DisplayPanel.Layout.Row    = 1;
                obj.DisplayPanel.Layout.Column = 1;   % or [1 2] if you want to span columns
            end


                
            obj.HistoryGrid = uigridlayout(obj.DisplayPanel, ...
                [obj.MAXIMUM_DISPLAY_OUTPUT_LINES 1], ...
                'RowHeight', repmat({24}, 1, obj.MAXIMUM_DISPLAY_OUTPUT_LINES), ...
                'ColumnWidth', {'1x'}, ...
                'RowSpacing', 4, 'Padding', [6 6 6 6]);

            % Pre-allocate labels (top-to-bottom)
            obj.OutputLines = gobjects(obj.MAXIMUM_DISPLAY_OUTPUT_LINES, 1);
            for r = 1:obj.MAXIMUM_DISPLAY_OUTPUT_LINES
                lbl = uilabel(obj.HistoryGrid, ...
                    'Text','', ...
                    'HorizontalAlignment','left', ...
                    'WordWrap','on', ...
                    'FontSize',14, ...
                    'BackgroundColor', obj.RowColor);
                lbl.Layout.Row = r;
                lbl.Layout.Column = 1;
                obj.OutputLines(r) = lbl;
            end

            % === Input field (fills its cell)
            inGrid = uigridlayout(inputParent, [1 1], ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'RowSpacing', 0, 'ColumnSpacing', 0, 'Padding', 0);


            % >>> ADD: make the input grid fill its cell
            if isa(inputParent,'matlab.ui.container.GridLayout')
                inGrid.Layout.Row    = 1;
                inGrid.Layout.Column = 1;
            end


            obj.InputExpression = uieditfield(inGrid, 'text', ...
                'BackgroundColor', [0.875 0.875 0.875], ...
                'FontColor', [0 0 0], ...
                'HorizontalAlignment','right');

            % === Initial state
            obj.History       = {''};
            obj.HistoryIndex  = 1;
            obj.CursorPosition = 1;

            % === Callbacks
            obj.InputExpression.ValueChangedFcn = @(src,~) obj.updateInput(src.Value);

            % Render once
            obj.updateDisplay();

        end





        
        function updateInput(obj, newValue)
                % commented out, so the live line never changes visually.
            % Mirror the input field into the "current" history line.
           % if isempty(obj.History) || obj.HistoryIndex == numel(obj.History)
            %    obj.History{end} = newValue;
            %else
            %    obj.History{end+1} = newValue;
            %    obj.HistoryIndex = numel(obj.History);
            %end
            obj.CursorPosition = strlength(newValue) + 1;
            %obj.updateDisplay();
        end




        
        function addEntry(obj, value)
            % Append "expr    value" as a single line and refresh.
            if obj.HistoryIndex < numel(obj.History)
                obj.History = obj.History(1:obj.HistoryIndex);  % trim forward history
            end

            expression = obj.InputExpression.Value;
            solution  = num2str(value);
            
    
  

            % simple aligned string (monospace look not guaranteed; you can remove spaces)
            %formatted = sprintf('%s    %s', expr, sol);

            % Format with alignment (same as before)
            labelWidth = 428; 
            charWidth = 10;  
            numSpaces = floor((labelWidth - (length(expression) + length(solution)) * charWidth) / charWidth);
            formattedResult = [expression, repmat(' ', 1, max(numSpaces, 0)), solution];


            obj.History{end+1} = formattedResult;
            obj.HistoryIndex   = numel(obj.History);

            % Clear input only after a confirmed evaluation
            obj.InputExpression.Value = '';

            obj.updateDisplay();
        end





        function updateDisplay(obj)
            % Clear / normalize all labels
            for k = 1:obj.MAXIMUM_DISPLAY_OUTPUT_LINES
                lk = obj.OutputLines(k);
                lk.Text = '';
                lk.FontWeight = 'normal';
                lk.BackgroundColor = obj.RowColor;
            end

     
            if isempty(obj.History), return; end

            % Compute visible window [startLine .. endLine] with last at bottom
            startLine = max(1, obj.HistoryIndex - (obj.MAXIMUM_DISPLAY_OUTPUT_LINES - 1));
            endLine   = obj.HistoryIndex;





            % Map history lines into the bottom of the label stack
            %row = obj.MAXIMUM_DISPLAY_OUTPUT_LINES - (endLine - startLine);
            % >>> write from the TOP so it's visible without scrolling
            row = 1;
            for i = startLine:endLine
                lineIndex = obj.MAXIMUM_DISPLAY_OUTPUT_LINES - (endLine - i);
                lbl = obj.OutputLines(row);
                lbl.Text = obj.History{i};

                % Highlight only the current history line
                if i == obj.HistoryIndex
                    lbl.FontWeight = 'bold';
                    lbl.FontColor = [0 0 0];
                    lbl.BackgroundColor = obj.HighlightColor;
                else
                    obj.OutputLines(lineIndex).FontWeight = 'normal';
                    obj.OutputLines(lineIndex).BackgroundColor =  [0.875 0.875 0.875];
                end
                row = row + 1;
            end
        end
    end
end
