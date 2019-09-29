local ENUM_MT = {}
ENUM_MT = {
	__index = function(t, k) return ENUM_MT[k] end,
	__tostring = function(t)
		local str = ""
		if t.name then str = t.name .. " {\n"
		else           str = "enum {\n"
		end
		for i=1, t.max do
			local idx = t._values[i]
			local v = t._ordered_fields[idx]
			str = string.format("%s    %-4d %s\n", str, idx, v)
		end
		return str .. "}"
	end
}

-- used to check for duplicated keys
local function is_in(t, new_k)
	for k, v in pairs(t) do
		if new_k == k then return true end
	end
	return false
end

local function enum(list, name)
	local t = {}
	t.name = name
	t.max = #list

	-- handy for __tostring()
	t._ordered_fields = {}
	t._values = {}

	-- default values
	local exp = false
	local step = 1
	local start = 0

	-- if 1st element contains enum formatting, parse it and remove it
	if not string.match(list[1], "^[a-zA-Z_]+") then
		local str = list[1]
		table.remove(list, 1)
		t.max = t.max - 1

		-- if string begins with a number, set it as start
		if tonumber(str:sub(1, 1)) ~= nil then
			start = tonumber(string.match(str, "[0-9]+")) or 0
		end

		-- check if there's any '+' or '*'
		local plus = string.find(str, '+')
		local ast = string.find(str, '*')

		if ast then
			exp = true
		elseif plus then
			-- if a '+' exists, check if there's a custom increment
			local inc = string.match(str:sub(plus+1, #str), "[0-9]+")
			if inc then step = inc end
		end
	end

	local idx = start
	for i=1, t.max do
		-- try splitting the current entry into parts, if possible
		local words = {}
		for word in list[i]:gmatch("[a-zA-Z0-9_-]+") do table.insert(words, word) end
		local k = words[1]
		assert( not is_in(t, k), string.format("\n\n    Entry '%s' already exists in enum.\n\n", k) )

		-- if a second element exists then current entry contains a
		-- custom value; set 'idx' to it
		if words[2] then
			if idx == start then start = tonumber(words[2]) end -- if it's the 1st one, also set start to it
			idx = tonumber(words[2])
		end

		-- store the entries and respective values
		t[k] = idx
		t._ordered_fields[idx] = k
		table.insert(t._values, idx)

		-- increase 'idx' by increments or exponential growth
		if not exp then
			idx = idx + step
		else
			if idx ~= -1 and idx ~= 0 and idx ~= 1 then
				if idx < 0 then idx = math.ceil(idx/2)
				else            idx = idx + idx end
			else
				idx = idx + 1
			end
		end
	end
	return setmetatable(t, ENUM_MT)
end

return enum
