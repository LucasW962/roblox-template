--!native

--[[
	Framework fully made by yoda962
	Distibuted with MIT Liscense

]]

local DataService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DocumentService = require(ServerStorage.ServerPackages.DocumentService)
local TypeFunctions = require(ReplicatedStorage.Shared.TypeFunctions)
local DataTemplate = require(ReplicatedStorage.Shared.data.dataTemplate)
local Sift = require(ReplicatedStorage.Packages.Sift)
local RuntimeTypecheck = require(script.runtimeTypecheck)
local Promise = require(ReplicatedStorage.Packages.Promise)
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local ServerNetwork = require(ReplicatedStorage.Shared.Network.server)

local DocuementStore = DocumentService.DocumentStore

export type DocumentCacheInterface = TypeFunctions.Required<typeof(RuntimeTypecheck(DataTemplate))>

export type PlayerDocument = typeof(DocuementStore.new():GetDocument())

local CachedDocuments = {} :: { [Player]: typeof(DocumentService.Document.new()) }
local DocumentCaches = {} :: { [Player]: DocumentCacheInterface }

local REMOVE_SENT = "__REMOVE__" -- blink wont send nil over network, using a sentinel

local function ReconcileAndCheck(data: TypeFunctions.Partial<typeof(DataTemplate)>): DocumentCacheInterface
	local Reconciled = Sift.Dictionary.mergeDeep(DataTemplate, data)

	return RuntimeTypecheck(Reconciled)
end

local DataStore = DocuementStore.new({
	dataStore = DataStoreService:GetDataStore("yoda962"),
	check = ReconcileAndCheck,
	default = DataTemplate,
	lockSessions = true,
})

local function completeMerge(document: typeof(DocuementStore.new():GetDocument())): DocumentCacheInterface
	local CurrentCache = document:GetCache()

	local Merged = Sift.Dictionary.mergeDeep(DataTemplate, CurrentCache)

	if not Sift.Dictionary.equals(CurrentCache, Merged) then
		document:SetCache(Merged)
		return Merged
	end

	return CurrentCache
end

local function GetChangedPaths(
	oldData: DocumentCacheInterface,
	newData: TypeFunctions.Partial<DocumentCacheInterface>,
	basePath: string?
): ({ [string]: any }, boolean)
	basePath = basePath or ""
	local changes = {}
	local hasChanges = false

	local allKeys = {}

	for key, _ in newData do
		allKeys[key] = true
	end

	for key, _ in oldData do
		allKeys[key] = true
	end

	for key, _ in allKeys do
		local currentPath = basePath == "" and key or basePath .. "/" .. key
		local oldValue = oldData[key]
		local newValue = newData[key]

		if oldValue ~= nil and newValue == nil then
			changes[currentPath] = REMOVE_SENT
			hasChanges = true
		elseif oldValue == nil and newValue ~= nil then
			changes[currentPath] = newValue
			hasChanges = true
		elseif oldValue ~= nil and newValue ~= nil then
			if type(newValue) == "table" and type(oldValue) == "table" then
				local nestChanges, nestedHasChanges = GetChangedPaths(oldValue, newValue, currentPath)
				if not nestedHasChanges then
					return
				end
				hasChanges = true
				for path, value in nestChanges do
					changes[path] = value
				end
			elseif not Sift.Dictionary.equals(oldValue, newValue) then
				changes[currentPath] = newValue
				hasChanges = true
			end
		end
	end
	return changes, hasChanges
end

function DataService.Write(player: Player, properties: TypeFunctions.Partial<typeof(DataTemplate)>)
	local document = DataStore.GetDocument(DataStore, tostring(player.UserId))
	local dataCache = document.GetCache(document)
	local newCache = Sift.Dictionary.copyDeep(dataCache)

	for path, value in properties do
		local pathArray = string.split(path :: keyof<typeof(DataTemplate)>, "/") -- fixes type issue
		local current = newCache
		for i = 1, #pathArray - 1 do
			current = current[tonumber(pathArray[i]) or pathArray[i]]
		end

		local goal = tonumber(pathArray[#pathArray]) or pathArray[#pathArray]

		if value == nil then
			current[goal] = nil
		else
			current[goal] = value
		end
	end

	local oldPlayerData = DocumentCaches[player] or {}

	local changes, hasChanges = GetChangedPaths(oldPlayerData, newCache)

	print(changes, hasChanges)

	if hasChanges then
		ServerNetwork.Controller.Replicate.Fire(player, {
			dataName = "DataDelta",
			dataValue = changes,
		})

		DocumentCaches[player] = Sift.Dictionary.copyDeep(newCache)
	end

	document:SetCache(newCache)
	print(`final cache for {player.Name} is {newCache}`)
end

function DataService.PlayerInit(Player: Player)
	local result, docuement = DataService.GetData(Player):catch(warn):await()

	if not result then
		warn("Failed to load data for", Player.Name)
	end

	local finalCache = completeMerge(docuement)

	CachedDocuments[Player] = finalCache
	DocumentCaches[Player] = Sift.Dictionary.copyDeep(finalCache)

	docuement.GetClosedSignal(docuement):Once(function()
		CachedDocuments[Player] = nil
	end)

	local AncestryConn: RBXScriptConnection? = nil

	AncestryConn = Player.AncestryChanged:Connect(function()
		if Player.Parent == Players then
			return
		end

		if AncestryConn then
			AncestryConn:Disconnect()
		end

		docuement.Close(docuement)
	end)

	ServerNetwork.Controller.Replicate.Fire(Player, {
		dataName = "Data",
		dataValue = finalCache,
	})
end

function DataService.GetData(Player: Player): typeof(Promise.new(
	function(resolve: (boolean) -> ...unknown, reject: (string) -> ...unknown, onCancel: unknown) end
))
	return Promise.new(function(resolve, reject, onCancel)
		local document = DataStore:GetDocument(tostring(Player.UserId)) :: typeof(DataStore.GetDocument(DataStore))
		local data = document:Open()

		if not data.success and data.reason == "SessionLockError" then
			document:Steal()
			data = document:Open()
		end

		if not data.success then
			if data.reason == "BackwardsCompatabilityError" then
				Player:Kick("Error getting document, please rejoin.")
			end
			if data.reason == "RobloxAPIError" then
				Player:Kick("Failed to load data, Internal roblox issue, rejoin.")
			end
			Player:Kick(`Failed to loaded data: {data.reason}`)
			resolve(nil)
		end

		print(`Loaded Data For {Player.Name}`, document.GetCache(document))
		resolve(document)
	end)
end

function DataService.Read(Player: Player): DocumentCacheInterface
	local document = DataStore.GetDocument(DataStore, tostring(Player.UserId))
	if not document.IsOpen(document) then
		repeat
			task.wait()
		until document.IsOpen(document)
	end
	return document.GetCache(document)
end

function DataService.Save(player: Player): ()
	local document = DataStore.GetDocument(DataStore, tostring(player.UserId))
	document.Save(document)
end

return DataService
