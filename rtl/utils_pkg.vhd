-- package declaration
library ieee;
use ieee.std_logic_1164.all;

package utils_pkg is
    function log2c (n: integer) return integer;
    function maxc (a: integer; b: integer) return integer;
end utils_pkg;

--package body
package body utils_pkg is
    function log2c (n: integer) return integer is
        variable m, p: integer;
    begin
        m := 0;
        p := 1;
        while p < n loop
            m := m + 1;
            p := p * 2;
        end loop;
        return m;
    end log2c;
    
    function maxc (a: integer; b: integer) return integer is
        variable c: integer;
    begin
        c := 0;
        if a > b then
            c := a;
        else
            c := b;
        end if;
        return c;
    end maxc;
end utils_pkg;