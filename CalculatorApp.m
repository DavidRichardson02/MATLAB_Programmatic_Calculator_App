classdef CalculatorApp
    % CalculatorApp serves as the main entry point for the calculator application.
    % It initializes the application's UI components and aggregates all other
    % component classes into a cohesive application structure. This class is
    % responsible for creating the main figure window and instantiating all
    % calculator components including display, number pad, arithmetic operators,
    % action buttons, mathematical constants, and relational symbols.

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
                    app.MainFigure = uifigure('Name', 'Intermediate Calculator', 'Position', [100, 100, 450, 600]);
    
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

%A very simple calculator app made programmatically in MATLAB. To use this app, create a new blank project, add the .m files from this repository to the project files, and then run by either: (1.) Opening 'CalculatorApp.m' and pressing the run button found in the editor tab, or (2.) type 'myCalculator = CalculatorApp();' in the command window.

%This repository is a very simple calculator app made programmatically in MATLAB. To use this app in MATLAB, create a new blank project, add each of the .m files from this repository to the project files, and then run the program by either: (1.) Opening 'CalculatorApp.m' and pressing the run button found in the editor tab, or (2.) type 'myCalculator = CalculatorApp();' in the command window.


%NOTE: the logic for the RelationalSymbols class has not been implemented but the buttons do work.


%ECE370_MATLAB_Calculator_Project

The current latest version of this repository is a very simple uifigure based calculator app made programmatically in MATLAB. NOTE: the logic for the RelationalSymbols class has not been implemented but the buttons do work.
To use this app in MATLAB, create a new blank project, add each of the .m files from this repository to the project files, and then run the program by either: (1.) Opening 'CalculatorApp.m' and pressing the run button found in the editor tab, or (2.) type 'myCalculator = CalculatorApp();' in the command window.

%while this project is open





