classdef OSCMessage < handle
    %OSC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        address;
        tagTypeList;
        
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
        
        function setAddress(obj)
            %
            % Address must end with a null termination
        end
        
        function addValue(obj)
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
            byteArray(end+1) = uint8('/');
            
        end
    end
    
    methods (Static)
    end
end

