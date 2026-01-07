local UserInputService = game:GetService("UserInputService")

local InputTypeDetector = {}

export type PlatformType = "Keyboard" | "Mobile" | "Xbox" | "Playstation"

export type InputConfig = {
	Keyboard: { Enum.KeyCode | Enum.UserInputType },
	Mobile: { Enum.KeyCode | Enum.UserInputType },
	Xbox: { Enum.KeyCode | Enum.UserInputType },
	Playstation: { Enum.KeyCode | Enum.UserInputType },
}

export type ActionCallback = (inputObject: InputObject, gameProcessed: boolean) -> ()

local currentPlatformType: PlatformType = "Keyboard"
local changeCallbacks: { (PlatformType) -> () } = {}
local registeredActions: { [string]: InputConfig } = {}
local actionCallbacks: { [string]: { ActionCallback } } = {}

local Debounces: { [string]: number } = {}

InputTypeDetector.Activated = false

local function getGamepadType(): "Xbox" | "Playstation"
	local buttonString = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA)
	return if buttonString == "ButtonA" then "Xbox" else "Playstation"
end

local function preferredInputToPlatform(preferredInput: Enum.PreferredInput): PlatformType
	if preferredInput == Enum.PreferredInput.Touch then
		return "Mobile"
	elseif preferredInput == Enum.PreferredInput.Gamepad then
		return getGamepadType()
	elseif preferredInput == Enum.PreferredInput.KeyboardAndMouse then
		return "Keyboard"
	end
	return "Keyboard"
end

local function updatePlatformType()
	local preferredInput = UserInputService.PreferredInput
	local newPlatform = preferredInputToPlatform(preferredInput)

	if newPlatform ~= currentPlatformType then
		currentPlatformType = newPlatform

		for _, callback in changeCallbacks do
			task.spawn(callback, newPlatform)
		end
	end
end

local function matchesInputConfig(inputObject: InputObject, inputs: { Enum.KeyCode | Enum.UserInputType }): boolean
	for _, input in inputs do
		if typeof(input) == "EnumItem" then
			if input.EnumType == Enum.UserInputType then
				if inputObject.UserInputType == input then
					return true
				end
			elseif input.EnumType == Enum.KeyCode then
				if inputObject.KeyCode == input then
					return true
				end
			end
		end
	end
	return false
end

local function checkActionTrigger(actionName: string, inputObject: InputObject): boolean
	local config = registeredActions[actionName]
	if not config then
		return false
	end

	local platformInputs = config[currentPlatformType]
	if not platformInputs then
		return false
	end

	return matchesInputConfig(inputObject, platformInputs)
end

function InputTypeDetector.initialize()
	if InputTypeDetector.Activated then
		return
	end

	currentPlatformType = preferredInputToPlatform(UserInputService.PreferredInput)

	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updatePlatformType)
	InputTypeDetector.Activated = true

	UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
		for actionName, callbacks in actionCallbacks do
			if checkActionTrigger(actionName, inputObject) then
				for _, callback in callbacks do
					task.spawn(callback, inputObject, gameProcessed)
				end
			end
		end
	end)
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

--[=[
	Register a named action with platform-specific input mappings
	
	@param actionName string -- Unique name for the action (e.g., "Fishing", "Attack", "Use")
	@param config InputConfig -- Input mappings for each platform
	
	Example:
	```lua
	InputTypeDetector.RegisterAction("Fishing", {
		Keyboard = { Enum.UserInputType.MouseButton1 },
		Mobile = { Enum.UserInputType.Touch },
		Xbox = { Enum.KeyCode.ButtonA },
		Playstation = { Enum.KeyCode.ButtonA },
	})
	```
]=]
function InputTypeDetector.RegisterAction(actionName: string, config: InputConfig)
	registeredActions[actionName] = config
	if not actionCallbacks[actionName] then
		actionCallbacks[actionName] = {}
	end
end

--[=[
	Subscribe to a specific named action
	
	@param actionName string -- Name of the registered action to listen for
	@param callback function -- Called with (InputObject, gameProcessed) when action input is detected
	@return function -- Unsubscribe function
	
	Example:
	```lua
	local disconnect = InputTypeDetector.OnAction("Fishing", function(input, processed)
		if processed then return end
		startFishing()
	end)
	```
]=]
function InputTypeDetector.OnAction(actionName: string, callback: ActionCallback, Debounce: number): () -> ()
	if not actionCallbacks[actionName] then
		actionCallbacks[actionName] = {}
	end

	local wrappedCallback = callback

	if Debounce and Debounce > 0 then
		local debounceKey = actionName .. tostring(callback)
		wrappedCallback = function(inputObject: InputObject, gameprocessed: boolean)
			if Debounces[debounceKey] then
				return
			end

			Debounces[debounceKey] = true
			task.delay(Debounce, function()
				Debounces[debounceKey] = nil
			end)

			callback(inputObject, gameprocessed)
		end
	end
	table.insert(actionCallbacks[actionName], wrappedCallback)
	return function()
		local callbacks = actionCallbacks[actionName]
		if callbacks then
			local index = table.find(callbacks, wrappedCallback)
			if index then
				table.remove(callbacks, index)
			end
		end
	end
end

--[=[
	Unregister an action and remove all its callbacks
	
	@param actionName string -- Name of the action to unregister
]=]
function InputTypeDetector.UnregisterAction(actionName: string)
	registeredActions[actionName] = nil
	actionCallbacks[actionName] = nil
end

--[=[
	Get the input configuration for a specific action and platform
	
	@param actionName string -- Name of the registered action
	@param platform PlatformType? -- Platform to get inputs for (defaults to current)
	@return { Enum.KeyCode | Enum.UserInputType }? -- Array of inputs for the platform
]=]
function InputTypeDetector.GetActionInputs(
	actionName: string,
	platform: PlatformType?
): { Enum.KeyCode | Enum.UserInputType }?
	local config = registeredActions[actionName]
	if not config then
		return nil
	end

	return config[platform or currentPlatformType]
end

return InputTypeDetector
