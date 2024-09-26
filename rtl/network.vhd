---------------------------------------------------------------------------------
-- This is free and unencumbered software released into the public domain.
--
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary, for any purpose, commercial or non-commercial, and by any
-- means.
--
-- In jurisdictions that recognize copyright laws, the author or authors
-- of this software dedicate any and all copyright interest in the
-- software to the public domain. We make this dedication for the benefit
-- of the public at large and to the detriment of our heirs and
-- successors. We intend this dedication to be an overt act of
-- relinquishment in perpetuity of all present and future rights to this
-- software under copyright law.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
-- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-- For more information, please refer to <http://unlicense.org/>
---------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library work;
use work.spiker_pkg.all;


entity network is
    generic (
        n_cycles : integer := 10;
        cycles_cnt_bitwidth : integer := 5
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        start : in std_logic;
        sample_ready : in std_logic;
        ready : out std_logic;
        sample : out std_logic;
        in_spikes : in std_logic_vector(3 downto 0);
        out_spikes : out std_logic_vector(1 downto 0)
    );
end entity network;

architecture behavior of network is


    component multi_cycle is
        generic (
            cycles_cnt_bitwidth : integer := 5;
            n_cycles : integer := 10
        );
        port (
            clk : in std_logic;
            rst_n : in std_logic;
            start : in std_logic;
            all_ready : in std_logic;
            ready : out std_logic;
            restart : out std_logic;
            start_all : out std_logic
        );
    end component;

    component layer_3_neurons_4_inputs is
        generic (
            n_exc_inputs : integer := 4;
            n_inh_inputs : integer := 3;
            exc_cnt_bitwidth : integer := 2;
            inh_cnt_bitwidth : integer := 2;
            neuron_bit_width : integer := 8;
            inh_weights_bit_width : integer := 6;
            exc_weights_bit_width : integer := 6;
            shift : integer := 4
        );
        port (
            clk : in std_logic;
            rst_n : in std_logic;
            start : in std_logic;
            restart : in std_logic;
            exc_spikes : in std_logic_vector(n_exc_inputs-1 downto 0);
            inh_spikes : in std_logic_vector(n_inh_inputs-1 downto 0);
            ready : out std_logic;
            out_spikes : out std_logic_vector(2 downto 0)
        );
    end component;

    component layer_2_neurons_3_inputs is
        generic (
            n_exc_inputs : integer := 3;
            n_inh_inputs : integer := 2;
            exc_cnt_bitwidth : integer := 2;
            inh_cnt_bitwidth : integer := 1;
            neuron_bit_width : integer := 8;
            inh_weights_bit_width : integer := 6;
            exc_weights_bit_width : integer := 6;
            shift : integer := 4
        );
        port (
            clk : in std_logic;
            rst_n : in std_logic;
            start : in std_logic;
            restart : in std_logic;
            exc_spikes : in std_logic_vector(n_exc_inputs-1 downto 0);
            inh_spikes : in std_logic_vector(n_inh_inputs-1 downto 0);
            ready : out std_logic;
            out_spikes : out std_logic_vector(1 downto 0)
        );
    end component;


    signal start_all : std_logic;
    signal all_ready : std_logic;
    signal restart : std_logic;
    signal layer_0_ready : std_logic;
    signal layer_0_feedback : std_logic_vector(2 downto 0);
    signal layer_1_ready : std_logic;
    signal layer_1_feedback : std_logic_vector(1 downto 0);
    signal exc_spikes_0_to_1 : std_logic_vector(2 downto 0);

begin

    sample <= start_all;
    all_ready <= sample_ready and layer_0_ready and layer_1_ready ;
    out_spikes <= layer_1_feedback;
    exc_spikes_0_to_1<= layer_0_feedback;


    multi_cycle_control : multi_cycle
        generic map(
            cycles_cnt_bitwidth => cycles_cnt_bitwidth,
            n_cycles => n_cycles
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            start => start,
            all_ready => all_ready,
            ready => ready,
            restart => restart,
            start_all => start_all
        );

    layer_0 : layer_3_neurons_4_inputs
        generic map(
            n_exc_inputs => 4,
            n_inh_inputs => 3,
            exc_cnt_bitwidth => 2,
            inh_cnt_bitwidth => 2,
            neuron_bit_width => 8,
            inh_weights_bit_width => 6,
            exc_weights_bit_width => 6,
            shift => 4
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            start => start_all,
            restart => restart,
            exc_spikes => in_spikes,
            inh_spikes => layer_0_feedback,
            ready => layer_0_ready,
            out_spikes => layer_0_feedback
        );

    layer_1 : layer_2_neurons_3_inputs
        generic map(
            n_exc_inputs => 3,
            n_inh_inputs => 2,
            exc_cnt_bitwidth => 2,
            inh_cnt_bitwidth => 1,
            neuron_bit_width => 8,
            inh_weights_bit_width => 6,
            exc_weights_bit_width => 6,
            shift => 4
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            start => start_all,
            restart => restart,
            exc_spikes => exc_spikes_0_to_1,
            inh_spikes => layer_1_feedback,
            ready => layer_1_ready,
            out_spikes => layer_1_feedback
        );


end architecture behavior;

