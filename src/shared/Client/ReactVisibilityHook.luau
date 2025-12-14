local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)

return function(isEnabled: boolean, closeDelay: number?)
	closeDelay = closeDelay or 1.5

	local isOpen, setOpen = React.useState(isEnabled)
	local isVisible, setVisible = React.useState(isEnabled)

	local style, api = ReactSpring.useSpring(function()
		return {
			transparency = 1,
			bgTransparency = 1,
			bg2Transparency = 1,
			scale = 0.7,
			position = UDim2.fromScale(0.5, 0.7),

			config = {
				tension = 500,
				clamp = true,
			},
		}
	end)

	React.useEffect(function()
		if isEnabled then
			setOpen(true)
			setVisible(true)

			api.start({ transparency = 0, bgTransparency = 0.63, bg2Transparency = 0.8 })
			api.start({
				scale = 1,
				position = UDim2.fromScale(0.5, 0.5),
				config = {
					tension = 1400,
					friction = 52,
				},
			})

			return
		end

		setOpen(false)
		api.start({
			transparency = 1,
			bgTransparency = 1,
			bg2Transparency = 1,
			scale = 0.7,
			position = UDim2.fromScale(0.5, 0.7),
		})

		local delayedTask = task.delay(closeDelay, function()
			setVisible(false)
		end)

		return function()
			task.cancel(delayedTask)
		end
	end, { isEnabled })

	return {
		isOpen = isOpen,
		isVisible = isVisible,
		style = style or {
			position = UDim2.fromScale(0.5, 0.7),
		},
	}
end
