--Progetto di Reti Logiche 10815900_10791818

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_reti_logiche is
    port(
		i_clk: in std_logic;
        i_rst: in std_logic;
        i_start: in std_logic;
        i_add: in std_logic_vector(15 downto 0);
        i_k: in std_logic_vector(9 downto 0);
        
        o_done: out std_logic;
        
        o_mem_addr: out std_logic_vector(15 downto 0);
        i_mem_data: in std_logic_vector(7 downto 0);
        o_mem_data: out std_logic_vector(7 downto 0);
        o_mem_we: out std_logic;
        o_mem_en: out std_logic
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (rst, s0, s1, s2, s3, s4,s5,s6,s7,final);
    signal state: state_type;
    signal int_address: std_logic_vector(15 downto 0);
    signal k : integer range 0 to 1023;
    signal reg : std_logic_vector(7 downto 0);
    signal C : std_logic_vector(7 downto 0);
begin
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            o_mem_en   <= '0';
            o_mem_we   <= '0';
            C <= "00011111";
            o_done     <= '0';
            k <= 0;
            state      <= rst;

        elsif i_clk'event and i_clk = '1' then
            if state=rst then
                -- Reset: disattiva tutti gli enable, -- richiesta indirizzo 0
                if i_start = '1' then
                     o_mem_we   <= '0';
                     int_address <= i_add + "0000000000000001";--indirizzo 1
                     o_mem_en   <= '1';
                     o_mem_addr   <= i_add;
                     k <= 0;
                     o_done     <= '0';
                     C <= "00011111";
                     state      <= s0;
                  else  
                     state <= rst;
                  end if;

            elsif state=s0 then  --aspetto
	            o_mem_en <= '0';
                k <= 2*to_integer(unsigned(i_k));
                state <=s1;
                o_mem_addr   <= int_address; --o_mem indirizzo 1
               
            elsif state=s1 then -- lettura indirizzo 0 , valore x generico
                if k=0 then
                    state <= final;
                else 
                    k<=k-1;
                    if i_mem_data = "00000000" then  -- Zero Start
                        C <= "00000000";
                    end if;            
                    state <= s2;
	                reg <= i_mem_data;
                end if;
                
                
            elsif state=s2 then -- valore 0, mando in uscita il primo valore nell’indirizzo 1 		
                o_mem_en <= '1';
                o_mem_we   <= '1';   
                int_address <= int_address + "0000000000000001";-- indirizzo 2
                o_mem_data <= C;
                k<=k-1;
                
                    state <= s3;
                
            
            elsif state=s3 then --richiesta 2
                if k=0 then
                    state <=final;
                else
                    o_mem_we <= '0';
            	   k<=k-1;
            	   state <= s4;
                    o_mem_en <= '1';
                    o_mem_addr   <= int_address; --o_mem indirizzo 2
                    int_address <= int_address + "0000000000000001";--indirizzo 3
                end if;
                
           	elsif state=s4 then --aspetto
                state <= s5;
                o_mem_en <= '0';
                o_mem_we <= '0';
                
            elsif state=s5 then  --  lettura indirizzo 2 , valore x generico
                k<=k-1; 

                    if i_mem_data = "00000000" then
                    	o_mem_en <= '1'; --stampo il reg
                		o_mem_we   <= '1';
                        o_mem_data <= reg;  
                       
                        --Decremento C
               			if C /= "00000000" then
                    		C <= C-1;
                		end if;
                    else
                        --C a 31
                        C<= "00011111";
                        reg <= i_mem_data;
                        o_mem_en <= '0';                     
                    end if;
                    state <= s6;
                    
            elsif state=s6 then --stampo C, valore 0
            	k<=k-1;
                if k=0 then
                    state <=final;
	            else
                	int_address <= int_address + "0000000000000001"; --idnirizzo 4
            	    state <= s7;
                end if;
                o_mem_en <= '1';
                o_mem_we   <= '1'; 
                o_mem_addr <= int_address; --o_mem indirizzo 3
                o_mem_data <= C;
                
            elsif state=s7 then --richiesta
                o_mem_we <= '0';
            	o_mem_en <= '1';
                o_mem_addr   <= int_address; --o_mem indirizzo 4
                int_address <= int_address + "0000000000000001"; --indirizzo 5
            	state <= s4; 
            
            elsif state=final then
                if i_start = '0' then
				    state<=rst;
				    o_done <= '0';
				    o_mem_en <= '0';
				    o_mem_we <= '0';
				else
                    o_mem_en <= '0';
                    o_mem_we <= '0';
                    o_done <= '1';
                    state <= final;
				end if;
            end if;
        end if;
    end process;
end Behavioral;