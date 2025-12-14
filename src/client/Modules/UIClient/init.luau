--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local StateMachine = require(ReplicatedStorage.Shared.StateMachine)

local module = {}

local LoadedModules = {} :: { [string]: any }
local componentRoots = {} :: { [string]: any }
local activeComponents = {} :: { [string]: boolean }
local lastComponentStates = {} :: { [string]: boolean }
local cleanupFunctions = {} :: { [string]: () -> () }

local closeHUD = {
	-- Shop = true,  -- Removed so HUD stays visible when in Shop
} :: { [string]: boolean }

local defaultVisible = {
	HUD = false,
	RodShop = false,
} :: { [string]: boolean }

local persistentComponents = {
	HUD = true,
} :: { [string]: boolean }

local UiState = StateMachine.new("UIState", "Global", "Idle") :: StateMachine.State<StateMachine.UIState>

local function loadModules()
	for _, child in script:QueryDescendants("ModuleScript") do
		if child.Name:lower():find("server") then
			continue
		end

		local success, result = pcall(require, child)
		if success then
			LoadedModules[child.Name] = result
		end
	end
end

function module.getSharedProps()
	local statesCopy = {}
	for key, value in activeComponents do
		statesCopy[key] = value
	end

	return {
		states = statesCopy,
		closeComponent = module.closeComponent,
		openComponent = module.openComponent,
		toggleComponent = module.toggleComponent,
	}
end

function module.updateAllComponents()
	for name, root in componentRoots do
		if not LoadedModules[name] then
			continue
		end

		local props = module.getSharedProps()
		local success, interface = pcall(React.createElement, LoadedModules[name], props :: any)

		if success then
			local renderSuccess, renderError = pcall(root.render, root, interface)
			if renderSuccess then
				print(`✓ Updated component {name}`)
			else
				warn(`✗ Failed to render {name}: {renderError}`)
			end
		else
			warn(`✗ Failed to create element for {name}: {interface}`)
		end
	end
end

function module.createComponent<U>(name: string, moduleFunction: U): (() -> ())?
	if type(moduleFunction) ~= "function" then
		warn(`Module {name} is not a function, skipping. Type: {type(moduleFunction)}`)
		return nil
	end

	local props = module.getSharedProps()
	local success, interface = pcall(React.createElement, moduleFunction, props :: any)
	if not success then
		warn(`Failed to create React element for {name}: {interface}`)
		return nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.IgnoreGuiInset = true
	screenGui.Name = name
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 0
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false

	local player = Players.LocalPlayer
	if not player then
		warn(`LocalPlayer not found when creating {name}`)
		return nil
	end

	local playerGui = player:WaitForChild("PlayerGui", 5)
	if not playerGui then
		warn(`PlayerGui not found when creating {name}`)
		return nil
	end

	screenGui.Parent = playerGui

	local root = ReactRoblox.createRoot(screenGui)
	local renderSuccess, renderError = pcall(root.render, root, interface)
	if not renderSuccess then
		warn(`Failed to render {name}: {renderError}`)
		screenGui:Destroy()
		return nil
	end

	componentRoots[name] = root

	return function()
		componentRoots[name] = nil
		activeComponents[name] = nil
		lastComponentStates[name] = nil

		local unmountSuccess, unmountError = pcall(root.unmount, root)
		if not unmountSuccess then
			warn(`Failed to unmount {name}: {unmountError}`)
		end

		if screenGui and screenGui.Parent then
			screenGui:Destroy()
		end
	end
end

function module.handleStateChange(newState: string, oldState: string)
	if newState == oldState then
		return
	end

	print(`UI State: {oldState} → {newState}`)

	if oldState and oldState ~= "Idle" and not persistentComponents[oldState] then
		activeComponents[oldState] = false
	end

	if newState ~= "Idle" and not persistentComponents[newState] then
		activeComponents[newState] = true
	end

	if closeHUD[newState] then
		activeComponents.HUD = false
	else
		activeComponents.HUD = true
	end

	module.updateAllComponents()
end

function module.openComponent(name: string)
	if activeComponents[name] == true then
		return
	end
	activeComponents[name] = true
	module.updateAllComponents()
end

function module.closeComponent(name: string)
	if activeComponents[name] == false then
		return
	end
	activeComponents[name] = false
	module.updateAllComponents()
end

function module.toggleComponent(name: string)
	activeComponents[name] = not activeComponents[name]
	module.updateAllComponents()
end

function module.isComponentActive(name: string): boolean
	return activeComponents[name] == true
end

function module.cleanup()
	for name, cleanup in cleanupFunctions do
		if type(cleanup) == "function" then
			local success, err = pcall(cleanup)
			if not success then
				warn(`Failed to cleanup {name}: {err}`)
			end
		end
	end

	cleanupFunctions = {}
	componentRoots = {}
	activeComponents = {}
	lastComponentStates = {}
end

module.Init = function()
	if not RunService:IsClient() then
		warn("UI Loader can only run on client")
		return
	end

	local player = Players.LocalPlayer
	if not player then
		warn("LocalPlayer not found")
		return
	end

	local playerGui = player:WaitForChild("PlayerGui", 10)
	if not playerGui then
		warn("PlayerGui not found")
		return
	end

	loadModules()

	for name, visible in defaultVisible do
		activeComponents[name] = visible
		lastComponentStates[name] = visible
	end

	for name, moduleFunction in LoadedModules do
		print(`Creating component: {name}`)

		local cleanup = module.createComponent(name, moduleFunction)
		if cleanup then
			cleanupFunctions[name] = cleanup
		end
	end

	UiState.Changed:Connect(function(newstate, oldstate, ...)
		module.handleStateChange(newstate, oldstate)
	end)
	task.delay(1.5, function()
		activeComponents.HUD = true
		module.updateAllComponents()
	end)
end

module.Init()

task.delay(15, function()
	UiState:ChangeState("RodShop")
end)

return module
