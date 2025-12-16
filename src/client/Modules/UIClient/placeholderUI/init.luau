local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local ReactVisibilityHook = require(ReplicatedStorage.Shared.Client.ReactVisibilityHook)
local ezStyle = require(ReplicatedStorage.Shared.Client.ezStyle)
local springSetup = require(ReplicatedStorage.Shared.Client.springSetup)

return function(props)
	local secondProps = ReactVisibilityHook(props.states.HUD, 1.5) --// pretend this is a HUD element that takes 1.5 seconds to open

	local style, api = ezStyle({ scale = 1 }, { friction = 28 })

	return React.createElement("Frame", {
		Size = UDim2.fromScale(0.1, 0.1),
		BackgroundTransparency = 1,
		Visible = secondProps.IsVisible,
	}, {
		UIButton = React.createElement(
			"TextButton",
			Sift.Dictionary.mergeDeep(
				{
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0, 0),
					Text = "Hello",
				},
				springSetup(style, api, function()
					print("Clicked")
				end)
			),
			{
				UIScale = React.createElement("UIScale", {
					Scale = style.scale,
				}),
			}
		),
	})
end
