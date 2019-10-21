--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
-- MIT License
--
-- Copyright (c) 2019 Skaruts (https://github.com/Skaruts/Lua-Enum)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local Enum = {}
local MT = {
	__index = function(t, k) return
		t._fields[k] or Enum[k] or t._iterable_values[k]
		or error(string.format("\n\n    Field %s does not exist in enum.\n\n", k), 2)
	end,
	__newindex = function(t, k, v) error("\n\n    Enum is immutable.\n\n", 2) end,
	__tostring = function(t)
		local str = "{\n"
		for i=1, #t._ordered_fields do
			local k = t._ordered_fields[i]
			local v = t._fields[k]
			str = str.. string.format("    %-4d %s\n", v, k)
		end
		return str .. "}"
	end
}
function Enum.new(...)
	if type(...) ~= "string" and type(...) ~= "table" then
		error("\n\n    Invalid object for enum initialization. Must be a table or list of strings.\n\n")
	end
	local t = { count = {}, _fields = {}, _ordered_fields = {}, _iterable_values = {} }
	setmetatable(t, MT)

	local exp = false    -- exponential stepping
	local step = 1       -- incremental step
	local start = 1      -- starting value
	local elems = {...}
	if type(elems[1]) == "table" then elems = elems[1] end

	-- if 1st field is the enum formatting, parse it and remove it
	if not string.match(elems[1], "^[%a_]+") then
		local str = elems[1]
		table.remove(elems, 1)

		-- if string begins with a number, set it as start
		if str:match("^[%d-]") then start = tonumber(str:match("[%d-]+")) or 1 end

		local plus = str:find('+')  -- check if there's any '+'
		if str:find('*') then       -- or '*'
			exp = true
		elseif plus then            -- if a '+' exists, check if there's a custom increment
			local inc = string.match(str:sub(plus+1, #str), "[%d-]+")
			if inc then step = inc end
		end
	end

	t.count = #elems

	local val = start
	for i=1, #elems do
		local words = {}    -- try splitting the current entry into parts, if possible
		for word in elems[i]:gmatch("[%w_-]+") do
			words[#words+1] = word
		end

		local k = words[1]
		if t._fields[k] then error( string.format("\n\n    Field '%s' already exists in enum.\n\n", k) ) end

		-- if a second element exists then current entry contains a custom value
		if words[2] then val = tonumber(words[2]) end

		-- store the entries and respective values
		t._fields[k] = val
		t._ordered_fields[i] = k    -- useful for printing
		t._iterable_values[i] = val -- useful for iterators

		-- increase 'val' by increments or exponential growth
		if not exp then                   val = val + step
		elseif val < -1 or val > 1 then   val = val < 0 and math.ceil(val/2) or val + val
		else                              val = val + 1
		end
	end
	return t
end

local function iterator(t, i)
	i = i+1
	local val = t[i]
	if i > #t then return end
	return i, val
end

function Enum:items()
	return iterator, self._iterable_values, 0
end

return setmetatable( Enum, { __call = function(_, ...) return Enum.new(...) end } )
