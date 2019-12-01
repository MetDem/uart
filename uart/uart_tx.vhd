library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_tx is
  port (
    clk, rst  : in  std_logic;
    i_start   : in  std_logic; -- start transmission
    i_data    : in  std_logic_vector(D-1 downto 0); -- data to be sent
    o_tx      : out std_logic; -- transmission out
    o_tx_done : out std_logic  -- transmission done
  ) ;
end uart_tx;

architecture rtl of uart_tx is

    signal cnt    : unsigned(TMRLEN_1 downto 0) := to_unsigned(M, TMRLEN);
    signal ticker : std_logic := '0'; 
    signal parity_even : std_logic := '0'; -- for even parity
    signal parity_odd  : std_logic := '1'; -- for odd  parity
    signal data_cnt : unsigned(4 downto 0) := (others=>'0');
    type state_type is (idle, start_bit, send_data, parity_state, stop_bit);
    signal p_state, n_state : state_type := idle;
    

begin
  -- timer process 
  process(clk,rst)
  begin
    if (rising_edge(clk)) then 
      if (rst = '1') then 
        ticker <= '0';
        cnt    <=  to_unsigned(M,TMRLEN);
      else 
        if(cnt = 0) then
          ticker <= '1';
          cnt    <= to_unsigned(M,TMRLEN);
          p_state <= n_state;
        else
          ticker <= '0';
          cnt <= cnt-1;
        end if;
      end if;
    end if;
  end process;
  
  --states 
  process(tick,parity_even,i_start,i_data,data_cnt,p_state)
  begin
    case state is 
      p_state <= idle;
      o_tx <= '1';
      o_tx_done <= '0';

      when idle =>
      o_tx <= '1';
        if (ticker = '1') then 
          if(i_start = '0') then
            n_state <= start_bit;
          else 
            n_state <= idle;
          end if;
        end if;
      
      when start_bit =>
      
        if  (ticker = '1') then 
          o_tx <= '0';
          n_state <= send_data;
        else 
          n_state <= start_bit;
        end if;
  
      when send_data =>
      o_tx <= i_data(integer(data_cnt));

        if (ticker = '1') then 
          parity_even <= parity_even xor i_data(integer(data_cnt));
          data_cnt <= data_cnt+1;
            if (data_cnt = 7) then
              n_state <= parity_state;
            else
              n_state <= send_data;
            end if;
        end if;

      when parity_state =>
        o_tx <= parity_even;
        if(ticker = '1') then
          n_state <= stop_bit;
        else
          n_state <= parity_state;
        end if;

      when stop_bit =>
        o_tx <= '1';
        o_tx_done <= '1';
        if(ticker = '1') then
          if(i_start = '1') then
            n_state <= start_bit;
          else
            n_state <= idle;
          end if;
        else
          n_state <= stop_bit;
        end if;
    end case;
  end process;

  
end rtl ; -uart_tx