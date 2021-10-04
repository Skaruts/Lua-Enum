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
local fmt = string.format
local match = string.match
local remove = table.remove
local ceil = math.ceil
local type = type
local next = next
local setmetatable = setmetatable

local function _iterator(t, i)
	i = i+1
	local val = t[i]
	if i > #t then return end
	return i, val
end

local Enum = {}
local MT = {
	__type = "enum",
	__index = function(t, k)
		return t._fields[k]
		or Enum[k]
		or t._iterable_values[k]
		or error(fmt("field %s does not exist in enum", k), 2)
	end,
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

-- for lua 5.1
function Enum:ipairs() return _iterator, self._iterable_values, 0 end
function Enum:pairs() return next, self._fields, nil end


local function _new(...)
	if type(...) ~= "string" and type(...) ~= "table" then
		error("invalid parameters for enum: must be a table or list of strings", 2)
	end

	local t = {
		count = {},
		_fields = {},
		_ordered_fields = {},
		_iterable_values = {},
		__longest_field = 0,  -- for pretty printing
	}

	local exp = false    -- exponential stepping
	local step = 1       -- incremental step
	local start = 1      -- starting value
	local elems = type(...) == "table" and ... or {...}

	-- if 1st field is the enum formatting, parse it and remove it
	if not elems[1]:match("^[%a_]+") then
		local str = elems[1]
		remove(elems, 1)

		-- if string begins with a number, set it as start value
		if str:match("^[%d-]") then
			start = tonumber(str:match("[%d-]+")) or 1
		end

		local plus = str:find('+')  -- check if there's a '+'
		if plus then  -- if a '+' exists, check if there's a custom increment
			local inc = match(str:sub(plus+1, #str), "[%d-]+")
			if inc then step = inc end
		elseif str:find('*') then  -- otherwise check if there's a '*'
			exp = true
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
		if t._fields[k] then error(fmt("duplicate field '%s' in enum", k), 2) end

		if #k > t.__longest_field then
			t.__longest_field = #k
		end

		-- if a second element exists then current entry contains a custom value
		if words[2] then val = tonumber(words[2]) end

		-- store the entries and respective values
		t._fields[k] = val
		t._ordered_fields[i] = k    -- useful for printing
		t._iterable_values[i] = val -- useful for iterators

		-- increase 'val' by increments or exponential growth
		if not exp then                   val = val + step
		elseif val < -1 or val > 1 then   val = val < 0 and ceil(val/2) or val + val
		else                              val = val + 1
		end
	end

	return setmetatable(t, MT)
end

-- pretty print - prints the enum neatly over several lines and indented
function Enum:pprint()
	local str = "enum {\n"
	for i=1, #self._ordered_fields do
		local k = self._ordered_fields[i]
		local v = self._fields[k]
		str = str.. fmt(fmt("    %%-%ds%%6d\n", self.__longest_field), k, v)
	end
	return str .. "}"
end




--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--
-- TESTS

-- local do_tests = true

if do_tests
and (not love or not debug.getinfo(2).name) then
	local e = _new({"*",
		"foo",
		"bar",
		"derp",
		"poo",
		"ferp",
		"snherp",
		"ftosdso"
	})

	print(e)

	-- for k,v in e:pairs() do print(k,v) end
	-- for i,v in e:ipairs() do print(i,v) end
	-- for k,v in pairs(e) do print(k,v) end
	-- for i,v in ipairs(e) do print(i,v) end
end
--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--



return setmetatable( Enum, { __call = function(_, ...) return _new(...) end } )
