library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_ACCESS is
	generic ( 
		largura_dados : natural := 32;
		largura_endereco : natural := 32;
		largura_endereco_reg : natural := 5
	);
	port (
		-- CLOCK:
			CLK              	: in std_logic;		
		
		-- INPUT:
			PC_MEM_IN			: in std_logic_vector(largura_dados-1 downto 0);
			Data_Rt				: in std_logic_vector(largura_dados-1 downto 0);
			Data_ULA_IN			: in std_logic_vector(largura_dados-1 downto 0);
			MUX_BEQ_BNE_OUT	: in std_logic;
			Imediato_LUI_IN	: in std_logic_vector(largura_dados-1 downto 0);
			Addr_Rd_IN 			: in std_logic_vector(largura_endereco_reg-1 downto 0);
			pulo_PC_BEQ_IN		: in std_logic_vector(largura_dados-1 downto 0);
			
		-- INPUT COTROLE:
			MEM_Ctrl				: in std_logic_vector(3 downto 0);
			WB_Ctrl_IN			: in std_logic_vector(2 downto 0);
			
		-- OUTPUT:
			RAM_OUT				: out std_logic_vector(largura_dados-1 downto 0);
			Data_ULA_OUT		: out std_logic_vector(largura_dados-1 downto 0);
			Imediato_LUI_OUT	: out std_logic_vector(largura_dados-1 downto 0);
			Addr_Rd_OUT			: out std_logic_vector(largura_endereco_reg-1 downto 0);
			PC_MEM_OUT			: out std_logic_vector(largura_dados-1 downto 0);
			pulo_PC_BEQ_OUT	: out std_logic_vector(largura_dados-1 downto 0);
				
			VGA_HS				:	out	std_logic;								--horiztonal sync pulse
			VGA_VS				:	out	std_logic;								--vertical sync pulse
			VGA_R					:	out	std_logic_vector(3 DOWNTO 0);
			VGA_G					:	out	std_logic_vector(3 DOWNTO 0);
			VGA_B					:	out	std_logic_vector(3 DOWNTO 0);			
			
		-- OUTPUT CONTROLE:
			WB_Ctrl_OUT			: out std_logic_vector(2 downto 0);
			Sel_MUX_PC_BEQ    : out std_logic
	);
end entity;

architecture arquitetura of MEM_ACCESS is 

signal HabRam 						: std_logic;

signal Base_tempo_OUT 			: std_logic;
signal ResetBaseTime 			: std_logic;
signal HabBaseTime				: std_logic;
signal FFBASETIME_OUT			: std_logic;

signal SIG_HAB_LIN_VGA			: std_logic;
signal SIG_HAB_COL_VGA			: std_logic;
signal SIG_HAB_DATA_VGA 		: std_logic;
signal SIG_HAB_WRITE_VGA_OUT 	: std_logic;

signal SIG_LIN_VGA 				: std_logic_vector(7 downto 0);
signal SIG_COL_VGA 				: std_logic_vector(7 downto 0);
signal SIG_DATA_VGA 				: std_logic_vector(7 downto 0);

begin

-------------------------------------------------------------------------------------------
--                                         RAM
-------------------------------------------------------------------------------------------

HabRam <= '1' when Data_ULA_IN(31 downto 6) = "00000000000000000000000000" else
			 '0';

RAM: entity work.RAMMIPS
			port map (
				clk => CLK, 
				Endereco => Data_ULA_IN, 
				Dado_in => Data_Rt, 
				Dado_out => RAM_OUT, 
				we => MEM_Ctrl(0), 
				re => MEM_Ctrl(1), 
				habilita => HabRam
			);
			
-------------------------------------------------------------------------------------------
--                                     BLOCO VGA
-------------------------------------------------------------------------------------------	

-------- Base de tempo ---------

-- Habilita leitura base de tempo
HabBaseTime <= '1' when Data_ULA_IN = x"000001FF" and MEM_Ctrl(1) = '1' else -- Lê base de tempo ao acessar endereço 511
					'0';

-- Habilita CLEAR base de tempo
ResetBaseTime <= '1' when Data_ULA_IN = x"00000200" and MEM_Ctrl(1) = '1' else -- RST base de tempo ao acessar endereço 512 
					  '0';
					  						
BaseDeTempoUmSegundo : entity work.divisorGenerico
        generic map (divisor => 4166666)   -- 24 fps.
        port map (clk => CLK, saida_clk => Base_tempo_OUT);
  
FFBASETEMPO : entity work.flipFlop
        port map (DIN => '1', DOUT => FFBASETIME_OUT, ENABLE => '1', CLK => Base_tempo_OUT, RST => ResetBaseTime);
		  
B3S_BASETEMPO :  entity work.buffer_3_state_mask
        port map(entrada => FFBASETIME_OUT, habilita =>  HabBaseTime, saida => RAM_OUT(0));
		  
-------- VGA ---------
		  
--Endereço 128
SIG_HAB_LIN_VGA <= '1' when Data_ULA_IN = x"00000080" and MEM_Ctrl(0) = '1' else 
						 '0';
						 
REG_LIN_VGA : entity work.registradorGenerico generic map (larguraDados => 8)
			port map(
				DIN => Data_Rt(7 downto 0),
				DOUT => SIG_LIN_VGA,
				ENABLE => SIG_HAB_LIN_VGA,
				CLK => CLK,
				RST => '0'
			);
			
			
--Endereço 129
SIG_HAB_COL_VGA <= '1' when Data_ULA_IN = x"00000081" and MEM_Ctrl(0) = '1' else
						 '0';
						 
REG_COL_VGA : entity work.registradorGenerico generic map (larguraDados => 8)
			port map(
				DIN => Data_Rt(7 downto 0),
				DOUT => SIG_COL_VGA,
				ENABLE => SIG_HAB_COL_VGA,
				CLK => CLK,
				RST => '0'
			);
			
	
--Endereço 130
SIG_HAB_DATA_VGA <= '1' when Data_ULA_IN = x"00000082" and MEM_Ctrl(0) = '1' else
						  '0';
						 
REG_DATA_VGA : entity work.registradorGenerico generic map (larguraDados => 8)
			port map(
				DIN => Data_Rt(7 downto 0),
				DOUT => SIG_DATA_VGA,
				ENABLE => SIG_HAB_DATA_VGA,
				CLK => CLK,
				RST => '0'
			);
						
--Endereço 131
SIG_HAB_WRITE_VGA_OUT <= '1' when Data_ULA_IN = x"00000083" and MEM_Ctrl(0) = '1' else
								 '0';	  

		  
driverVGA: entity work.driverVGA  
port map (CLOCK_50    => CLK,							--clock 50 MHz
	--FPGA_RESET_N:	IN		std_logic;				--active low asycnchronous reset
	VGA_HS				=> VGA_HS,						--horiztonal sync pulse
	VGA_VS				=> VGA_VS,						--vertical sync pulse
	VGA_R					=> VGA_R,		
	VGA_G					=> VGA_G,		
	VGA_B					=> VGA_B,		
	posLin 				=> SIG_LIN_VGA,	
	posCol 				=> SIG_COL_VGA,
	dadoIN 				=> SIG_DATA_VGA, 
	VideoRAMWREnable 	=> SIG_HAB_WRITE_VGA_OUT
	);	
			
-------------------------------------------------------------------------------------------
--                                       OUTPUTS
-------------------------------------------------------------------------------------------
-- Passagem dos pontos de controle de WB
WB_Ctrl_OUT <= WB_Ctrl_IN;

-- Seleção do MUX de BEQ ou PC+4
Sel_MUX_PC_BEQ <= MUX_BEQ_BNE_OUT and (MEM_Ctrl(3) or MEM_Ctrl(2));

-- Passagem do LUI
Imediato_LUI_OUT <= Imediato_LUI_IN;

-- Passagem Resultado ULA:
Data_ULA_OUT <= Data_ULA_IN;

-- Passagem Addr RD
Addr_Rd_OUT <= Addr_Rd_IN;

-- Passagem PC_MEM
PC_MEM_OUT <= PC_MEM_IN;

-- Recebe pulo do BEQ
pulo_PC_BEQ_OUT <= pulo_PC_BEQ_IN;

end architecture;
