-- ===========================================================================
-- Project        : Implementation of the AES Encryption Algorithm on FPGA
-- File           : mixColumnTB.vhd
-- Authors        : EL AZZOUZI NASREDDINE 
--
-- Date           : June 2025
-- Version        : 1.1
-- 
-- Description    : mixColumn  testbench
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mixColumnTB is
end entity;

architecture Behavioral of mixColumnTB is
    signal i_block_tb : std_logic_vector(127 downto 0) := (others => '0');
    signal o_block_tb : std_logic_vector(127 downto 0);
    
    component mixColumn 
    port(
        i_block : in std_logic_vector(127 downto 0);
        o_block : out std_logic_vector(127 downto 0)
    );
    end component;

begin
    DUT: mixColumn 
    port map(
        i_block => i_block_tb,
        o_block => o_block_tb
    );

    STIMULUS: process
    begin
        -- Test Case 1
        i_block_tb <= x"618b611f45cac9d89b73ad97691abea7";
        wait for 10 ns;
        assert o_block_tb = x"09d03a77fa515164516ad831849687ff" 
            report "Test 1 failed: Expected x09d03a77fa515164516ad831849687ff"
            severity error;
        
        -- Test Case 2 (NIST Standard)
        i_block_tb <= x"d4bf5d30e0b452aeb84111f11e2798e5";
        wait for 10 ns;
        assert o_block_tb = x"046681e5e0cb199a48f8d37a2806264c"
            report "Test 2 failed: Expected x046681e5e0cb199a48f8d37a2806264c"
            severity error;
        
        wait;
    end process;
end architecture;