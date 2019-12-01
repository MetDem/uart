library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.constants.all;

entity unpacker is
    port ( 
        i_clk      : in std_logic;                           
        i_rx_ready : in std_logic;
        i_rx       : in std_logic_vector(D downto 0);
        
        o_unpacker   : out std_logic_vector(D downto 0); 
        o_ready    : out std_logic
        
        
    );
end entity unpacker;

architecture rtl of unpacker is
    type state_type is (rst, check_src, check_dst, check_ident, decryp, check_sum, send_data);
    signal state : state_type := rst;

    signal s_key : std_logic_vector(7 downto 0) := (others=> '1');
    signal s_buff_payload: std_logic_vector(127 downto 0) := (others => '0');


    signal s_cnt : unsigned(3 downto 0) := "0000";
    signal s_cntdone : unsigned(3 downto 0) := "1111" ;

    signal s_reset        : std_logic := '1';
    signal s_decryp_ready : std_logic := '0';
    signal s_src_addr_ready : std_logic := '0';
    signal s_dst_addr_ready : std_logic := '0';
    signal s_identifier_ready : std_logic := '0';
    signal s_checksum_ready   : std_logic := '0';
    signal s_send_data_ready : std_logic := '0';

    signal cntrst : std_logic := '0';
    signal cntdone : std_logic := '0';
    signal cnt     : unsigned(31 downto 0) := (others=>'0');

begin

    process(i_clk) is
    begin 
    if rising_edge(i_clk) then
        if cntrst ='1' then
            cnt<= to_unsigned(M-1,32);
            cntdone<='0';
        else 
            if cnt=0 then
                cntdone<='1';
                cnt<=to_unsigned(M-1,32);
            else
                cntdone <='0';
                cnt<=cnt-1;
            end if;
        end if;
    end if;
    end process;


process(i_clk) is

begin

    if rising_edge(i_clk) then
        state <= rst;
        cntrst <= '0';
        o_ready <= '0';
        o_unpacker <= x"00";

        case state is 

            when rst =>
                cntrst <= '1';
                s_buff_payload <= (others => '0');


                if (i_rx_ready = '1') then 
                    cntrst <= '0';
                    s_src_addr_ready <= '1';
                    state <= check_src;
                end if;

            when check_src => 
                if(s_src_addr_ready = '1' and i_rx_ready = '1') then
                    if(i_rx = DST_ADDRESS) then
                        s_src_addr_ready <= '0';
                        s_dst_addr_ready <= '1';
                        state <= check_dst;
                    else 
                        state <= rst;
                    end if;
                end if;
            
            when check_dst =>
                if(s_dst_addr_ready = '1' and i_rx_ready = '1') then
                    if(i_rx = OUR_ADDRESS) then
                        s_dst_addr_ready <= '0';
                        s_identifier_ready <= '1';
                        state <= check_ident;
                    else
                        state <= rst;
                    end if;
                end if;
            
            when check_ident =>
                if(s_identifier_ready = '1' and i_rx_ready = '1') then
                    if(i_rx = IDENTIFIER) then
                        s_identifier_ready <= '0';
                        s_decryp_ready <= '1';
                        state <= decryp;
                    else
                        state <= decryp;
                    end if;
                end if;
            
            when decryp => 
                if(i_rx_ready = '1' and s_decryp_ready = '1') then 
                        s_buff_payload(127 downto 120) <= s_key xor i_rx;
                        if(s_cnt = s_cntdone) then
                            s_checksum_ready <= '1';
                            state <= check_sum;
                            s_cnt <= "0000";
                            s_decryp_ready <= '0';
                        else
                            s_cnt <= s_cnt + 1;
                            s_buff_payload <= s_buff_payload(119 downto 0) & s_buff_payload(127 downto 120);
                            state <= decryp;
                            s_decryp_ready <= '1';
                        end if;    
                end if;

                when check_sum => 
                if(s_checksum_ready = '1' and i_rx_ready = '1') then
                    if(i_rx = CHECKSUM) then
                        s_send_data_ready <= '1';
                        s_checksum_ready <= '0';
                        state <= send_data; 
                    else 
                        state <= rst;
                    end if;
            
                end if;

            when send_data => 
                if(s_send_data_ready = '1' and cntdone = '1') then
                    o_unpacker <= s_buff_payload(7 downto 0);
                    if(s_cnt = s_cntdone) then
                        s_send_data_ready <= '0';
                        s_cnt <= "0000";
                        state <= rst;
                        o_ready <= '1';
                    else
                        s_buff_payload <= s_buff_payload(7 downto 0) & s_buff_payload(127 downto 8);
                        s_cnt <= s_cnt + 1;
                        s_send_data_ready <= '1';
                        state <= send_data;
                    end if;
                end if;
            end case;
    end if;

    end process;

end rtl;
