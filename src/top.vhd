-- ===========================================================================
-- Project        : Implementation of the AES Encryption Algorithm on FPGA
-- File           : top.vhd
-- Authors        : EL AZZOUZI NASREDDINE 
--
-- Date           : June 2025
-- Version        : 1.1
-- 
-- Description    : Complete VHDL implementation performs 128-bit AES encryption using a 10-round structure (AES-128) with all standard transformations:
--                  SubBytes → ShiftRows → MixColumns → AddRoundKey
-- ============================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  
   
entity top is  
port (	clk   : in std_logic;
		start : in std_logic;
		busy  : out std_logic;
        plaintext  : in std_logic_vector(127 downto 0);
		valid_o    : out std_logic;
        ciphertext_o : out std_logic_vector(127 downto 0);
		key        : out std_logic_vector(127 downto 0));
end entity;

architecture topArch of top is
signal ciphertext : std_logic_vector(127 downto 0) :=(others => '0');
type KeysArray_t is array(0 to 10) of std_logic_vector(127 downto 0);
signal KeysArray : KeysArray_t := (
		x"2b7e151628aed2a6abf7158809cf4f3c",  -- Round 0
		x"a0fafe1788542cb123a339392a6c7605",  -- Round 1
		x"f2c295f27a96b9435935807a7359f67f",  -- Round 2
		x"3d80477d4716fe3e1e237e446d7a883b",  -- Round 3
		x"ef44a541a8525b7fb671253bdb0bad00",  -- Round 4
		x"d4d1c6f87c839d87caf2b8bc11f915bc",  -- Round 5
		x"6d88a37a110b3efddbf98641ca0093fd",  -- Round 6
		x"4e54f70e5f5fc9f384a64fb24ea6dc4f",  -- Round 7
		x"ead27321b58dbad2312bf5607f8d292f",  -- Round 8
		x"ac7766f319fadc2128d12941575c006e",  -- Round 9
		x"d014f9a8c9ee2589e13f0cc8b6630ca6"); -- Round 10
constant max_rounds : unsigned(3 downto 0) := x"A";
signal round    : unsigned(3 downto 0) :=(others => '0');
signal roundReg : unsigned(3 downto 0) :=(others => '0');

type state_t is (idle,round0 , subByteLayer , shiftRowsLayer , mixColumnLayer , keyAddLayer, finish );
signal current_state , next_state : state_t;


signal i_Sbox : std_logic_vector(127 downto 0);--input to Sbox
signal o_Sbox : std_logic_vector(127 downto 0);--output of Sbox

signal i_keyAddKey	,i_dataAddKey : std_logic_vector(127 downto 0); --input roundKey and data to addKey 
signal o_dataAddKey : std_logic_vector(127 downto 0); --output data of addKey

signal i_dataShiftRows : std_logic_vector(127 downto 0);
signal o_dataShiftRows : std_logic_vector(127 downto 0);

signal i_dataMixColumn : std_logic_vector(127 downto 0);
signal o_dataMixColumn : std_logic_vector(127 downto 0);


signal finished : std_logic :='0';

component subByte 
port(
     i_data : in std_logic_vector(7 downto 0); --input data 
     o_data : out std_logic_vector(7 downto 0)-- output data
);
end component;
component shiftRows
    port (
        i_data : in std_logic_vector(127 downto 0); --input data
        o_data : out std_logic_vector(127 downto 0) --output data
    );
end component;
component mixColumn
port(
     i_block : in std_logic_vector(127 downto 0); --input data block  in GF(2^8)
     o_block : out std_logic_vector(127 downto 0)-- output data
);
end component;

component addKey is 
port (  roundKey : in std_logic_vector(127 downto 0);
        i_data   : in std_logic_vector(127 downto 0);
		o_data   : out std_logic_vector(127 downto 0));
end component;
begin 
	------------------------------------------------------
    --                 SubByte Layer                    --
    ------------------------------------------------------
	subByteInst0  : subByte  port map  (i_data => i_sbox(7 downto 0) ,    o_data => o_Sbox(7 downto 0));
	subByteInst1  : subByte  port map  (i_data => i_sbox(15 downto 8)  ,  o_data => o_Sbox(15 downto 8));
	subByteInst2  : subByte  port map  (i_data => i_sbox(23 downto 16) ,  o_data => o_Sbox(23 downto 16));
	subByteInst3  : subByte  port map  (i_data => i_sbox(31 downto 24) ,  o_data => o_Sbox(31 downto 24));
	subByteInst4  : subByte  port map  (i_data => i_sbox(39 downto 32) ,  o_data => o_Sbox(39 downto 32));
	subByteInst5  : subByte  port map  (i_data => i_sbox(47 downto 40) ,  o_data => o_Sbox(47 downto 40));
	subByteInst6  : subByte  port map  (i_data => i_sbox(55 downto 48) ,  o_data => o_Sbox(55 downto 48));
	subByteInst7  : subByte  port map  (i_data => i_sbox(63 downto 56) ,  o_data => o_Sbox(63 downto 56));
	subByteInst8  : subByte  port map  (i_data => i_sbox(71 downto 64) ,  o_data => o_Sbox(71 downto 64));
	subByteInst9  : subByte  port map  (i_data => i_sbox(79 downto 72) ,  o_data => o_Sbox(79 downto 72));
	subByteInst10 : subByte port map   (i_data => i_sbox(87 downto 80) ,  o_data => o_Sbox(87 downto 80));
	subByteInst11 : subByte port map   (i_data => i_sbox(95 downto 88) ,  o_data => o_Sbox(95 downto 88));
	subByteInst12 : subByte port map   (i_data => i_sbox(103 downto 96),  o_data => o_Sbox(103 downto 96));
	subByteInst13 : subByte port map   (i_data => i_sbox(111 downto 104), o_data => o_Sbox(111 downto 104));
	subByteInst14 : subByte port map   (i_data => i_sbox(119 downto 112), o_data => o_Sbox(119 downto 112));
	subByteInst15 : subByte port map   (i_data => i_sbox(127 downto 120), o_data => o_Sbox(127 downto 120));
	------------------------------------------------------
    --                 ShiftRows Layer                  --
    ------------------------------------------------------
	shiftRowInst : shiftRows  
    port map ( i_data => i_dataShiftRows, 
               o_data => o_dataShiftRows
             );
	------------------------------------------------------
    --                MixColumn Layer                   --
    ------------------------------------------------------
	mixColumnInst : mixColumn 
    port map( i_block => i_dataMixColumn ,
              o_block => o_dataMixColumn
            );
	------------------------------------------------------
    --                 KeyAdd Layer                     --
    ------------------------------------------------------
	keyAddInst : addKey 
    port map ( roundKey => i_keyAddKey, 
               i_data   => i_dataAddKey, 
               o_data   => o_dataAddKey
             );

	MEMORY_LOGIC : process(clk)
	               begin
				        if (rising_edge(clk)) then 
						    current_state <= next_state;
						end if;
				   end process;

	NEXT_STATE_LOGIC  : process(current_state , start ,round)
	                    begin
						case (current_state) is
				        when idle => 
                             if start = '1' then 
						        next_state <= round0;
							else 
							    next_state <= idle;
							end if;
						when round0 => 
                             next_state <= subByteLayer;
						when keyAddLayer => 
                             if (round < max_rounds) then --round < 10
						        next_state <= subByteLayer;
							 elsif (round = max_rounds) then
								next_state <= finish;
							 end if;
						when subByteLayer => 
                             next_state <= shiftRowsLayer;
						when shiftRowsLayer =>
                             if (round < max_rounds) then 
						        next_state <= mixColumnLayer;
							 else 
								next_state <= keyAddLayer;
							 end if;
						when mixColumnLayer => 
                             next_state <= keyAddLayer;
						when finish  => 
                             next_state <= idle;
						when others => 
                             null;
					    end case;
				  end process;
	OUTPUT_LOGIC : process (current_state )
	               begin
						finished <= '0';
				        case (current_state) is
				        when idle =>
                             round <= (others => '0');
						     busy <= '0';
							 valid_o <= '0';
						when round0 => 
                             i_keyAddKey  <= KeysArray(0);
                             i_dataAddKey <= plaintext;
                             busy <= '1'; 
                        when subByteLayer => 
						     if round < max_rounds then
                                round <= roundReg + to_unsigned(1,4);--
								i_sbox <= o_dataAddKey;
							 end if;
						when shiftRowsLayer =>
						     i_dataShiftRows <= o_sbox;
						when mixColumnLayer =>
						     i_dataMixColumn <= o_dataShiftRows;
						when keyAddLayer =>
						     i_keyAddKey <= KeysArray(to_integer(round));
							 if round < max_rounds then
								i_dataAddKey <= o_dataMixColumn;
							 elsif round = max_rounds then 
							    i_dataAddKey <= o_dataShiftRows;
							  end if;
                        when finish =>
						     ciphertext <= o_dataAddKey;
							 valid_o <= '1';
							 busy <= '0';
							 finished <= '1';
				        when others => 
						     null;
				     end case;
				   end process;					
    ciphertext_o  <= ciphertext;
	key <= KeysArray(0);


	RoundRegister : process (clk) 
	begin
	     if (rising_edge(clk)) then 
		    roundReg <= round ;
	     end if;
	end process ;
end architecture;