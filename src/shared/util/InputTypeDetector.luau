local UserInputService = game:GetService("UserInputService")

local InputTypeDetector = {}

export type PlatformType = "Keyboard" | "Mobile" | "Xbox" | "Playstation"

local currentPlatformType: PlatformType = "Keyboard"
local changeCallbacks: { (PlatformType) -> () } = {}

local function getCategoryOfInputType(inputType: Enum.UserInputType): PlatformType | "Unknown"
	local inputTypeString = tostring(inputType)

	if string.find(inputTypeString, "Gamepad") then
		local buttonString = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA)
		return if buttonString == "ButtonA" then "Xbox" else "Playstation"
	end

	if inputType == Enum.UserInputType.Keyboard or string.find(inputTypeString, "Mouse") then
		return "Keyboard"
	end

	if inputType == Enum.UserInputType.Touch then
		return "Mobile"
	end

	return "Unknown"
end

local function getDefaultPlatformType(): PlatformType
	local lastInput = UserInputService:GetLastInputType()
	local category = getCategoryOfInputType(lastInput)

	if category ~= "Unknown" then
		return category
	end

	if UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
		return "Keyboard"
	elseif UserInputService.TouchEnabled then
		return "Mobile"
	elseif UserInputService.GamepadEnabled then
		local buttonString = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA)
		return if buttonString == "ButtonA" then "Xbox" else "Playstation"
	else
		return "Keyboard"
	end
end

local function updateInputType(inputType: Enum.UserInputType)
	local newPlatform = getCategoryOfInputType(inputType)

	if newPlatform ~= "Unknown" and newPlatform ~= currentPlatformType then
		currentPlatformType = newPlatform

		for _, callback in changeCallbacks do
			task.spawn(callback, newPlatform)
		end
	end
end

local function initialize()
	currentPlatformType = getDefaultPlatformType()

	UserInputService.LastInputTypeChanged:Connect(updateInputType)
end

--[=[
	Gets the current platform type
	@return PlatformType -- "Keyboard", "Mobile", "Xbox", or "Playstation"
]=]
function InputTypeDetector.GetCurrentPlatform(): PlatformType
	return currentPlatformType
end

--[=[
	Subscribe to platform type changes
	@param callback function -- Called with the new PlatformType when it changes
	@return function -- Unsubscribe function
]=]
function InputTypeDetector.OnPlatformChanged(callback: (PlatformType) -> ()): () -> ()
	table.insert(changeCallbacks, callback)

	-- Return unsubscribe function
	return function()
		local index = table.find(changeCallbacks, callback)
		if index then
			table.remove(changeCallbacks, index)
		end
	end
end

--[=[
	Checks if the current platform is a specific type
	@param platformType PlatformType
	@return boolean
]=]
function InputTypeDetector.IsPlatform(platformType: PlatformType): boolean
	return currentPlatformType == platformType
end

--[=[
	Checks if the current platform uses a gamepad (Xbox or Playstation)
	@return boolean
]=]
function InputTypeDetector.IsGamepad(): boolean
	return currentPlatformType == "Xbox" or currentPlatformType == "Playstation"
end

--[=[
	Manually update the platform type (for testing or special cases)
	@param platformType PlatformType
]=]
function InputTypeDetector.SetPlatform(platformType: PlatformType)
	if platformType ~= currentPlatformType then
		currentPlatformType = platformType

		for _, callback in changeCallbacks do
			task.spawn(callback, platformType)
		end
	end
end

initialize()

return InputTypeDetector
