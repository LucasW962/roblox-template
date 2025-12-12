local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guard = require(ReplicatedStorage.Packages.Guard)
local TypeFunctions = require(ReplicatedStorage.Shared.TypeFunctions)
local DataTemplate = require(ReplicatedStorage.Shared.data.dataTemplate)

return function(data: TypeFunctions.DeepReadonly<typeof(DataTemplate)>): TypeFunctions.Required<typeof(DataTemplate)>
	return {
		Level = Guard.Number(data.Level),
	}
end
