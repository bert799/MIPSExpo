library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROMMIPS IS
   generic (
          dataWidth: natural := 32;
          addrWidth: natural := 32;
       memoryAddrWidth:  natural := 6 );   -- 64 posicoes de 32 bits cada
   port (
          Endereco : in  std_logic_vector (addrWidth-1 downto 0);
          Dado     : out std_logic_vector (dataWidth-1 downto 0) );
end entity;

architecture assincrona OF ROMMIPS IS
  type blocoMemoria IS ARRAY(0 TO 2**memoryAddrWidth - 1) OF std_logic_vector(dataWidth-1 downto 0);

  function initMemory
        return blocoMemoria is variable tmp : blocoMemoria := (others => (others => '0'));
  begin
--INIT
tmp(0) := x"20100006"; -- addi $s0, $zero, 0 #posição linha s0 28
tmp(1) := x"2011000a"; -- addi $s1, $zero, 0 #posição coluna s1 1f
tmp(2) := x"20120000"; -- addi $s2, $zero, 0 #posição prox coluna s2
tmp(3) := x"20130001"; -- addi $s3, $zero, 1 #carrega 1 para comparar
tmp(4) := x"20140001"; -- addi $s4, $zero, 1 #frame da animação
--LOOP PRINCIPAL
tmp(5) := x"8c0801ff"; -- lw $t0, 511($zero) #lê base de tempo
tmp(6) := x"00000000"; -- nop
tmp(7) := x"00000000"; -- nop
tmp(8) := x"11130006"; -- beq $t0, $s3, renderFrame
tmp(9) := x"00000000"; -- nop
tmp(10) := x"00000000"; -- nop
tmp(11) := x"00000000"; -- nop
tmp(12) := x"08000005"; -- j loop_principal
tmp(13) := x"00000000"; -- nop
tmp(14) := x"00000000"; -- nop
--Render Frame
tmp(15) := x"8c080200"; -- lw $t0, 512($zero) #reseta base de tempo
tmp(16) := x"2A890004"; -- slti $t1, $s4, 4 #confere que não acabaram os frames de animação
tmp(17) := x"11330006"; -- beq $t1, $s3, display_frame
tmp(18) := x"00000000"; -- nop
tmp(19) := x"00000000"; -- nop
tmp(20) := x"00000000"; -- nop
tmp(21) := x"0c000022"; -- jal reset_frames
tmp(22) := x"00000000"; -- nop
tmp(23) := x"00000000"; -- nop
--Display Frame
tmp(24) := x"ac000130"; -- sw $zero, 130($zero) #Grava frame -- limpa frame
tmp(25) := x"ac000083"; -- sw $zero, 131($zero) #escreve tela
--tmp(24) := x"22100001"; -- += linha
tmp(26) := x"ac100080"; -- sw $s0, 128($zero) #Grava linha
tmp(27) := x"ac110081"; -- sw $s1, 129($zero) #Grava coluna
--tmp(27) := x"22310001"; -- += coluna
tmp(28) := x"ac140082"; -- sw $s4, 130($zero) #Grava frame
tmp(29) := x"ac000083"; -- sw $zero, 131($zero) #escreve tela
tmp(30) := x"22940001"; -- addi $s4, $s4, 1 #Prepara Próximo frame
--tmp(30) := x"00000000"; -- nop
tmp(31) := x"08000005"; -- j loop_principal
tmp(32) := x"00000000"; -- nop
tmp(33) := x"00000000"; -- nop
--Reset Frames
tmp(34) := x"20140001"; -- addi $s4, $zero, 1 #frame da animação
tmp(35) := x"20090000"; -- addi $t1, $zero, 0 #zera conferência
tmp(36) := x"03e00008"; -- jr $ra  
  
  
  
  
  
------------------------------------------------------------------------------------------------------------
-------------------------------- Programa teste MIPS Pipeline Simples A e B --------------------------------

--			 tmp(0)  := x"3c090000";      --lui $t1, 0x0000;
--			 tmp(1)  := x"3c0baaaa";      --lui $t3, 0xAAAA;
--			 tmp(2)  := x"3c0f1000";      --lui $t7, 0x1000;
--			 tmp(3)  := x"3529000a";      --ori $t1, $t1, 0x0A;     # $t1 (#9) := 0x0A
--			 tmp(4)  := x"356baaaa";      --ori $t3, $t3, 0xAAAA;   # $t3 (#11) := 0xAAAAAAAA
--			 tmp(5)  := x"35ef0000";      --ori $t7, $t7, 0x0000;   # $t7 (#15) := 0x10000000 (4096*64k)
--			 tmp(6)  := x"212a0001";      --addi $t2, $t1, 0x01;    # $t2 (#10) := 0x0B
--			 tmp(7)  := x"01606025";      --or $t4, $t3, $0;        # $t4 (#12) := 0xAAAAAAAA
--			 tmp(8)  := x"316dffff";      --andi $t5, $t3, 0xFFFF;  # $t5 (#13) := 0x0000AAAA
--			 tmp(9)  := x"01497022";      --sub $t6, $t2, $t1;      # $t6 (#14) := 0x01
--			 tmp(10) := x"ac090008";      --sw $t1, 8($zero);       # M[8) = 0x0A
--			 tmp(11) := x"8c080008";      --lw $t0, 8($zero);
--			 tmp(12) := x"010a7824";      --and $t7, $t0, $t2;      # Hazard Load Use
--			 tmp(13) := x"290fffff";      --slti $t7, $t0, 0xFFFF;
--			 tmp(14) := x"012a402a";      --slt $t0, $t1, $t2;
--		--destinoBEQ:
--			 tmp(15) := x"012e4820";      --add $t1, $t1, $t6;      # t0 = t2, segunda vez: t0 != t2
--			 tmp(16) := x"00000000";      --nop;
--			 tmp(17) := x"00000000";      --nop;
--			 tmp(18) := x"112afffc";      --beq $t1, $t2, destinoBEQ;  # Desvia na primeira e nao desvia depois
--			 tmp(19) := x"00000000";      --nop;
--			 tmp(20) := x"00000000";      --nop;
--			 tmp(21) := x"00000000";      --nop;
--			 tmp(22) := x"0c000020";      --jal subrotina;
--			 tmp(23) := x"00000000";      --nop;
--			 tmp(24) := x"00000000";      --nop;
--			 tmp(25) := x"00000000";      --nop;
--			 tmp(26) := x"00000000";      --nop;
--			 tmp(27) := x"150d0008";      --bne $t0, $t5, fim
--			 tmp(28) := x"00000000";      --nop;
--			 tmp(29) := x"00000000";      --nop;
--			 tmp(30) := x"00000000";      --nop;
--			 tmp(31) := x"00000000";      --nop;
--		--subrotina:
--			 tmp(32) := x"00000000";      --nop;
--			 tmp(33) := x"03e00008";      --jr $ra;
--			 tmp(34) := x"00000000";      --nop;
--			 tmp(35) := x"00000000";      --nop;
--		--fim:
--			 tmp(36) := x"00000000";      --nop;
--			 tmp(37) := x"08000024";      --j fim;
--			 tmp(38) := x"00000000";      --nop;
--			 tmp(39) := x"00000000";      --nop;
			 
			 
------------------------------------------------------------------------------------------------------------
---------------------------------- Programa teste MIPS Pipeline FORWARDING ---------------------------------

--			 tmp(0)  := x"3c090000";      --lui  $t1, 0x0000;
--			 tmp(1)  := x"3c0baaaa";      --lui  $t3, 0xAAAA;
--			 tmp(2)  := x"3c0f1000";      --lui  $t7, 0x1000;
--			 tmp(3)  := x"3529000a";      --ori  $t1, $t1, 0x0A;     # $t1 (#9)  := 0x0000000A
--			 tmp(4)  := x"356baaaa";      --ori  $t3, $t3, 0xAAAA;   # $t3 (#11) := 0xAAAAAAAA
--			 tmp(5)  := x"35ef0000";      --ori  $t7, $t7, 0x0000;   # $t7 (#15) := 0x10000000 (4096*64k)
--			 tmp(6)	:= x"216B0001";		--addi $t3, $t3, 0x0001;   # $t3 (#11) := 0xAAAAAAAB
--			 tmp(7)	:= x"216BFFFF";		--addi $t3, $t3, 0xFFFF;   # $t3 (#11) := 0xAAAAAAAA
--			 tmp(8)	:= x"AC090008";		--sw	 $t1, 8($zero);   	# M(8) 		:= 0x0000000A
--			 tmp(9)	:= x"8C0D0008";		--lw	 $t5, 8($zero);   	# $t5 (#13) := 0x0000000A
--			 tmp(10)	:= x"00000000";		--nop
--			 tmp(11) :=	x"01A96820";		--add  $t5, $t5, $t1;      # $t5 (#13) := 0x00000014


------------------------------------------------------------------------------------------------------------
------------------------------ Programa teste MIPS Pipeline FORWARDING & STALL -----------------------------

--			 tmp(0)  := x"3c090000";      --lui  $t1, 0x0000;
--			 tmp(1)  := x"3c0baaaa";      --lui  $t3, 0xAAAA;
--			 tmp(2)  := x"3c0f1000";      --lui  $t7, 0x1000;
--			 tmp(3)  := x"3529000a";      --ori  $t1, $t1, 0x0A;     # $t1 (#9)  := 0x0000000A
--			 tmp(4)  := x"356baaaa";      --ori  $t3, $t3, 0xAAAA;   # $t3 (#11) := 0xAAAAAAAA
--			 tmp(5)  := x"35ef0000";      --ori  $t7, $t7, 0x0000;   # $t7 (#15) := 0x10000000 (4096*64k)
--			 tmp(6)	:= x"216B0001";		--addi $t3, $t3, 0x0001;   # $t3 (#11) := 0xAAAAAAAB
--			 tmp(7)	:= x"216BFFFF";		--addi $t3, $t3, 0xFFFF;   # $t3 (#11) := 0xAAAAAAAA
--			 tmp(8)	:= x"AC090008";		--sw	 $t1, 8($zero);   	# M(8) 		:= 0x0000000A
--			 tmp(9)	:= x"8C0D0008";		--lw	 $t5, 8($zero);   	# $t5 (#13) := 0x0000000A
--			 tmp(10) :=	x"01A96820";		--add  $t5, $t5, $t1;      # $t5 (#13) := 0x00000014


			 
        return tmp;
		  
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

-- Utiliza uma quantidade menor de endereços locais:
   signal EnderecoLocal : std_logic_vector(memoryAddrWidth-1 downto 0);

begin
  EnderecoLocal <= Endereco(memoryAddrWidth+1 downto 2);
  Dado <= memROM (to_integer(unsigned(EnderecoLocal)));
end architecture;