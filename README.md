## Lua Enum
Implements enums in Lua in a way that allows some flexibility and minimal effort. It automatically assigns values to its elements in increments of 1, or of a specified value, or exponentially, and it allows to easily add custom values. It also allows negative values, and provides a `count` property that holds the number of elements in the enum.

## Usage

```lua
local Enum = require "enum" 

local days = Enum( '0+1',    -- optional format (see below) -- these are the default values
  "SUNDAY", 
  "MONDAY",
  "TUESDAY",
  "WEDNESDAY",
  "THURSDAY   100",    -- you can append custom values, separated by white-space
  "FRIDAY     -10",    -- enums support negative values
  "SATURDAY"
)

-- or using a table (it can contain the format)
local t = {"SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"}
local days = Enum(t)
```

After that you can use it:
```lua
print(days.TUESDAY)  -- 2
print(days.THURSDAY) -- 100
print(days.count)    -- 7 (number of elements in the enum)
print(days)          -- prints the entire enum
days:pprint()        -- pretty-prints the enum in a more readable form
```

Standard naming rules for identifiers apply: element names cannot contain spaces, must start by a letter or underscore, can contain numbers, etc.

Duplicate elements will throw an error.

### Format

The format is optional, and it allows you to specify how values are assigned. When omited, a default enum is created, where elements are given values from `0` to `N`, and are incremented by `1`. If it's included, then it has to be the first parameter.

The format should look like this: `"<start_value> <increment>"`, where `<start_value>` is any integer number, and `<increment>` is either a `+` followed by another integer, or a single `*`. The `+` makes regular increments, the `*` makes exponential increments. The format string can contain spaces.

For example:

```lua
'10+5'      -- starts at 10, increments by 5
'16'        -- starts at 16, increments by 1 (since <increment> was omitted)
'+2'        -- starts at 0 (since <start_value> was omited), increments by 2
'*'         -- starts at 0, increments exponentially
'1*'        -- starts at 1, increments exponentially
'-10 + -1'  -- starts at -10, increments by -1 (decrements)
```

When using `*` the increment is automatically calculated to exponents (if you put a number after the `*`, it gets ignored). However, you can still control the flow of the increments by adding custom values to elements.

**Note:** Using a custom value on the first enum element will override `<start_value>`

### Loops

You can use enums in loops. 
```lua
-- loop with `ipairs` or `pairs` in lua 5.2+
for i, v in ipairs(days) do
    print(i, v)
end

for k, v in pairs(days) do
    print(k, v)
end

-- loop with `Enum.ipairs` or `Enum.pairs` in lua 5.1
for i, v in days:ipairs() do 
    print(i, v)
end

for k, v in days:pairs() do 
    print(k, v)
end

-- or loop normally (enum elements are always from '1' to 'enum.count', independently of their values)
for i=1, days.count do
    print(days[i])
end
```

## Some real world examples

```lua
local window_flags = Enum('*',
  "DEFAULT",         -- 0 
  "NO_TITLE",        -- 1
  "NO_DRAGGING",     -- 2
  "NO_CLOSE",        -- 4
  "NO_BORDER",       -- 8
  "NO_ICON",         -- 16
  "FULLSCREEN"       -- 32
)
```

```lua
local tile_types = Enum(
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
