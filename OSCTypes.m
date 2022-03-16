classdef OSCTypes < uint8
    %OSCTYPES Enum-class for some (not all) OSC types
    % See http://opensoundcontrol.org/node/3/ for an overview of all OSC
    % types
    %
    % Usage:
    % ------
    % % Create an Int32 OSC type
    % type = OSCTypes.Int32;
    % 
    % % create a Float32
    % type = OSCTypes(uint8('f'));
    % type = OSCTypes.fromChar('f');
    % 
    % % Compare
    % if (type.toChar() == 'f')
    %   disp('Type is a Float!')
    % end
    %
    % --------------------------------------------------------------------------
    % Author:  Michael Wulf
    %          Washington University in St. Louis
    %          Kepecs Lab
    % 
    % Date:    03/16/2022
    % Version: 1.0.1
    % Github:  https://github.com/Michael-Wulf/OSCMessage
    % --------------------------------------------------------------------------
    
    enumeration
        Int32      (105) % ('i') Int32 OSC type 
        Float32    (102) % ('f') Float32 OSC type
        OscString  (115) % ('s') OSC-String OSC type
        Int64      (104) % ('h') Int64 OSC type
        OscTimetag (116) % ('t') OSC-timetag type
        Double     (100) % ('d') Int32 OSC type
        Ascii32     (99) % ('c') ASCII32 OSC type
    end
    
    methods
        
        function c = toChar(obj)
            c = char(uint8(obj));
        end
    end
    
    methods (Static)
        function oscType = fromChar(value)
            oscType = OSCTypes(uint8(value));
        end
    end
end

