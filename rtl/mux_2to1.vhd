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


entity mux_2to1 is
    port (
        mux_sel : in std_logic;
        in0 : in std_logic;
        in1 : in std_logic;
        mux_out : out std_logic
    );
end entity mux_2to1;

architecture behavior of mux_2to1 is


begin

    selection : process(mux_sel, in0, in1 )
    begin

        case mux_sel is

            when '0' =>
                mux_out <= in0;


            when others =>
                mux_out <= in1;


        end case;

    end process selection;


end architecture behavior;

