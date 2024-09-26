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


entity multi_input_dp_4_exc_3_inh is
    generic (
        n_exc_inputs : integer := 4;
        n_inh_inputs : integer := 3;
        exc_cnt_bitwidth : integer := 2;
        inh_cnt_bitwidth : integer := 2
    );
    port (
        clk : in std_logic;
        exc_spikes : in std_logic_vector(n_exc_inputs-1 downto 0);
        inh_spikes : in std_logic_vector(n_inh_inputs-1 downto 0);
        exc_sample : in std_logic;
        exc_rst_n : in std_logic;
        exc_cnt_en : in std_logic;
        exc_cnt_rst_n : in std_logic;
        inh_sample : in std_logic;
        inh_rst_n : in std_logic;
        inh_cnt_en : in std_logic;
        inh_cnt_rst_n : in std_logic;
        exc_yes : out std_logic;
        exc_spike : out std_logic;
        exc_stop : out std_logic;
        exc_cnt : out std_logic_vector(exc_cnt_bitwidth - 1 downto 0);
        inh_yes : out std_logic;
        inh_spike : out std_logic;
        inh_stop : out std_logic;
        inh_cnt : out std_logic_vector(inh_cnt_bitwidth - 1 downto 0)
    );
end entity multi_input_dp_4_exc_3_inh;

architecture behavior of multi_input_dp_4_exc_3_inh is


    component generic_or is
        generic (
            N : integer := 4
        );
        port (
            or_in : in std_logic_vector(N-1 downto 0);
            or_out : out std_logic
        );
    end component;

    component reg_sync_rst is
        generic (
            N : integer := 4
        );
        port (
            clk : in std_logic;
            en : in std_logic;
            rst_n : in std_logic;
            reg_in : in std_logic_vector(N-1 downto 0);
            reg_out : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component cnt is
        generic (
            N : integer := 8;
            rst_value : integer := 0
        );
        port (
            clk : in std_logic;
            cnt_en : in std_logic;
            cnt_rst_n : in std_logic;
            cnt_out : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component cmp_eq is
        generic (
            N : integer := 2
        );
        port (
            in0 : in std_logic_vector(N-1 downto 0);
            in1 : in std_logic_vector(N-1 downto 0);
            cmp_out : out std_logic
        );
    end component;

    component mux_4to1 is
        port (
            mux_sel : in std_logic_vector(1 downto 0);
            in0 : in std_logic;
            in1 : in std_logic;
            in2 : in std_logic;
            in3 : in std_logic;
            mux_out : out std_logic
        );
    end component;


    signal exc_spikes_sampled : std_logic_vector(n_exc_inputs-1 downto 0);
    signal inh_spikes_sampled : std_logic_vector(n_inh_inputs-1 downto 0);
    signal exc_cnt_sig : std_logic_vector(exc_cnt_bitwidth-1 downto 0);
    signal inh_cnt_sig : std_logic_vector(inh_cnt_bitwidth-1 downto 0);

begin

    exc_cnt <= exc_cnt_sig;
    inh_cnt <= inh_cnt_sig;


    exc_or : generic_or
        generic map(
            N => n_exc_inputs
        )
        port map(
            or_in => exc_spikes,
            or_out => exc_yes
        );

    inh_or : generic_or
        generic map(
            N => n_inh_inputs
        )
        port map(
            or_in => inh_spikes,
            or_out => inh_yes
        );

    exc_reg : reg_sync_rst
        generic map(
            N => n_exc_inputs
        )
        port map(
            clk => clk,
            en => exc_sample,
            rst_n => exc_rst_n,
            reg_in => exc_spikes,
            reg_out => exc_spikes_sampled
        );

    inh_reg : reg_sync_rst
        generic map(
            N => n_inh_inputs
        )
        port map(
            clk => clk,
            en => inh_sample,
            rst_n => inh_rst_n,
            reg_in => inh_spikes,
            reg_out => inh_spikes_sampled
        );

    exc_mux : mux_4to1
        port map(
            mux_sel => exc_cnt_sig,
            in0 => exc_spikes_sampled(0),
            in1 => exc_spikes_sampled(1),
            in2 => exc_spikes_sampled(2),
            in3 => exc_spikes_sampled(3),
            mux_out => exc_spike
        );

    inh_mux : mux_4to1
        port map(
            mux_sel => inh_cnt_sig,
            in0 => inh_spikes_sampled(0),
            in1 => inh_spikes_sampled(1),
            in2 => inh_spikes_sampled(2),
            in3 => '0',
            mux_out => inh_spike
        );

    exc_counter : cnt
        generic map(
            N => exc_cnt_bitwidth,
            rst_value => 3
        )
        port map(
            clk => clk,
            cnt_en => exc_cnt_en,
            cnt_rst_n => exc_cnt_rst_n,
            cnt_out => exc_cnt_sig
        );

    inh_counter : cnt
        generic map(
            N => inh_cnt_bitwidth,
            rst_value => 3
        )
        port map(
            clk => clk,
            cnt_en => inh_cnt_en,
            cnt_rst_n => inh_cnt_rst_n,
            cnt_out => inh_cnt_sig
        );

    exc_cmp : cmp_eq
        generic map(
            N => exc_cnt_bitwidth
        )
        port map(
            in0 => exc_cnt_sig,
            in1 => std_logic_vector(to_unsigned(n_exc_inputs-2, exc_cnt_bitwidth)),
            cmp_out => exc_stop
        );

    inh_cmp : cmp_eq
        generic map(
            N => inh_cnt_bitwidth
        )
        port map(
            in0 => inh_cnt_sig,
            in1 => std_logic_vector(to_unsigned(n_inh_inputs-2, inh_cnt_bitwidth)),
            cmp_out => inh_stop
        );


end architecture behavior;

