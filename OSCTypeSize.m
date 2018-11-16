classdef OSCTypeSize < uint8
    %OSCTYPES Enum-class for the size (number of bytes) of OSCTypes
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
        Int32      (4) % 4 byte, 32-bit
        Float32    (4) % 4 byte, 32-bit
        OscString  (1) % 1 byte,  8-bit
        Int64      (8) % 8 byte, 64-bit
        OscTimetag (8) % 8 byte, 64-bit
        Double     (8) % 8 byte, 64-bit
        Ascii32    (4) % 4 byte, 32-bit
    end
end