local Client = {}

Client.LoadedModules = {} :: { [string]: { [string]: any } }

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Client.atoms)

local Plr = Players.LocalPlayer

for _, child in script.Modules:QueryDescendants("ModuleScript") do
	Client.LoadedModules[child.Name] = require(child)
end

local function CharacterAddedFunctions(Char: Model)
	for _, Module in Client.LoadedModules do
		if Module.CharacterAdded and type(Module.CharacterAdded) == "function" then
			Module.CharacterAdded(Char)
		end
	end
end

local function PlayerRemovingFunctions(Player: Player)
	if Plr ~= Player then
		return
	end
	for _, Module in Client.LoadedModules do
		if Module.PlayerRemoving and type(Module.PlayerRemoving) == "function" then
			Module.PlayerRemoving(Player)
		end
	end
end

print(Client.LoadedModules)

Plr.CharacterAdded:Connect(CharacterAddedFunctions)
Plr.CharacterRemoving:Connect(CharacterAddedFunctions)
Players.PlayerRemoving:Connect(PlayerRemovingFunctions)
