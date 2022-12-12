library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DecoderOpcode is
	port (
		opcode: in std_logic_vector(5 downto 0);
		saida: out std_logic_vector(2 downto 0)			
	);
end entity;

architecture comportamento of DecoderOpcode is 
	begin
		-- ULACtrl:
		-- 	(2)	Inverte B
		--  (1 ~ 0) MUX ULA
		

		saida <= "010" when opcode = "101011" else -- SW   -- op: Add
					"010" when opcode = "100011" else -- LW	-- op: Add
					"110" when opcode = "000100" else -- BEQ	-- op: Sub
					"110" when opcode = "000101" else -- BNE	-- op: Sub
					"010" when opcode = "001000" else -- ADDI -- op: Add
					"000" when opcode = "001100" else -- ANDI -- op: And
					"001" when opcode = "001101" else -- ORI  -- op: Or
					"111" when opcode = "001010" else -- SLTI -- op: Slt
					"000"; 
					
end architecture;
