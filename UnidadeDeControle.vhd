library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UnidadeDeControle is
	port (
			opcode: in std_logic_vector(5 downto 0);
			funct: in std_logic_vector(5 downto 0);
			saida: out std_logic_vector(13 downto 0)
	);
end entity;

architecture comportamento of UnidadeDeControle is 
	begin
		-- Palavra de Controle : 
		-- 	(13)	JR
		-- 	(12)	MuxPC+4/BEQ_JMP
		-- (11,10)	MUX_RT_RD_R31
		--		 (9)	ORI_ANDI
		-- 	 (8)	Hab_escrita_reg
		-- 	 (7)	Mux_RT_Im
		-- 	 (6)	Tipo_R
		--   (5,4)	Mux_ULA_Mem
		-- 	 (3)	BEQ
		-- 	 (2)	BNE
		-- 	 (1)	Hab_leitura_Mem
		-- 	 (0)	Hab_escrita_MEm
		
		
		saida <= "10000001000000" when opcode = "000000" and funct = "001000" else -- JR
					"00010101000000" when opcode = "000000" else -- Operações do tipo R fora JR
					"00000110010010" when opcode = "100011" else -- LW
					"00000010000001" when opcode = "101011" else -- SW
					"00000000001000" when opcode = "000100" else -- BEQ
					"01000000000000" when opcode = "000010" else -- JMP
					"00000100110000" when opcode = "001111" else -- LUI
					"00000110000000" when opcode = "001000" else -- ADDI
					"00001110000000" when opcode = "001100" else -- ANDI
					"00001110000000" when opcode = "001101" else -- ORI
					"00000110000000" when opcode = "001010" else -- SLTI
					"00000000000100" when opcode = "000101" else -- BNE
					"01100100100000" when opcode = "000011" else -- JAL
					"00000000000000"; -- NOP para operações não definidas
					
end architecture;
