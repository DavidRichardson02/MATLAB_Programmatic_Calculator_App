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
                CalculatorDisplay        % The output window responsible for rendering user interactions, 
                ActionButtons        % Provide functionality for submitting user-entries to the display and manage the logic for evaluating expressions.
                
                NumberPad        % A container grouping together each of the digits 0-9 as well as a symbol for negatives
                ArithmeticOperators        %
                MathematicalConstants        %
                RelationalSymbols        %
        end






        methods
                function app = CalculatorApp()
                        % Initializes the UI and components of the calculator application.
                        app.MainFigure = uifigure('Name', 'Intermediate Scientific Calculator, MATLAB_Version_01', 'Position', [100, 100, 450, 600]);
    
                        % Instantiate the CalculatorDisplay, which now includes the input field
                        app.CalculatorDisplay = CalculatorDisplay(app.MainFigure);
    
                        % Adjust component classes to use CalculatorDisplay for input and display
                        app.NumberPad = NumberPad(app.MainFigure, app.CalculatorDisplay.InputExpression);
                        app.ArithmeticOperators = ArithmeticOperators(app.MainFigure, app.CalculatorDisplay.InputExpression);
                        app.ActionButtons = ActionButtons(app.MainFigure, app.CalculatorDisplay);
                        app.MathematicalConstants = MathematicalConstants(app.MainFigure, app.CalculatorDisplay.InputExpression);
                        app.RelationalSymbols = RelationalSymbols(app.MainFigure, app.CalculatorDisplay.InputExpression);
                end








    end
end










