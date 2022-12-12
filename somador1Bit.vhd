library ieee;
use ieee.std_logic_1164.all;

entity somador1Bit is
    port
    (
        entradaA, entradaB, carryIN: in STD_LOGIC;
        saida, carryOUT:  out STD_LOGIC
    );
end entity;

architecture comportamento of somador1Bit is
    begin
        saida <= (entradaA xor entradaB) xor carryIN;
		  carryOUT <= ((entradaA xor entradaB) and carryIN) or (entradaA and entradaB);
end architecture;