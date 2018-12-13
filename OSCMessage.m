classdef OSCMessage < handle
    %OSC Message Simple MATLAB implementation of the OSC Message format
    % 
    % See http://opensoundcontrol.org/node/3/ for an overview of the structure
    % of an OSCMessage
    %
    % --------------------------------------------------------------------------
    % Author:  Michael Wulf
    %          Cold Spring Harbor Laboratory
    %          Kepecs Lab
    %          One Bungtown Road
    %          Cold Spring Harboor
    %          NY 11724, USA
    %
    % Date:    12/13/2018
    % Version: 1.0.1
    % --------------------------------------------------------------------------
    
    properties (GetAccess = public, SetAccess = protected)
        address       = '';      % OSC address
        typeTagList   = cell(0); % List of TypeTags
        attributeList = cell(0); % List of attributes
    end
    
    methods
        function obj = OSCMessage(varargin)
            %OSCMESSAGE Construct an instance of this class
            
            if (nargin == 0)
                % Empty OSCMessage...
                
            elseif (nargin == 1)
                % OSCMessage as byte array specified
                byteArray = varargin{1};
                
                validateattributes(byteArray, {'uint8'}, {'vector'}, 'OSCMessage', 'byteArray');
                
                % Check that byteArray is a row vector!
                if (size(byteArray, 1) > 1)
                    byteArray = byteArray';
                end
                
                % Get address out of the byteArray
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Find position of the slash
                idSlash = find(byteArray == '/', 1);
                
                if (isempty(idSlash))
                    error('Specified byteArray does not contain the OSC message start symbol ''/''!');
                end
                
                if (idSlash == 1)
                    dataLength = length(byteArray); %#ok<NASGU>
                    
                elseif (idSlash > 1)
                    % Check if something was sent before the slash -> message lengt?!?
                    
                    % Take the bytes before the slash
                    temp = byteArray(1:(idSlash-1));
                    
                    % Convert these single bytes to an integer by first
                    % converting them to a hex-char array...it to hex
                    temp = dec2hex(temp,2);
                    temp = sprintf('%s', temp);
                    dataLength = hex2dec(temp);
                    
                    msgLen = length(byteArray-idSlash+1);
                    
                    if ( dataLength > msgLen )
                        warning('Specified data length to high!');
                        dataLength = msgLen; %#ok<NASGU>
                    end
                    
                    % Remove everything before the slash...
                    % If a length (or what so ever) is sent before the
                    % address, the value could also be the ascii number of
                    % the ',' (TzpeTag)...
                    byteArray = byteArray(idSlash:end);

                else
                    error('Unsopported OSC message format! Slash position > 5?!?');
                end
                
                % Find the position of Type Tag idicator ','
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                idTypeTag = find(byteArray == ',', 1);
                
                if ( isempty(idTypeTag) )
                    % Just address
                    obj.address = char(byteArray(1:end));
                    % Remove all zero elements in the string
                    obj.address = erase(obj.address, char(0));
                    return;
                else
                    % Take out the address of the byte array
                    obj.address = char(byteArray(2:(idTypeTag-1)));
                    % Remove possible zero elements...
                    obj.address = erase(obj.address, char(0));
                end
                
                % Remove everything before the Type Tag...
                byteArray = byteArray(idTypeTag:end);
                
                % Find the first zero element!
                idFirstZero = find(byteArray == 0, 1);
                
                if (idFirstZero == 2)
                    %no data given!
                    return;
                else
                    % The length of the type Tag portion (including ',' and
                    % null-terminating character) must be a multiple of 4
                    % bytes!
                    
                    % First, calculate the modulo value of 4
                    moduloValue = mod(idFirstZero, 4);
                    
                    if ( moduloValue == 0 )
                        % If the position of the first null-character is a
                        % mutliple of 4, the follwing byte belongs already to
                        % the data portion of the message...
                        idFirstDataByte = idFirstZero + 1;
                    else
                        % If the modulo value is not a multiple of 4, we
                        % have to take additional bytes before reaching the
                        % data portion...
                        idFirstDataByte = idFirstZero + (4 - moduloValue) + 1;
                    end
                    
                    if ( idFirstDataByte > length(byteArray) )
                        error('OSC message has a worng format! Type Tags specified but no data transmitted!');
                    end
                end
                
                % Get the Type Tags
                typeTags = byteArray(2:idFirstZero-1);
                
                if isempty(typeTags)
                    error('Error while processing OSC message. OSC message has a wrong format!');
                end
                
                for cntr = 1:1:length(typeTags)
                    try
                        % Cast the current byte as an uint8 value and use this
                        % to get the corresponding OSCType from the enum class
                        % OSCTypes!
                        obj.typeTagList = [obj.typeTagList {OSCTypes(uint8(typeTags(cntr)))}];
                    catch
                        error('Unknown OSC Type Tag %s', typeTags(cntr));
                    end
                end
                
                % remove everything except the data portion...
                byteArray = byteArray(idFirstDataByte:end);
                
                for cntr = 1:1:length(obj.typeTagList)
                    % Get number of remaining bytes
                    remainingBytes = length(byteArray);
                    
                    % Get next OSC Type Tag
                    currType = obj.typeTagList{cntr};
                    
                    % Get size of Type Tag
                    numBytes = double(OSCTypeSize(currType.char));
                    
                    newAttribute = [];
                    % Every OSC-type has a fix length - except a string!
                    if (currType ~= OSCTypes.OscString)
                        if (numBytes > remainingBytes)
                            error('OSC message frame format error! Not enough bytes left...!');
                        end
                        
                        % Take the bytes of the current type out of the array
                        bytes = byteArray(1:numBytes);
                        
                        switch (currType)
                            case OSCTypes.Int32
                                % 32-bit two's complement integer (int32, big-endian!)
                                
                                %sign = 1;
                                %if (bytes(1) >= 128)
                                %    sign = -1;
                                %    bytes(1) = bytes(1)-128;
                                %end
                                %temp = int32(hex2dec(sprintf('%02x', bytes)));
                                %if (sign == -1)
                                %    temp = temp - (2^31);
                                %end
                                %newAttribute = int32(temp);
                                newAttribute = typecast(fliplr(bytes), 'int32');
                                
                            case OSCTypes.Int64
                                % 64-bit two's complement integer (int64, big-endian!)
                                
                                %sign = 1;
                                %if (bytes(1) >= 128)
                                %    sign = -1;
                                %    bytes(1) = bytes(1)-128;
                                %end
                                %temp = int64(hex2dec(sprintf('%02x', bytes)));
                                %if (sign == -1)
                                %    temp = temp - (2^63);
                                %end
                                %newAttribute = int64(temp);
                                newAttribute = typecast(fliplr(bytes), 'int64');
                                
                            case OSCTypes.Float32
                                % 32-bit single precision floating point numbers
                                
                                % temp = uint8(sscanf(num2hex(single(0.5)), '%2x'))'
                                % typecast(temp, 'single')
                                newAttribute = typecast(fliplr(bytes), 'single');
                                
                            case OSCTypes.Double
                                % 64-bit double precision floating point numbers
                                newAttribute = typecast(fliplr(bytes), 'double');
                            
                            case OSCTypes.Ascii32
                                % ASCII character - right aligned in 32-bit
                                newAttribute = char(bytes(4));
                            
                            case OSCTypes.OscTimetag
                                % OSC timetag value
                                newAttribute = OSCTimetag(bytes);
                        end
                        
                        % Remove bytes from array
                        byteArray = byteArray(numBytes+1:end);
                        
                    else
                        % Special treatment for strings
                        idNullChar = find(byteArray == 0, 1);
                        
                        % First, calculate the modulo value of 4
                        moduloValue = mod(idNullChar, 4);
                        
                        % finding the end of the 32-bit alignment...
                        if ( moduloValue == 0 )
                            % If the position of the first null-character is a
                            % mutliple of 4, the string is 32-bit alligned
                            idStringEnd = idNullChar;
                        else
                            % If the modulo value is not a multiple of 4, we
                            % have to take additional bytes before reaching the
                            % end of the 32-bit alignment...
                            idStringEnd = idNullChar + (4 - moduloValue);
                        end
                        
                        if idStringEnd >= length(byteArray)
                            idStringEnd = length(byteArray);
                        end
                        
                        % Copy string and remove trailing null characters
                        newAttribute = char(byteArray(1:idStringEnd));
                        newAttribute = erase(newAttribute, char(0));

                        % Remove bytes from array
                        byteArray = byteArray(idStringEnd+1:end);
                    end

                    % Store new attribute in list
                    obj.attributeList = [obj.attributeList {newAttribute}];
                end
                
                
            elseif ( nargin == 3)
                % address, typeTagList and attributeList specified
                addr       = varargin{1};
                types      = varargin{2};
                attributes = varargin{3};
                
                % Validate address
                validateattributes(addr,       {'char'}, {}, 'OSCMessage', 'address');
                validateattributes(types,      {'cell'}, {}, 'OSCMessage', 'types');
                validateattributes(attributes, {'cell'}, {}, 'OSCMessage', 'attributes');
                
                % Check that length of types and attributes match
                numTypes = length(types);
                numAttributes = length(attributes);
                if (numTypes ~= numAttributes)
                    error('Number of given types must match number of given attributes!');
                end
                
                % Check that at least one type/attribute pair is given
                if (numTypes == 0)
                    % Store the address now...
                    obj.address = addr;
                    % Leave the constructor!
                    return;
                end
                
                % No check all type/attribute pairs...
                for cntr = 1:1:numTypes
                    % Take current type and attribute
                    currType = types{cntr};
                    currAttr = attributes{cntr};
                    
                    % Check that current type is of class OSCTypes...
                    if ( ~strcmpi(class(currType), 'OSCTypes') )
                        error('Type Tags must be specified as cell array of OSCTypes attributes!');
                    end
                    
                    % Now check that attribute and type match!
                    switch (currType)
                        
                        case OSCTypes.Int32
                            % An int32 can store all the values of int8,
                            % uint8, int16, uint16, int32... 
                            % Because MATLAB uses double as the standard
                            % format, we should also check if it is a
                            % double without a fractional value....
                            if ( (~isnumeric(currAttr))          ||...
                                 (~(isa(currAttr, 'int8')   ||...
                                    isa(currAttr, 'uint8')  ||...
                                    isa(currAttr, 'int16')  ||...
                                    isa(currAttr, 'uint16') ||...
                                    isa(currAttr, 'int32')  ||...
                                    isa(currAttr, 'float')  ||...
                                    isa(currAttr, 'double')))    ||...
                                 (~(mod(currAttr,1) == 0)))
                                
                                % Output teh error message...
                                error('Attribute #%d is supposed to be an int32. Instead it is of class %s', cntr, class(currAttr));
                            end
                            
                            if (numel(currAttr) ~= 1)
                                error('Only scalar int32 values are supported!')
                            end
                            
                        case OSCT.Int64
                            % An int64 can store all the values of int8,
                            % uint8, int16, uint16, int32, uint32, int64... 
                            % Because MATLAB uses double as the standard
                            % format, we should also check if it is a
                            % double without a fractional value....
                            if ( (~isnumeric(currAttr))          ||...
                                 (~(isa(currAttr, 'int8')   ||...
                                    isa(currAttr, 'uint8')  ||...
                                    isa(currAttr, 'int16')  ||...
                                    isa(currAttr, 'uint16') ||...
                                    isa(currAttr, 'int32')  ||...
                                    isa(currAttr, 'uint32') ||...
                                    isa(currAttr, 'int64')  ||...
                                    isa(currAttr, 'float')  ||...
                                    isa(currAttr, 'double')))    ||...
                                 (~(mod(currAttr,1) == 0)))
                                
                                % Output teh error message...
                                error('Attribute #%d is supposed to be an int64. Instead it is of class %s', cntr, class(currAttr));
                            end
                            
                            if (numel(currAttr) ~= 1)
                                error('Only scalar int64 values are supported!')
                            end
                            
                        case OSCTypes.Float32
                            % A single/float (64-bit IEEE-754) can store all the
                            % values of int8, uint8, int16, uint16 and
                            % float...
                            % Because MATLAB uses double as the standard
                            % format, we should also check if it is a
                            % double that can be expressed as a float
                            if ( (~isnumeric(currAttr))           ||...
                                 (~(isa(currAttr, 'uint8')  || ...
                                    isa(currAttr, 'int8')   || ...
                                    isa(currAttr, 'uint16') || ...
                                    isa(currAttr, 'int16')  || ...
                                    isa(currAttr, 'single')))     || ...
                                 (~(isa(currAttr, 'double') && (abs(currAttr - single(currAttr)) < eps))))
                                
                                % Output teh error message...
                                error('Attribute #%d is supposed to be a single/float. Instead it is of class %s', cntr, class(currAttr));
                            end
                            
                            if (numel(currAttr) ~= 1)
                                error('Only scalar float/single values are supported!')
                            end
                            
                        case OSCTypes.Double
                            % A double (64-bit IEEE-754) can store all the
                            % values of almost every datatype without
                            % losing precision - except (u)int64
                            if ( (~isnumeric(currAttr))    ||...
                                 (isa(currAttr, 'uint64')) ||...
                                 (isa(currAttr, 'int64')) )
                                
                                % Output teh error message...
                                error('Attribute #%d is supposed to be a double. Instead it is of class %s', cntr, class(currAttr));
                            end
                            
                            if (numel(currAttr) ~= 1)
                                error('Only scalar double values are supported!')
                            end
                            
                        case OSCTypes.Ascii32
                            % Check for char...
                            if (~isa(currAttr, 'char'))
                                error('Attribute #%d is supposed to be a char. Instead it is of class %s', cntr, class(currAttr));
                            end
                            
                            if (numel(currAttr) ~= 1)
                                error('Only scalar int32 values are supported!')
                            end
                            
                        case OSCTypes.OscString
                            % Check for char...
                            if (~isa(currAttr, 'char'))
                                error('Attribute #%d is supposed to be a char/char-array. Instead it is of class %s', cntr, class(currAttr));
                            end
                            
                            if (~isvector(currAttr))
                                error('Only char-vectors are supported!')
                            end
                            
                        case OSCTypes.OscTimetag
                            % Check for OSCTimetag...
                            if (~(strcmpi(class(currAttr), 'OSCTimetag')))
                                error('Attribute #%d is supposed to be an OSCTimetag. Instead it is of class %s', cntr, class(currAttr));
                            end
                    end

                end
                
                % Store the values before leaving the constructor
                obj.address       = addr;
                obj.typeTagList   = types;
                obj.attributeList = attributes;
                
            else
                % Not supported number of arguments!
                error('Number of arguments not supported!')
            end

        end
                
        function setAddress(obj, argAddress)
            %SETADDRESS Set the address property of this OSCMessage instance
            % Address must end with a null termination
            
            if (nargin ~= 2)
                % First arg is the object itself
                error('A address must be specified!');
            end
            
            % Check argument
            validateattributes(argAddress, {'char'}, {}, 'setAddress', 'argAddress');
            
            % Set address
            obj.address = argAddress;
        end
        
        function addInt32(obj, argInt32)
            %ADDINT32 Add an int32 value to the message
            
            % Set the attribute
            obj.addAttribute(OSCTypes.Int32, argInt32);
        end
        
        function addInt64(obj, argInt64)
            %ADDINT64 Add an int64 value to the message
            
            % Set the attribute
            obj.addAttribute(OSCTypes.Int64, argInt64);
        end
        
        function addFloat(obj, argFloat)
            %ADDFLOAT Add a single/float value to the message
            
            % Set the attribute
            obj.addAttribute(OSCTypes.Float32, argFloat);
        end
        
        function addDouble(obj, argDouble)
            %ADDDOUBLE Add a double value to the message
            
            % Set the attribute
            obj.addAttribute(OSCTypes.Double, argDouble);
        end
        
        function addAscii32(obj, argAscii)
            %ADDASCII32 Add an ASCII character value to the message
            
            % Set the attribute
            obj.addAttribute(OSCTypes.Ascii32, argAscii);
        end
        
        function addOscTimetag(obj, argOscTimetag)
            %ADDOSCTIMETAG Add an OSCTimetag to the message
            % Set the attribute
            obj.addAttribute(OSCTypes.OscTimetag, argOscTimetag);
        end
        
        function addString(obj, argString)
            %ADDSTRING Add a string to the message
            
            % Set the attribute
            obj.addAttribute(OSCTypes.OscString, argString);
        end
        
        function addAttribute(obj, type, attribute)
            %ADDATRIBUTE Add an attribute to the message.
            % Consider valid OSCTypes for adding values!
            
            % Check and set attribute
            if (nargin < 3)
                error('A type and an attribute must be specified!')
            end
            
            if (numel(type) ~= 1)
                error('Type must be a scalar value!')
            end
            
            if (numel(attribute) ~= 1)
                if (~ischar(attribute))
                    error('Attribute must be a scalar value or string (char-vector)!')
                end
            end
            
            % Depending on the type cast the attribute
            switch(type)
                case OSCTypes.Int32
                    % Add an Int32 attribute to the OSCMessage instance
                    if (~(isa(attribute, 'int32')))
                        warning('Specified attribute is not an int32 value! To avoid truncation or loss of precision, convert it to int32 before calling this function!');
                    end
                    % Cast to int32
                    newAttribute = int32(attribute);
                    
                case OSCTypes.Int64
                    % Add an Int64 attribute to the OSCMessage instance
                    if (~(isa(attribute, 'int64')))
                        warning('Specified attribute is not an int64 value! To avoid truncation or loss of precision, convert it to int64 before calling this function!');
                    end
                    % Cast to int64
                    newAttribute = int64(attribute);
                    
                case OSCTypes.Float32
                    % Add a single/float attribute to the OSCMessage instance
                    if (~(isa(attribute, 'single')))
                        warning('Specified attribute is not a single/float value! To avoid truncation or loss of precision, convert it to single/float before calling this function!');
                    end
                    % Cast to single
                    newAttribute = single(attribute);
                    
                case OSCTypes.Double
                    % Add a double attribute to the OSCMessage instance
                    if (~(isa(attribute, 'double')))
                        warning('Specified attribute is not a double value! To avoid truncation or loss of precision, convert it to double before calling this function!');
                    end
                    % Cast to double
                    newAttribute = double(attribute);
                    
                case OSCTypes.Ascii32
                    % Add a char attribute to the OSCMessage instance
                    if (~(isa(attribute, 'char') || isa(argAscii, 'uint8')))
                        warning('Specified attribute is not a char/uint8 value! To avoid truncation or loss of precision, convert it to char before calling this function!');
                    end
                    % Cast to char/uint8
                    newAttribute = uint8(attribute);
                    
                case OSCTypes.OscString
                    % Add a char attribute to the OSCMessage instance
                    if (~(isa(attribute, 'char') || isa(argAscii, 'uint8')))
                        warning('Specified attribute is not a char/uint8 value! To avoid truncation or loss of precision, convert it to char before calling this function!');
                    end
                    % Cast to char/uint8
                    newAttribute = char(attribute);
                    
                case OSCTypes.OscTimetag
                    % Add a OSCTimetag attribute to the OSCMessage instance
                    if (~isa(attribute, 'OSCTimetag'))
                        error('Specified attribute is not an OSCTimetag object!');
                    end
                    % Submit attribute
                    newAttribute = attribute;
                    
                otherwise
                    error('Unknown OSC Type Tag!');
            end
            
            % Add type tag to type tag list
            obj.typeTagList = [obj.typeTagList {type}];
            
            % Add attribute to attribute list
            obj.attributeList = [obj.attributeList {newAttribute}];
            
        end
        
        function clearAttributes(obj)
            %CLEARATTRIBUTES Clears the attribute part of the message (payload)
            
            % Just re-initialze the cell arrays 
            obj.typeTagList   = cell(0); % List of TypeTags
            obj.attributeList = cell(0); % List of attributes
            
        end % clearAttributes
        
        function byteArray = toByteArray(obj)
            %TOBYTEARRAY Convert the OSCMessage object into a byte array to be
            %transmitted to the receiver (e.g. via TCP/UDP)
            
            % Create an aempty byte array
            byteArray = uint8([]);
            
            % Add '/'
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            byteArray(end+1) = uint8('/');
            
            % Add address
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            tempAddress = obj.address;
            
            if ( isempty(tempAddress) )
                byteArray = [byteArray, uint8(zeros(1,3))];
            else
                
                % The last character of the string muss be the Null-char!
                if ( tempAddress(end) ~= 0 )
                    tempAddress = [tempAddress char(0)];
                else
                    % If last character was already a null char, check if there
                    % are multiple null chars!
                    firstNull = find(tempAddress == 0, 1);
                    tempAddress = tempAddress(1:firstNull);
                end
                
                % Now check the 32-bit allignment of the address
                % Example for address 'addressXY'
                % 2F(,) 61(a) 64(d) 64(d)
                % 72(r) 65(e) 73(s) 73(s)
                % 58(X) 59(Y) 00()  ??()  
                % -> Null-char added but one Null-char must be added to
                %    fill 32-bit allignment!
                
                % Valid length of the address including the terminating
                % Null-char are 3, 7, 11, 15...
                % So modulo( (length+1), 4) must be zero...
                % Otherwise we have to add Null-chars...
                mlen = mod(length(tempAddress)+1, 4);
                
                if (mlen ~= 0)
                    addNulls = 4 - mlen;
                    tempAddress = [tempAddress char(zeros(1, addNulls))];
                    clear addNulls;
                end
                clear mlen
                
                % Add address to the byte array
                byteArray = [byteArray uint8(tempAddress)];
                
            end
            clear tempAddress;
            
            % Add typeTags
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %byteArray(end+1) = uint8(',');
            
            % Get number of type tags
            numTypeTags   = length(obj.typeTagList);
            
            % Get number of attributes
            numAttributes = length(obj.attributeList);
            
            % Number of type tags and attributes must match
            if (numTypeTags ~= numAttributes)
                % Should not be the case...
                error('Something went wrong! The number of Type Tags does not match the number of attributes!')
            end
            
            % If no type tags are specified, leave the function...
            if (numTypeTags == 0)
                return;
            end
            
            % Iterate through all the type tags
            %-------------------------------------------------------------------
            typeArrayLength = (numTypeTags + 1) + 4 - mod((numTypeTags+1), 4);
            typeArray    = uint8(zeros(1, typeArrayLength));
            
            % Add separator
            typeArray(1) = uint8(',');
            
            attrArray = [];
            
            for cntr = 1:1:numTypeTags
                % Get current OSC type tag
                currType = obj.typeTagList{cntr};
                typeArray(cntr+1) = currType.toChar();
                
                % Get corresponding attribute
                currAttr = obj.attributeList{cntr};
                
                % Check that the attribute is not empty!
                if (isempty(currAttr))
                    error('Attribute #%d is empty!?!', cntr);
                end
                
                if ( (numel(currAttr) > 1) && (currType ~= OSCTypes.OscString) )
                    warning('Only scalar values and strings (char arrays) allowed! Taking first element of attribute 3%d!', cntr);
                    currAttr = currAttr(1);
                end
                
                % Create dummy placeholder for byte structure of that atribute
                currBytes = []; %#ok<NASGU>
                
                switch(currType)
                    case OSCTypes.Int32
                        currBytes = fliplr(typecast( int32(currAttr), 'uint8'));
                        
                    case OSCTypes.Int64
                        currBytes = fliplr(typecast( int64(currAttr), 'uint8'));
                        
                    case OSCTypes.Float32
                        currBytes = fliplr(typecast(single(currAttr), 'uint8'));
                        
                    case OSCTypes.Double
                        currBytes = fliplr(typecast(double(currAttr), 'uint8'));
                        
                    case OSCTypes.Ascii32
                        currBytes    = uint8(zeros(1,4));
                        currBytes(4) = uint8(char(currAttr));
                        
                    case OSCTypes.OscTimetag
                        if (~isa(currAttr, 'OSCTimetag'))
                            error('Type tag #%d specifies an OSCTimetag but attribute is of class %s!', cntr, class(currAttr));
                        end
                        % Convert to byte array
                        currBytes = currAttr.toByteArray();
                        
                    case OSCTypes.OscString
                        if (~isa(currAttr, 'char'))
                            error('Type tag #%d specifies an OSCString (char-vector) but attribute is of class %s!', cntr, class(currAttr));
                        end
                        
                        % Append one null character
                        tempString = [currAttr char(0)];
                        
                        % Check that only one null char is at the end
                        firstNull  = find(tempString == 0, 1);
                        
                        % No check that length (including null charater) is a
                        % multiple of 4...
                        tempString = tempString(1:firstNull);
                        strAppend  = 4 - mod(length(tempString), 4);
                        
                        if (strAppend > 0)
                            tempString = [tempString uint8(zeros(1, strAppend))]; %#ok<AGROW>
                        end
                        
                        % Convert to byte array
                        currBytes = uint8(tempString);
                        
                        
                    otherwise
                        error('Something went wrong! The given OSCType is invalid! How can that happen?!?');
                end
                
                % Append attribute array
                attrArray = [attrArray currBytes]; %#ok<AGROW>
            end
            
            % Combine arrays before leaving this method
            byteArray = [byteArray typeArray attrArray];
        end
    end
end