library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_rx is

  port (
      clk, rst   : in  std_logic;
      i_rx       : in  std_logic; -- incoming rx data
      o_data     : out std_logic_vector(D-1 downto 0); -- received data
      o_rx_ready : out std_logic  -- received buffer ready
  );
  end uart_rx;

architecture rtl of uart_rx is

  signal cnt    : unsigned(TMRLEN_1 downto 0) := to_unsigned(M, TMRLEN);
  signal ticker : std_logic := '0'; 
  signal parity_even : std_logic := '0'; -- for even parity
  signal parity_odd  : std_logic := '1'; -- for odd  parity
  signal data_cnt : unsigned(4 downto 0) := (others=>'0');
  signal databuff : std_logic_vector(D-1 downto 0) := (others=>'0');
  type state_type is (idle, start_bit, rec_data, parity_state, stop_bit);
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
          ti
          cker <= '0';
          cnt <= cnt-1;
        end if;
      end if;
    end if;
  end process;

  process(tick,parity_even,i_start,i_data,data_cnt,p_state)
  begin
    case state is 
      p_state <= idle;
      databuff <= (others=> '0');

      when idle =>
          if(i_rx = '0') then
            n_state <= start_bit;
          else 
            n_state <= idle;
          end if;
        end if;
      
      when start_bit =>
      
        if  (ticker = '1') then 
          if (i_rx <= '0') then
            n_state <= send_data;
          else 
            n_state <= idle;
          end if;
        else 
          n_state <= start_bit;
        end if;
  
      when rec_data =>

        if (ticker = '1') then 
          parity_even <= parity_even xor i_rx;
          databuff <= i_rx & databuff(databuff'length downto 1);
          data_cnt <= data_cnt+1
            if (data_cnt = 8) then
              data_cnt <= "0000";
              n_state <= parity_state;
            else
              n_state <= rec_data;
            end if;
        end if;

      when parity_state =>
        if(ticker = '1') then
          if (parity_even /= i_rx)
          n_state <= idle;
          else
          n_state <= stop_bit;
          end if;
        else 
          n_state <= parity_state;
        end if;

      when stop_bit =>
      
    end case;
  end process;
  
  
end architecture rtl;

