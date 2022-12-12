library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FETCH is
	generic ( 
		largura_dados : natural := 32;
		largura_endereco : natural := 32
	);
	port (
		-- CLOCK:
			CLK              	: in std_logic;		
		
		-- INPUT:
			puloPC_BEQ_OUT		: in std_logic_vector(largura_dados-1 downto 0);
			shift_imediato_J	: in std_logic_vector(largura_dados-1 downto 0);
			Rs_OUT				: in std_logic_vector(largura_dados-1 downto 0);
			
		-- MUX SELECTORS:
			Sel_MUX_PC_BEQ		: in std_logic;	--MUX_BEQ_BNE_OUT and (BEQ or BNE)
			sel_MUX_PC_BEQ_JMP: in std_logic;   --Unidade de Controle bit(12)
			sel_MUX_JR			: in std_logic;   --Unidade de Controle bit(13)
			stall					: in std_logic;
			
		-- OUTPUT:
			Instrucao			: out std_logic_vector(largura_dados-1 downto 0);
			PC_M_4				: out std_logic_vector(largura_dados-1 downto 0);
			PC_AT_OUT			: out std_logic_vector(largura_dados-1 downto 0)
	);
end entity;

architecture arquitetura of FETCH is 

---Program Counter---
	signal PC_IN 				: std_logic_vector(largura_dados-1 downto 0);
	signal PC_OUT 				: std_logic_vector(largura_dados-1 downto 0);
	signal IncrementaPC_OUT	: std_logic_vector(largura_dados-1 downto 0);
	signal MUX_PC_BEQ_OUT   : std_logic_vector(largura_dados-1 downto 0);
	signal MUX_PC_JMP_OUT  	: std_logic_vector(largura_dados-1 downto 0);


begin


-------------------------------------------------------------------------------------------
--                                   Program Counter
-------------------------------------------------------------------------------------------
-- Registrador Program Counter:
PC : entity work.registradorGenerico   generic map (larguraDados => largura_dados)
			port map (
				DIN => PC_IN, 
				DOUT => PC_OUT, 
				ENABLE => not(stall), 
				CLK => CLK, 
				RST => '0'
			);

-- Somador PC+4:
incrementaPC :  entity work.somaConstante  generic map (larguraDados => largura_dados, constante => 4)
			port map( 
				entrada => PC_OUT, 
				saida => IncrementaPC_OUT
			);


PC_M_4 <= IncrementaPC_OUT;
-------------------------------------------------------------------------------------------
--                                         ROM
-------------------------------------------------------------------------------------------
ROM : entity work.ROMMIPS
			port map (
				Endereco => PC_OUT, 
				Dado => Instrucao
			);


-------------------------------------------------------------------------------------------
--                                         MUX
-------------------------------------------------------------------------------------------


-- Mux entre PC+4 e BEQ
MUX_PC_BEQ : entity work.muxGenerico2x1 generic map(larguraDados => largura_dados)
			port map (
				entradaA_MUX => IncrementaPC_OUT, 
				entradaB_MUX => puloPC_BEQ_OUT, 
				seletor_MUX => Sel_MUX_PC_BEQ,
				saida_MUX => MUX_PC_BEQ_OUT
			);


-- Mux entre PC+4/BEQ e JMP
MUX_PC_BEQ_JMP : entity work.muxGenerico2x1 generic map(larguraDados => largura_dados)
			port map (
				entradaA_MUX => MUX_PC_BEQ_OUT, 
				entradaB_MUX => shift_imediato_J, 
				seletor_MUX => sel_MUX_PC_BEQ_JMP, 
				saida_MUX => MUX_PC_JMP_OUT
			);

-- Mux entre MUX_PC_JMP e JR
MUX_PC_JR : entity work.muxGenerico2x1 generic map(larguraDados => largura_dados)
			port map (
				entradaA_MUX => MUX_PC_JMP_OUT, 
				entradaB_MUX => Rs_OUT, 
				seletor_MUX => sel_MUX_JR, 
				saida_MUX => PC_IN
			);

			
-------------------------------------------------------------------------------------------
--                                       OUTPUTS
-------------------------------------------------------------------------------------------

PC_AT_OUT <= PC_OUT;

end architecture;
