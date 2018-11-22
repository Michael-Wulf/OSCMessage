classdef OSCTimetag
    %OSCTIMETAG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        seconds   = uint32(0);
        fractions = uint32(0);
    end
    
    methods
        function obj = OSCTimetag(varargin)
            %OSCTIMETAG Construct an instance of this class
            %   Detailed explanation goes here
            
            if (~ ((nargin == 1) || (nargin==7)) )
                error('Unsupported number of input arguments! Only');
            end
            
            
            if nargin == 1
                % One input argument
                % - String: Call datetime-function
                % - Double: Days from 0-0-0000 00:00:00 (MATLAB format)
                % - Byte array: receiving from OSCMessage
                
                % Take the input argument
                argin = varargin{1};
                
                if ischar(argin)
                    % Input as string for datetime function
                    try
                        % Call MATLAB function datetime to get the number of
                        % days (including fractional part) of given date/time
                        % since January 0, 0000
                        tempTimestamp = datetime(argin);
                    catch
                        error('Could not recognize the date/time format of %s! See help of MATLAB-internal function datetime for valid DatStrings!',argin);
                    end
                    
                    % Get timestamp for Jan-01-1900 00:00:00
                    tempTimestamp1900 = datetime('01-Jan-1900 00:00:00');
                    
                    % Calculate difference
                    diffTimestamp = tempTimestamp - tempTimestamp1900;
                    
                    if (diffTimestamp < 0)
                        warning('Specified timestamp lies earlier than Jan-01-1900 00:00:00! Setting OSCTimestamp to zero!');
                        diffTimestamp = 0;
                    end
                    
                    % Convert to seconds
                    diffTimestamp = diffTimestamp * 86400;
                    
                    % full seconds
                    obj.seconds = uint32(floor(diffTimestamp));
                    
                    % fractional seconds
                    frac = modulo(diffTimestamp, 1);
                    
                    % Set fractional part....
                    obj.fractions = uint32(floor(frac * (2^32)));
                    
                else
                    if (numel(argin) == 1)
                        if (isa(argin, 'double'))
                            % Days since January 0, 0000 (MATLAB timestamps)
                            
                            tempTimestamp = argin;
                            
                            % Get timestamp for Jan-01-1900 00:00:00
                            tempTimestamp1900 = datetime('01-Jan-1900 00:00:00');
                            
                            % Calculate difference
                            diffTimestamp = tempTimestamp - tempTimestamp1900;
                            
                            if (diffTimestamp < 0)
                                warning('Specified timestamp lies earlier than Jan-01-1900 00:00:00! Setting OSCTimestamp to zero!');
                                diffTimestamp = 0;
                            end
                            
                            % Convert to seconds
                            diffTimestamp = diffTimestamp * 86400;
                            
                            % full seconds
                            obj.seconds = uint32(floor(diffTimestamp));
                            
                            % fractional seconds
                            frac = modulo(diffTimestamp, 1);
                            
                            % Set fractional part....
                            obj.fractions = uint32(floor(frac * (2^32)));
                            
                        else
                            % Unsupported...
                            error('Unsupported datatype to create an OSCTimestamp!');
                        end
                    elseif ( (size(argin, 1) == 1) && (size(argin, 2)==8) )
                        if (isa(argin, 'uint8'))
                            
                        else
                            % Unsupported...
                            error('Unsupported datatype to create an OSCTimestamp!');
                        end
                    else
                        % Unsupported...
                        error('Unsupported datatype to create an OSCTimestamp!');
                    end

                end
            elseif nargin == 6
                y    = varargin{1}; % Year
                m    = varargin{2}; % Month
                d    = varargin{3}; % Day
                h    = varargin{4}; % Hour
                min  = varargin{5}; % Minute
                sec  = varargin{6}; % Seconds
                
            elseif nargin == 7
                y    = varargin{1}; % Year
                m    = varargin{2}; % Month
                d    = varargin{3}; % Day
                h    = varargin{4}; % Hour
                min  = varargin{5}; % Minute
                sec  = varargin{6}; % Seconds
                msec = varargin{7}; % Milliseconds
            else
                % Should be caught before...
                % Display an error message
            end
                
            
        end
        
        function d = toMatlabformat(obj)
        end
        
        function c = toChar(obj)
            
            datestr(timestamp,'dd-mm-yyyy HH:MM:SS.FFF');
        end
        
        function byteArray = toByteArray(obj)
            %TOBYTEARRAY Converts the OSCTimetag instance into a byte array
            %   Detailed explanation goes here
            
            % Create an empty uint8 array
            byteArray = uint8(zeros(1,8));

            % Create Bitmasks
            maskByte1 = uint32(hex2dec('ff000000'));
            maskByte2 = uint32(hex2dec('00ff0000'));
            maskByte3 = uint32(hex2dec('0000ff00'));
            maskByte4 = uint32(hex2dec('000000ff'));
            
            % Copy the 32-bit seconds part into the byte array
            byteArray(1) = uint8(bitshift(bitand(obj.seconds, maskByte1), -24));
            byteArray(2) = uint8(bitshift(bitand(obj.seconds, maskByte2), -16));
            byteArray(3) = uint8(bitshift(bitand(obj.seconds, maskByte3),  -8));
            byteArray(4) = uint8(bitshift(bitand(obj.seconds, maskByte4),   0));
            
            % Copy the 32-bit fractions part into the byte array
            byteArray(5) = uint8(bitshift(bitand(obj.fractions, maskByte1), -24));
            byteArray(6) = uint8(bitshift(bitand(obj.fractions, maskByte2), -16));
            byteArray(7) = uint8(bitshift(bitand(obj.fractions, maskByte3),  -8));
            byteArray(8) = uint8(bitshift(bitand(obj.fractions, maskByte4),   0));
        end
    end
end

