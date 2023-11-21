library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULAbit31 is
  port   (
    -- Input ports
    A        : in  std_logic;
    B        : in  std_logic;
    carryIN : in  std_logic;
	 SLT      : in  std_logic;
	 InverteB : in  std_logic;
	 Sel      : in  std_logic_vector(1 downto 0);

    -- Output ports
	 overflow :  out  std_logic;
    Res      :  out  std_logic
  );
end entity;


architecture arquitetura of ULAbit31 is

  signal MUXB_OUT : std_logic;
  signal SOM_OUT  : std_logic;
  signal C_OUT    : std_logic;

begin
	
	MUXB :  entity work.mux2x1
        port map( entradaA_MUX => B, 
						entradaB_MUX => (not B), 
						seletor_MUX => InverteB, 
						saida_MUX => MUXB_OUT );

	SOM :  entity work.somador1Bit
        port map( entradaA => A, 
						entradaB => MUXB_OUT, 
						carryIN => carryIN, 
						saida => SOM_OUT, 
						carryOUT => C_OUT );
		  
	MUXOUT: entity work.mux4x1
        port map( entradaA_MUX => (A and MUXB_OUT), 
						entradaB_MUX => (A or MUXB_OUT), 
						entradaC_MUX => SOM_OUT, 
						entradaD_MUX => SLT, 
						seletor_MUX => Sel, 
						saida_MUX => Res );
						
	overflow <= (carryIN xor C_OUT) xor SOM_OUT;

end architecture;