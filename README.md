## Lua Enum
Implements enums in Lua in a way that allows some flexibility and minimal effort. It automatically assigns values to its elements in increments of 1, of a specified value, or exponentially, and it allows easy use of custom values. It also allows negative values, and provides a `count` field that holds the number of elements in the enum.

## Usage
Drop this file in your project and require it
```lua
local Enum = require "enum" -- returns the Enum constructor
```
Then create enums by calling the constructor and passing it a table where each key is an enum element:
```lua
local days = Enum( 
  "1+1",          -- optional format string (those are default values)
  "SUNDAY", 
  "MONDAY",
  "TUESDAY",
  "WEDNESDAY",
  "THURSDAY 100", -- optional custom values
  "FRIDAY",
  "SATURDAY"
)
```

After that you can use it:
```lua
print(days.TUESDAY)  -- 3
print(days.FRIDAY)   -- 6
print(days.count)    -- 7 (number of fields in the enum)
print(days)          -- prints the entire enum (in human-readable form)
```

The format string is optional. If it's included, it as to be the first parameter. If it's omited, a default enum (where elements are given values from `1` to `N` and are incremented by `1`) is created. However, by adding the format string you can manipulate how values are assigned. 

You can also append custom values (including negative ones) to the enum keys themselves, separated by whitespace (see example near the bottom).

The format string looks like this: `"<start_value><increment>"`, where `<start_value>` is any integer number, and `<increment>` is a `+` followed by another integer, or a `*`. The `+` makes regular increments, the `*` makes exponential increments.
```lua
"10+5"    -- starts at 10, increments by 5
"16"      -- starts at 16, increments by 1 (since <increment> was omitted)
"+2"      -- starts at 1 (since <start_value> was omited), increments by 2
"*"       -- starts at 1, increments exponentially
"0*"      -- starts at 0, increments exponentially
"-10+-1"  -- starts at -10, decrements by -1
```
Naturally, when using `*` you cannot specify the increment by a number, as it gets automatically calculated to exponents (if you put a number there it gets ignored). However, you can still use custom values to control the flow of the increments.

Lastly:
- The format string can contain spaces
- Standard naming rules for identifiers apply: element names cannot contain spaces, must start by a letter or underscore, can contain numbers after that, etc
- Duplicated elements will throw an error
- Using a custom value on the first enum element will override `<start_value>`
- Using negative custom values with exponential growth will increase them by half toward `0`
- You can use enums in loops. Enum has its own iterator `items()` that returns an ordered array with its elements:
```lua
-- loop with Enum:items()
for i, v in days:items() do  -- 
	print(i, v)
end

-- loop normally
for i=1, days.count do
	print(foo[i])
end
```

## Examples
Enum that starts at `10` and is incremented by `+2`:
```lua
local days = Enum( "10+2", -- <-- by personal preference, I place the format here, instead of in the next line
  "SUNDAY",       -- 10
  "MONDAY",       -- 12
  "TUESDAY",      -- 14
  "WEDNESDAY",    -- 16
  -- etc
)
```
Enum that increments exponentially:
```lua
local Flags = Enum( "*",    -- remember, increment values get ignored if included along with `*`
  "SOME_FLAG_1",       -- 1
  "SOME_FLAG_2",       -- 2
  "SOME_FLAG_3",       -- 4
  "SOME_FLAG_4",       -- 8
  "SOME_FLAG_5",       -- 16
  "SOME_FLAG_6",       -- 32
  "SOME_FLAG_7"        -- 64
)
```
Enum with custom values appended to the keys, separated by spaces or tabs:
```lua
local Tiles = Enum( "0"
  "VOID",                -- 0
  "WALL_STONE",          -- 1
  "WALL_WOOD"            -- 2
  "WALL_PLASTER"         -- 3
  "FLOOR_DIRT    20",    -- 20
  "FLOOR_GRASS",         -- 21
  "FLOOR_WOOD",          -- 22
  "WATER         40",    -- 40
  "LAVA"                 -- 41
)
```
You can also provide the elements in a table
```lua
local t = {"SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"}
table.insert(t, "0", 1) -- add the format
local days = Enum(t)
```
