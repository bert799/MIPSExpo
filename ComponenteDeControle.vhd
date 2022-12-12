library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ComponenteDeControle is
	port (
			opcode: in std_logic_vector(5 downto 0);
			funct: in std_logic_vector(5 downto 0);
			palavraDeControle: out std_logic_vector(13 downto 0);
			UlaCtrl: out std_logic_vector(2 downto 0)
	);
end entity;

architecture arquitetura of ComponenteDeControle is 
	
	signal saidaDecOp_ULA: std_logic_vector(2 downto 0);
	signal saidaDecFun_ULA: std_logic_vector(2 downto 0);
	
	signal sel_ULA_OP : std_logic;
	
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
		
		
		-- Decodificação do Opcode para Palvra de Controle
		UnidadeDeControle : entity work.UnidadeDeControle
				port map(opcode=>opcode, funct => funct, saida=>palavraDeControle);
				
		-- Decodificação da operação da ULA vindo do Opcode
		DecOpcode_ULA : entity work.DecoderOpcode
				port map(opcode=>opcode , saida=>saidaDecOp_ULA);
				
		-- Decodificação da operação da ULA vindo da funct
		DecFunct_ULA : entity work.DecoderFunct
				port map(funct=>funct , saida=>saidaDecFun_ULA);
				
		
		-- Seleção da Operação da ULA vindo do Opcode(tipo I ou J) ou da funct(tipo R)
		sel_ULA_OP <= palavraDeControle(6);
		MUX_ULA_OP : entity work.muxGenerico2x1 generic map(larguraDados => 3)
				port map (entradaA_MUX => saidaDecOp_ULA, entradaB_MUX => saidaDecFun_ULA, seletor_MUX => sel_ULA_OP, saida_MUX => UlaCtrl);
		
end architecture;
