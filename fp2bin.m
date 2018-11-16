function binary = fp2bin(flpoint, format)
%FP2BIN Convert a floating point number into it's binary representation
%   Detailed explanation goes here

if ( nargin < 1)
    error('No floating point number give!');
end

% Validate the flpoint argument
validateattributes(flpoint, {'single', 'double'}, {'nonempty', 'scalar'}, 'fp2bin', 'flpoint');

if ( nargin == 1 )
    format = 'double';
end

% Validate the format argument
validateattributes(format, {'char'}, {'nonempty'}, 'fp2bin', 'format');

% Remove leading and trailing whitespaces...
format = strtrim(format);

if ( (strcmpi(format, 'single')) || (strcmpi(format, 'float')) )
    % Take the internal function num2hex to convert a single/float value
    % into the corresponding hex notation
    hexValues = num2hex(single(flpoint));
    
    % Now take the hex representation and interprete it as a decimal value
    % and convert this to a binary representation
    binary    = dec2bin(hex2dec(hexValues),32);
    
elseif ( strcmpi(format, 'double') )
    % Take the internal function num2hex to convert a double value
    % into the corresponding hex notation
    hexValues = num2hex(double(flpoint));
    
    % ATTENTION:
    % It is not possible to just do it the same way as for the single/float
    % format! The problem is, that especcially larger values can't be
    % stored accurate enough! hex2dec tries to convert a hex representation
    % (as an integer value!!!) into the double format. Up until 2^53, integer 
    % values can be stored precisely, but from 2^53 the double format will even
    % lose precisions for integers! From 2^53 to 2^54 only the even numbers
    % can be stored. From 2^42 to 2^55 only multiples of 4 can be stored.
    % Than multiples of 8 and so on. Distance between two adjacent numbers
    % in the range between 2^n and 2^(n+1) can be calculated by 2^(n-52)!
    %
    % Solution: 
    % To avoid the previously described circumstance, we can split it into
    % 2x32-bit values!
    
    % Take the internal function num2hex to convert the first 8 hex values
    % to a binary representation y first converting it to an integer and
    % than take it's binary representation
    binary1 = dec2bin(hex2dec(hexValues(1:8)),32);
    % Now do the same thing with the second 32-bit part
    binary2 = dec2bin(hex2dec(hexValues(9:16)),32);
    % Finally, combine both binary representations
    binary = [binary1 binary2];
else
    error('Unknown format: %s', format);
end
end