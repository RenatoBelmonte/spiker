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
use ieee.numeric_std.all;
library work;
use work.spiker_pkg.all;


entity layer_2_neurons_3_inputs is
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
end entity layer_2_neurons_3_inputs;

architecture behavior of layer_2_neurons_3_inputs is


    constant v_th_0 : signed(neuron_bit_width-1 downto 0) := "00010000";
    constant v_th_1 : signed(neuron_bit_width-1 downto 0) := "00010000";

    component multi_input_3_exc_2_inh is
        generic (
            n_exc_inputs : integer := 3;
            n_inh_inputs : integer := 2;
            exc_cnt_bitwidth : integer := 2;
            inh_cnt_bitwidth : integer := 1
        );
        port (
            clk : in std_logic;
            rst_n : in std_logic;
            restart : in std_logic;
            start : in std_logic;
            exc_spikes : in std_logic_vector(n_exc_inputs-1 downto 0);
            inh_spikes : in std_logic_vector(n_inh_inputs-1 downto 0);
            neurons_ready : in std_logic;
            exc_cnt : out std_logic_vector(exc_cnt_bitwidth - 1 downto 0);
            inh_cnt : out std_logic_vector(inh_cnt_bitwidth - 1 downto 0);
            ready : out std_logic;
            neuron_restart : out std_logic;
            exc : out std_logic;
            inh : out std_logic;
            out_sample : out std_logic;
            exc_spike : out std_logic;
            inh_spike : out std_logic
        );
    end component;

    component neuron is
        generic (
            neuron_bit_width : integer := 8;
            inh_weights_bit_width : integer := 6;
            exc_weights_bit_width : integer := 6;
            shift : integer := 4
        );
        port (
            v_th : in signed(neuron_bit_width-1 downto 0);
            inh_weight : in signed(inh_weights_bit_width-1 downto 0);
            exc_weight : in signed(exc_weights_bit_width-1 downto 0);
            clk : in std_logic;
            rst_n : in std_logic;
            restart : in std_logic;
            exc : in std_logic;
            inh : in std_logic;
            exc_spike : in std_logic;
            inh_spike : in std_logic;
            neuron_ready : out std_logic;
            out_spike : out std_logic
        );
    end component;

    component rom_3x2_exclif2 is
        port (
            clka : in std_logic;
            addra : in std_logic_vector(1 downto 0);
            dout_0 : out std_logic_vector(5 downto 0);
            dout_1 : out std_logic_vector(5 downto 0)
        );
    end component;

    component rom_2x2_inhlif2 is
        port (
            clka : in std_logic;
            addra : in std_logic_vector(0 downto 0);
            dout_0 : out std_logic_vector(5 downto 0);
            dout_1 : out std_logic_vector(5 downto 0)
        );
    end component;

    component addr_converter is
        generic (
            N : integer := 2
        );
        port (
            addr_in : in std_logic_vector(N-1 downto 0);
            addr_out : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component barrier is
        generic (
            N : integer := 2
        );
        port (
            clk : in std_logic;
            rst_n : in std_logic;
            restart : in std_logic;
            out_sample : in std_logic;
            reg_in : in std_logic_vector(N-1 downto 0);
            ready : out std_logic;
            reg_out : out std_logic_vector(N-1 downto 0)
        );
    end component;


    signal start_neurons : std_logic;
    signal neurons_restart : std_logic;
    signal neurons_ready : std_logic;
    signal exc : std_logic;
    signal inh : std_logic;
    signal exc_spike : std_logic;
    signal inh_spike : std_logic;
    signal exc_cnt : std_logic_vector(exc_cnt_bitwidth - 1 downto 0);
    signal inh_cnt : std_logic_vector(inh_cnt_bitwidth - 1 downto 0);
    signal exc_addr : std_logic_vector(exc_cnt_bitwidth - 1 downto 0);
    signal inh_addr : std_logic_vector(inh_cnt_bitwidth - 1 downto 0);
    signal neuron_restart : std_logic;
    signal barrier_ready : std_logic;
    signal out_spikes_inst : std_logic_vector(1 downto 0);
    signal out_sample : std_logic;
    signal neuron_ready_0 : std_logic;
    signal inh_weight_0 : std_logic_vector(inh_weights_bit_width-1 downto 0);
    signal exc_weight_0 : std_logic_vector(exc_weights_bit_width-1 downto 0);
    signal neuron_ready_1 : std_logic;
    signal inh_weight_1 : std_logic_vector(inh_weights_bit_width-1 downto 0);
    signal exc_weight_1 : std_logic_vector(exc_weights_bit_width-1 downto 0);

begin

    neurons_ready <= neuron_ready_0 and neuron_ready_1 and barrier_ready;


    multi_input_control : multi_input_3_exc_2_inh
        generic map(
            n_exc_inputs => n_exc_inputs,
            n_inh_inputs => n_inh_inputs,
            exc_cnt_bitwidth => exc_cnt_bitwidth,
            inh_cnt_bitwidth => inh_cnt_bitwidth
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            restart => restart,
            start => start,
            exc_spikes => exc_spikes,
            inh_spikes => inh_spikes,
            neurons_ready => neurons_ready,
            exc_cnt => exc_cnt,
            inh_cnt => inh_cnt,
            ready => ready,
            neuron_restart => neuron_restart,
            exc => exc,
            inh => inh,
            out_sample => out_sample,
            exc_spike => exc_spike,
            inh_spike => inh_spike
        );

    neuron_0 : neuron
        generic map(
            neuron_bit_width => neuron_bit_width,
            inh_weights_bit_width => inh_weights_bit_width,
            exc_weights_bit_width => exc_weights_bit_width,
            shift => shift
        )
        port map(
            v_th => v_th_0,
            inh_weight => signed(inh_weight_0),
            exc_weight => signed(exc_weight_0),
            clk => clk,
            rst_n => rst_n,
            restart => neuron_restart,
            exc => exc,
            inh => inh,
            exc_spike => exc_spike,
            inh_spike => inh_spike,
            neuron_ready => neuron_ready_0,
            out_spike => out_spikes_inst(0)
        );

    neuron_1 : neuron
        generic map(
            neuron_bit_width => neuron_bit_width,
            inh_weights_bit_width => inh_weights_bit_width,
            exc_weights_bit_width => exc_weights_bit_width,
            shift => shift
        )
        port map(
            v_th => v_th_1,
            inh_weight => signed(inh_weight_1),
            exc_weight => signed(exc_weight_1),
            clk => clk,
            rst_n => rst_n,
            restart => neuron_restart,
            exc => exc,
            inh => inh,
            exc_spike => exc_spike,
            inh_spike => inh_spike,
            neuron_ready => neuron_ready_1,
            out_spike => out_spikes_inst(1)
        );

    exc_mem : rom_3x2_exclif2
        port map(
            clka => clk,
            addra => exc_addr,
            dout_0 => exc_weight_0,
            dout_1 => exc_weight_1
        );

    exc_addr_conv : addr_converter
        generic map(
            N => exc_cnt_bitwidth
        )
        port map(
            addr_in => exc_cnt,
            addr_out => exc_addr
        );

    inh_mem : rom_2x2_inhlif2
        port map(
            clka => clk,
            addra => inh_addr,
            dout_0 => inh_weight_0,
            dout_1 => inh_weight_1
        );

    inh_addr_conv : addr_converter
        generic map(
            N => inh_cnt_bitwidth
        )
        port map(
            addr_in => inh_cnt,
            addr_out => inh_addr
        );

    spikes_barrier : barrier
        generic map(
            N => 2
        )
        port map(
            clk => clk,
            rst_n => rst_n,
            restart => restart,
            out_sample => out_sample,
            reg_in => out_spikes_inst,
            ready => barrier_ready,
            reg_out => out_spikes
        );


end architecture behavior;

