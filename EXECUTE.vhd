library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXECUTE is
	generic ( 
		largura_dados : natural := 32;
		largura_endereco : natural := 32;
		largura_endereco_reg : natural := 5
	);
	port (
		-- CLOCK:
			CLK              		: in std_logic;		
		
		-- INPUT CONTROLE:
			ULA_Ctrl					: in std_logic_vector(2 downto 0);
			EX_Crtl					: in std_logic_vector(3 downto 0);
			MEM_Ctrl_IN				: in std_logic_vector(3 downto 0);
			WB_Ctrl_IN				: in std_logic_vector(2 downto 0);
			
		-- INPUT:
			PC_EX_IN					: in std_logic_vector(largura_dados-1 downto 0);
			I_Extended				: in std_logic_vector(largura_dados-1 downto 0);
			Data_Rt					: in std_logic_vector(largura_dados-1 downto 0);
			Data_Rs					: in std_logic_vector(largura_dados-1 downto 0);
			Addr_Rs					: in std_logic_vector(largura_endereco_reg-1 downto 0);
			Addr_Rt					: in std_logic_vector(largura_endereco_reg-1 downto 0);
			Addr_Rd					: in std_logic_vector(largura_endereco_reg-1 downto 0);
			Imediato_LUI_IN		: in std_logic_vector(largura_dados-1 downto 0);
			RESULT_EX_MEM			: in std_logic_vector(largura_dados-1 downto 0);
			RESULT_MEM_WB			: in std_logic_vector(largura_dados-1 downto 0);
			REG_DEST_EX_MEM		: in std_logic_vector(largura_endereco_reg-1 downto 0);
			REG_DEST_MEM_WB		: in std_logic_vector(largura_endereco_reg-1 downto 0);
			habEscritaREG_EX_MEM	: in std_logic;
			habEscritaREG_MEM_WB	: in std_logic;
			
		-- OUTPUT:
			Addr_Reg_Destino		: out std_logic_vector(largura_endereco_reg-1 downto 0);
			MUX_BEQ_BNE_OUT		: out std_logic;
			puloPC_BEQ_OUT			: out std_logic_vector(largura_dados-1 downto 0);
			Data_Rt_OUT				: out std_logic_vector(largura_dados-1 downto 0);
			Imediato_LUI_OUT		: out std_logic_vector(largura_dados-1 downto 0);
			PC_EX_OUT				: out std_logic_vector(largura_dados-1 downto 0);
			ULA_OUT					: out std_logic_vector(largura_dados-1 downto 0);
			
		-- OUTPUT CONTROLE:
			MEM_Ctrl_OUT			: out std_logic_vector(3 downto 0);
			WB_Ctrl_OUT				: out std_logic_vector(2 downto 0)
	);
end entity;

architecture arquitetura of EXECUTE is 

---MUX Sel---
	signal selMUXForwardingA	: std_logic_vector(1 downto 0);
	signal selMUXForwardingB	: std_logic_vector(1 downto 0);
	
---MUX Forwarding---
	signal MUX_FOR_A_OUT			: std_logic_vector(largura_dados-1 downto 0);
	signal MUX_FOR_B_OUT			: std_logic_vector(largura_dados-1 downto 0);

---ULA---
	signal MUX_ULA_OUT 			: std_logic_vector(largura_dados-1 downto 0);
	signal Is_Igual				: std_logic;
	
---Imediato I---
	signal shift_I_BEQ 			: std_logic_vector(largura_dados-1 downto 0);

begin

			
-------------------------------------------------------------------------------------------
--                                     FORWARDING
-------------------------------------------------------------------------------------------	
-- Seletor do Mux para forwarding da porta A da ULA
selMUXForwardingA <= "10" when ((habEscritaREG_MEM_WB = '1') and (REG_DEST_MEM_WB /= "00000") 
											and not((habEscritaREG_EX_MEM = '1') and (REG_DEST_EX_MEM /= "00000") 
											and (REG_DEST_EX_MEM = Addr_Rs)) and (REG_DEST_MEM_WB = Addr_Rs)) else
							"01" when ((habEscritaREG_EX_MEM = '1') and (REG_DEST_EX_MEM /= "00000") 
											and (REG_DEST_EX_MEM = Addr_Rs)) else
							"00";


---------------------------- MUX Forwarding entrada A ULA ---------------------------------
MUX_FOR_A: entity work.muxGenerico4x1 generic map(larguraDados => largura_dados)
			port map (
				entradaA_MUX => Data_Rs, 
				entradaB_MUX => RESULT_EX_MEM, 
				entradaC_MUX => RESULT_MEM_WB,
				entradaD_MUX => x"00000000",
				seletor_MUX => selMUXForwardingA, 
				saida_MUX => MUX_FOR_A_OUT
			);

			
-- Seletor do Mux para forwarding da porta B da ULA
selMUXForwardingB <= "10" when ((habEscritaREG_MEM_WB = '1') and (REG_DEST_MEM_WB /= "00000") 
											and not((habEscritaREG_EX_MEM = '1') and (REG_DEST_EX_MEM /= "00000") 
											and (REG_DEST_EX_MEM = Addr_Rt)) and (REG_DEST_MEM_WB = Addr_Rt)) else
							"01" when ((habEscritaREG_EX_MEM = '1') and (REG_DEST_EX_MEM /= "00000") 
											and (REG_DEST_EX_MEM = Addr_Rt)) else
							"00";


---------------------------- MUX Forwarding entrada B ULA ---------------------------------
MUX_FOR_B: entity work.muxGenerico4x1 generic map(larguraDados => largura_dados)
			port map (
				entradaA_MUX => Data_Rt, 
				entradaB_MUX => RESULT_EX_MEM, 
				entradaC_MUX => RESULT_MEM_WB,
				entradaD_MUX => x"00000000",
				seletor_MUX => selMUXForwardingB, 
				saida_MUX => MUX_FOR_B_OUT
			);			
			
			

			
----------------------------------- MUX entrada B ULA -------------------------------------
-- Mux: seleciona entre os dados em Rt ou Imediato para a entrada B da ULA
MUX_ULA: entity work.muxGenerico2x1 generic map(larguraDados => largura_dados)
			port map (
				entradaA_MUX => MUX_FOR_B_OUT, 
				entradaB_MUX => I_Extended, 
				seletor_MUX => EX_Crtl(1), 
				saida_MUX => MUX_ULA_OUT
			);			

-------------------------------------------------------------------------------------------
--                                         ULA
-------------------------------------------------------------------------------------------
ULA : entity work.ULAMIPS  generic map(larguraDados => largura_dados)
			port map (
				A => MUX_FOR_A_OUT, 
				B =>  MUX_ULA_OUT, 
				sel => ULA_Ctrl(1 downto 0), 
				invB => ULA_Ctrl(2),
				Saida => ULA_OUT, 
				isEQ=> Is_Igual
			);
			



-------------------------------------------------------------------------------------------
--                                   Config BEQ & BNE
-------------------------------------------------------------------------------------------
-- SHIFT: shift do Imediato Para o Tipo I para BEQ
shift_I_BEQ(1 downto 0) <= "00";
shift_I_BEQ(31 downto 2) <= I_Extended(29 downto 0);


-- Somador de PC+4 + BEQ
puloPCBEQ: entity work.somadorGenerico generic map (larguraDados => largura_dados)
			port map (
				entradaA => PC_EX_IN, 
				entradaB => shift_I_BEQ, 
				saida => puloPC_BEQ_OUT
			);
			

-- Mux entre igual ou diferente
MUX_BEQ_BNE : entity work.mux2x1
			port map (
				entradaA_MUX => not(Is_Igual), 
				entradaB_MUX => Is_Igual, 
				seletor_MUX =>  EX_Crtl(0), 
				saida_MUX => MUX_BEQ_BNE_OUT
			);
			

-------------------------------------------------------------------------------------------
--                                     Addr Destino
-------------------------------------------------------------------------------------------
-- Mux: seleciona o endereço do registrador de destino: entre o endereço de Rd ou Rt ou R31
MUX_RD_ADDR: entity work.muxGenerico4x1 generic map(larguraDados => 5)
			port map (
				entradaA_MUX => Addr_Rt, 
				entradaB_MUX => Addr_Rd,
				entradaC_MUX => "11111",      --R31
				entradaD_MUX => "00000",      --R0, preenchimento
				seletor_MUX => EX_Crtl(3 downto 2), 
				saida_MUX => Addr_Reg_Destino
			); 	
			
-------------------------------------------------------------------------------------------
--                                       OUTPUTS
-------------------------------------------------------------------------------------------

-- Passagem Valor Rt para SW
Data_Rt_OUT <= Data_Rt;

-- Passagem dos controles de MEM e WB
MEM_Ctrl_OUT <= MEM_Ctrl_IN;
WB_Ctrl_OUT <= WB_Ctrl_IN;


-- Passagem do LUI
Imediato_LUI_OUT <= Imediato_LUI_IN;

-- Passagem PC + 4:
PC_EX_OUT <= PC_EX_IN;


end architecture;
