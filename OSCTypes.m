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

