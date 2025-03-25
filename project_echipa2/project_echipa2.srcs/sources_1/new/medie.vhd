library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity medie is
Port (
    clk:IN std_logic; --avem nevoie de clock ca afisam pe display
	a1:IN std_logic_vector(3 downto 0); --intrarea 1 pe 4 biti
	a2:IN std_logic_vector(3 downto 0); --intrarea 2 pe 4 biti
	a3:IN std_logic_vector(3 downto 0); --intrarea 3 pe 4 biti
	a4:IN std_logic_vector(3 downto 0); --intrarea 4 pe 4 biti
	cat:OUT std_logic_vector(6 downto 0); --pt afisarea pe display
	an: OUT std_logic_vector(3 downto 0)
 );
end medie;

architecture Behavioral of medie is

signal b: std_logic_vector(3 downto 0):=x"0"; --valoare initiala zero in hexa
signal digit0: std_logic_vector(3 downto 0);
signal digit1: std_logic_vector(3 downto 0);
signal digit2: std_logic_vector(3 downto 0);
signal digit3: std_logic_vector(3 downto 0);

signal a1_extended: std_logic_vector(4 downto 0);
signal a2_extended: std_logic_vector(4 downto 0);
signal a3_extended: std_logic_vector(4 downto 0);
signal a4_extended: std_logic_vector(4 downto 0);
signal sum_a1_a2: std_logic_vector(4 downto 0);
signal sum_a3_a4: std_logic_vector(4 downto 0);
signal sum1_extended: std_logic_vector(5 downto 0);
signal sum2_extended: std_logic_vector(5 downto 0);
signal sum: std_logic_vector(5 downto 0);

signal cnt: STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal mux_digit: STD_LOGIC_VECTOR(3 downto 0);

begin

--Medie

a1_extended <= '0' & a1; --adaugam zero pe pozitia 5
a2_extended <= '0' & a2;
a3_extended <= '0' & a3;
a4_extended <= '0' & a4;

process(a1_extended,a2_extended,a3_extended,a4_extended)
begin
sum_a1_a2 <= a1_extended + a2_extended; --facem suma dintre primele doua intrari
sum_a3_a4 <= a3_extended + a4_extended; --facem suma dintre ultimele doua intrari
sum1_extended <= '0' & sum_a1_a2;
sum2_extended <= '0' & sum_a3_a4;
sum <= sum1_extended + sum2_extended; --facem suma totala

--b = sum / 4 (shiftare la dreapta cu 2 pozitii)
b <= sum(5 downto 2); --ii atribuim lui b primii 4 biti din sum (incepand cu MSB)

end process;

--Decodor

process(b)
begin
--pentru o intrare pe 4 biti, maximul e F(1111) = 15 => primele doua afisari pe display vor fi mereu 0
digit3 <= "0000";
digit2 <= "0000";

digit0 <= conv_std_logic_vector((conv_integer(b) mod 10), 4); --facem un vector de 4 biti pt fiecare cifra zecimala
digit1 <= conv_std_logic_vector((conv_integer(b)/10) mod 10, 4);
--digit2 <= conv_std_logic_vector((conv_integer(b)/100), 4);
--digit3 <= conv_std_logic_vector((conv_integer(b)/1000),4);

end process;

--Display

process(clk)
begin
    if(clk='1' and clk'event) then
        cnt<=cnt+1;
     end if;
end process;

process(cnt(15 downto 14), digit0, digit1, digit2, digit3)
begin
    case(cnt(15 downto 14)) is
        when "00" => mux_digit<=digit0;
        when "01" => mux_digit<=digit1;
        when "10" => mux_digit<=digit2;
        when "11" => mux_digit<=digit3;
        when others =>
     end case;
end process;

process(cnt(15 downto 14))
begin
    case(cnt(15 downto 14)) is
        when "00" => an<="1110";
        when "01" => an<="1101";
        when "10" => an<="1011";
        when "11" => an<="0111";
        when others =>
     end case;
end process;

with mux_digit select
   cat<= "1111001" when "0001",   --1
         "0100100" when "0010",   --2
         "0110000" when "0011",   --3
         "0011001" when "0100",   --4
         "0010010" when "0101",   --5
         "0000010" when "0110",   --6
         "1111000" when "0111",   --7
         "0000000" when "1000",   --8
         "0010000" when "1001",   --9
         "0001000" when "1010",   --A
         "0000011" when "1011",   --b
         "1000110" when "1100",   --C
         "0100001" when "1101",   --d
         "0000110" when "1110",   --E
         "0001110" when "1111",   --F
         "1000000" when others;   --0

end Behavioral;
