local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NormalTypes = require(ReplicatedStorage.Shared.Types.NormalTypes)
local React = require(ReplicatedStorage.Packages.React)

return function(
	style: NormalTypes.SpringStyle,
	SpringCallback: NormalTypes.SpringCallback,
	activatedCallback: () -> ()?,
	CustomProps: NormalTypes.SpringStyleFull?
)
	return {
		[React.Event.MouseEnter] = function()
			SpringCallback.start({ scale = CustomProps and CustomProps.scaleEnter or 1.05 })
		end,
		[React.Event.MouseLeave] = function()
			SpringCallback.start({ scale = 1 })
		end,
		[React.Event.MouseButton1Down] = function()
			SpringCallback.start({ scale = CustomProps and CustomProps.scaleDown or 0.95 })
		end,
		[React.Event.MouseButton1Up] = function()
			SpringCallback.start({ scale = CustomProps and CustomProps.scaleUp or 1.05 })
		end,
		[React.Event.Activated] = function()
			if activatedCallback then
				activatedCallback()
			end
		end,
	}
end
