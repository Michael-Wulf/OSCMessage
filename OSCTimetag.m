classdef OSCTimetag
    %OSCTIMETAG Implementation of the OSC Timtag timestap format
    % An OSC timetag timestamp stores the passed seconds since Jan-01-1900 00:00:00
    % as two separate uint32 values (whole seconds and fractional seconds with a
    % precision of 2^(-32))
    
    properties
        seconds   = uint32(0);
        fractions = uint32(0);
    end
    
    methods
        function obj = OSCTimetag(varargin)
            %OSCTIMETAG Construct an instance of this class
            %   Detailed explanation goes here
            
            if (~ ((nargin == 1) || (nargin==7) || (nargin==7)) )
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
                        % Call MATLAB functions datetime & datenum to get the number of
                        % days (including fractional part) of given date/time
                        % since January 0, 0000
                        tempTimestamp = datenum(datetime(argin));
                    catch
                        error('Could not recognize the date/time format of %s! See help of MATLAB-internal function datetime for valid DatStrings!',argin);
                    end
                    
                    % Get timestamp for Jan-01-1900 00:00:00
                    tempTimestamp1900 = datenum(datetime('01-Jan-1900 00:00:00'));
                    
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
                    frac = mod(diffTimestamp, 1);
                    
                    % Set fractional part....
                    obj.fractions = uint32(floor(frac * (2^32)));
                    
                else
                    if (numel(argin) == 1)
                        if (isa(argin, 'double'))
                            % Days since January 0, 0000 (MATLAB timestamp from datenum function)
                            tempTimestamp = argin;
                            
                            % Get timestamp for Jan-01-1900 00:00:00
                            tempTimestamp1900 = datenum(datetime('01-Jan-1900 00:00:00'));
                            
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
                            frac = mod(diffTimestamp, 1);
                            
                            % Set fractional part....
                            obj.fractions = uint32(floor(frac * (2^32)));
                            
                        elseif (isa(argin, 'duration'))
                            % Convert duration type to number of days since 
                            % January 0, 0000 (MATLAB timestamps)
                            tempTimestamp = datenum(argin);
                            
                            % Get timestamp for Jan-01-1900 00:00:00
                            tempTimestamp1900 = datenum(datetime('01-Jan-1900 00:00:00'));
                            
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
                            frac = mod(diffTimestamp, 1);
                            
                            % Set fractional part....
                            obj.fractions = uint32(floor(frac * (2^32)));
                        else
                            % Unsupported...
                            error('Unsupported datatype to create an OSCTimestamp!');
                        end
                    elseif ( isvector(argin) && (length(argin)==8) )
                        if (isa(argin, 'uint8'))
                            % Convert the 8 bytes into 2 32-bit uint values
                            uint32_1 = bitshift(uint32(argin(1)), 24);
                            uint32_2 = bitshift(uint32(argin(2)), 16);
                            uint32_3 = bitshift(uint32(argin(3)),  8);
                            uint32_4 = bitshift(uint32(argin(4)),  0);
                            
                            obj.seconds = uint32(uint32_1 + uint32_2 + uint32_3 + uint32_4);
                            
                            uint32_1 = bitshift(uint32(argin(5)), 24);
                            uint32_2 = bitshift(uint32(argin(6)), 16);
                            uint32_3 = bitshift(uint32(argin(7)),  8);
                            uint32_4 = bitshift(uint32(argin(8)),  0);
                            
                            obj.fractions = uint32(uint32_1 + uint32_2 + uint32_3 + uint32_4);
                        else
                            % Unsupported...
                            error('Unsupported datatype to create an OSCTimestamp!');
                        end
                    else
                        % Unsupported...
                        error('Unsupported datatype to create an OSCTimestamp!');
                    end

                end
            elseif ( (nargin == 6) || (nargin == 7) )
                
                y    = varargin{1}; % Year
                m    = varargin{2}; % Month
                d    = varargin{3}; % Day
                h    = varargin{4}; % Hour
                min  = varargin{5}; % Minute
                sec  = varargin{6}; % Seconds
                if (nargin == 7)
                    msec = varargin{7}; % Milliseconds
                else
                    msec = 0;
                end
                
                % Input as string for datetime function
                try
                    % Call MATLAB functions datetime & datenum to get the number of
                    % days (including fractional part) of given date/time
                    % since January 0, 0000
                    tempTimestamp = datenum(datetime(y, m, d, h, min, sec, msec));
                catch
                    error('Could not recognize the date/time format! Specified values for year, month, day, hour, minut, second, and millisecond must be given as scalar values (e.g. OSCTimetag(2018, 12, 24, 13, 12, ,25, 125)');
                end
                
                % Get timestamp for Jan-01-1900 00:00:00
                tempTimestamp1900 = datenum(datetime('01-Jan-1900 00:00:00'));
                
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
                frac = mod(diffTimestamp, 1);
                
                % Set fractional part....
                obj.fractions = uint32(floor(frac * (2^32)));

            else
                % Should be caught before...
                % Display an error message
            end
            
            if (obj.seconds == uint32((2^32) - 1))
                warning('Attention! OSC Timetag format overflow!')
            end
        end
          
        function d = toDatetime(obj)
            %TODATETIME Converts the OSC Timetag into a MATLAB datetime object
            % OSC Timetags represents the duration since 01-Jan-1900 00:00:00 as a 64-bit value in
            % seconds (32-bit for the whole seconds and 32-bit for the
            % fractional part).
            % This function converts this back into the MATLA duration format.
            d = datetime(double(obj.seconds) + double(obj.fractions)/(2^32), 'ConvertFrom', 'epochtime', 'epoch', '1900-01-01');
        end
        
        function d = toMatlabTimestampFormat(obj)
            %TOMATLABTIMESTAMPFORMAT Converts the OSC Timetag into hours since January 0, 0000
            d = datenum( obj.toDatetime() );
        end
        
        function c = toChar(obj)
            %TOCHAR Converts the OSC Timetag into a char vector (string)
            % Representing the timestamp as a calendar value with day, month, 
            % year, hour, minute, second, millisecond values(e.g. 24-Dec-2018 13:12:25.125)
            c = datestr(obj.toDatetime() ,'dd-mmm-yyyy HH:MM:SS.FFF');
        end
        
        function byteArray = toByteArray(obj)
            %TOBYTEARRAY Converts the OSCTimetag instance into a byte array
            
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