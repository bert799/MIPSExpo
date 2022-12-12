library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DecoderFunct is
	port (
		funct: in std_logic_vector(5 downto 0);
		saida: out std_logic_vector(2 downto 0)			
	);
end entity;

architecture comportamento of DecoderFunct is 
	begin
		-- ULACtrl:
		-- 	(2)	Inverte B
		--  (1 ~ 0) MUX ULA
		
		saida <= "000" when funct = "100100" else -- op: AND
					"001" when funct = "100101" else -- op: OR
					"010" when funct = "100000" else -- op: ADD
					"110" when funct = "100010" else -- op: SUB
					"111" when funct = "101010" else -- op: SLT
					"000";  

					
end architecture;
