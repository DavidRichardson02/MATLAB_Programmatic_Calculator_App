%{
ActionButtons class:
      Manages action-oriented buttons such as "del", "Clear", "Enter", and "Menu".
      This class defines functionality for clearing the display and calculating
      expressions, displaying results or error messages directly through the
      CalculatorDisplay component.

        
        Hardcoding used for:
                - The text and name of each action button
                - Assigning the callback function of each action button
                - The positioning of each action button
%}
classdef ActionButtons
        properties
                ParentContainer        % Parent container for the action buttons
                CalculatorDisplay        % Updated to directly interact with CalculatorDisplay
        end






        methods
                function obj = ActionButtons(parent, calculatorDisplay)
                        %{
                                Constructor for ActionButtons class. Initializes action buttons.
                        %}


                        obj.ParentContainer = parent;
                        obj.CalculatorDisplay = calculatorDisplay; % Use CalculatorDisplay for operations


                        % Create action buttons
                        obj.createButtons();
                end








                function createButtons(obj)
                        %{
                                Creates the "del", "Clear", "Enter", and "Menu" buttons and sets their callbacks.
                        %}
                        % Button labels and their positions
                        actionButtons = {'del', 'Clear', 'Enter', 'Menu'};
                        positions = {[250, 275, 30, 30], [75, 275, 80, 30], [162.5, 275, 80, 30], [285, 275, 40, 30]};


                        % Create each button with its label, position, and callback function
                        for i = 1:length(actionButtons)
                                uibutton(obj.ParentContainer, 'Text', actionButtons{i}, 'Position', positions{i}, ...
                                        'ButtonPushedFcn', @(btn, event) obj.handleButtonAction(actionButtons{i}));
                        end
                end








                function handleButtonAction(obj, buttonLabel)
                        switch buttonLabel
                                case 'del'
                                        obj.deleteLastCharacter();
                                case 'Clear'
                                        obj.clearExpression();
                                case 'Enter'
                                        obj.calculateExpression();
                                case 'Menu'
                                        % Code to handle 'Menu' button action
                                otherwise
                                        disp(['Unknown button action: ', buttonLabel]);
                        end
                end








                function deleteLastCharacter(obj)
                        %{
                                Deletes the latest character in the input expression.
                        %}
                        currentExpression = obj.CalculatorDisplay.InputExpression.Value;
                        if ~isempty(currentExpression)
                                % Remove the last character from the expression
                                updatedExpression = currentExpression(1:end-1);
                                obj.CalculatorDisplay.InputExpression.Value = updatedExpression;
                        end
                end








                function clearExpression(obj)
                        %{
                                Clears the input and display in CalculatorDisplay.
                        %}
                        obj.CalculatorDisplay.InputExpression.Value = ''; % Clear input field
                end








                function displayErrorMessage(obj, message)
                        % Displays an error message in a modal dialog box.
                        uialert(obj.ParentContainer, message, 'Error', 'Icon', 'error');
                end








                function delimitersValidity = validateDelimiters(~, expression)
                        % Initialize validity flag
                        delimitersValidity = true;


                        % Check for balanced parentheses
                        if count(expression, '(') ~= count(expression, ')')
                                delimitersValidity = false;
                                disp('Error: Unbalanced parentheses.');
                                return;
                        end


                        % Check for balanced brackets
                        if count(expression, '[') ~= count(expression, ']')
                                delimitersValidity = false;
                                disp('Error: Unbalanced brackets.');
                                return;
                        end


                        % Check for balanced curly brackets
                        if count(expression, '{') ~= count(expression, '}')
                                delimitersValidity = false;
                                disp('Error: Unbalanced curly brackets.');
                                return;
                        end





                        % Check for consecutive parentheses, brackets, curly brackets
                        if ~isempty(regexp(expression, '(\(\)|\[\]|\{\})', 'once'))
                                delimitersValidity = false;
                                disp('Error: Consecutive or empty delimiters.');
                                return;
                        end


                        % Check for unclosed parentheses, brackets, curly brackets
                        unclosedPattern = '(\([^\)]*$)|(\[[^\]]*$)|(\{[^\}]*$)';
                        if ~isempty(regexp(expression, unclosedPattern, 'once'))
                                delimitersValidity = false;
                                disp('Error: Unclosed delimiters.');
                                return;
                        end


                        % Check for closed but empty parentheses, brackets, curly brackets
                        emptyPattern = '(\(\))|(\[\])|(\{\})';
                        if ~isempty(regexp(expression, emptyPattern, 'once'))
                                delimitersValidity = false;
                                disp('Error: Empty delimiters.');
                                return;
                        end




                end








                function operatorsValidity = validateOperators(~, expression)


                        % Initialize validity flag
                        operatorsValidity = true;
                        operators = '+-*/';
                        nOperators = length(operators);

                        %% Check for misuse of operators(can't be first or last, must be preceded by and followed by either a digit or parenthesis)
                        for i = 1:length(expression)
                                if expression(i) == operators(1) ||  expression(i) == operators(2) ||  expression(i) == operators(3) ||  expression(i) == operators(4)
                                        if i == 1 || i == length(expression) % If the operator is the first or last character
                                                operatorsValidity = false;
                                                disp('Error: Invalid use of operators.');
                                                return;
                                        end
                                end
                        end


                        %% Check for consecutive operators of the same kind
                        for i = 1:length(operators)
                                operator = operators(i);
                                if contains(expression, [operator, operator])
                                        operatorsValidity = false;
                                        disp('Error: Consecutive operators (', operator, ').');
                                        return;
                                end
                        end


                        %% Check for consecutive operators of different kinds
                        for i = 1:nOperators
                                for j = 1:nOperators    % For each operator i, loop through all operators j!=i, generate an array with the two operators as elements, and parse the expression to detect occurences of the operator pair
                                        if i ~= j  % Ensure we're pairing different operators
                                                operatorPair = [operators(i), operators(j)];    % Generate each [i,j] pair of different operators for the current operator i

                                                if contains(expression, operatorPair)   % The 'contains' function checks if the current operator pair is found in the input expression
                                                        % If a pair is found operatorsValidity is set to false and an error message with the offending operator pair is displayed before exiting the function
                                                        operatorsValidity = false;
                                                        disp(['Error: Consecutive different operators (' operatorPair ').']);
                                                        return;
                                                end
                                        end
                                end
                        end
                end








                function  isValid = validateExpression(obj, expression)
                        %{

                        %}


                        if isempty(expression)
                                isValid = false;
                                disp('Error: Empty expression.');
                                return;
                        end


                        % Initialize validity flag
                        isValid = true;


                        delimitersValidity = obj.validateDelimiters(expression);
                        if ~delimitersValidity
                                isValid = false;
                                obj.displayErrorMessage('Error: Invalid use of delimiters.');
                                return;
                        end


                        operatorsValidity = obj.validateOperators(expression);
                        if ~operatorsValidity
                                isValid = false;
                                obj.displayErrorMessage('Error: Invalid use of operators.');
                                return;
                        end



                        % Check for valid decimal point usagey
                        digits = '0123456789piexpπ';
                        for i = 1:length(expression)
                                if expression(i) == '.'
                                        if i == 1 || i == length(expression) || ...
                                                        ~ismember(expression(i-1), digits) || ...
                                                        (~ismember(expression(i+1), digits)) % Or if the proceding character is not a digit(and this isn't the last character)
                                                isValid = false;
                                                obj.displayErrorMessage('Error: Invalid use of decimal point.');
                                                disp('Error: Invalid decimal point placement.'); % More detailed error info shown in command window
                                                return;
                                        end
                                end
                        end
                        %}



                end








                function calculateExpression(obj)
                        %{
                                Evaluates the current expression in CalculatorDisplay and displays the result or an error.
                        %}


                        expression = obj.CalculatorDisplay.InputExpression.Value; % Get current expression from CalculatorDisplay
                        isValid = obj.validateExpression(expression);


                        if isValid

                                try
                                        result = eval(expression); % Evaluate expression
                                        obj.CalculatorDisplay.addEntry(num2str(result)); % Display result

                                catch
                                        % Case where the expression was determined to be valid but the MATLAB function, 'eval(expression)', failed
                                        obj.displayErrorMessage('Error: Failed evaluation of valid expression.');
                                end

                        else
                                obj.displayErrorMessage('Error: Invalid Expression.'); % Display error, more detailed error info shown in command window instead of modal dialogue box
                                obj.CalculatorDisplay.InputExpression.Value = ''; % Clear input field
                        end

                end

















        end
end










