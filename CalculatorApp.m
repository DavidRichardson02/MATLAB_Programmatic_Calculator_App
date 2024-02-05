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
                MainFigure
                CalculatorDisplay
                NumberPad
                ArithmeticOperators
                ActionButtons
                MathematicalConstants
                RelationalSymbols
        end






        methods
                function app = CalculatorApp()
                        % Initializes the UI and components of the calculator application.
                        app.MainFigure = uifigure('Name', 'Intermediate Scientific Calculator, MATLAB_Version_01', 'Position', [100, 100, 450, 600]);
    
                        % Instantiate the CalculatorDisplay, which now includes the input field
                        app.CalculatorDisplay = CalculatorDisplay(app.MainFigure);
    
                        % Adjust component classes to use CalculatorDisplay for input and display
                        app.NumberPad = NumberPad(app.MainFigure, app.CalculatorDisplay.InputExpr);
                        app.ArithmeticOperators = ArithmeticOperators(app.MainFigure, app.CalculatorDisplay.InputExpr);
                        app.ActionButtons = ActionButtons(app.MainFigure, app.CalculatorDisplay);
                        app.MathematicalConstants = MathematicalConstants(app.MainFigure, app.CalculatorDisplay.InputExpr);
                        app.RelationalSymbols = RelationalSymbols(app.MainFigure, app.CalculatorDisplay.InputExpr);
                end








    end
end










