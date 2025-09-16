function outputStr = Conversions(inputString)

    % Define a regular expression pattern to match 'word(characters)'
    pattern = '(\w+)\(([^)]+)\)'; % \w+ matches one or more word characters, 
                                  % \( and \) match the literal parentheses,
                                  % [^)]+ matches one or more characters that are not a closing parenthesis
    
    % Apply the pattern
    
    tokens = regexp(inputString, pattern, 'tokens');
    
    % 'tokens' will be a cell array containing another cell array with matched sub-patterns.
    % If a match is found, extract the function name and the arguments.
    if ~isempty(tokens)
        functionName = tokens{1}{1}; % The function name
        arguments = tokens{1}{2};    % The arguments within the parentheses
        disp(['Function name: ', functionName]);
        disp(['Arguments: ', arguments]);     
        ExtractedStr = [functionName, '(', arguments, ')'];
        if ~ischar(arguments)|any(ismember(arguments, '+-*/^')) %if the argument only contains numbers and/or operators
            ConvertStr = [functionName, '(', num2str(eval(arguments)), ')'];
            ValueStr = simpleConv(ConvertStr);
            inputString = strrep(inputString, ExtractedStr, ValueStr);
        else %if there is a hexadecimal number that is to be converted.
            ConvertStr = [functionName, '(', num2str(arguments), ')'];
            ValueStr = simpleConv(ConvertStr);
            inputString = strrep(inputString, ExtractedStr, ValueStr);
        end
    end

    disp("No More Conversions");
    if startsWith(inputString, '0x')||startsWith(inputString, '0b') %exception for binary and hex as they can't be evaluated.
        result = inputString;
    else
        result = eval(inputString);
    end
    resultStr = num2str(result);
    disp(resultStr);

    outputStr = resultStr;

end


%this function acccepts the conversion and value to be converted
% like dec_bin(10) or ft_m(23)... and returns a string.
function output = simpleConv(inputString)
    if startsWith(inputString, 'bin_dec')
        numberStr = getValueStr(inputString);
        output = num2str(bin2dec(numberStr));
    elseif startsWith(inputString, 'bin_hex')
        numberStr = getValueStr(inputString);
        output = ['0x', (dec2hex(bin2dec(numberStr)))];
    elseif startsWith(inputString, 'dec_bin')
        number = getValue(inputString);
        output = ['0b', num2str(dec2bin(number))];
    elseif startsWith(inputString, 'dec_hex')
        number = getValue(inputString);
        output = ['0x', (dec2hex(number))];
    elseif startsWith(inputString, 'hex_bin')
        numberStr = getValueStr(inputString);
        output = ['0x', num2str(dec2bin(hex2dec(numberStr)))];
    elseif startsWith(inputString, 'hex_dec')
        numberStr = getValueStr(inputString);
        output = num2str(hex2dec(numberStr));
    elseif startsWith(inputString, 'F_C')
        number = getValue(inputString);
        output = num2str(5/9*(number-32));
    elseif startsWith(inputString, 'C_F')
        number = getValue(inputString);
        output = num2str(9/5*number+32);
    elseif startsWith(inputString, 'ft_m')
        number = getValue(inputString);
        output = num2str(number/3.2808);
    elseif startsWith(inputString, 'm_ft')
        number = getValue(inputString);
        output = num2str(number*3.2808);
    elseif startsWith(inputString, 'inch_cm')
        number = getValue(inputString);
        output = num2str(number*2.54);
    elseif startsWith(inputString, 'cm_inch')
        number = getValue(inputString);
        output = num2str(number/2.54);
    elseif startsWith(inputString, 'lb_kg')
        number = getValue(inputString);
        output = num2str(number*0.453592);
    elseif startsWith(inputString, 'kg_lb')
        number = getValue(inputString);
        output = num2str(number/0.453592);
    elseif startsWith(inputString, 'floz_L')
        number = getValue(inputString);
        output = num2str(number*0.02841);
    elseif startsWith(inputString, 'floz_gal')
        number = getValue(inputString);
        output = num2str(number*0.0078125);
    elseif startsWith(inputString, 'L_floz')
        number = getValue(inputString);
        output = num2str(number/0.02841);
    elseif startsWith(inputString, 'L_gal')
        number = getValue(inputString);
        output = num2str(number*0.264172);
    elseif startsWith(inputString, 'gal_fl.oz')
        number = getValue(inputString);
        output = num2str(number/0.0078125);
    elseif startsWith(inputString, 'gal_L')
        number = getValue(inputString);
        output = num2str(number/0.264172);
    elseif startsWith(inputString, 'ftlb_Nm')
        number = getValue(inputString);
        output = num2str(number*1.355818);
    elseif startsWith(inputString, 'Nm_ftlb')
        number = getValue(inputString);
        output = num2str(number/1.355818);
    else
        output = inputString;
    end
end

function numberStr = getValueStr(inputString)
            % Use regular expressions to extract the number between parentheses
            pattern = '\((.*?)\)'; % The parentheses in the pattern are escaped
            tokens = regexp(inputString, pattern, 'tokens');
            
            % Check if a number was found and perform the operation
            if ~isempty(tokens)
                % Extract the number string and convert to a double
                numberStr = tokens{1}{1};
                disp(numberStr);
                disp(numberStr);
                disp(numberStr);
            else
                % If no number was found, return an error message
                numberStr = '0';
                return
            end
end

function number = getValue(inputString)
            % Use regular expressions to extract the number between parentheses
            pattern = '\((.*?)\)'; % The parentheses in the pattern are escaped
            tokens = regexp(inputString, pattern, 'tokens');
            
            % Check if a number was found and perform the operation
            if ~isempty(tokens)
                % Extract the number string and convert to a double
                numberStr = tokens{1}{1};
                number = str2double(numberStr);
            else
                % If no number was found, return an error message
                number = 0;
                return
            end
end
