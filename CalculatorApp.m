%{ 
CalculatorApp class:
      CalculatorApp serves as the main entry point for the calculator application.
      It initializes the application's UI components and aggregates all other
      component classes into a cohesive application structure. This class is
      responsible for creating the main figure window and instantiating all
      calculator components including display, number pad, arithmetic operators,
      action buttons, mathematical constants, and relational symbols.
%}
classdef CalculatorApp
        properties
                MainFigure        % The main figure of the application and master container of all calculator components
                CalculationDisplay        % The output window responsible for rendering user interactions, 
                ActionButtons        % Provide functionality for submitting user-entries to the display and manage the logic for evaluating expressions.
                
                NumberPad        % A container grouping together each of the digits 0-9 as well as a symbol for negatives
                ArithmeticOperators        % Serve as a container for grouping together the basic arithmetic operators as buttons 
                MathematicalConstants        % The most common mathematical constants found on calculators, such as: PI, euler's, etc.
                RelationalSymbols        % Groups together components of the calculator related to comparison based relational symbols
                TrigonometricFunctions         % Serves as a container for encapsulating the various trigonometric operations to be performed
                CommonDelimiters         % A container for providing access to some of the most commonly used delimiters in calculators, things like parentheses, commas, brackets, etc.
                ExponentialLogarithm 
        end

        

%       [Button/Key press] -> Controller(Pad).onPress() -> CalculatorApp.appendToken()
%        -> Display.update() -> (when '=' pressed) CalculatorApp.evaluate()
%        -> ExpressionEngine.evaluate(expr) -> result -> Display.showResult()
%
%   This keeps concerns separate:
%   Adding new buttons (e.g., ln, 10^x) is trivial: create button + appendToken('log(') or wrapper.
%   Expression parsing is centralized and safe (no arbitrary code execution).



        methods
                function app = CalculatorApp()
                        % Initializes the UI and components of the calculator application.
                        app.MainFigure = uifigure('Name', 'Scientific Calculator, MATLAB_Version_02', 'Position', [100, 100, 450, 600]);
                        movegui(app.MainFigure,'center'); 



                        % Instantiate the CalculatorDisplay, which now includes the input field
                        app.CalculationDisplay = CalculationDisplay(app.MainFigure); % Old way of instantiating the CalculatorDisplay
    
                        % Adjust component classes to use CalculatorDisplay for input and display
                        app.NumberPad = NumberPad(app.MainFigure, app.CalculationDisplay.InputExpression);
                        app.ArithmeticOperators = ArithmeticOperators(app.MainFigure, app.CalculationDisplay.InputExpression);
                        app.ActionButtons = ActionButtons(app.MainFigure, app.CalculationDisplay);
                        app.TrigonometricFunctions = TrigonometricFunctions(app.MainFigure, app.CalculationDisplay.InputExpression); 
                        app.ExponentialLogarithm = ExponentialLogarithm(app.MainFigure, app.CalculationDisplay.InputExpression); 
                        app.MathematicalConstants = MathematicalConstants(app.MainFigure, app.CalculationDisplay.InputExpression);
                        app.RelationalSymbols = RelationalSymbols(app.MainFigure, app.CalculationDisplay.InputExpression);
                        app.CommonDelimiters = CommonDelimiters(app.MainFigure, app.CalculationDisplay.InputExpression);



                        % Provide hyperlink to Github repo for this project
                        hlink = uihyperlink(app.MainFigure, 'Text', 'Project Git', ...
                                'URL', 'https://github.com/DavidRichardson02/MATLAB_Calculator_Project/tree/main', ...
                                'Position', [330, 2.5, 100, 50], ...
                                'BackgroundColor', [0.875 0.875 0.875], ...
                                'VisitedColor', [0.4940 0.1840 0.5560], ... 
                                'FontColor', [0 0.3470 0.6410], ...
                                'HorizontalAlignment', 'center'); 
                       
                        hlink.Tooltip = hlink.URL; % Add a tooltip that shows the URL when the app user hovers their pointer over the hyperlink.
                        
                        
                        tb = uitoolbar(app.MainFigure);
                        pt = uipushtool(tb);
                        [img,map] = imread(fullfile(matlabroot,...
                                'toolbox','matlab','icons','matlabicon.gif'));
                        ptImage = ind2rgb(img,map);
                        pt.CData = ptImage;

                
                end








    end
end





%{
TO DO(tennative):
        SHORT TERM:
                - Unit Conversion(all)

                - Incorporate the display's history of output lines to accomodate
                  single entry operations on the previous expression, if it was valid

                - Number system conversion(i.e., binary to decimal, etc.)




        LONG TERM:
                - graphing interface

                - file operations

                - Use the 'CSV_File_Data_Set_Analysis' C program to generate plots
                  and/or MATLAB scripts to plot
%}





