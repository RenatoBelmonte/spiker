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


entity rom_3x3_inhlif1_ip is
    port (
        clka : in std_logic;
        addra : in std_logic_vector(1 downto 0);
        douta : out std_logic_vector(17 downto 0)
    );
end entity rom_3x3_inhlif1_ip;

architecture behavior of rom_3x3_inhlif1_ip is


    type rom_type is array (0 to 3) of std_logic_vector(17 downto 0);


    constant mem : rom_type := (
"000000000000000000",
"000000000000000000",
"000000000000000000",
"000000000000000000");

begin

    rom_behavior : process(clka )
    begin

        if clka'event and clka='1' 
        then

            douta <= mem(to_integer(unsigned(addra)));

        end if;

    end process rom_behavior;


end architecture behavior;

