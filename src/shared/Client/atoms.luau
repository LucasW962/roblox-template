local Atoms = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dataTemplate = require("../data/dataTemplate")
local Charm = require(ReplicatedStorage.Packages.Charm)
local ClientNetwork = require(ReplicatedStorage.Shared.Network.client)
local TypeFunctions = require(ReplicatedStorage.Shared.TypeFunctions)
local DataTemplate = require(ReplicatedStorage.Shared.data.dataTemplate)



Atoms.Atoms = {} :: {[keyof<typeof(DataTemplate)>]: <T>(T?) -> TypeFunctions.ValuesOf<typeof(DataTemplate)>}


local REMOVE_SENT = "__REMOVE__"

for statName, default in DataTemplate do
	Atoms.Atoms[statName] = Charm.atom(default)
end

print(Atoms)

local function shallowCopy(t)
	if type(t) ~= "table" then
		return t
	end
	local out = {}
	for k, v in t do
		if type(v) == "table" then
			local sub = {}
			for kk, vv in v do
				sub[kk] = vv
			end
			out[k] = sub
		else
			out[k] = v
		end
	end
	return out
end

local function applyDelta(changes: TypeFunctions.Partial<typeof(DataTemplate)>)
	for path: keyof<typeof(DataTemplate)>, value in changes do
		local pathArray = string.split(path :: keyof<typeof(dataTemplate)>, "/")
		local atomName = pathArray[1]
		local isRemoval = value == REMOVE_SENT
		local atom = Atoms.Atoms[atomName]

		if #pathArray == 1 then
			if atom then
				if isRemoval then
					local default = DataTemplate[atomName]
					if default ~= nil then
						atom(default)
					else
						atom({})
					end
				else
					atom(value)
				end
			else
				if not isRemoval then
					Atoms.Atoms[atomName] = Charm.atom(value)
				end
			end
		else
			if not atom then
				if isRemoval then
					continue
				else
					Atoms.Atoms[atomName] = Charm.atom({})
					atom = Atoms.Atoms[atomName]
				end
			end

			local current = atom()
			if type(current) ~= "table" then
				current = {}
			end
			local newData = shallowCopy(current)
			local cursor = newData
			for i = 2, #pathArray - 1 do
				local key = tonumber(pathArray[i]) or pathArray[i]
				if cursor[key] == nil then
					if isRemoval then
						cursor = nil
						break
					else
						cursor[key] = {}
					end
				end
				cursor = cursor[key]
				if type(cursor) ~= "table" then
					if isRemoval then
						cursor = nil
						break
					else
						cursor = {}
					end
				end
			end
			if cursor then
				local finalKey = tonumber(pathArray[#pathArray]) or pathArray[#pathArray]
				if isRemoval then
					cursor[finalKey] = nil
				else
					cursor[finalKey] = value
				end
				atom(newData)
			end
		end
	end
end

ClientNetwork.Controller.Replicate.On(function(data: {dataName: string, dataValue: TypeFunctions.DeepReadonly<TypeFunctions.Partial<typeof(DataTemplate)>>})
    print(data)
	if data.dataName == "Data" then
		for name, value in data.dataValue do
			if Atoms.Atoms[name] then
				Atoms.Atoms[name](value)
			else
				Atoms.Atoms[name] = Charm.atom(value)
			end
		end
	elseif data.dataName == "DataDelta" then
		applyDelta(data.dataValue)
	end
end)

return table.freeze(Atoms)
