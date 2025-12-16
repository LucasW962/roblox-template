--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local UIState = require(script.Enums.UIState)
local StateNames = require(script.StateNames)
local TypeFunctions = require(ReplicatedStorage.Shared.TypeFunctions)

export type StateTransitionEvent<T> = {
	from: T,
	to: T,
	timestamp: number,
	metadata: {[string]: any}?
}

export type StateValidator<T> = (currentState: T, newState: T) -> boolean

export type StateCallback<T> = (state: T, context: StateContext<T>) -> ()

export type StateContext<T> = {
	currentState: T,
	previousState: T,
	transitionHistory: {StateTransitionEvent<T>},
	metadata: {[string]: any}
}

export type StateModule<T> = {
	new: (stateMachine: State<T>, context: StateContext<T>) -> StateModuleInstance<T>,
}

export type StateModuleInstance<T> = {
	RequirementCheck: ((context: StateContext<T>) -> boolean)?,
	EnterCallback: ((state: T, context: StateContext<T>) -> ())?,
	LeaveCallback: ((state: T, context: StateContext<T>) -> ())?,
	ValidationRules: {StateValidator<T>}?,
	Priority: number?,
}

export type StateTransitionResult<T> = {
	success: boolean,
	from: T,
	to: T,
	error: string?,
	executionTime: number
}

export type State<T> = {
	Destroy: () -> (),
	Changed: Signal.Signal<...any>,
	GetCurrentState: (self: State<T>) -> T,
	GetLastState: (self: State<T>) -> T,
	GetContext: (self: State<T>) -> StateContext<T>,
	GetTransitionHistory: (self: State<T>) -> {StateTransitionEvent<T>},
	ChangeLastState: (self: State<T>) -> StateTransitionResult<T>,
	ChangeState: (self: State<T>, newState: T, metadata: {[string]: any}?) -> StateTransitionResult<T>,
	ValidateTransition: (self: State<T>, newState: T) -> boolean,
	AddValidator: (self: State<T>, validator: StateValidator<T>) -> (),
	RemoveValidator: (self: State<T>, validator: StateValidator<T>) -> (),
	ValidateState: (self: State<T>, validator: StateValidator<T>) -> boolean,
	GetStateContext: (self: State<T>) -> StateContext<T>?,
	UpdateMetadata: (self: State<T>, key: string, value: any) -> (),
}






export type StateName = TypeFunctions.DeepReadonly<keyof<typeof(StateNames)>>
export type UIState = TypeFunctions.DeepReadonly<keyof<typeof(UIState)>>




export type StringLike = string | number | boolean


export type StateMachineConstructor = {
    new: <T>(stateName: StateName, stateType: ("Global" | "Self")?, initialState: T?) -> State<T>
}




export type StateConfiguration<T> = {
	initialState: T,
	maxHistorySize: number?,
	enableMetrics: boolean?,
	validators: {StateValidator<T>}?,
	globalCallbacks: {
		onTransition: StateCallback<T>?,
		onError: ((error: string, context: StateContext<T>) -> ())?,
	}?
}

export type ValidStateKeys<T> = keyof<T> 





export type StateMachine = {
	new: <T>(
		stateName: StateName, 
		config: StateConfiguration<T>?, 
		stateType: ("Global" | "Self")?, 
		...any
	) -> State<T>,
	createValidator: <T>(predicate: (T, T) -> boolean) -> StateValidator<T>,
	createStateModule: <T>(
		enterFn: StateCallback<T>?, 
		leaveFn: StateCallback<T>?, 
		requirementFn: ((StateContext<T>) -> boolean)?
	) -> StateModule<T>,
}


local stateCaches: {[StateName]: State<any>} = {}
local stateEnums: {[string]: {[string]: {string}}} = {}

local function initializeStateEnums()
	local statesEnumsFolder = script:WaitForChild("Enums")
	for _, moduleScript : ModuleScript in statesEnumsFolder:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			stateEnums[moduleScript.Name] = require(moduleScript) :: any
		end
	end
end

local MAX_HISTORY_SIZE = 5

local function createDefaultContext<T>(initialState: T): StateContext<T>
	return {
		currentState = initialState,
		previousState = initialState,
		transitionHistory = {},
		metadata = {}
	}
end

local function loadStateModules<T>(stateName: StateName, self: State<T>, context: StateContext<T>): {[string]: StateModuleInstance<T>}
	local stateModules: {[string]: StateModuleInstance<T>} = {}
	local stateFolder = script:FindFirstChild(stateName)
	
	if not stateFolder then
		return stateModules
	end
	
	for _, moduleScript in stateFolder:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			local module = require(moduleScript) :: StateModule<T>
			stateModules[moduleScript.Name] = module.new(self, context)
		end
	end
	
	return stateModules
end


local function isTransitionAllowed(stateName: StateName, currentState: string, newState: string): boolean
	local stateEnum = stateEnums[stateName]
	if not stateEnum then
		warn(`State enum not found for '{stateName}'`)
		return false
	end
	
	local allowedTransitions = stateEnum[currentState]
	if not allowedTransitions then
		warn(`No transitions defined for state '{currentState}' in '{stateName}'`)
		return false
	end
	
	return table.find(allowedTransitions, newState) ~= nil or table.find(allowedTransitions, "Any") ~= nil
end


export type StateModuleCallbackNames = "EnterCallback" | "LeaveCallback" | "RequirementCheck"

local function executeCallback<T>(stateModule: StateModuleInstance<T>?, callbackName: StateModuleCallbackNames)
    if not stateModule then
        return
    end
    
    local callback = (stateModule :: any)[callbackName] :: (any) -> ()?
    if callback and typeof(callback) == "function" then
        callback(stateModule) 
    end
end
local function checkRequirements<T>(stateModule: StateModuleInstance<T>?, context: StateContext<T>): boolean
    if not stateModule then
        return true
    end
    
    if typeof(stateModule.RequirementCheck) == "function" then
        return stateModule.RequirementCheck(context)
    end
    
    return true
end
local StateMachine = {}
StateMachine.__index = StateMachine



function StateMachine.new<T>(stateName: StateName, stateType: ("Global" | "Self")?, initialState: T?): State<T>
	if (not stateType or stateType == "Global") and stateCaches[stateName] then
		return stateCaches[stateName] :: any
	end

	local defaultState = initialState or ("Idle" :: any)
	local context = createDefaultContext(defaultState)
	
	local self = setmetatable({
		state = defaultState,
		oldState = defaultState,
		stateModules = {} :: {[string]: StateModuleInstance<T>},
		stateName = stateName,
		Changed = Signal.new(),
		context = context,
	}, StateMachine)

	self.stateModules = loadStateModules(stateName, self :: any, context)

	if not stateType or stateType == "Global" then
		stateCaches[stateName] = self :: State<T>
	end

	return self :: State<T>
end

function StateMachine:GetCurrentState<T>(): T
	return self.state
end

function StateMachine:GetLastState<T>(): T
	return self.oldState
end

function StateMachine:ChangeLastState<T>(): StateTransitionResult<T>
	return self:ChangeState(self.oldState)
end

local function toStringKey<T>(value: T): string
	return tostring(value)
end

function StateMachine:ChangeState<T>(newState: T, metadata: {[string]: any}?): StateTransitionResult<T>
	local startTime = tick()
	
	if toStringKey(newState) == toStringKey(self.state) then
		return {
			success = true,
			from = self.state,
			to = newState,
			executionTime = tick() - startTime
		}
	end


	if not isTransitionAllowed(self.stateName, toStringKey(self.state), toStringKey(newState)) then
		local errorMsg = `Cannot transition from '{self.state}' to '{newState}' in '{self.stateName}'`
		warn(errorMsg)
		return {
			success = false,
			from = self.state,
			to = newState,
			error = errorMsg,
			executionTime = tick() - startTime
		}
	end

	local newStateModule = self.stateModules[toStringKey(newState)]
	local currentStateModule = self.stateModules[toStringKey(self.state)]

    if not checkRequirements(newStateModule, self.context) then
        local errorMsg = `Requirement check failed for transition from '{self.state}' to '{newState}'`
		warn(errorMsg)
		return {
			success = false,
			from = self.state,
			to = newState,
			error = errorMsg,
			executionTime = tick() - startTime
		}
    end

    if self.context then
		table.insert(self.context.transitionHistory, {
			from = self.state,
			to = newState,
			timestamp = os.clock(),
			metadata = metadata
		})
		
		while #self.context.transitionHistory > MAX_HISTORY_SIZE do
			table.remove(self.context.transitionHistory, 1)
		end
		
		self.context.previousState = self.context.currentState
		self.context.currentState = newState
		
		if metadata then
			for key, value in metadata do
				self.context.metadata[key] = value
			end
		end
	end

	executeCallback(currentStateModule, "LeaveCallback")
	executeCallback(newStateModule, "EnterCallback")

	self.oldState = self.state
	self.state = newState
	
	self.Changed:Fire(self.state, self.oldState)
	
	return {
		success = true,
		from = self.oldState,
		to = newState,
		executionTime = tick() - startTime
	}
end

function StateMachine:ValidateState<T>(validator: StateValidator<T>): boolean
	if not self.context then
		return false
	end
	return validator(self.context.currentState, self.context.currentState)
end

function StateMachine:GetStateContext<T>(): StateContext<T>?
	return self.context
end

function StateMachine:GetContext<T>(): StateContext<T>
	return self.context
end

function StateMachine:GetTransitionHistory<T>(): {StateTransitionEvent<T>}
	if self.context then
		return self.context.transitionHistory :: {StateTransitionEvent<T>}
	end
	return {}
end

function StateMachine:ValidateTransition<T>(newState: T): boolean
	return isTransitionAllowed(self.stateName, toStringKey(self.state), toStringKey(newState))
end

function StateMachine:AddValidator<T>(validator: StateValidator<T>)
	--// TODO
end

function StateMachine:RemoveValidator<T>(validator: StateValidator<T>)
	--// TODO
end

function StateMachine:UpdateMetadata<T>(key: string, value: T)
	if self.context then
		self.context.metadata[key] = value
	end
end

function StateMachine:Destroy()
	self.Changed:Destroy()
	table.clear(self.stateModules)
	if self.context then
		table.clear(self.context.transitionHistory)
		table.clear(self.context.metadata)
	end
end

initializeStateEnums()

return StateMachine :: StateMachineConstructor