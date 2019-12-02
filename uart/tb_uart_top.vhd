library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.constants.all;

entity tb_uart_top is
  port (
  ) ;
end tb_uart_top;


architecture Behavioral of tb_uart_top is

    signal clk: std_logic := '0';
    signal uart_rx_i: std_logic := '0';
    signal uart_tx_o: std_logic := '0'; 


begin

    uart_top : entity work.uart_top(rtl)
    port map(clk=>clk, a=>a, uart_rx_i=>uart_rx_i, uart_tx_o=> uart_tx_o);

    process
    begin
        clk <= not clk;
        wait for TIMER/4; 
    end process;

    process
    begin 
    wait for 10 ns;
        uart_rx_i <= "00000000";
    wait for 100 ns;
        uart_rx_i <= "00010101";
    wait;
    end process;

end Behavioral ; -tb_uart_topehaviotb_uart_top
