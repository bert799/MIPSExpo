library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DECODE is
	generic ( 
		largura_dados : natural := 32;
		largura_endereco : natural := 32;
		largura_endereco_reg : natural := 5
	);
	port (
		-- CLOCK:
			CLK              	: in std_logic;		
		
		-- INPUT:
			Instrucao			: in std_logic_vector(largura_dados-1 downto 0);
			PC_DEC_IN			: in std_logic_vector(largura_dados-1 downto 0);
			Endereco_Destino	: in std_logic_vector(largura_endereco_reg-1 downto 0);
			RegBlock_IN			: in std_logic_vector(largura_dados-1 downto 0);
			MEM_READ_ID_EX		: in std_logic;
			Addr_Rt_ID_EX		: in std_logic_vector(largura_endereco_reg-1 downto 0);
			
		-- HABILITA:
			habEscritaRegIN	: in std_logic;
			
		-- OUTPUT:
			I_Extended			: out std_logic_vector(largura_dados-1 downto 0);
			Addr_Rs_OUT			: out std_logic_vector(largura_endereco_reg-1 downto 0);
			Addr_Rt_OUT			: out std_logic_vector(largura_endereco_reg-1 downto 0);
			Addr_Rd_OUT			: out std_logic_vector(largura_endereco_reg-1 downto 0);
			Data_Rs_OUT			: out std_logic_vector(largura_dados-1 downto 0);
			Data_Rt_OUT			: out std_logic_vector(largura_dados-1 downto 0);
			PC_DEC_OUT			: out std_logic_vector(largura_dados-1 downto 0);
			shifted_I_J_OUT	: out std_logic_vector(largura_dados-1 downto 0);
			Imediato_LUI		: out std_logic_vector(largura_dados-1 downto 0);
			
		-- OUTPUT CONTROLE:
			ULA_Ctrl_OUT		: out std_logic_vector(2 downto 0);
			EX_ctrl				: out std_logic_vector(3 downto 0);
			MEM_Ctrl				: out std_logic_vector(3 downto 0);
			WB_Ctrl				: out std_logic_vector(2 downto 0);
			sel_JMP				: out std_logic;
			sel_JR				: out std_logic;
			stall_OUT			: out std_logic
	);
end entity;

architecture arquitetura of DECODE is 

---Instrução---
	alias Opcode 				: std_logic_vector(5 downto 0)  is Instrucao(31 downto 26);
	alias Funct 				: std_logic_vector(5 downto 0)  is Instrucao(5 downto 0);
	alias Endereco_Rs 		: std_logic_vector(4 downto 0)  is Instrucao(25 downto 21);
	alias Endereco_Rt 		: std_logic_vector(4 downto 0)  is Instrucao(20 downto 16);
	alias Endereco_Rd 		: std_logic_vector(4 downto 0)  is Instrucao(15 downto 11);
	alias Imediato_I			: std_logic_vector(15 downto 0) is Instrucao(15 downto 0);
	alias Imediato_J			: std_logic_vector(25 downto 0) is Instrucao(25 downto 0);
	
---Banco Registradores---
	signal Rs_OUT 				: std_logic_vector(largura_dados-1 downto 0);
	signal Rt_OUT 				: std_logic_vector(largura_dados-1 downto 0);
	
---Pontos de Controle---
	signal palavra_Decoded  : std_logic_vector(13 downto 0);
	signal palavra_Controle : std_logic_vector(13 downto 0);
	alias JR		        		: std_logic 			is palavra_Controle(13);
	alias MUX_PC_BEQ_JMP		: std_logic 			is palavra_Controle(12);
	alias MUX_Rt_Rd_R31		: std_logic_vector 	is palavra_Controle(11 downto 10);
	alias ORI_ANDI				: std_logic 			is palavra_Controle(9);
	alias habEscritaReg		: std_logic 			is palavra_Controle(8);
	alias MUX_Rt_Imediato	: std_logic 			is palavra_Controle(7);
	alias MUX_ULA_MEM			: std_logic_vector 	is palavra_Controle(5 downto 4);
	alias BEQ					: std_logic 			is palavra_Controle(3);
	alias BNE					: std_logic 			is palavra_Controle(2);
	alias habLeituraMEM		: std_logic 			is palavra_Controle(1);
	alias habEscritaMEM		: std_logic 			is palavra_Controle(0);
	
---Pontos de Controle ULA---
	signal ULACtrl				: std_logic_vector(2 downto 0);
	
---Imediato I---
	signal Imediato_I_extd 	: std_logic_vector(largura_dados-1 downto 0);
	
---Imediato J---	
	signal shift_imediato_J : std_logic_vector(largura_dados-1 downto 0);
	
---Stall---
	signal stall				: std_logic;


begin

-------------------------------------------------------------------------------------------
--                                Bloco de Registradores
-------------------------------------------------------------------------------------------
REG_BLOCK: entity work.bancoReg 
			port map (
				clk=> CLK,
				enderecoA=> Endereco_Rs,
				enderecoB=> Endereco_Rt,
				enderecoC=> Endereco_Destino,
				dadoEscritaC=> RegBlock_IN,
				escreveC=> habEscritaRegIN,
				saidaA=> Rs_OUT,
				saidaB=> Rt_OUT
			);
			

-------------------------------------------------------------------------------------------
--                                       DECODER
-------------------------------------------------------------------------------------------
DECODER: work.ComponenteDeControle
			port map (
				opcode => Opcode,
				funct => Funct,
				palavraDeControle => palavra_Decoded, 
				ULACtrl => ULACtrl
			);
			
			
-------------------------------------------------------------------------------------------
--                                   Extende Imediato
-------------------------------------------------------------------------------------------
Estende_imediato : entity work.estendeSinalGenerico
			port map (
				estendeSinal_IN => Imediato_I,
				ORI_ANDI => ORI_ANDI,
				estendeSinal_OUT => Imediato_I_extd
			);
			

-------------------------------------------------------------------------------------------
--                                    SHIFT FOR JMP
-------------------------------------------------------------------------------------------
-- SHIFT: shift do Imediato Para o Tipo J
shift_imediato_J(1 downto 0) <= "00";
shift_imediato_J(27 downto 2) <= Imediato_J;
shift_imediato_J(31 downto 28) <= PC_DEC_IN(31 downto 28);	


-------------------------------------------------------------------------------------------
--                                       SHIFT LUI
-------------------------------------------------------------------------------------------		
-- Shift Imediato para Operação LUI:
Imediato_LUI(31 downto 16) <= Imediato_I;
Imediato_LUI(15 downto 0)  <= "0000000000000000";


-------------------------------------------------------------------------------------------
--                                        STALL
-------------------------------------------------------------------------------------------

stall <= '1' when ((MEM_READ_ID_EX = '1') and ((Addr_Rt_ID_EX = Endereco_Rs) or (Addr_Rt_ID_EX = Endereco_Rt))) else
			'0';


			
MUX_PAL_STALL: entity work.muxGenerico2x1
			generic map (
				larguraDados => 14
			)
			port map (
				entradaA_MUX => palavra_Decoded,
				entradaB_MUX => "00000000000000",
				seletor_MUX => stall,
				saida_MUX => palavra_Controle
			);
			

-------------------------------------------------------------------------------------------
--                                       OUTPUTS
-------------------------------------------------------------------------------------------
-- Shift Imediato
I_Extended <= Imediato_I_extd;
shifted_I_J_OUT <= shift_imediato_J;

-- PC+4 Pass
PC_DEC_OUT <= PC_DEC_IN;

-- Endereços de Rt e Rd
Addr_Rs_OUT <= Endereco_Rs;
Addr_Rt_OUT <= Endereco_Rt;
Addr_Rd_OUT <= Endereco_Rd;

-- Dados de Rs e Rt
Data_Rs_OUT <= Rs_OUT;
Data_Rt_OUT <= Rt_OUT;

-- Pontos de Controle:
ULA_Ctrl_OUT <= ULACtrl;
sel_JMP <= MUX_PC_BEQ_JMP;
sel_JR <= JR;

-- Stall
stall_OUT <= stall;

-- Controle para Execução
EX_ctrl(3 downto 2) <= MUX_Rt_Rd_R31;
EX_ctrl(1) <= MUX_Rt_Imediato;
EX_ctrl(0) <= BEQ;

-- Controle de Acesso Memória
MEM_Ctrl(3) <= BEQ;
MEM_Ctrl(2) <= BNE;
MEM_Ctrl(1) <= habLeituraMEM;
MEM_Ctrl(0) <= habEscritaMEM;

-- Controle de WB:
WB_Ctrl(2) <= habEscritaReg;
WB_Ctrl(1 downto 0) <= MUX_ULA_MEM;

end architecture;
