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
    % ---------------------------------------------------------------------
    % Author:  Michael Wulf
    %          Washington University in St. Louis
    %          Kepecs Lab
    % 
    % Date:    04/15/2022
    % Version: 1.0.2
    % Github:  https://github.com/Michael-Wulf/OSCMessage
    %
    % Copyright (C) 2022 Michael Wulf
    %
    % This program is free software; you can redistribute it and/or
    % modify it under the terms of the GNU General Public License
    % as published by the Free Software Foundation; either version 2
    % of the License, or (at your option) any later version.
    % 
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    % 
    % You should have received a copy of the GNU General Public License
    % along with this program; if not, write to the Free Software
    % Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
    % MA  02110-1301, USA.
    % ---------------------------------------------------------------------
    
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