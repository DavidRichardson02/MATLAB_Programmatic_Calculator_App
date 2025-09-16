%{
CalculatorDisplay class:
      Manages both the display for calculation results and the editable text field
      CalculatorDisplay manages a multi-line display for the calculator.
      This class supports multiple lines for user entries and results, with new entries appearing
      at the bottom and previous entries moving up.

The handle class is the superclass for all classes that follow handle semantics. A handle is a variable that refers to an object of a handle class. Multiple variables can refer to the same object.
The handle class is an abstract class, so you cannot create an instance of this class directly. You use the handle class to derive other classes, which can be concrete classes whose instances are handle objects.

%}
classdef CalculationDisplay < handle
        properties
                DisplayPanel        % Main container for grouping together the display elements in a panel   :   Represented as a 'uipanel' object
                OutputLines        % Array of label components for each display line   :   Represented as 'uilabel' objects of the DisplayPanel's 'uipanel' object
                History        % History of calculations and inputs
                HistoryIndex        % Current index in the history for navigation
                CursorPosition        % Position of the cursor in the current input     <--- currently unused, want to have the blinking cursor on text line but not working as of rn
                InputExpression        % Editable text field for user input
                OccupiedOutputLineCount        % Count of the output lines that are occupied by some prior expression   <--- currently unused
                MAXIMUM_DISPLAY_OUTPUT_LINES = 100;        % Maxmimum number of display output lines allowed
                
                ResultLabels          % Array of all UILabels used in history
                LastHighlightedLabel  % The UILabel that was last highlighted
        end






        methods
                function obj = CalculationDisplay(parent)
                        %{
                                Initializes the display area, input field within the given parent UI component.
                        %}


                        % Temporary hardocoded values for initial positions/sizes of components.
                        panelPosition = [10, 400, 430, 190];
                        inputFieldPosition = [10, 350, 400, 30];




                        % Create the main panel for displaying output from user entries
                        obj.DisplayPanel = uipanel(parent, ... % The first argument specifies the 'uifigure' parent to which this panel belongs
                                'Title', 'Output Window', ...   % Hardcoded
                                'BorderColor', 'black', ...
                                'Scrollable', 'on', ...
                                'BackgroundColor', 'white', ...
                                'Position', panelPosition);



                        % Create and configure the display lines for the panel
                        obj.initializeDisplayLines();
                        obj.History = {''}; % Start with an empty entry
                        obj.HistoryIndex = 1;
                        obj.CursorPosition = 1;




                        % Create the input field and define it's function callback
                        % Initialize the input field as an editable text field with text characters accepted as entries.
                        obj.InputExpression = uieditfield(parent, 'text', 'Position', inputFieldPosition, ...
                                'BackgroundColor', [0.9 0.9 0.9], ...
                                'HorizontalAlignment', 'right');


                        % Define the function callbacks
                        obj.InputExpression.ValueChangedFcn = @(src, event) obj.updateInput(src.Value); % Handle input changes
                end




                



                function initializeDisplayLines(obj)
                        %{
                                Initializes the display lines within the main container.
                        %}

                        obj.OccupiedOutputLineCount = 0;
                        obj.OutputLines = gobjects(obj.MAXIMUM_DISPLAY_OUTPUT_LINES, 1); % Initialize MAXIMUM_DISPLAY_OUTPUT_LINES number of lines. Represent output lines as graphical objects, 'gobjects',?
                        for i = 1:obj.MAXIMUM_DISPLAY_OUTPUT_LINES
                                obj.OutputLines(i) = uilabel(obj.DisplayPanel, 'Position', [1, 35 * (i-1), 428, 30], ...
                                        'HorizontalAlignment', 'left', 'FontSize', 14, 'Text', '', 'WordWrap', 'on'); % Setting WordWrap to on breaks text into new lines so that each line fits within the width of the component
                        end
                        obj.updateDisplay();
                end








                function updateInput(obj, newValue)
                        %{
                                Handles updates to the input field, displaying the current value.
                        %}


                        % Update the last line of the display to show the current input
                        if isempty(obj.History) || obj.HistoryIndex == length(obj.History)
                                % If the output lines are all empty or we are currently on the last entry, then update it directly
                                obj.History{end} = newValue;
                        else
                                % Otherwise, add the new value as the latest entry
                                obj.History{end+1} = newValue;
                                obj.HistoryIndex = length(obj.History);
                        end

                        % Ensure the display is updated to reflect the latest input
                        obj.updateDisplay();

                        % Reset the cursor position for editing(unsure?)
                        obj.CursorPosition = length(newValue) + 1;
                end











                function addEntry(obj, entry)
                        % Adds a new entry to the history and updates the display.

                        if obj.HistoryIndex < length(obj.History)
                                obj.History = obj.History(1:obj.HistoryIndex); % Trim forward history if necessary
                        end

                        % Convert the result to string and store
                        solution = num2str(entry);

                        % Format with alignment (same as before)
                        labelWidth = 428; 
                        charWidth = 10;  
                        numSpaces = floor((labelWidth - (length(obj.InputExpression.Value) + length(solution)) * charWidth) / charWidth);
                        formattedResult = [obj.InputExpression.Value, repmat(' ', 1, max(numSpaces, 0)), solution];

                        % Add to history and update index
                        obj.History{end+1} = formattedResult;
                        obj.HistoryIndex = length(obj.History);

                         % Clear the input expression and update the display
                        obj.InputExpression.Value = '';
                        obj.updateDisplay();
                end
  



                function updateDisplay(obj)
                        %{
                                Updates the display to show the history of calculations or the current entry.
                                This method needs to clear the existing text across all lines and repopulate the output lines based 
                                on the history of lines/expressions and the current index.
                        %}

                        % Each time the display is updated, the existing output lines are cleared
                        % and then reinitialized with the old lines up to the most recent line, which is initialized with the current entry
                        set(obj.OutputLines, 'Text', '', 'FontWeight', 'normal', 'BackgroundColor', [0.65 0.65 0.65]);  % Grey


                        % Find the widest expression in the history
                        maxExprLength = 0;      %  Stores the length of the widest expression in the history of output
                        for i = 1:length(obj.History)
                                expression = obj.History{i};
                                exprLength = length(expression);
                                if exprLength > maxExprLength
                                        maxExprLength = exprLength;
                                end
                        end



                        startLine = max(1, obj.HistoryIndex - (obj.MAXIMUM_DISPLAY_OUTPUT_LINES - 1)); % Sets the starting output line to the last, highest index, history line(-4 is because there are 5 lines total, arbitrary and hardcoded)
                        endLine = obj.HistoryIndex;


                        for i = startLine:endLine
                                lineIndex = obj.MAXIMUM_DISPLAY_OUTPUT_LINES - (endLine - i);
                                expression = obj.History{i};
                                % Calculate the number of spaces needed for alignment
                                numSpaces = maxExprLength - length(expression);       % Based on the difference between the length of the widest expression and the length of the current

                                % Format the text with spaces for alignment
                                formattedText = [expression, repmat(' ', 1, numSpaces)];      % Concatenating the expression with the required number of spaces.
                                

                                obj.OutputLines(lineIndex).Text = formattedText; % Set the text of each line


                                % Highlight the most recent entry line
                                if i == obj.HistoryIndex
                                        obj.OutputLines(lineIndex).FontWeight = 'bold';
                                        obj.OutputLines(lineIndex).BackgroundColor =  [0.68, 0.85, 0.9];  % light blue
                                else
                                        obj.OutputLines(lineIndex).FontWeight = 'normal';
                                        obj.OutputLines(lineIndex).BackgroundColor =  [0.875 0.875 0.875];
                                end
                        end
                        obj.OccupiedOutputLineCount = 0;

                end








        end
end








