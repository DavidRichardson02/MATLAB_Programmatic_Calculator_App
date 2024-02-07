%{ 
CalculatorDisplay class:
      Manages both the display for calculation results and the editable text field
      CalculatorDisplay manages a multi-line display for the calculator.
      This class supports multiple lines for user entries and results, with new entries appearing
      at the bottom and previous entries moving up. It also includes a directional pad
      for navigating through the entries and editing them.
%}
classdef CalculatorDisplay < handle
        properties
                DisplayPanel        % Main container for grouping together the display elements in a panel
                OutputLines        % Array of label components for each display line
                History        % History of calculations and inputs
                HistoryIndex        % Current index in the history for navigation
                CursorPosition        % Position of the cursor in the current input
                InputExpression        % Editable text field for user input
        end
    





        methods
                function obj = CalculatorDisplay(parent)
                        %{                              
                                Initializes the display area, input field within the given parent UI component, and the directional pad for navigation.
                        %}  


                         obj.DisplayPanel = uipanel(parent, ...
                                 "Title", "Output Window", ...
                                 "BorderColor", "black", ...
                                 "Scrollable","on", ...
                                 "BackgroundColor", "white", 'Position', [10, 400, 430, 190]);


                        
                        obj.initializeDisplayLines();
                        obj.History = {''}; % Start with an empty entry
                        obj.HistoryIndex = 1;
                        obj.CursorPosition = 1;


                        % Initialize directional pad and the input field 
                        obj.initializeDirectionalPad(parent);
                        obj.createInputField(parent); 
                end
        







                function createInputField(obj, parent)
                        %{                              
                                Creates an editable text field for user input.
                        %}  


                        obj.InputExpression = uieditfield(parent, 'text', 'Position', [10, 10, 400, 30], 'HorizontalAlignment', 'right');
                        obj.InputExpression.ValueChangedFcn = @(src, event) obj.updateInput(src.Value); % Optional: Handle input changes
                end
      







                function updateInput(obj, newValue)
                        %{                              
                                Handles updates to the input field, displaying the current value.
                                This method can be extended to include validation or immediate calculations.
                        %}  

    
                        % Update the last line of the display to show the current input
                        if isempty(obj.History) || obj.HistoryIndex == length(obj.History)
                                % If we're currently on the last entry, update it directly
                                obj.History{end} = newValue;
                        else
                                % Otherwise, add the new value as the latest entry
                                obj.History{end+1} = newValue;
                                obj.HistoryIndex = length(obj.History);
                        end
    
                        % Ensure the display is updated to reflect the latest input
                        obj.updateDisplay();
    
                        % Optionally, reset the cursor position for editing
                        obj.CursorPosition = length(newValue) + 1;
                end

        
        





                function initializeDisplayLines(obj)
                        %{                              
                                Initializes the display lines within the main container.
                        %}  


                        obj.OutputLines = gobjects(5, 1); % Assuming 5 lines for simplicity
                        for i = 1:5
                                obj.OutputLines(i) = uilabel(obj.DisplayPanel, 'Position', [1, 35 * (i-1), 428, 30], ...
                                                        'HorizontalAlignment', 'left', 'FontSize', 14, 'Text', '');
                        end
                        obj.updateDisplay();
                end
        







                function initializeDirectionalPad(obj, parent)
                        %{                              
                                Initializes directional pad buttons for navigation and editing.
                        %}  


                        directions = {'up', 'down', 'left', 'right'};
                        positions = {[330, 105, 30, 30], [330, 75, 30, 30], [300, 75, 30, 30], [360, 75, 30, 30]};
                        for i = 1:4
                                uibutton(parent, 'Text', directions{i}, 'Position', positions{i}, ...
                                        'ButtonPushedFcn', @(btn,event) obj.handleDirection(directions{i}));
                        end
                end
        







                function handleDirection(obj, direction)
                        %{                              
                                Handles directional input from the user for navigation and editing.
                        %}  


                        switch direction
                                case 'up'
                                        obj.HistoryIndex = max(1, obj.HistoryIndex - 1);
                                case 'down'
                                        obj.HistoryIndex = min(length(obj.History), obj.HistoryIndex + 1);
                                case 'left'
                                        obj.CursorPosition = max(1, obj.CursorPosition - 1);
                                case 'right'
                                        currentEntry = obj.History{obj.HistoryIndex};
                                        obj.CursorPosition = min(length(currentEntry) + 1, obj.CursorPosition + 1);
                        end
                        obj.updateDisplay();
                end
                







                function updateDisplay(obj)
                        %{                              
                                Updates the display to show the history of calculations or the current entry.
                                This method needs to clear the existing text and repopulate it based on the history
                                and the current index.
                        %}  


                        set(obj.OutputLines, 'Text', ''); % Clear all lines
                        startLine = max(1, obj.HistoryIndex - 4);
                        endLine = obj.HistoryIndex;
                        for i = startLine:endLine
                                lineIndex = 5 - (endLine - i);
                                obj.OutputLines(lineIndex).Text = obj.History{i};
                        end
                end








                function displayResult(obj, expression, result)
                        %{                              
                                Displays the calculation result in the format: expression = result
                                This method is intended to be called after a calculation is performed.
                        %}  


                        formattedResult = [expression, ' = ', num2str(result)];
                        obj.addEntry(formattedResult);
                end







                
                function addEntry(obj, entry)
                        %{                              
                                Adds a new entry to the history and updates the display.
                        %}  

            
                        if obj.HistoryIndex < length(obj.History)      % If not at the end of the history, trim any forward history
                                obj.History = obj.History(1:obj.HistoryIndex);
                        end

                        % Format the display string to show "input = result"
                        formattedResult = [obj.InputExpression.Value, ' = ', num2str(entry)];
                        
                        % Add the formatted string to the history
                        obj.History{end+1} = formattedResult;


                        % Update the index to point to the latest entry
                        obj.HistoryIndex = length(obj.History);

            
                        % Ensure the display is updated to show the latest entry
                        obj.updateDisplay();
                end







                
    end
end










