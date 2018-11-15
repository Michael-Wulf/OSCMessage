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
    % type = OSCTypes('f');
    % 
    % % Compare
    % if (type.toChar() == 'f')
    %   disp('Type is a Float!')
    % end
    %
    % --------------------------------------------------------------------------
    % Author:  Michael Wulf
    %          Cold Spring Harbor Laboratory
    %          Kepecs Lab
    %          One Bungtown Road
    %          Cold Spring Harboor
    %          NY 11724, USA
    %
    % Date:    11/15/2018
    % Version: 1.0.0
    % --------------------------------------------------------------------------
    
    enumeration
        Int32      ('i') % Int32 OSC type
        Float32    ('f') % Float32 OSC type
        OscString  ('s') % OSC-String OSC type
        Int64      ('h') % Int64 OSC type
        OscTimetag ('t') % OSC-timetag type
        Double     ('d') % Int32 OSC type
        Ascii32    ('c') % Int32 OSC type
    end
    
    methods
        function c = toChar(obj)
            c = char(uint8(obj));
        end
    end
end

