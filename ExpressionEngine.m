% ===================================================
% ExpressionEngine 
% ===================================================
classdef ExpressionEngine
    % ExpressionEngine
    %   Converts UI-friendly math text into eval-safe MATLAB math.
    %     
    %  - Normalizes UI glyphs to MATLAB syntax (•, ÷, ≥, ≤, π, ln, √, etc.)
    %  - Strips whitespace
    %  - Tokenizes and validates expression grammar
    %  - Inserts implicit multiplication (e.g., 2π, 2(3+4), (2)(3))
    %  - Produces an eval-ready string
    % 
    % 
    %   Pipeline in sanitize():
    %     1) normalizeSymbols   — map glyphs (÷ ≥ ≤ π ln √ φ …) to ASCII / MATLAB
    %     2) stripWhitespace    — remove spaces/tabs/newlines
    %     3) tokenize           — NUM/ID/OP/CMP/L/R/COMMA stream using regex
    %     4) validateBalanced   — parentheses / bracket matching
    %     5) validateTokens     — whitelist IDs and basic numeric sanity
    %     6) validateOperators  — context rules for operators/comparisons
    %     7) stitch             — rebuild final eval string (constants if needed)
    %
    % Usage:
    %   eng = ExpressionEngine();
    %   [ok, evalStr, msg] = eng.sanitize(rawStr);
    %   if ok
    %       result = eval(evalStr);  % or your own evaluator
    %   else
    %       uialert(parentFigure, msg, 'Error');
    %   end

    properties (Constant, Access=private)
        % Allowed ASCII operators after normalization
        BinOps = {'+','-','*','/','^'};

        % Delimiters considered
        LeftDelims  = {'(','[','{'};
        RightDelims = {')',']','}'};

        % Valid comparison operators (after normalization)
        % (Parsing CMP is optional; normalization future-proofs.)
        CmpOps = {'==','~=','<=','>=','<','>'};

        % Whitelisted function names (extend as needed)
        % NOTE: 'log' is natural log in MATLAB. 'ln(' is normalized to 'log('.
        Funcs = {'sin','cos','tan','asin','acos','atan', ...
                 'sinh','cosh','tanh','asinh','acosh','atanh', ...
                 'sqrt','log','log10','log2','exp','abs','floor','ceil','round'};

        % Whitelisted constants/identifiers (extend as needed)
        % 'phi' will be stitched to (1+sqrt(5))/2 if it survives tokens.
        Consts = {'pi','i','j','phi','ans'};
    end

    methods
        function [ok, evalStr, msg] = sanitize(obj, raw)
            % Full pipeline: normalize -> strip -> tokenize -> validate -> stitch
            msg = '';
            try
                s = obj.normalizeSymbols(raw);
                s = obj.stripWhitespace(s);
                [tokens, kinds] = obj.tokenize(s);

                % High-level validations
                obj.validateBalanced(tokens, kinds);
                obj.validateTokens(tokens, kinds);
                obj.validateOperators(tokens, kinds);

                % Recompose final string
                evalStr = obj.stitch(tokens, kinds);
                ok = true;

            catch ME
                ok = false;
                evalStr = '';
                msg = ME.message;
            end
        end
    





function [ok, value, msg, printableExpr] = evaluate(obj, raw, model)
% EVALUATE  Phase-0 front door: normalize → tokenize → implicit mult
%           → assignment/variables → deg/rad → safe eval
    msg = ''; printableExpr = '';
    
    try
        % 1) Normalize and strip
        s = obj.normalizeSymbols(raw);
        s = obj.stripWhitespace(s);

        % 2) Tokenize + basic validations (yours)
        [toks, kinds] = obj.tokenize(s);
        obj.validateBalanced(toks, kinds);
        obj.validateTokens(toks, kinds);
        obj.validateOperators(toks, kinds);

        % 3) Insert implicit multiplication (2pi, 2(3+4), (2)(3), pi(2+3), etc.)
        %[toks, kinds] = obj.insertImplicitMultiplication(toks, kinds);

        % 4) Detect assignment:   <name> '=' <expr>
        meta = obj.detectAssignment(toks, kinds);

        % 5) Rewrite identifiers for variables & constants; wrap trig for deg
        expr = obj.buildExpressionString(toks, kinds, model, meta);

        printableExpr = expr;   % what gets shown in history as the "expr" column
        printableExpr = char(expr);  % ensure char for any downstream use


        % 6) Evaluate in a SAFE scope: only whitelisted funcs + provided vars
        value = obj.safeEval(expr, model);

        % 7) Persist vars / ans
        if meta.isAssignment
            model.Vars.(meta.name) = value;
        end
        model.Vars.ans = value;

        ok = true;

    catch ME
        ok = false;
        value = [];
        msg = ME.message;
    end
end





function [t2,k2] = insertImplicitMultiplication(obj, t, k)
    isValL     = @(kk) (kk=="NUM") | (kk=="ID") | (kk=="R");
    isStartR   = @(kk) (kk=="NUM") | (kk=="ID") | (kk=="L");
    isFuncAt   = @(idx) (k{idx}=="ID") && (idx<numel(t)) && k{idx+1}=="L" ...
                        && ismember(t{idx}, obj.Funcs);

    outT = {}; outK = {};
    for i = 1:numel(t)
        outT{end+1} = t{i}; outK{end+1} = k{i}; %#ok<AGROW>
        if i < numel(t) && isValL(k{i}) && isStartR(k{i+1})
            % Insert unless it's a known function call like sin(
            if ~(k{i}=="ID" && k{i+1}=="L" && isFuncAt(i))
                outT{end+1} = '*'; outK{end+1} = "OP"; %#ok<AGROW>
            end
        end
    end
    t2 = outT; k2 = outK;
end



function meta = detectAssignment(~, t, k)
    meta = struct('isAssignment',false,'name','','rhsIdx',1);
    if numel(t) >= 3 && k{1}=="ID" && strcmp(t{2},'=')
        meta.isAssignment = true;
        meta.name = t{1};
        meta.rhsIdx = 3;
    end
end







function expr = buildExpressionString(obj, t, k, model, meta)
    % Convert token stream back to a string expression with:
    %  - user variables: unknown IDs become model.Vars.<id>
    %  - constants: pi stays pi; i/j stay i/j; phi already expanded earlier
    %  - degree mode: wrap sin/cos/tan/asin/acos/atan appropriately
    %
    % We'll rebuild once while applying rules. We only process RHS if assignment.
    startIdx = meta.rhsIdx;
    funs = obj.Funcs;            % from your whitelist
    consts = obj.Consts;         % pi, i, j, phi
    deg = strcmpi(model.AngleMode,'deg');

    out = strings(1,0);

    i = startIdx;
    while i <= numel(t)
        tok = t{i}; kind = k{i};

        if kind == "ID"
            id = tok;

            % Function call? (ID followed by '(')
            if i < numel(t) && k{i+1} == "L"
                % Degree-mode wrappers:
                if deg && any(strcmp(id, {'sin','cos','tan'}))
                    out(end+1) = id + '((pi/180)*';  % open extra paren
                    % We'll rely on the existing right ')' to close; add one more at the very end.
                    % Track balance:
                    [i, out] = emitCallBody(out, t, k, i+2);   % i currently at ID, i+1 is '('
                    out(end+1) = ')';  % close our wrapper
                    continue
                elseif deg && any(strcmp(id, {'asin','acos','atan'}))
                    % asin(x) -> (180/pi)*asin(x)
                    out(end+1) = '(180/pi)*' + id + '(';
                    [i, out] = emitCallBody(out, t, k, i+2);
                    out(end+1) = ')';
                    continue
                else
                    % Normal function call
                    out(end+1) = id + '(';
                    [i, out] = emitCallBody(out, t, k, i+2);
                    out(end+1) = ')';
                    continue
                end
            end

            % Not a function. If not a constant or whitelisted, treat as variable.
            if ~ismember(id, [funs consts "ans"])
                id = "model.Vars." + id;  % variable reference
            end
            out(end+1) = string(id);

        else
            % All other tokens as-is (ops, numbers, delimiters, commas, comparisons)
            out(end+1) = string(tok);
        end

        i = i + 1;
    end

    expr = strjoin(out, "");
    expr = char(expr);           % <- add this line



    % ---- helpers ----
    function [j, outS] = emitCallBody(outS, T, K, j)
        % Emits tokens until the matching ')' is consumed. Assumes T{j-1} was '('.
        depth = 1;
        while j <= numel(T)
            tok2 = T{j}; kind2 = K{j};
            if kind2=="L", depth = depth + 1; end
            if kind2=="R", depth = depth - 1; end
            outS(end+1) = string(tok2); %#ok<AGROW>
            if kind2=="R" && depth==0, break; end
            j = j + 1;
        end
    end
end






function val = safeEval(obj, expr, model)
% Evaluate expression with a restricted function environment


    % Ensure char vector, not string scalar
    if isstring(expr), expr = char(expr); end   


    % Whitelist math function handles (pull from your whitelist)
    wh = model.Vars;
    % Core ops will be parsed directly; functions needed:
    for f = obj.Funcs
        wh.(f{1}) = str2func(f{1});
    end
    % Constant i/j
    i = 1i; j = 1i; %#ok<NASGU,ASGLU> 
    pi = builtin('pi'); %#ok<NASGU>

    % Evaluate in a local function workspace so only whitelisted names + model exist
    val = eval(expr);   %#ok<EVLDIR> % still eval, but scope-limited to locals
    % NOTE: expr refers to things like sin, cos, sqrt, model.Vars.x, etc.
end






    
    %% === Normalization ===
    %methods (Access=private)
        function s = normalizeSymbols(~, s)
            % Map UI glyphs / aliases to MATLAB equivalents
            % arithmetic
            s = strrep(s, '•', '*');
            s = strrep(s, '∙', '*');
            s = strrep(s, '×', '*');
            s = strrep(s, '÷', '/');
            s = strrep(s, '−', '-'); % unicode minus -> ASCII minus

            % comparisons
            s = strrep(s, '≥', '>=');
            s = strrep(s, '≤', '<=');
            s = strrep(s, '≠', '~=');

            % constants / functions
            s = strrep(s, 'π', 'pi');
            % ln( -> log(
            s = regexprep(s, '\bln\s*\(', 'log(');

            % sqrt / radical forms:
            % basic: just treat '√' like 'sqrt', user should add '(' via button
            % ex: "√(" -> "sqrt("
            s = strrep(s, '√', 'sqrt');


            % golden ratio symbol -> explicit expression
            s = strrep(s, 'φ', '(1+sqrt(5))/2');

            % optional: normalize commas within numbers like "1,234" -> "1234"
            % (commented; use only if you want to allow localized grouping)
            % s = regexprep(s, '(?<=\d),(?=\d{3}\b)', '');
        end

        function s = stripWhitespace(~, s)
            s = regexprep(s, '\s+', '');
        end
    %end



    %% === Tokenization ===
    %methods (Access=private)
        function [toks, kinds] = tokenize(~, s)
            % Token categories:
            %  NUM:   integer/decimal/scientific: 12, .5, 5., 1.2e-3
            %  ID:    identifiers (function names, constants)
            %  OP:    + - * / ^
            %  CMP:   == ~= <= >= < >
            %  L/R:   ( ) [ ] { }
            %  COMMA: ,
            if isempty(s)
                error('Expression is empty.');
            end

            % Build a regex that captures at most one token at a time
            num    = '(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][\+\-]?\d+)?';
            id     = '[A-Za-z_]\w*';
            cmp    = '==|~=|<=|>=|<|>';
            op     = '[\+\-\*\/\^]';
            ldelim = '[\(\[\{]';
            rdelim = '[\)\]\}]';
            comma  = ',';

            master = ['(' num ')|(' id ')|(' cmp ')|(' op ')|(' ldelim ')|(' rdelim ')|(' comma ')'];

            toks = {};
            kinds = {};
            i = 1;
            while i <= strlength(s)
                str = extractBetween(s, i, strlength(s));
                str = str{1};
                m = regexp(str, ['^' master], 'once', 'tokens');
                if isempty(m)
                    badChar = extractBetween(s, i, i);
                    error('Invalid token starting at "%s" (position %d).', badChar{1}, i);
                end

                % Determine which alt matched
                alts = m;
                % alts: {num, id, cmp, op, l, r, comma}
                if ~isempty(alts{1}), toks{end+1} = alts{1}; kinds{end+1} = "NUM";
                elseif ~isempty(alts{2}), toks{end+1} = alts{2}; kinds{end+1} = "ID";
                elseif ~isempty(alts{3}), toks{end+1} = alts{3}; kinds{end+1} = "CMP";
                elseif ~isempty(alts{4}), toks{end+1} = alts{4}; kinds{end+1} = "OP";
                elseif ~isempty(alts{5}), toks{end+1} = alts{5}; kinds{end+1} = "L";
                elseif ~isempty(alts{6}), toks{end+1} = alts{6}; kinds{end+1} = "R";
                elseif ~isempty(alts{7}), toks{end+1} = alts{7}; kinds{end+1} = "COMMA";
                else
                    error('Unrecognized token at position %d.', i);
                end

                % Advance index by matched token length
                i = i + strlength(toks{end});
            end
        end
    %end




    
    %% === Validation ===
    %methods (Access=private)
        function validateBalanced(obj, toks, kinds)
            % Balanced (), [], {}
            stack = strings(0);
            for k = 1:numel(toks)
                if kinds{k} == "L"
                    stack(end+1) = toks{k}; %#ok<AGROW>
                elseif kinds{k} == "R"
                    if isempty(stack), error('Unbalanced delimiters: extra closing "%s".', toks{k}); end
                    open = stack(end); stack(end) = [];
                    if ~obj.matchedPair(open, toks{k})
                        error('Mismatched delimiters: "%s" closed by "%s".', open, toks{k});
                    end
                end
            end
            if ~isempty(stack)
                error('Unbalanced delimiters: missing closing for "%s".', stack(end));
            end
        end





        function tf = matchedPair(~, l, r)
            pairs = struct('(',')','[',']','{','}');
            tf = isfield(pairs, l) && strcmp(pairs.(l), r);
        end





        function validateTokens(obj, toks, kinds)
            % Validate identifiers (functions/constants), and simple number sanity
            for k = 1:numel(toks)
                switch kinds{k}
                    case "ID"
                        id = toks{k};
                        if ~ismember(id, [obj.Funcs, obj.Consts])
                            % allow 'ans' if you plan to support it:
                            if ~strcmp(id,'ans')
                                error('Unknown identifier "%s".', id);
                            end
                        end
                    case "NUM"
                        % reject numbers with consecutive dots (shouldn't happen due to regex)
                        if contains(toks{k}, '..')
                            error('Malformed number near "%s".', toks{k});
                        end
                end
            end
        end




        function validateOperators(~, toks, kinds)
            % Contextual operator rules (after normalization)
            % - Allow leading unary '-' (but not +,*,/,^)
            % - No binary operator immediately after binary operator (except unary - handling)
            % - No operator right before a right delimiter
            % - No operator right after a left delimiter (except unary '-')
            % - Expression cannot end with binary operator
            if isempty(toks), error('Empty expression.'); end

            isOp = @(k) kinds{k}=="OP";
            isCmp= @(k) kinds{k}=="CMP";
            isL  = @(k) kinds{k}=="L";
            isR  = @(k) kinds{k}=="R";
            isNum= @(k) kinds{k}=="NUM";
            isId = @(k) kinds{k}=="ID";
            isVal= @(k) isNum(k) || isId(k) || isR(k); % value-like on the left side of a binop

            % Leading token
            if isOp(1)
                if ~strcmp(toks{1}, '-')  % unary minus allowed
                    error('Expression cannot start with operator "%s".', toks{1});
                end
            elseif isCmp(1)
                error('Expression cannot start with comparison "%s".', toks{1});
            end

            % Walk through tokens and enforce context
            for k = 1:numel(toks)
                if isOp(k)
                    op = toks{k};
                    if k == numel(toks)
                        error('Expression cannot end with operator "%s".', op);
                    end
                    % Previous must be a value (unless this is unary '-')
                    if strcmp(op,'-')
                        if k==1 || isL(k-1) || isOp(k-1) || isCmp(k-1) || kinds{k-1}=="COMMA"
                            % treat as unary minus -> ok
                        else
                            % binary '-': requires a value on the left
                            if ~isVal(k-1)
                                error('Operator "-" in invalid position.');
                            end
                        end
                    else
                        % other binary ops require a value on the left and non-right-delim on right
                        if k==1 || ~isVal(k-1)
                            error('Binary operator "%s" in invalid position.', op);
                        end
                        if k<numel(toks) && (isOp(k+1) || isCmp(k+1) || isR(k+1) || kinds{k+1}=="COMMA")
                            error('Invalid token after operator "%s".', op);
                        end
                    end
                elseif isCmp(k)
                    % Comparisons are binary and cannot chain with ops improperly
                    if k==1 || k==numel(toks) || ~isVal(k-1)
                        error('Comparison "%s" in invalid position.', toks{k});
                    end
                    if k<numel(toks) && (isOp(k+1) || isCmp(k+1) || isR(k+1) || kinds{k+1}=="COMMA")
                        error('Invalid token after comparison "%s".', toks{k});
                    end
                elseif isL(k)
                    % next cannot be a binary operator or comparison (but can be unary '-')
                    if k<numel(toks) && ( (isOp(k+1) && ~strcmp(toks{k+1},'-')) || isCmp(k+1) || kinds{k+1}=="COMMA" )
                        error('Invalid token after "%s".', toks{k});
                    end
                elseif isR(k)
                    % prev cannot be operator/comparison/comma/left-delim
                    if k>1 && (isOp(k-1) || isCmp(k-1) || kinds{k-1}=="COMMA" || isL(k-1))
                        error('Invalid token before "%s".', toks{k});
                    end
                end
            end
        end
    








    %% === Stitch back to eval-ready ===
    %methods (Access=private)
        function out = stitch(obj, toks, kinds)
            % Convert identifiers that stand for constants where needed.
            % Example: keep 'pi' as is; leave functions and numbers unchanged.
            outParts = strings(1, numel(toks));
            for k = 1:numel(toks)
                tk = toks{k};
                kd = kinds{k};

                if kd == "ID"
                    % If 'phi' remained, replace with explicit value
                    if strcmp(tk,'phi')
                        tk = '(1+sqrt(5))/2';
                    end
                end

                outParts(k) = string(tk);
            end
            out = strjoin(outParts, "");
        end
 end

end


