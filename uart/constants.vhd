----------------------------------------------------------------------------------
-- Project Name: FPGA PROJECT UART

-- Description: CONSTANTS FOR SOME BIT LENGHT, ADDRESSES; 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package constants is



--clock and baud rate constants 
constant BAUDRATE : integer := 115200; 
constant CLK_FREQ : integer := 125000000;
constant TIMER    : integer := CLK_FREQ/BAUDRATE;
-- Constants for rx and tx module 
constant D : integer := 7; -- data bits
constant P : integer := 1; -- parity, 0 for disable, 1 for odd, 2 for even
constant S : integer := 1; -- stop bit
constant M : integer := 10; -- timer count value for a given 
--total frame size
constant ULEN     : integer := 160;
constant ULEN_1   : integer := 159;
--timer size
constant TMRLEN   : integer := 32;
constant TMRLEN_1 : integer := 31;
-- 8-bit source address
constant SRC_ADDR_START  : integer := 0;  
constant SRC_ADDR_END    : integer := 7;  
constant OUR_ADDRESS     : std_logic_vector(SRC_ADDR_END DOWNTO SRC_ADDR_START) := x"05";
--8-bit destination address
constant DST_ADDR_START  : integer := 8;
constant DST_ADDR_END    : integer := 15;
constant DST_ADDRESS     : std_logic_vector(DST_ADDR_END DOWNTO DST_ADDR_START) :=  x"00";
--8-bit identifier
constant IDENTIFIER_START: integer :=16;
constant IDENTIFIER_END  : integer :=23;
constant IDENTIFIER       : std_logic_vector(IDENTIFIER_END DOWNTO IDENTIFIER_START) :=  x"00";
--128-bit payload
constant PAYLOAD_START   : integer :=24;
constant PAYLOAD_END     : integer :=151;
--8-bit checksum
constant CHECKSUM_START  : integer :=152;
constant CHECKSUM_END    : integer :=159;
constant CHECKSUM        : std_logic_vector(CHECKSUM_END DOWNTO CHECKSUM_START) := x"00";

------------------------------------------------------
--------------------------------------------ADDEDBYSTS
------------------------------------------------------


end constants;
