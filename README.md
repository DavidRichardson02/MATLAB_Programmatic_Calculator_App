A very simple calculator app made programmatically in MATLAB. To use this app, create a new blank project in MATLAB, add all of the .m files from this repository to the project files so that they are all in the same folder, 
and then run by either:  (1.) Opening 'CalculatorApp.m' and pressing the run button found in the editor tab, or (2.) type 'myCalculator = CalculatorApp();' in the command window.


              NOTE: Does NOT contain functionality for: handling negatives, any trigonometry, any conversion of units, order of operations, intervals, rigorous error management, any sort of grid layouts(and by extension automatic 
              space partitions for components and their interface elements, meaning they are positioned by hard coded values here), plus a ton of quality of life stuff. ALSO, the logic for the RelationalSymbols class's interface 
              components has not been implemented.

  
Overall an extremely rough around the edges calculator app that really shouldn't be used as anything other than a starting point for getting familiar with the MATLAB syntax(especially with regards to interactive apps).
ALSO, the logic for the RelationalSymbols class's interface elements has not been implemented, but the buttons do work.




![Screenshot 2024-02-02 at 4 46 48 AM](https://github.com/DavidRichardson02/MATLAB_Calculator_Project_01/assets/144840390/7ee9317e-bf4c-4817-bf58-8d35d23c5620)







Lastly, while the app is still generally unacceptable, quite a lot of planning and thought went into making an extensible and flexible structure with it's foundation based in the intended core functionalities to be provided, 
which not only make up the roots of the program from which all other branches will emerge, but also introduce problems that can only be satisfied by meeting certain conditions, and in doing so provide guidance for how 
to proceed with any further modularizations based on the nature of the logic and code needed to satisfy each condition relative to the full context of the program. Designed for minimal friction with future developments,
with a few very noteable exceptions, namely: implementing automatically positioned interface components(hardcoded cause it's a bother), using a fundamentally different approach for calculating and displaying the user interactions(too long to go into, I picked this way), etc. ~there's more but im bored, ill probably list some more later if i feel like it.





![Screenshot 2024-02-02 at 2 27 45 AM](https://github.com/DavidRichardson02/MATLAB_Calculator_Project_01/assets/144840390/e478d98c-e826-49a7-9bba-d144c20592a3)
