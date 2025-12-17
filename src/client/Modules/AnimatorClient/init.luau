local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets :: Folder
local Animations = Assets.Animations :: Folder
local AnimatorUtil = require(ReplicatedStorage.Shared.util.AnimatorUtil)
local module = {}

function module.CharacterAdded(character: Model)
	local Humanoid = character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then
		return
	end

	local Animator = Humanoid:FindFirstChildOfClass("Animator")

	if not Animator then
		return
	end
	print("Preload")
	AnimatorUtil.preload(Animator, Animations:QueryDescendants(">Animation"))
end

return module
