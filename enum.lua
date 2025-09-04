--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--[[    MIT License

Copyright (c) 2019 Skaruts (https://github.com/Skaruts/Lua-Enum)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--
--          Enum    (version 18)
--
--    An Enumeration implementation in Lua.
--
--
--      Quick Reference:
--          local Foo = Enum [[
--              NULL
--              DERP
--          ]]
--
--          Foo:ipairs()  -- for lua 5.2+ use the regular 'ipairs'
--          Foo:pairs()   -- for lua 5.2+ use the regular 'pairs'
--
--          Foo:pretty_str()
--          Foo:get_field_name(field_val)
--          Foo:copy_to(t)
--
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==

local fmt          = string.format
local remove       = table.remove
local floor         = math.floor
local ceil         = math.ceil
local abs          = math.abs
local type         = type
local next         = next
local select       = select
local tonumber     = tonumber
local setmetatable = setmetatable


local function _iterator(t, i)
	i = i+1
	local val = t[i]
	if i > #t then return end
	return i, val
end


local Enum = {
	__type = "Enum", -- personal convention

	__newindex = function(t, k, v) error("cannot assign to an enum (enums are immutable)", 2) end,
	__tostring = function(t)
		local str = "enum: "
		for i=1, #t._ordered_fields do
			local k = t._ordered_fields[i]
			local v = t._fields[k]
			str = str .. fmt("%s = %d", k, v)
			if i < #t._ordered_fields then str = str .. ", " end
		end
		return str .. ""
	end,
	-- for lua 5.2+
	__ipairs = function(t) return _iterator, t._iterable_values, 0 end,
	__pairs = function(t) return next, t._fields, nil end,
}

Enum.__index = function(t, k)
	return t._fields[k]
	or Enum[k]
	or t._iterable_values[k]
	or error(fmt("field %s does not exist in enum", k), 2)
end


function Enum.make_globals(enable)
	error("'Enum.make_globals' has been deprecated and replaced with 'enum:copy_to'", 2)
end

-- for lua 5.1
function Enum:ipairs() return _iterator, self._iterable_values, 0 end
function Enum:pairs() return next, self._fields, nil end

-- returns a string representation of the Enum for pretty printing
-- lays out the enum neatly over several lines with indentation,
-- optionally preffixed by 'name'
function Enum:pretty_str(name)
	name = name or "Enum"
	local str = name .. " {\n"
	for i=1, #self._ordered_fields do
		local k = self._ordered_fields[i]
		local v = self._fields[k]
		str = str.. fmt(fmt("    %%-%ds%%d\n", self._longest_field+4), k, v)
	end
	return str .. "}"
end

function Enum:get_field_name(field_val)
	return self._fields_by_value[field_val]
end

-- copy enum fields into table 't',
-- such that enum.FOO becomes also available as t.FOO
function Enum:copy_to(t)
	for k, v in self:pairs() do
		t[k] = v
	end
end

local function _new_from_table(...)
	local t = {
		count = {},
		_fields = {},
		_iterable_values = {},
		_ordered_fields = {},
		_fields_by_value = {},
		_longest_field = 0,  -- for pretty printing
	}

	local exp = false    -- exponential stepping
	local step = 1       -- incremental step
	local elems = type(...) == "table" and ... or {...}

	-- check format
	local str = elems[1]:match("^[-+*%d]+")
	if str then
		remove(elems, 1)

		if tonumber(str) then
			step = tonumber(str)
		else
			if #str == 1 then
				if     str == '-' then step = -1
				elseif str == '+' then step = 1
				elseif str == '*' then
					step, exp = 2, true
				else
					error(fmt("invalid format '%s'", str))
				end
			else
				if str:sub(1, 1) ~= '*' then error(fmt("invalid format '%s'", str)) end
				step, exp = 2, true
				local inc = tonumber(str:match('%-?%d$'))
				if not inc and str:sub(2, 2) == '-' then inc = -2 end
				step = (inc and inc ~= 0) and inc or step
			end
		end
	end

	if step == 0 then error("Enum stepping cannot be zero", 2) end

	-- assemble the enum
	t.count = #elems
	local val = 0

	for i=1, #elems do
		local words = {}    -- try splitting the current entry into parts, if possible
		for word in elems[i]:gmatch("[%w_-]+") do
			words[#words+1] = word
		end

		-- check for duplicates
		local k = words[1]
		if t._fields[k] then error(fmt("duplicate field '%s' in enum", k), 2) end

		-- keep track of longest for pretty printing
		if #k > t._longest_field then t._longest_field = #k end

		-- if a second element exists then current entry contains a custom value
		if words[2] then val = tonumber(words[2]) end
		if not val then error(fmt("invalid value '%s' for enum field", words[2]), 2) end

		-- store the entries and respective values
		t._fields[k] = val
		t._ordered_fields[i] = k    -- useful for printing
		t._iterable_values[i] = val -- useful for iterators
		t._fields_by_value[val] = k

		-- increase 'val' by increments or exponential growth
		if not exp then
			val = val + step
		else
			if val ~= 0 then
				if val > 0 and step < 0 then
					val = floor(val / abs(step))
				elseif val < 0 and step > 0 then
					-- val = val * step
					val = ceil(val / abs(step))
				else
					val = val * abs(step)
				end
			else
				val = step > 0 and 1 or -1
			end
		end
	end

	return setmetatable(t, Enum)
end


local function _new_from_string(...)
	-- check if it's more than one string
	if select("#",...) > 1 then return _new_from_table(...) end

	-- remove comments
	local s = (...):gsub("%-%-[^\n]+", "")

	-- remove whitespace and ',' or '=', join custom values to their fields
	-- and put everything in a table
	local t = {}
	for word in s:gmatch('([^,\r\n\t =]+)') do
		if not tonumber(word) or #t == 0 then  -- if NAN or is format string
			t[#t+1] = word
		else
			t[#t] = t[#t] .. " " .. tonumber(word)
		end
	end
	return _new_from_table(t)
end


local _constructors = {
	string = _new_from_string,
	table = _new_from_table,
}

function Enum.new(...)
	local constructor = _constructors[type(...)]
	if not constructor then error("invalid parameters for enum: must be a string, table or string varargs", 2) end
	return constructor(...)
end


return setmetatable( Enum, { __call = function(_, ...) return Enum.new(...) end } )
