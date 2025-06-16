-- ===========================================================================
-- Project        : Implementation of the AES Encryption Algorithm on FPGA
-- File           : mixColumn.vhd
-- Authors        : EL AZZOUZI NASREDDINE 
--
-- Date           : June 2025
-- Version        : 1.1
-- 
-- Description    : Implementation of mixColumn sublayer of AES 
--                  with integrated multiplication by 2 and 3 in GF(2^8)
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mixColumn is 
port(
     i_block : in std_logic_vector(127 downto 0); --input data block in GF(2^8)
     o_block : out std_logic_vector(127 downto 0) -- output data
);
end entity;

architecture mixColumnArch of mixColumn is
    -- Input bytes
    signal B0, B1, B2, B3, B4, B5, B6, B7, B8, B9, B10, B11, B12, B13, B14, B15 : std_logic_vector(7 downto 0);
    -- Output bytes
    signal C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15 : std_logic_vector(7 downto 0);
    
    -- Internal multiplication results
    signal mult_by2_results : std_logic_vector(127 downto 0);
    signal mult_by3_results : std_logic_vector(127 downto 0);
    
    -- Multiply by 2 in GF(2^8)
    function multiply_by_2(data : std_logic_vector(7 downto 0)) return std_logic_vector is
        variable shifted : std_logic_vector(7 downto 0);
    begin
        shifted := data(6 downto 0) & '0';  -- Left shift
        if data(7) = '1' then
            return shifted xor x"1B";  -- XOR with irreducible polynomial
        else
            return shifted;
        end if;
    end function;
    
    -- Multiply by 3 in GF(2^8) (which is multiply_by_2 + XOR original)
    function multiply_by_3(data : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return multiply_by_2(data) xor data;
    end function;

begin
    -- Extract input bytes
    B0  <= i_block(7 downto 0);
    B1  <= i_block(15 downto 8);
    B2  <= i_block(23 downto 16);
    B3  <= i_block(31 downto 24);
    B4  <= i_block(39 downto 32);
    B5  <= i_block(47 downto 40);
    B6  <= i_block(55 downto 48);
    B7  <= i_block(63 downto 56);
    B8  <= i_block(71 downto 64);
    B9  <= i_block(79 downto 72);
    B10 <= i_block(87 downto 80);
    B11 <= i_block(95 downto 88);
    B12 <= i_block(103 downto 96);
    B13 <= i_block(111 downto 104);
    B14 <= i_block(119 downto 112);
    B15 <= i_block(127 downto 120);
    
    -- Pre-calculate all multiplication results
    mult_by2_results(7 downto 0)   <= multiply_by_2(B0);
    mult_by2_results(15 downto 8)  <= multiply_by_2(B1);
    mult_by2_results(23 downto 16) <= multiply_by_2(B2);
    mult_by2_results(31 downto 24) <= multiply_by_2(B3);
    mult_by2_results(39 downto 32) <= multiply_by_2(B4);
    mult_by2_results(47 downto 40) <= multiply_by_2(B5);
    mult_by2_results(55 downto 48) <= multiply_by_2(B6);
    mult_by2_results(63 downto 56) <= multiply_by_2(B7);
    mult_by2_results(71 downto 64) <= multiply_by_2(B8);
    mult_by2_results(79 downto 72) <= multiply_by_2(B9);
    mult_by2_results(87 downto 80) <= multiply_by_2(B10);
    mult_by2_results(95 downto 88) <= multiply_by_2(B11);
    mult_by2_results(103 downto 96) <= multiply_by_2(B12);
    mult_by2_results(111 downto 104) <= multiply_by_2(B13);
    mult_by2_results(119 downto 112) <= multiply_by_2(B14);
    mult_by2_results(127 downto 120) <= multiply_by_2(B15);
    
    mult_by3_results(7 downto 0)   <= multiply_by_3(B0);
    mult_by3_results(15 downto 8)  <= multiply_by_3(B1);
    mult_by3_results(23 downto 16) <= multiply_by_3(B2);
    mult_by3_results(31 downto 24) <= multiply_by_3(B3);
    mult_by3_results(39 downto 32) <= multiply_by_3(B4);
    mult_by3_results(47 downto 40) <= multiply_by_3(B5);
    mult_by3_results(55 downto 48) <= multiply_by_3(B6);
    mult_by3_results(63 downto 56) <= multiply_by_3(B7);
    mult_by3_results(71 downto 64) <= multiply_by_3(B8);
    mult_by3_results(79 downto 72) <= multiply_by_3(B9);
    mult_by3_results(87 downto 80) <= multiply_by_3(B10);
    mult_by3_results(95 downto 88) <= multiply_by_3(B11);
    mult_by3_results(103 downto 96) <= multiply_by_3(B12);
    mult_by3_results(111 downto 104) <= multiply_by_3(B13);
    mult_by3_results(119 downto 112) <= multiply_by_3(B14);
    mult_by3_results(127 downto 120) <= multiply_by_3(B15);
    
    -- Compute each output byte using the MixColumns matrix
    C0  <= mult_by2_results(7 downto 0)   xor mult_by3_results(31 downto 24) xor B2  xor B1;
    C1  <= mult_by2_results(15 downto 8)  xor mult_by3_results(7 downto 0)   xor B2  xor B3;
    C2  <= mult_by2_results(23 downto 16) xor mult_by3_results(15 downto 8)  xor B0  xor B3;
    C3  <= mult_by2_results(31 downto 24) xor mult_by3_results(23 downto 16) xor B0  xor B1;
    
    C4  <= mult_by2_results(39 downto 32) xor mult_by3_results(63 downto 56) xor B5  xor B6;
    C5  <= mult_by2_results(47 downto 40) xor mult_by3_results(39 downto 32) xor B6  xor B7;
    C6  <= mult_by2_results(55 downto 48) xor mult_by3_results(47 downto 40) xor B4  xor B7;
    C7  <= mult_by2_results(63 downto 56) xor mult_by3_results(55 downto 48) xor B4  xor B5;
    
    C8  <= mult_by2_results(71 downto 64) xor mult_by3_results(95 downto 88) xor B10 xor B9;
    C9  <= mult_by2_results(79 downto 72) xor mult_by3_results(71 downto 64) xor B10 xor B11;
    C10 <= mult_by2_results(87 downto 80) xor mult_by3_results(79 downto 72) xor B8  xor B11;
    C11 <= mult_by2_results(95 downto 88) xor mult_by3_results(87 downto 80) xor B8  xor B9;
    
    C12 <= mult_by2_results(103 downto 96) xor mult_by3_results(127 downto 120) xor B14 xor B13;
    C13 <= mult_by2_results(111 downto 104) xor mult_by3_results(103 downto 96) xor B14 xor B15;
    C14 <= mult_by2_results(119 downto 112) xor mult_by3_results(111 downto 104) xor B12 xor B15;
    C15 <= mult_by2_results(127 downto 120) xor mult_by3_results(119 downto 112) xor B12 xor B13;
    
    -- Combine output bytes
    o_block <= C15 & C14 & C13 & C12 & C11 & C10 & C9 & C8 & 
               C7 & C6 & C5 & C4 & C3 & C2 & C1 & C0;
end architecture;