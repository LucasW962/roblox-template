local ReplicatedStorage = game:GetService("ReplicatedStorage")
<<<<<<< HEAD
local Guard = require(ReplicatedStorage.Shared.t)
=======
local Guard = require(ReplicatedStorage.Packages.Guard)
>>>>>>> e711346ee46bc1967ab87eca5c6d3e23e75dc2d4
local TypeFunctions = require(ReplicatedStorage.Shared.TypeFunctions)
local DataTemplate = require(ReplicatedStorage.Shared.data.dataTemplate)

return function(data: TypeFunctions.DeepReadonly<typeof(DataTemplate)>): TypeFunctions.Required<typeof(DataTemplate)>
	return {
<<<<<<< HEAD
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
=======
		Level = Guard.Number(data.Level),
>>>>>>> e711346ee46bc1967ab87eca5c6d3e23e75dc2d4
	}
end
