# MATLAB Scientific Calculator — Modular UI Library


**A serial-class, fully programmatic calculator built with native MATLAB UI components.**
Each functional area is encapsulated in its own class (see table below), enabling you to extend or replace individual modules without touching the rest of the system.

---





## 🧩 Architecture Overview

| Core Class               | Responsibility                                                                          |
| ------------------------ | --------------------------------------------------------------------------------------- |
| `CalculatorApp`          | Entry point — creates the main `uifigure`, lays out the UI, and wires modules together. |
| `CalculationDisplay`     | Unified scrollable output panel and editable input field with command history.          |
| `NumberPad`, `AlphaPad`  | Provide numeric (`0–9`, `.`, `-`) and hexadecimal (`A–F`) input buttons.                |
| `ArithmeticOperators`    | `+  −  ×  ÷` buttons with safe callbacks and symbol normalization.                      |
| `TrigonometricFunctions` | Drop-down panel with `sin`, `cos`, `tan` plus inverse/hyperbolic toggles.               |
| `ExponentialLogarithm`   | Drop-down panel with `exp`, `ln`, `log`, `log10`, auto-inserts `(`.                     |
| `RelationalSymbols`      | Inserts comparison operators: `<  >  ≤  ≥`.                                             |
| `CommonDelimiters`       | Inserts brackets, braces, colons, and commas.                                           |
| `ActionButtons`          | Handles **del / clear / enter / menu**, validates before `eval`.                        |

> **Why modular?**
>
> * Swap out individual modules (pads, rails, display)
> * Reuse the engine in a larger app
> * Unit-test each component in isolation




<br>
<br>


flowchart TD
  A[NumberPad / Operators / Rail Items / Keyboard] -->|append tokens| B[CalculationDisplay.InputExpression (uieditfield)]
  B -->|ValueChangedFcn → live mirroring| C[CalculationDisplay.updateInput(...) ← live “current line”]
  C --> D[[User hits Enter / clicks enter]]
  D --> E[ActionButtons.calculateExpression(...)]
  E --> F[ExpressionEngine.sanitize(raw)]
  F -->|normalize → strip → tokenize → validate → stitch| G(evalStr)
  E --> G
  G --> H[[eval(evalStr)  ↺ can be swapped for pure evaluator]]
  H --> I[CalculationDisplay.addEntry(result)]
  I --> J[CalculationDisplay.updateDisplay() (history + highlight)]


<br>
<br>

  
---


## ✨ Features

* **Scientific functions** — trigonometry, exponentials, logarithms, π, *e*, hex input
* **Robust expression validation** — catches unbalanced delimiters, malformed numbers, invalid operator sequences
* **Command history with scrollable display** — up to 100 previous results; newest entry is automatically highlighted
* **Completely code-based UI** — no `.mlapp` or App Designer files; all layout and styling is done programmatically for version control friendliness

---

## 🚀 Getting Started

1. **Create a new blank MATLAB project** (or use an existing one).
2. **Copy all `.m` files** from this repository into the same project folder.
3. **Run the app** using either of the following:

   * Open `CalculatorApp.m` and press **Run** in the MATLAB Editor, **or**
   * In the Command Window, type:

     ```matlab
     myCalculator = CalculatorApp();
     ```

---

## ⚠️ Notes & Limitations

* Currently **does not support**:

  * Unit conversions
  * Number system conversions
  * Graphing or plotting
* Layout is built with grid containers (`uigridlayout`), but does not yet include:

  * Responsive reflow logic
  * Drag/drop component positioning
* Many additional quality-of-life features are planned but not yet implemented




<br>
<br>


<img width="527" height="701" alt="Screenshot 2025-09-17 at 11 05 41 PM" src="https://github.com/user-attachments/assets/4ef46c81-2c2c-4b65-bd92-014ff16e3283" />



<br>


https://github.com/user-attachments/assets/1b61265a-2bd2-424c-aca5-61bff4e746da


<br>
<br>










