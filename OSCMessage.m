classdef OSCMessage < handle
    %OSC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        address       = "";      % OSC address
        typeTagList   = cell(0); % List of TypeTags
        attributeList = cell(0); % List of attributes
    end
    
    methods
        function obj = OSCMessage(varargin)
            %OSC Construct an instance of this class
            
            if (nargin == 0)
                % Empty OSCMessage...
                return;
                
            elseif (nargin == 1)
                % OSCMessage as byte array specified
                byteArray = varargin{1};
                
                validateattributes(byteArray, {'uint8'}, {'vector'}, 'OSCMessage', 'byteArray');
                
                % Get address out of the byteArray
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Find position of the slash
                idSlash = find(byteArray == '/', 1);
                
                if (isempty(idSlash))
                    error('Specified byteArray does not contain the OSC message start symbol ''/''!');
                end
                
                if (idSlash == 1)
                    dataLength = length(byteArray);
                    
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
                        dataLength = msgLen;
                    end
                    
                    % Remove everything before the slash...
                    % If a length (or what so ever) is sent before the
                    % address, the value could also be the ascii number of
                    % the ',' (TzpeTag)...
                    byteArray = byteArray(idSlash:end);

                else
                    error('Unsopported OSC message format! Slash position > 5?!?');
                end
                
                % Find the TypeTags...
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
                
                % Remove everything before the TypeTag...
                byteArray = byteArray(idTypeTag:end);
                
                % Find the first zero element!
                idFirstZero = find(byteArray == 0, 1);
                
                if (idFirstZero == 2)
                    %no data given!
                    return;
                else
                    moduloValue = mod(idFirstZero, 4);
                    if ( moduloValue == 0 )
                        idFirstDataByte = idFirstZero + 1;
                    else
                        idFirstDataByte = idFirstZero + (4 - moduloValue) + 1;
                    end
                    
                    if ( idFirstDataByte > length(byteArray) )
                        error('OSC message has a worng format! TypeTags specified but no data transmitted!');
                    end
                end
                
                % Get the TypeTags
                typeTags = byteArray(2:idFirstZero-1);
                
                if isempty(typeTags)
                    error('Error while processing OSC message. OSC message has a wrong format!');
                end
                
                for cntr = 1:1:length(typeTags)
                    try
                        obj.typeTagList = [obj.typeTagList {OSCTypes(uint8(typeTags(cntr)))}];
                    catch
                        error('Unknown OSC TypeTag %s', typeTags(cntr));
                    end
                end
                
                
                byteArray = byteArray(idFirstDataByte:end);
                
                for cntr = 1:1:length(obj.typeTagList)
                    % Get number of remaining bytes
                    remainingBytes = length(byteArray);
                    
                    % Get next OSCTypeTag
                    currType = obj.typeTagList{cntr};
                    
                    % Get Size of TypeTag
                    numBytes = double(OSCTypeSize(currType.char));
                    
                    if (currType ~= OSCTypes.OscString)
                        if (numBytes > remainingBytes)
                            error('OSC message frame format error! Not enough bytes left...!');
                        end
                        
                        bytes = byteArray(1:numBytes);
                        
                        switch (currType)
                            case OSCTypes.Int32
                                
                            case OSCTypes.Int64
                            case OSCTypes.Float32
                        end
                        
                    else
                        nextZero = find(byteArray == 0, 1);
                        
                        
                        
                    end

                    
                            
                end
                
                
            elseif ( nargin == 3)
                % address, typeTagList and attributeList specified
                
                
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
        
        function addAttribute(obj, type, attribute)
            % 
            %
            
            if (nargin < 3)
                error('A type and an attribute must be specified!')
            end
            
            
        end
        
        function addInt32(obj, argInt32)
            
            
        end
        
        function addFloat(obj, argFloat)
        end
        
        function addString(obj, argString)
        end
        
        function addInt64(obj, argInt64)
        end
        
        function addOscTimetag(obj, argOscTimetag)
            %
            % 64 bit
            % First 32-bits: Seconds since Jan-01-1900
            % Last 32-bits: Fractional seconds
        end
        
        function addDouble(obj, argDouble)
            
        end
        
        function addAscii32(obj, argAscii)
        end
        
        
        function byteArray = toByteArray(obj)
            byteArray = uint8();
            
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
            byteArray(end+1) = uint8(',');
            
            
        end
    end
    
    methods (Static)
    end
end

