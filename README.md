## Lua Enum
Implements enums in Lua in a way that allows some flexibility and minimal effort. It automatically assigns values to its fields in increments of 1, or of a specified value, or exponentially, and it allows to easily add custom values. It also allows negative values and negative growth, and provides a `count` property that holds the number of fields in the enum.

## Usage

Enums can be constructed in three ways:

```lua
local Enum = require "enum" 


-- construct enum from a multiline string (most convenient)
-- (can contain single line comments, and parentheses can be omitted)
local days = Enum [[ +1    -- optional format (see below) -- this is the default format
    SUNDAY             
    MONDAY             
    TUESDAY            
    WEDNESDAY
    THURSDAY  = 100    -- you can append custom values, separated by '=' or just white-space
    FRIDAY    = -10    -- enums support negative values
    SATURDAY
]]


-- construct enum from a table of strings (parentheses can also be omitted)
local days = Enum { '+1',
    "SUNDAY", 
    "MONDAY", 
    "TUESDAY", 
    "WEDNESDAY", 
    "THURSDAY    100",    -- only the multiline-string constructor above
    "FRIDAY      -10",    -- supports '=' as a separator
    "SATURDAY"
}


-- construct enum from several loose strings
local days = Enum( '+1',    
    "SUNDAY", 
    "MONDAY",
    "TUESDAY",
    "WEDNESDAY",
    "THURSDAY    100",
    "FRIDAY      -10",
    "SATURDAY"
)

```
After that you can use it:
```lua
print(days.TUESDAY)  -- 2
print(days.THURSDAY) -- 100
print(days.count)    -- 7 (number of fields in the enum)

print(days:get_field_name(2))  -- MONDAY

-- usualy only for debugging purposes
print(days)               -- prints the entire enum
print(days:pretty_str())  -- pretty-prints the enum in a more readable form
```

Standard naming rules for identifiers apply: element names cannot contain spaces, must start with a letter or underscore, can contain numbers, etc.

Duplicate fields will throw an error.

##### Note: Enums start at '0' by default. If you need them to start from '1' you must specify a custom value for the first element.

If you'd like to transfer the fields of an enum into some other table, you can call `Enum.copy_to(t)`. Note that this is a simple copy, it won't merge enums. This is only intended for flattening enums into a class table, or to create globals from enum fields.



### Format

The format is optional, and it allows you to specify how values are incremented. When omited, a default enum is created, where fields are given values from `0` to `N`, and are incremented by `1`. If it's included, then it must be the first parameter.

For most use cases, a simple sign should be enough (increment values can be omitted):
```lua
+        -- increment by 1 - equivalent to '+1', or just '1' (this is the default, so it can be omited entirely)
-        -- decrement by 1 - equivalent to '-1'
*        -- exponential increments by double - equivalent to '*2'   - (0, 1, 2, 4, 8, 16, ...)
*-       -- exponential decrements by double - equivalent to '*-2'  - (0, -1, -2, -4, -8, -16, ...)
```

However, different increments can be specified after the sign:

```lua
+3       -- increaments by 3 (the '+' can be omitted)
-10      -- decrements by 10
*4       -- increments exponentially by quadruple (0, 1, 4, 16, 64, ...)
*-4      -- decrements exponentially by quadruple (0, -1, -4, -16, -64, ...)
```

You can still control the flow of the increments by adding custom values to fields.


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

-- or loop normally (enum fields are always from '1' to 'enum.count', independently of their values)
for i=1, days.count do
    print(days[i])
end
```

## Some real world examples

```lua
local window_flags = Enum [[ *
    DEFAULT              -- 0 
    NO_TITLE             -- 1
    NO_DRAGGING          -- 2
    NO_CLOSE             -- 4
    NO_BORDER            -- 8
    NO_ICON              -- 16
    FULLSCREEN           -- 32
]]
```

```lua
local tile_types = Enum [[
    VOID                 -- 0
    WALL_STONE           -- 1
    WALL_WOOD            -- 2
    WALL_PLASTER         -- 3
    FLOOR_DIRT   = 20    -- 20
    FLOOR_GRASS          -- 21
    FLOOR_WOOD           -- 22
    WATER        = 40    -- 40
    LAVA                 -- 41
]]
```
