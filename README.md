### Usage
First require the file:
```lua
require "enum"
```
Then you can create enums by calling `enum()` and passing it a table of string fields as an argument, like so:
```lua
local days = enum({
  "SUNDAY", 
  "MONDAY",
  "TUESDAY",
  -- etc
})
```
That creates a default enum, where fields are given values from `0` to `N`, incremented by `1`. You can create enums of different formats by adding a format string before the first enum field. When the first string specifies the format, it gets parsed and removed before the enum's construction takes place. You can also append custom values (including negative ones) to the field strings.

The format string looks like this: `"<start value><increment>"` (no spaces), where `<start value>` is any integer number and `<increment>` is a `+` followed by another integer or a `*`. `+` makes regular increments, `*` makes exponential increments.
```lua
"10+5"  -- starts at 10, increments by 5
"16"    -- starts at 16, increments by 1 (since increment was omitted)
"+2"    -- starts at 0 (start was omited), increments by 2
"*"     -- starts at 0, increments exponentially
"1*"    -- starts at 1, increments exponentially
```
Naturally, when using `*` you can't specify the increment by a number, as it gets set automatically to exponents. However, you can still use custom values (see the examples below).

Standard naming rules for identifiers apply: field names cannot contain spaces, must start by a letter or underscore, can contain numbers after that.
Duplicated strings will throw an error. 

## Examples
An enum that starts at `10` and is incremented by `+2`:
```lua
local days = enum({ "10+2",
  "SUNDAY",       -- 10
  "MONDAY",       -- 12
  "TUESDAY",      -- 14
  "WEDNESDAY",    -- 16
  -- etc
})
```
An enum that increments exponentially:
```lua
local days = enum({ "*",    -- remember, if an increment is included along with `*`, it gets ignored
  "SUNDAY",       -- 0
  "MONDAY",       -- 1
  "TUESDAY",      -- 2
  "WEDNESDAY",    -- 4
  "THURSDAY",     -- 8
  "FRIDAY",       -- 16
  "SATURDAY"      -- 32
})
```
You can also specify the starting position when using `*`, as in `16*`.

To use custom values, append them to the strings, separated by a space or tab:
```lua
local days = enum({ "+5",    -- starts at 0 (because the start value was omitted), and increments by 5
  "SUNDAY",       -- 5
  "MONDAY",       -- 10
  "TUESDAY 100",  -- 100
  "WEDNESDAY",    -- 105
  "THURSDAY",     -- 110
  "FRIDAY 256",   -- 256
  "SATURDAY"      -- 261
})
```
