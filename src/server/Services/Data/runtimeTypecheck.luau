local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guard = require(ReplicatedStorage.Shared.t)
local TypeFunctions = require(ReplicatedStorage.Shared.TypeFunctions)
local DataTemplate = require(ReplicatedStorage.Shared.data.dataTemplate)

return function(data: TypeFunctions.DeepReadonly<typeof(DataTemplate)>): TypeFunctions.Required<typeof(DataTemplate)>
	return {
		Fish = Guard.map(
			Guard.string,
			Guard.interface({
				Weight = Guard.number,
				Mutation = Guard.string,
			})
		)(data.Fish),
		Cash = Guard.number(data.Cash),
		Bobbers = Guard.map(Guard.string, Guard.boolean)(data.Bobbers),
		Rods = Guard.map(Guard.string, Guard.boolean)(data.Rods),
	}
end
