library ieee;
use ieee.std_logic_1164.all;

entity ULAMIPS is
  -- Total de bits das entradas e saidas
  generic ( larguraDados : natural := 32
  );
  port   (
    A			: in std_logic_vector(31 downto 0);
    B    	: in std_logic_vector(31 downto 0);
	 sel  	: in std_logic_vector(1 downto 0);
	 invB 	: in std_logic;
    Saida	: out std_logic_vector(31 downto 0);
	 isEQ 	: out std_logic
  );
end entity;


architecture arquitetura of ULAMIPS is

  signal OVER_bit31 : std_logic;
  signal C0_1       : std_logic;
  signal C1_2       : std_logic;
  signal C2_3       : std_logic;
  signal C3_4       : std_logic;
  signal C4_5       : std_logic;
  signal C5_6       : std_logic;
  signal C6_7       : std_logic;
  signal C7_8       : std_logic;
  signal C8_9       : std_logic;
  signal C9_10      : std_logic;
  signal C10_11     : std_logic;
  signal C11_12     : std_logic;
  signal C12_13     : std_logic;
  signal C13_14     : std_logic;
  signal C14_15     : std_logic;
  signal C15_16     : std_logic;
  signal C16_17     : std_logic;
  signal C17_18     : std_logic;
  signal C18_19     : std_logic;
  signal C19_20     : std_logic;
  signal C20_21     : std_logic;
  signal C21_22     : std_logic;
  signal C22_23     : std_logic;
  signal C23_24     : std_logic;
  signal C24_25     : std_logic;
  signal C25_26     : std_logic;
  signal C26_27     : std_logic;
  signal C27_28     : std_logic;
  signal C28_29     : std_logic;
  signal C29_30     : std_logic;
  signal C30_31     : std_logic;
  signal S : std_logic_vector(31 downto 0);
  
begin


-- Bit 0:
ULAbit0 :  entity work.ULAbit
        port map( A        => A(0),
                  B        =>  B(0),
                  carryIN  => invB,
                  SLT      => OVER_bit31,
					   InverteB => invB,
						Sel      => sel,
						carryOUT => C0_1,
						Res      => S(0));

-- Bit 1:
ULAbit1 :  entity work.ULAbit
        port map( A        => A(1),
                  B        =>  B(1),
                  carryIN  => C0_1,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C1_2,
						Res      => S(1));

-- Bit 2:
ULAbit2 :  entity work.ULAbit
        port map( A        => A(2),
                  B        =>  B(2),
                  carryIN  => C1_2,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C2_3,
						Res      => S(2));

-- Bit 3:
ULAbit3 :  entity work.ULAbit
        port map( A        => A(3),
                  B        =>  B(3),
                  carryIN  => C2_3,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C3_4,
						Res      => S(3));

-- Bit 4:
ULAbit4 :  entity work.ULAbit
        port map( A        => A(4),
                  B        =>  B(4),
                  carryIN  => C3_4,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C4_5,
						Res      => S(4));

-- Bit 5:
ULAbit5 :  entity work.ULAbit
        port map( A        => A(5),
                  B        =>  B(5),
                  carryIN  => C4_5,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C5_6,
						Res      => S(5));

-- Bit 6:
ULAbit6 :  entity work.ULAbit
        port map( A        => A(6),
                  B        =>  B(6),
                  carryIN  => C5_6,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C6_7,
						Res      => S(6));

-- Bit 7:
ULAbit7 :  entity work.ULAbit
        port map( A        => A(7),
                  B        =>  B(7),
                  carryIN  => C6_7,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C7_8,
						Res      => S(7));

-- Bit 8:
ULAbit8 :  entity work.ULAbit
        port map( A        => A(8),
                  B        =>  B(8),
                  carryIN  => C7_8,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C8_9,
						Res      => S(8));

-- Bit 9:
ULAbit9 :  entity work.ULAbit
        port map( A        => A(9),
                  B        =>  B(9),
                  carryIN  => C8_9,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C9_10,
						Res      => S(9));

-- Bit 10:
ULAbit10 :  entity work.ULAbit
        port map( A        => A(10),
                  B        =>  B(10),
                  carryIN  => C9_10,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C10_11,
						Res      => S(10));

-- Bit 11:
ULAbit11 :  entity work.ULAbit
        port map( A        => A(11),
                  B        =>  B(11),
                  carryIN  => C10_11,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C11_12,
						Res      => S(11));

-- Bit 12:
ULAbit12 :  entity work.ULAbit
        port map( A        => A(12),
                  B        =>  B(12),
                  carryIN  => C11_12,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C12_13,
						Res      => S(12));

-- Bit 13:
ULAbit13 :  entity work.ULAbit
        port map( A        => A(13),
                  B        =>  B(13),
                  carryIN  => C12_13,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C13_14,
						Res      => S(13));

-- Bit 14:
ULAbit14 :  entity work.ULAbit
        port map( A        => A(14),
                  B        =>  B(14),
                  carryIN  => C13_14,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C14_15,
						Res      => S(14));

-- Bit 15:
ULAbit15 :  entity work.ULAbit
        port map( A        => A(15),
                  B        =>  B(15),
                  carryIN  => C14_15,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C15_16,
						Res      => S(15));

-- Bit 16:
ULAbit16 :  entity work.ULAbit
        port map( A        => A(16),
                  B        =>  B(16),
                  carryIN  => C15_16,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C16_17,
						Res      => S(16));

-- Bit 17:
ULAbit17 :  entity work.ULAbit
        port map( A        => A(17),
                  B        =>  B(17),
                  carryIN  => C16_17,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C17_18,
						Res      => S(17));

-- Bit 18:
ULAbit18 :  entity work.ULAbit
        port map( A        => A(18),
                  B        =>  B(18),
                  carryIN  => C17_18,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C18_19,
						Res      => S(18));

-- Bit 19:
ULAbit19 :  entity work.ULAbit
        port map( A        => A(19),
                  B        =>  B(19),
                  carryIN  => C18_19,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C19_20,
						Res      => S(19));

-- Bit 20:
ULAbit20 :  entity work.ULAbit
        port map( A        => A(20),
                  B        =>  B(20),
                  carryIN  => C19_20,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C20_21,
						Res      => S(20));

-- Bit 21:
ULAbit21 :  entity work.ULAbit
        port map( A        => A(21),
                  B        =>  B(21),
                  carryIN  => C20_21,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C21_22,
						Res      => S(21));

-- Bit 22:
ULAbit22 :  entity work.ULAbit
        port map( A        => A(22),
                  B        =>  B(22),
                  carryIN  => C21_22,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C22_23,
						Res      => S(22));

-- Bit 23:
ULAbit23 :  entity work.ULAbit
        port map( A        => A(23),
                  B        =>  B(23),
                  carryIN  => C22_23,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C23_24,
						Res      => S(23));

-- Bit 24:
ULAbit24 :  entity work.ULAbit
        port map( A        => A(24),
                  B        =>  B(24),
                  carryIN  => C23_24,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C24_25,
						Res      => S(24));

-- Bit 25:
ULAbit25 :  entity work.ULAbit
        port map( A        => A(25),
                  B        =>  B(25),
                  carryIN  => C24_25,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C25_26,
						Res      => S(25));

-- Bit 26:
ULAbit26 :  entity work.ULAbit
        port map( A        => A(26),
                  B        =>  B(26),
                  carryIN  => C25_26,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C26_27,
						Res      => S(26));

-- Bit 27:
ULAbit27 :  entity work.ULAbit
        port map( A        => A(27),
                  B        =>  B(27),
                  carryIN  => C26_27,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C27_28,
						Res      => S(27));

-- Bit 28:
ULAbit28 :  entity work.ULAbit
        port map( A        => A(28),
                  B        =>  B(28),
                  carryIN  => C27_28,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C28_29,
						Res      => S(28));

-- Bit 29:
ULAbit29 :  entity work.ULAbit
        port map( A        => A(29),
                  B        =>  B(29),
                  carryIN  => C28_29,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C29_30,
						Res      => S(29));

-- Bit 30:
ULAbit30 :  entity work.ULAbit
        port map( A        => A(30),
                  B        =>  B(30),
                  carryIN  => C29_30,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						carryOUT => C30_31,
						Res      => S(30));

-- Bit 31:
ULAbit31 :  entity work.ULAbit31
        port map( A        => A(31),
                  B        =>  B(31),
                  carryIN  => C30_31,
                  SLT      => '0',
						InverteB => invB,
						Sel      => sel,
						overflow => OVER_bit31,
						Res      => S(31));

isEQ <= not (S(0) or S(1) or S(2) or S(3) or S(4) or S(5) or S(6) or S(7) or S(8) or S(9) or S(10) or S(11) or S(12) or S(13) or S(14) or S(15) or S(16) or S(17) or S(18) or S(19) or S(20) or S(21) or S(22) or S(23) or S(24) or S(25) or S(26) or S(27) or S(28) or S(29) or S(30) or S(31));
Saida <= S;

end architecture;