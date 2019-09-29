### Usage
First require the file:
```lua
enum = require "enum"  
```
Then you can create enums by calling `enum()` and passing it as an argument a table where each key is an enum field:
```lua
local days = enum({ 
  "0+1", -- optional enum format
  "SUNDAY", 
  "MONDAY",
  "TUESDAY",
  -- etc
}, "days) -- optional enum name
```
To create a default enum, where fields are given values from `0` to `N` and are incremented by `1`, you can simply omit the format string. However, by adding the format string as the first element of the enum you can create different enums. When the first key specifies the format, it gets parsed and removed before the enum's construction takes place. You can also append custom values (including negative ones) to the enum keys themselves (see examples below).

The format string looks like this: `"<start value><increment>"` (no spaces), where `<start value>` is any integer number and `<increment>` is a `+` followed by another integer or a `*`. The `+` makes regular increments, the `*` makes exponential increments.
```lua
"10+5"  -- starts at 10, increments by 5
"16"    -- starts at 16, increments by 1 (since increment was omitted)
"+2"    -- starts at 0 (since start value was omited), increments by 2
"*"     -- starts at 0, increments exponentially
"1*"    -- starts at 1, increments exponentially
```
Naturally, when using `*` you can't specify the increment by a number, as it gets automatically calculated to exponents. However, you can still use custom values.

Standard naming rules for identifiers apply: field names cannot contain spaces, must start by a letter or underscore, can contain numbers after that.

Duplicated strings will throw an error. 

Using a custom value on the first enum element will override `<start value>`.

## Examples
An enum that starts at `10` and is incremented by `+2`:
```lua
local days = enum({ "10+2", -- <-- I usually place the format here, instead of the next line
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
Enum with custom values appended to the keys, separated by a space or tab:
```lua
local days = enum({ "+5",
  "SUNDAY",       -- 5
  "MONDAY",       -- 10
  "TUESDAY 100",  -- 100
  "WEDNESDAY",    -- 105
  "THURSDAY",     -- 110
  "FRIDAY 256",   -- 256
  "SATURDAY"      -- 261
})
```
