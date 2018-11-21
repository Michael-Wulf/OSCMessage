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
                % - Double:
                % - Byte array:
                
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
                    tempTimestamp1900 = datetime('01-Jan-1900 00:00:00');
                    
                    diffTimestamp = tempTimestamp - tempTimestamp1900;
                    
                    if (diffTimestamp < 0)
                        warning('Specified timestamp lies earlier than Jan-01-1900 00:00:00! Setting OSCTimestamp to zero!');
                        diffTimestamp = 0;
                    end
                    
                    diffTimestamp = diffTimestamp * 86400;
                    
                    obj.seconds = uint32(floor(diffTimestamp));
                    
                    frac = modulo(diffTimestamp, 1)
                        
                    
                else
                    if (numel(argin) == 1)
                    elseif ( (size(argin, 1) == 1) && (size(argin, 2)==8) )
                    else
                        % Unsupported 
                    end
                elseif isa(argin, 'double')
                    % Days since January 0, 0000 (MATLAB timestamps)
                    
                else
                    % Unsupported
                end
            elseif nargin == 6
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
        
        function byteArray = toByteArray(obj)
            %TOBYTEARRAY Converts the OSCTimetag instance into a byte array
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

