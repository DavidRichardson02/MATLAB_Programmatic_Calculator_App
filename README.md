# MATLAB Scientific Calculator — Modular UI Library

**Serial‑class, fully‑programmatic calculator built with native MATLAB UI components.**  
Instead of one monolithic `.m` file, every functional area lives in its own class (see diagram below), so you can drop in or extend only the parts you need.



| Core class | Responsibility |
|------------|----------------|
| `CalculatorApp` | Boots the app, creates the main `uifigure`, wires every sub‑module together. |
| `CalculationDisplay` | Scrollable multi‑line output *plus* editable input field with command history. |
| `NumberPad`, `AlphaPad` | Decimal digits, hex digits A‑F, decimal point, negative sign. |
| `ArithmeticOperators` | `+ − × ÷` buttons with expression‑safe callbacks. |
| `TrigonometricFunctions`, `ExponentialLogarithm` | Drop‑down panels for `sin cos tan` and `exp log pow`, auto‑insert `(`. |
| `RelationalSymbols`, `CommonDelimiters` | Comparison (`< > ≤ ≥`) and delimiter (`( ) [ ] { }`) helpers. |
| `ActionButtons` | *del* · *clear* · *enter* · *menu*; runs expression validation before `eval`. |

> **Why modular?**  
> Swap UI skins, embed the engine in a bigger project, or unit‑test components in isolation.

## Features
* **Scientific functions** – trigonometry, exponentials, π, *e*, log, hexadecimal digits.  
* **Robust expression validator** – catches unbalanced delimiters, consecutive/bogus operators, stray decimals.  
* **Command history & scrollable display** – up to 100 prior results, autoscroll to newest.  
* **Drop‑in UI** – no Guide/AppDesigner files; everything is pure code for easy version control.


A calculator app made programmatically in MATLAB. To use this app, create a new blank project in MATLAB, add all of the .m files from this repository to the project files so that they are all in the same folder, 
and then run by either:  (1.) Opening 'CalculatorApp.m' and pressing the run button found in the editor tab, or (2.) type 'myCalculator = CalculatorApp();' in the command window.


              NOTE: Does NOT contain functionality for: any conversion of units, any sort of grid layouts(and by extension automatic 
              space partitions for components and their interface elements, meaning they are positioned by hard coded values here), plus a ton of quality of life stuff.



  



<img width="453" height="656" alt="Screenshot 2025-09-16 at 7 13 07 PM" src="https://github.com/user-attachments/assets/2e1b0af0-a7b6-4108-b50e-599b93f5fb02" />








https://github.com/user-attachments/assets/600ec135-46b4-49e8-812c-c651368e1913





## Quick start
```matlab
>> addpath(genpath(pwd))        % once per session
>> app = CalculatorApp();       % launches GUI



