library ieee;
use ieee.std_logic_1164.all;

entity MIPSentregaFinal is
	generic ( 
		largura_dados : natural := 32;
		largura_endereco : natural := 32;
		largura_endereco_reg : natural := 5;
		simulacao : boolean := TRUE
	);
	port (
		CLOCK_50			: in std_logic;
		KEY 					: in std_logic_vector(3 downto 0);
		FPGA_RESET_N 		: in std_logic;
		SW 					: in std_logic_vector(9 downto 0);
	 
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector (6 DOWNTO 0);
		LEDR  				: out std_logic_vector(9 downto 0)
	);
end entity;


architecture arquitetura of MIPSentregaFinal is

	signal CLK 							: std_logic;
	
--- IF ---
	signal PC_OUT						: std_logic_vector(largura_dados-1 downto 0);
	
--- IF/ID ---
	signal Instrucao 					: std_logic_vector(largura_dados-1 downto 0);
	signal PC_M_4_IF_ID 				: std_logic_vector(largura_dados-1 downto 0);
	
--- IF/ID OUT ---
	signal Instrucao_OUT 			: std_logic_vector(largura_dados-1 downto 0);
	signal PC_M_4_IF_ID_OUT  		: std_logic_vector(largura_dados-1 downto 0);
	
--- ID ---
	signal shifted_I_for_J			: std_logic_vector(largura_dados-1 downto 0);
	signal sel_PC_JMP					: std_logic;
	signal sel_PC_JR					: std_logic;
	signal stall						: std_logic;

--- ID/EX ---
	signal I_Extended					: std_logic_vector(largura_dados-1 downto 0);
	signal Addr_Rs_ID_EX				: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal Addr_Rt_ID_EX				: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal Addr_Rd_ID_EX				: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal Data_Rs_ID_EX 			: std_logic_vector(largura_dados-1 downto 0);
	signal Data_Rt_ID_EX 			: std_logic_vector(largura_dados-1 downto 0);
	signal PC_M_4_ID_EX 				: std_logic_vector(largura_dados-1 downto 0);
	signal Imediato_LUI_ID_EX 		: std_logic_vector(largura_dados-1 downto 0);
	
	signal ULA_Ctrl					: std_logic_vector(2 downto 0);
	signal EX_ctrl						: std_logic_vector(3 downto 0);
	signal MEM_Ctrl_ID_EX			: std_logic_vector(3 downto 0);
	signal WB_Ctrl_ID_EX				: std_logic_vector(2 downto 0);
	
--- ID/EX OUT ---
	signal I_Extended_OUT			: std_logic_vector(largura_dados-1 downto 0);
	signal Addr_Rs_ID_EX_OUT		: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal Addr_Rt_ID_EX_OUT		: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal Addr_Rd_ID_EX_OUT		: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal Data_Rs_ID_EX_OUT 		: std_logic_vector(largura_dados-1 downto 0);
	signal Data_Rt_ID_EX_OUT 		: std_logic_vector(largura_dados-1 downto 0);
	signal PC_M_4_ID_EX_OUT 		: std_logic_vector(largura_dados-1 downto 0);
	signal Imediato_LUI_ID_EX_OUT : std_logic_vector(largura_dados-1 downto 0);
	
	signal ULA_Ctrl_OUT				: std_logic_vector(2 downto 0);
	signal EX_ctrl_OUT				: std_logic_vector(3 downto 0);
	signal MEM_Ctrl_ID_EX_OUT		: std_logic_vector(3 downto 0);
	signal WB_Ctrl_ID_EX_OUT		: std_logic_vector(2 downto 0);
	
--- EX/MEM ---
	signal Addr_Rd_EX_MEM			: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal MUX_BEQ_BNE_OUT			: std_logic;
	signal PC_M_4_EX_MEM 			: std_logic_vector(largura_dados-1 downto 0);
	signal Imediato_LUI_EX_MEM 	: std_logic_vector(largura_dados-1 downto 0);
	signal Data_Rt_EX_MEM 			: std_logic_vector(largura_dados-1 downto 0);
	signal Data_ULA_EX_MEM 			: std_logic_vector(largura_dados-1 downto 0);
	signal PC_BEQ_EX_MEM				: std_logic_vector(largura_dados-1 downto 0);
	
	signal MEM_Ctrl_EX_MEM			: std_logic_vector(3 downto 0);
	signal WB_Ctrl_EX_MEM			: std_logic_vector(2 downto 0);
	
--- EX/MEM OUT ---
	signal Addr_Rd_EX_MEM_OUT		: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal MUX_BEQ_BNE_OUT_OUT		: std_logic;
	signal PC_M_4_EX_MEM_OUT 		: std_logic_vector(largura_dados-1 downto 0);
	signal Imediato_LUI_EX_MEM_OUT: std_logic_vector(largura_dados-1 downto 0);
	signal Data_Rt_EX_MEM_OUT 		: std_logic_vector(largura_dados-1 downto 0);
	signal Data_ULA_EX_MEM_OUT 	: std_logic_vector(largura_dados-1 downto 0);
	signal PC_BEQ_EX_MEM_OUT		: std_logic_vector(largura_dados-1 downto 0);
	
	signal MEM_Ctrl_EX_MEM_OUT		: std_logic_vector(3 downto 0);
	signal WB_Ctrl_EX_MEM_OUT		: std_logic_vector(2 downto 0);
	
--- MEM ---
	signal PC_BEQ_Res					: std_logic_vector(largura_dados-1 downto 0);
	signal sel_PC_BEQ					: std_logic;

--- MEM/WB ---
	signal Data_RAM_OUT				: std_logic_vector(largura_dados-1 downto 0);
	signal Data_ULA_MEM_WB 			: std_logic_vector(largura_dados-1 downto 0);
	signal Imediato_LUI_MEM_WB 	: std_logic_vector(largura_dados-1 downto 0);
	signal Addr_Rd_MEM_WB			: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal PC_M_4_MEM_WB 			: std_logic_vector(largura_dados-1 downto 0);
	signal WB_Ctrl_MEM_WB			: std_logic_vector(2 downto 0);
	
--- MEM/WB OUT ---
	signal Data_RAM_OUT_OUT			: std_logic_vector(largura_dados-1 downto 0);
	signal Data_ULA_MEM_WB_OUT 	: std_logic_vector(largura_dados-1 downto 0);
	signal Imediato_LUI_MEM_WB_OUT: std_logic_vector(largura_dados-1 downto 0);
	signal Addr_Rd_MEM_WB_OUT		: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal PC_M_4_MEM_WB_OUT 		: std_logic_vector(largura_dados-1 downto 0);
	signal WB_Ctrl_MEM_WB_OUT		: std_logic_vector(2 downto 0);

--- WB OUT ---
	signal Addr_Rd_Final				: std_logic_vector(largura_endereco_reg-1 downto 0);
	signal Data_Rd_Final				: std_logic_vector(largura_dados-1 downto 0);
	signal habEscritaReg				: std_logic;
		
--- Display ---
	signal MUX_Display_OUT			: std_logic_vector(largura_dados-1 downto 0);
	
	
  
begin

gravar: if simulacao generate
CLK <= KEY(0);
else generate
CLK <= CLOCK_50;
end generate;


FETCH: entity work.FETCH
			port map (
				-- CLOCK:
					CLK 					=> CLK,		
				
				-- INPUT:
					puloPC_BEQ_OUT		=> PC_BEQ_Res,
					shift_imediato_J 	=> shifted_I_for_J,
					Rs_OUT				=> Data_Rs_ID_EX,
					
				-- MUX SELECTORS:
					Sel_MUX_PC_BEQ		=> sel_PC_BEQ,
					sel_MUX_PC_BEQ_JMP=> sel_PC_JMP,
					sel_MUX_JR			=> sel_PC_JR,
					stall					=> stall,
					
				-- OUTPUT:
					Instrucao			=> Instrucao,
					PC_M_4				=> PC_M_4_IF_ID,
					PC_AT_OUT			=> PC_OUT
			);
			

			
REG_IF_ID: entity work.registradorGenerico
			generic map (
				larguraDados => 64
			)
			port map (
					CLK => CLK,
					RST => '0',
					ENABLE => not(stall),
				
				-- DIN
					DIN(31 downto 0) 		=> Instrucao,
					DIN(63 downto 32) 	=> PC_M_4_IF_ID,
				
				-- DOUT
					DOUT(31 downto 0) 	=> Instrucao_OUT,
					DOUT(63 downto 32) 	=> PC_M_4_IF_ID_OUT
			);
	
	

DECODE: entity work.DECODE
			port map (
				-- CLOCK:
					CLK              	=> CLK,
				
				-- INPUT:
					Instrucao			=> Instrucao_OUT,
					PC_DEC_IN			=> PC_M_4_IF_ID_OUT,
					Endereco_Destino	=> Addr_Rd_Final,
					RegBlock_IN			=> Data_Rd_Final,
					MEM_READ_ID_EX		=> MEM_Ctrl_ID_EX_OUT(1),
					Addr_Rt_ID_EX		=> Addr_Rt_ID_EX_OUT,
					
				-- HABILITA:
					habEscritaRegIN	=> habEscritaReg,
					
				-- OUTPUT:
					I_Extended			=> I_Extended,
					Addr_Rs_OUT			=> Addr_Rs_ID_EX,
					Addr_Rt_OUT			=> Addr_Rt_ID_EX,
					Addr_Rd_OUT			=> Addr_Rd_ID_EX,
					Data_Rs_OUT			=> Data_Rs_ID_EX,
					Data_Rt_OUT			=> Data_Rt_ID_EX,
					PC_DEC_OUT			=> PC_M_4_ID_EX,
					shifted_I_J_OUT	=> shifted_I_for_J,
					Imediato_LUI		=> Imediato_LUI_ID_EX,
					
				-- OUTPUT CONTROLE:
					ULA_Ctrl_OUT		=> ULA_Ctrl,
					EX_ctrl				=> EX_ctrl,
					MEM_Ctrl				=> MEM_Ctrl_ID_EX,
					WB_Ctrl				=> WB_Ctrl_ID_EX,
					sel_JMP				=> sel_PC_JMP,
					sel_JR				=> sel_PC_JR,
					stall_OUT			=> stall
			);

		
			
REG_ID_EX: entity work.registradorGenerico
			generic map (
				larguraDados => 189
			)
			port map (
					CLK => CLK,
					RST => '0',
					ENABLE => '1',
				
				-- DIN
					DIN(31 downto 0) 		=> I_Extended,
					DIN(36 downto 32) 	=> Addr_Rs_ID_EX,
					DIN(41 downto 37) 	=> Addr_Rt_ID_EX,
					DIN(46 downto 42)		=> Addr_Rd_ID_EX,
					DIN(78 downto 47)		=> Data_Rs_ID_EX,
					DIN(110 downto 79)	=> Data_Rt_ID_EX,
					DIN(142 downto 111)	=> PC_M_4_ID_EX,
					DIN(174 downto 143)	=> Imediato_LUI_ID_EX,
					DIN(177 downto 175)	=> ULA_Ctrl,
					DIN(181 downto 178)	=> EX_ctrl,
					DIN(185 downto 182)	=> MEM_Ctrl_ID_EX,
					DIN(188 downto 186)	=> WB_Ctrl_ID_EX,
					
				
				-- DOUT
					DOUT(31 downto 0) 	=> I_Extended_OUT,
					DOUT(36 downto 32) 	=> Addr_Rs_ID_EX_OUT,
					DOUT(41 downto 37) 	=> Addr_Rt_ID_EX_OUT,
					DOUT(46 downto 42)	=> Addr_Rd_ID_EX_OUT,
					DOUT(78 downto 47)	=> Data_Rs_ID_EX_OUT,
					DOUT(110 downto 79)	=> Data_Rt_ID_EX_OUT,
					DOUT(142 downto 111)	=> PC_M_4_ID_EX_OUT,
					DOUT(174 downto 143)	=> Imediato_LUI_ID_EX_OUT,
					DOUT(177 downto 175)	=> ULA_Ctrl_OUT,
					DOUT(181 downto 178)	=> EX_ctrl_OUT,
					DOUT(185 downto 182)	=> MEM_Ctrl_ID_EX_OUT,
					DOUT(188 downto 186)	=> WB_Ctrl_ID_EX_OUT
			);
			
			
			
			

EXECUTE: entity work.EXECUTE
			port map (
				-- CLOCK:
					CLK              		=> CLK,		
				
				-- INPUT CONTROLE:
					ULA_Ctrl					=> ULA_Ctrl_OUT,
					EX_Crtl					=> EX_ctrl_OUT,
					MEM_Ctrl_IN				=> MEM_Ctrl_ID_EX_OUT,
					WB_Ctrl_IN				=> WB_Ctrl_ID_EX_OUT,
					
				-- INPUT:
					PC_EX_IN					=> PC_M_4_ID_EX_OUT,
					I_Extended				=> I_Extended_OUT,
					Data_Rt					=> Data_Rt_ID_EX_OUT,
					Data_Rs					=> Data_Rs_ID_EX_OUT,
					Addr_Rs					=>	Addr_Rs_ID_EX_OUT,
					Addr_Rt					=>	Addr_Rt_ID_EX_OUT,
					Addr_Rd					=>	Addr_Rd_ID_EX_OUT,
					Imediato_LUI_IN		=> Imediato_LUI_ID_EX_OUT,
					RESULT_EX_MEM			=>	Data_ULA_EX_MEM_OUT,
					RESULT_MEM_WB			=> Data_Rd_Final,
					REG_DEST_EX_MEM		=> Addr_Rd_EX_MEM_OUT,
					REG_DEST_MEM_WB		=> Addr_Rd_Final,
					habEscritaREG_EX_MEM	=> WB_Ctrl_EX_MEM_OUT(2),
					habEscritaREG_MEM_WB	=> habEscritaReg,
					
				-- OUTPUT:
					Addr_Reg_Destino		=> Addr_Rd_EX_MEM,
					MUX_BEQ_BNE_OUT		=> MUX_BEQ_BNE_OUT,
					puloPC_BEQ_OUT			=> PC_BEQ_EX_MEM,
					Data_Rt_OUT				=> Data_Rt_EX_MEM,
					Imediato_LUI_OUT		=>	Imediato_LUI_EX_MEM,
					PC_EX_OUT				=> PC_M_4_EX_MEM,
					ULA_OUT					=>	Data_ULA_EX_MEM,
				
				-- OUTPUT CONTROLE:
					MEM_Ctrl_OUT			=> MEM_Ctrl_EX_MEM,
					WB_Ctrl_OUT				=> WB_Ctrl_EX_MEM
				
			);
			



REG_EX_MEM: entity work.registradorGenerico
			generic map (
				larguraDados => 173 
			)
			port map (
					CLK => CLK,
					RST => '0',
					ENABLE => '1',
				
				-- DIN
					DIN(4 downto 0) 		=> Addr_Rd_EX_MEM,
					DIN(5) 					=> MUX_BEQ_BNE_OUT,
					DIN(37 downto 6) 		=> PC_M_4_EX_MEM,
					DIN(69 downto 38) 	=> Imediato_LUI_EX_MEM,
					DIN(101 downto 70) 	=> Data_Rt_EX_MEM,
					DIN(133 downto 102) 	=> Data_ULA_EX_MEM,
					DIN(165 downto 134) 	=> PC_BEQ_EX_MEM,
					DIN(169 downto 166) 	=> MEM_Ctrl_EX_MEM,
					DIN(172 downto 170) 	=> WB_Ctrl_EX_MEM,
				
				-- DOUT
					DOUT(4 downto 0) 		=> Addr_Rd_EX_MEM_OUT,
					DOUT(5) 					=> MUX_BEQ_BNE_OUT_OUT,
					DOUT(37 downto 6) 	=> PC_M_4_EX_MEM_OUT,
					DOUT(69 downto 38) 	=> Imediato_LUI_EX_MEM_OUT,
					DOUT(101 downto 70) 	=> Data_Rt_EX_MEM_OUT,
					DOUT(133 downto 102) => Data_ULA_EX_MEM_OUT,
					DOUT(165 downto 134) => PC_BEQ_EX_MEM_OUT,
					DOUT(169 downto 166) => MEM_Ctrl_EX_MEM_OUT,
					DOUT(172 downto 170) => WB_Ctrl_EX_MEM_OUT
			);




MEM: entity work.MEM_ACCESS
			port map (
				-- CLOCK:
					CLK              	=> CLK,		
				
				-- INPUT:
					PC_MEM_IN			=> PC_M_4_EX_MEM_OUT,
					Data_Rt				=> Data_Rt_EX_MEM_OUT,
					Data_ULA_IN			=> Data_ULA_EX_MEM_OUT,
					MUX_BEQ_BNE_OUT	=> MUX_BEQ_BNE_OUT_OUT,
					Imediato_LUI_IN	=>	Imediato_LUI_EX_MEM_OUT,
					Addr_Rd_IN 			=> Addr_Rd_EX_MEM_OUT,
					pulo_PC_BEQ_IN		=> PC_BEQ_EX_MEM_OUT,
					
				-- INPUT COTROLE:
					MEM_Ctrl				=> MEM_Ctrl_EX_MEM_OUT,
					WB_Ctrl_IN			=> WB_Ctrl_EX_MEM_OUT,
					
				-- OUTPUT:
					RAM_OUT				=> Data_RAM_OUT,
					Data_ULA_OUT		=> Data_ULA_MEM_WB,
					Imediato_LUI_OUT	=> Imediato_LUI_MEM_WB,
					Addr_Rd_OUT			=> Addr_Rd_MEM_WB,
					PC_MEM_OUT			=> PC_M_4_MEM_WB,
					pulo_PC_BEQ_OUT	=>	PC_BEQ_Res,
					
				-- OUTPUT CONTROLE:
					WB_Ctrl_OUT			=> WB_Ctrl_MEM_WB,
					Sel_MUX_PC_BEQ    => sel_PC_BEQ
			);
			
			

REG_MEM_WB: entity work.registradorGenerico
			generic map (
				larguraDados => 136
			)
			port map (
					CLK => CLK,
					RST => '0',
					ENABLE => '1',
				
				-- DIN
					DIN(31 downto 0) 		=> Data_RAM_OUT,
					DIN(63 downto 32) 	=> Data_ULA_MEM_WB,
					DIN(95 downto 64) 	=> Imediato_LUI_MEM_WB,
					DIN(100 downto 96) 	=> Addr_Rd_MEM_WB,
					DIN(132 downto 101) 	=> PC_M_4_MEM_WB,
					DIN(135 downto 133) 	=> WB_Ctrl_MEM_WB,
				
				-- DOUT
					DOUT(31 downto 0) 	=> Data_RAM_OUT_OUT,
					DOUT(63 downto 32) 	=> Data_ULA_MEM_WB_OUT,
					DOUT(95 downto 64) 	=> Imediato_LUI_MEM_WB_OUT,
					DOUT(100 downto 96) 	=> Addr_Rd_MEM_WB_OUT,
					DOUT(132 downto 101) => PC_M_4_MEM_WB_OUT,
					DOUT(135 downto 133) => WB_Ctrl_MEM_WB_OUT
			);
			
			
			
WB: entity work.WRITE_BACK
			port map (
				-- CLOCK:	
					CLK              	=> CLK,
				
				-- INPUT:
					Addr_Rd_IN			=> Addr_Rd_MEM_WB_OUT,
					ULA_OUT				=> Data_ULA_MEM_WB_OUT,
					RAM_OUT				=> Data_RAM_OUT_OUT,
					PC_WB_IN				=> PC_M_4_MEM_WB_OUT,
					Imediato_LUI		=> Imediato_LUI_MEM_WB_OUT,
					
				-- INPUT COTROLE:
					WB_Ctrl				=> WB_Ctrl_MEM_WB_OUT,
					
				-- OUTPUT:
					Addr_Rd_OUT			=> Addr_Rd_Final,
					Data_Rd_OUT			=> Data_Rd_Final,
					
				-- OUTPUT CONTROLE:
					habEscritaReg_OUT	=> habEscritaReg
			);



			 
-------------------------------------------------------------------------------------------
--                                  Saídas no Display
-------------------------------------------------------------------------------------------
-- Mux para Display: Seleciona entre PC e saída da ULA
MUX_Display: entity work.muxGenerico4x1 generic map(larguraDados => largura_dados)
			port map (
				entradaA_MUX => PC_OUT,
				entradaB_MUX => PC_M_4_ID_EX_OUT, 
				entradaC_MUX => Data_ULA_EX_MEM,
				entradaD_MUX => Data_Rd_Final,
				seletor_MUX => SW(1 downto 0), 
				saida_MUX => MUX_Display_OUT
			);			 

------------------------------------------- HEXs ------------------------------------------
H0 : entity work.conversorHex7Seg
			port map (
				dadoHex => MUX_Display_OUT(3 downto 0),
				apaga => '0',
				negativo => '0',
            overFlow => '0',
            saida7seg => HEX0
			);

H1 : entity work.conversorHex7Seg
			port map (
				dadoHex => MUX_Display_OUT(7 downto 4),
				apaga =>  '0',
				negativo => '0',
				overFlow =>  '0',
				saida7seg => HEX1
			);
				  
H2 : entity work.conversorHex7Seg
			port map (
				dadoHex => MUX_Display_OUT(11 downto 8),
				apaga =>  '0',
				negativo => '0',
				overFlow =>  '0',
				saida7seg => HEX2
			);
					  
H3 : entity work.conversorHex7Seg
			port map (
				dadoHex => MUX_Display_OUT(15 downto 12),
				apaga =>  '0',
				negativo => '0',
				overFlow =>  '0',
				saida7seg => HEX3
			);
					  
H4 :  entity work.conversorHex7Seg
			port map ( 
				dadoHex => MUX_Display_OUT(19 downto 16),
				apaga =>  '0',
				negativo => '0',
				overFlow =>  '0',
				saida7seg => HEX4
			);
			  
H5 :  entity work.conversorHex7Seg
			port map (
				dadoHex => MUX_Display_OUT(23 downto 20),
				apaga =>  '0',
				negativo => '0',
				overFlow =>  '0',
				saida7seg => HEX5
			);


			
			
-------------------------------------------------------------------------------------------
--                                  VGA
-------------------------------------------------------------------------------------------			




			
------------------------------------------- LEDs ------------------------------------------
LEDR(3 downto 0) <= MUX_Display_OUT(27 downto 24);
LEDR(7 downto 4) <= MUX_Display_OUT(31 downto 28);


LEDR(8) <= habEscritaReg;
LEDR(9) <= MUX_BEQ_BNE_OUT;


end architecture;