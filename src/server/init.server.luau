--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoadedModules = {} :: { [string]: ModuleScript }
local DataService = require(script.Services.Data)

local function RegisterDirectory(Folder: Folder)
	for _, child: ModuleScript in Folder:QueryDescendants("ModuleScripts") do
		if child.Name:find(string.lower("client")) then
			continue
		end
		if child.Name == "Data" then
			continue
		end
		LoadedModules[child.Name] = require(child) :: any
	end
end

local function CharacterAdded(Character: Model)
	for moduleName, module in LoadedModules do
		if type(module) == "table" and module.CharacterAdded and typeof(module.CharacterAdded) == "function" then
			module.CharacterAdded(Character)
		end
	end
end

local function PlayerAdded(Player: Player)
	DataService.PlayerInit(Player)
	if Player.Character then
		CharacterAdded(Player.Character :: Model)
	end

	Player.CharacterAdded:Connect(CharacterAdded)
	for moduleName, module in LoadedModules do
		if
			type(module) == "table"
			and module.PlayerInit
			and typeof(module.PlayerInit) == "function"
			and module.Name ~= "Data"
		then
			module.PlayerInit(Player)
		end
	end
end

local function PlayerRemoving(Player: Player)
	for moduleName, module in LoadedModules do
		if type(module) == "table" and module.PlayerRemoving and typeof(module.PlayerRemoving) == "function" then
			module.PlayerRemoving(Player)
		end
	end
end

for _, player in Players:GetPlayers() do
	PlayerAdded(player)
end

for _, module in LoadedModules do
	if
		type(module) == "table"
		and typeof(module) ~= "function"
		and module.Init
		and typeof(module.Init) == "function"
	then
		module.Init()
	end
end

Players.PlayerRemoving:Connect(PlayerRemoving)
Players.PlayerAdded:Connect(PlayerAdded)
