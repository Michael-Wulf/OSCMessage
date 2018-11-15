classdef OSCMessage < handle
    %OSC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        address       = "";      % OSC address
        typeTagList   = cell(0); % List of TypeTags
        attributeList = cell(0); % List of attributes
    end
    
    methods
        function obj = OSC(varargin)
            %OSC Construct an instance of this class

        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
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
            
            if
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

