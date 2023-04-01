library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.all;
--use ieee.numeric_std.ALL;
use ieee.std_logic_arith.ALL;

entity draw_trex is
	generic(
		H_counter_size: natural:= 10;
		V_counter_size: natural:= 10
	);
	port(
		clk: in std_logic;
		jump: in std_logic;
		agachar: in std_logic;
		pixel_x: in integer;
		pixel_y: in integer;
		rgbDrawColor: out std_logic_vector(11 downto 0) := (others => '0')
	);
end draw_trex;

architecture arch of draw_trex is
	constant PIX : integer := 16;
	constant COLS : integer := 40;
	constant T_FAC : integer := 100000;
	constant cactusSpeed1: integer := 70;
	constant cactusSpeed2 : integer := 100;
	constant cloudSpeed1 : integer := 60;
	constant cloudSpeed2 : integer := 80;
	constant cloudSpeed3 : integer := 100;
	constant cloudSpeed4 : integer := 120;
	constant cloudSpeed5 : integer := 140;
	constant teroSpeed : integer := 160;
	
	signal cloudX_1: integer := 40;
	signal cloudY_1: integer := 0;
	signal cloudX_2: integer := 40;
	signal cloudY_2: integer := 4;
	signal cloudX_3: integer := 40;
	signal cloudY_3: integer := 6;
	signal cloudX_4: integer := 40;
	signal cloudY_4: integer := 8;
	signal cloudX_5: integer := 40;
	signal cloudY_5: integer := 6;
	
	-- T-Rex
	signal trexX: integer := 8;
	signal trexY: integer := 24;
	signal saltando: std_logic := '0';
	signal agachando: std_logic := '0';
	
	-- Terodactylo
	signal teroX: integer := COLS; 
	signal teroY: integer := 20;
	
	-- Cactus	
	signal cactusX_1: integer := COLS;
	signal cactusY: integer := 24;
	signal cactusX_2: integer := COLS;
	signal cactusY2: integer := 24;
	
	
-- Sprites
type sprite_block is array(0 to 15, 0 to 15) of integer range 0 to 1;
type sprite_block1 is array(0 to 15, 0 to 25) of integer range 0 to 1;
constant cloud: sprite_block:=(  (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 5
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 6
									 (0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0), -- 7
									 (0,0,0,0,0,1,1,0,0,0,1,1,1,1,0,0), -- 8
									 (0,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1), -- 9
									 (1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1), -- 10
									 (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1), -- 11
									 (0,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1), -- 12
		 							 (0,0,1,1,1,1,0,0,0,0,0,1,1,0,0,0), -- 13
									 (0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0), -- 14
									 (0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0));-- 15

constant trex_2: sprite_block:=((0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 0 
									(0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1), -- 1 
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 2
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 3
									(0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0), -- 4
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0), -- 5
									(0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 6
									(1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 7
									(1,1,0,0,1,1,1,1,1,1,1,0,0,1,0,0), -- 8
									(1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
									(0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 10
									(0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 11
									(0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
		 							(0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0), -- 13
									(0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0), -- 14
									(0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0));-- 15
								
constant trex_3: sprite_block1:= ((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0
                           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1
                           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
                           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 3
                           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,1,1), -- 4
                           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,1,1), -- 5
                           (0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 6
                           (0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 7
                           (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 8
                           (0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0), -- 9
                           (0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0), -- 10
                           (0,0,0,0,0,1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,0,0,0), -- 11
                           (0,0,0,0,0,0,1,1,1,0,1,1,0,0,0,0,0,0,1,1,1,0,1,1,0,0), -- 12
                           (0,0,0,0,0,0,0,1,1,1,0,1,1,1,0,0,0,0,1,1,0,0,1,1,1,0), -- 13
                           (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0), -- 14
                           (0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,1,1,1,0,1,0,0,0,0)); --15
	

constant cactus: sprite_block :=((0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,1,0,1,1,1,0,1,0,0,0,0), -- 4
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 5
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 6
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 7
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 8
									 (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 9
									 (0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0), -- 10
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 11
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0));-- 15		

constant tero_1: sprite_block:=((0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 2
									 (0,0,0,1,1,0,0,1,1,1,1,0,0,0,0,0), -- 3
									 (0,0,1,1,1,0,0,1,1,1,1,1,0,0,0,0), -- 4
									 (0,1,1,1,1,0,0,1,1,1,1,1,1,0,0,0), -- 5
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 6
									 (0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1), -- 7
									 (0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0), -- 8
									 (0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0), -- 9
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 11
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 10
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15
									 
type color_arr is array(0 to 1) of std_logic_vector(11 downto 0);									 
constant sprite_color : color_arr := ("000000000000", "000000001111");
constant sprite_color2 : color_arr := ("000000000000", "000011110000");

begin
	draw_objects: process(clk, pixel_x, pixel_y)	
	
	variable sprite_x : integer := 0;
	variable sprite_y : integer := 0;
	
	begin			
		if(clk'event and clk='1') then		
			-- Dibuja el fondo
			rgbDrawColor <= "0000" & "0000" & "0000";
					
			-- Dibuja el suelo
			if(pixel_y = 400 or pixel_y = 401) then
				rgbDrawColor <= "1100" & "1100" & "1100";		
			end if;
			
			sprite_x := pixel_x mod PIX;
			sprite_y := pixel_y mod PIX;
			
			-- Tero
			if ((pixel_x / PIX = teroX) and (pixel_y / PIX = teroY)) then 
				rgbDrawColor <= sprite_color(tero_1(sprite_y, sprite_x));
			end if;	
							
			-- Nube 1
			if ((pixel_x / PIX = cloudX_1) and (pixel_y / PIX = cloudY_1)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;	
	
         -- Nube 2
			if ((pixel_x / PIX = cloudX_2) and (pixel_y / PIX =cloudY_2)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;		
			
			-- Nube 3
			if ((pixel_x / PIX = cloudX_3) and (pixel_y / PIX = cloudY_3)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;
			
		   -- Nube 4
			if ((pixel_x / PIX = cloudX_4) and (pixel_y / PIX = cloudY_4)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;	
			
			-- Nube 5
			if ((pixel_x / PIX = cloudX_5) and (pixel_y / PIX = cloudY_5)) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
			end if;	
			
			-- Cactus1
			if ((pixel_x / PIX = cactusX_1) and (pixel_y / PIX = cactusY)) then 
				rgbDrawColor <= sprite_color2(cactus(sprite_y, sprite_x));
			end if;
		
		   -- cactus2
			if ((pixel_x / PIX = cactusX_2) and (pixel_y / PIX = cactusY2)) then 
				rgbDrawColor <= sprite_color2(cactus(sprite_y, sprite_x));
			end if;	
			
			
			-- T-Rex
			if (saltando = '1') then
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color2(trex_2(sprite_y, sprite_x));			
				end if;
			else
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color(trex_2(sprite_y, sprite_x));			
				end if;
			end if;
			
			if (agachando = '1') then
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color2(trex_3(sprite_y, sprite_x));			
				end if;
			else
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color(trex_2(sprite_y, sprite_x));			
				end if;
			end if;
			
		end if;
	end process;
	
	actions: process(clk, jump)	
	variable cactusCount1: integer := 0;
	variable cactusCount2: integer := 0;
	variable cloudCount1: integer := 0;
	variable cloudCount2: integer := 0;
	variable cloudCount3: integer := 0;
	variable cloudCount4: integer := 0;
	variable cloudCount5: integer := 0;
	variable teroCount: integer := 0;
	begin		
			if(clk'event and clk = '1') then
			
			-- Salto
			if(jump = '1') then
				saltando <= '1';
				if (trexY > 20) then
					trexY <= trexY - 1;
				else
					saltando <= '0';
				end if;
			else
			   saltando <= '0';
				if (trexY < 24) then
					trexY <= trexY + 1;
				end if;
			end if;		
			
			-- Agacharse
			if(agachar = '1') then
				agachando <= '1';
			--	if (trexY > 20) then
				--	trexY <= trexY - 1;
				--else
					--agachando <= '0';
				--end if;
			else
			   agachando <= '0';
				--if (trexY < 24) then
					--trexY <= trexY + 1;
				--end if;
			end if;		
			
			
			
			-- Movimiento del Cactus 1
			-- Cactus Movement
			if (cactusCount1 >= T_FAC * cactusSpeed1) then
				if (cactusX_1 <= 0) then
					cactusX_1 <= COLS;				
				else
					cactusX_1 <= cactusX_1 - 1;					
				end if;
				cactusCount1 := 0;
			end if;
			cactusCount1 := cactusCount1 + 1;
			
			-- Movimiento del Cactus 2
			if (cactusCount2 >= T_FAC * cactusSpeed2) then
				if (cactusX_2 <= 0) then
					cactusX_2 <= COLS;				
				else
					cactusX_2 <= cactusX_2 - 1;					
				end if;
				cactusCount2 := 0;
			end if;
			cactusCount2 := cactusCount2 + 1;
			
			-- Movimiento de la Nube 1
			if (cloudCount1 >= T_FAC * cloudSpeed1) then
				if (cloudX_1 <= 0) then
					cloudX_1 <= COLS;				
				else
					cloudX_1 <= cloudX_1 - 1;					
				end if;
				cloudCount1 := 0;
			end if;
			cloudCount1 := cloudCount1 + 1;
			
			-- Movimiento de la Nube 2
			if (cloudCount2 >= T_FAC * cloudSpeed2) then
				if (cloudX_2 <= 0) then
					cloudX_2 <= COLS;				
				else
					cloudX_2 <= cloudX_2 - 1;					
				end if;
				cloudCount2 := 0;
			end if;
			cloudCount2 := cloudCount2 + 1;
			
			-- Movimiento de la Nube 3
			if (cloudCount3 >= T_FAC * cloudSpeed3) then
				if (cloudX_3 <= 0) then
					cloudX_3 <= COLS;				
				else
					cloudX_3 <= cloudX_3 - 1;					
				end if;
				cloudCount3 := 0;
			end if;
			cloudCount3 := cloudCount3 + 1;
			
			-- Movimiento de la Nube 4
			if (cloudCount4 >= T_FAC * cloudSpeed4) then
				if (cloudX_4 <= 0) then
					cloudX_4 <= COLS;				
				else
					cloudX_4 <= cloudX_4 - 1;					
				end if;
				cloudCount4 := 0;
			end if;
			cloudCount4 := cloudCount4 + 1;
			
			-- Movimiento de la Nube 5
			if (cloudCount5 >= T_FAC * cloudSpeed5) then
				if (cloudX_5 <= 0) then
					cloudX_5 <= COLS;				
				else
					cloudX_5 <= cloudX_5 - 1;					
				end if;
				cloudCount5 := 0;
			end if;
			cloudCount5 := cloudCount5 + 1;
			
			--Movimiento del Terodactylo
			if (teroCount >= T_FAC * teroSpeed) then
				if (teroX <= 0) then
					teroX <= COLS;				
				else
					teroX <= teroX - 1;					
				end if;
				teroCount := 0;
			end if;
			teroCount := teroCount + 1;
			
			
			end if;
	end process;
	
end arch;