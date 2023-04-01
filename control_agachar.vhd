-- Control de agachar al presionar el boton

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity control_agachar is
	generic(
		counter_size: integer := 26
	);
	port(
		clk: in std_logic;
		key2: in std_logic; -- activa en bajo
		pulse2: out std_logic := '0'		
	);
end control_agachar;


architecture arch of control_agachar is	
	signal counter: std_logic_vector(counter_size-1 downto 0) := (others => '0');
	signal ff1, ff2: std_logic;
	signal reset: std_logic;
	begin		
		reset <= ff1 xor ff2;
		process(clk)
			variable pulso_activo : std_logic := '0';			
		begin
			if(clk'event and clk='1') then
				ff1 <= key2;
				ff2 <= ff1;			
				if(reset = '1' and pulso_activo = '0') then
					pulse2 <= '1';
					counter <= (others => '0');
					pulso_activo := '1';
				elsif(counter(counter_size-1) /= '1') then
					counter <= counter + 1;
				else
					pulse2 <= '0';
					pulso_activo := '0';
				end if;
			end if;
		end process;		
	end arch;