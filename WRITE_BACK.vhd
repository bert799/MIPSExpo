library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WRITE_BACK is
	generic ( 
		largura_dados : natural := 32;
		largura_endereco : natural := 32;
		largura_endereco_reg : natural := 5
	);
	port (
		-- CLOCK:	
			CLK              	: in std_logic;
		
		-- INPUT:
			Addr_Rd_IN			: in std_logic_vector(largura_endereco_reg-1 downto 0);
			ULA_OUT				: in std_logic_vector(largura_dados-1 downto 0);
			RAM_OUT				: in std_logic_vector(largura_dados-1 downto 0);
			PC_WB_IN				: in std_logic_vector(largura_dados-1 downto 0);
			Imediato_LUI		: in std_logic_vector(largura_dados-1 downto 0);
			
		-- INPUT COTROLE:
			WB_Ctrl				: in std_logic_vector(2 downto 0);
			
		-- OUTPUT:
			Addr_Rd_OUT			: out std_logic_vector(largura_endereco_reg-1 downto 0);
			Data_Rd_OUT			: out std_logic_vector(largura_dados-1 downto 0);
			
		-- OUTPUT CONTROLE:
			habEscritaReg_OUT	: out std_logic
	);
end entity;

architecture arquitetura of WRITE_BACK is 


begin

-------------------------------------------------------------------------------------------
--                                        MUX WB
-------------------------------------------------------------------------------------------
-- MUX: seleciona entre a saida da ULA e a saída da RAM para guardar no banco de registradores
MUX_ULA_RAM: entity work.muxGenerico4x1 generic map(larguraDados => largura_dados)
			port map ( 
				entradaA_MUX => ULA_OUT, 
				entradaB_MUX => RAM_OUT,
				entradaC_MUX => PC_WB_IN,
				entradaD_MUX => Imediato_LUI,
				seletor_MUX => WB_Ctrl(1 downto 0), 
				saida_MUX => Data_Rd_OUT
			); 
			

-------------------------------------------------------------------------------------------
--                                       OUTPUTS
-------------------------------------------------------------------------------------------
-- informa qual será o endereço de escrita dos dados
Addr_Rd_OUT <= Addr_Rd_IN;

-- habilita a escrita no banco de registradores
habEscritaReg_OUT <= WB_Ctrl(2);


end architecture;
