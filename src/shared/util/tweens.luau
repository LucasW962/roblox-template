--!native
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local formatNumber = require(ReplicatedStorage.Shared.util.formats).numberFormat

@native
local function useNumberTween(
	target: number,
	speed: number,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	formatType: ("Comma" | "Short")?,
	decimalPlaces: number?
): string
	local animated, setAnimated = React.useState(target)
	local currentTweenRef = React.useRef(nil :: Tween?)
	local numberValueRef = React.useRef(nil :: NumberValue?)

	React.useEffect(function()
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = animated
		numberValueRef.current = numberValue

		local connection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			local val = numberValue.Value
			local goal = target

			if math.abs(val - goal) < 0.01 then
				setAnimated(goal)
			else
				setAnimated(val)
			end
		end)

		return function()
			connection:Disconnect()
			if numberValueRef.current then
				numberValueRef.current:Destroy()
			end
		end
	end, {})

	React.useEffect(function()
		local currentTween = currentTweenRef.current
		if currentTween then
			currentTween:Cancel()
		end

		local numberValue = numberValueRef.current
		if not numberValue then
			return
		end

		numberValue.Value = animated

		local tweenInfo = TweenInfo.new(
			speed / 50,
			easingStyle or Enum.EasingStyle.Linear,
			easingDirection or Enum.EasingDirection.Out
		)

		currentTween = TweenService:Create(numberValue, tweenInfo, {
			Value = target,
		})
		currentTween:Play()
		currentTweenRef.current = currentTween

		return function()
			if currentTweenRef.current then
				currentTweenRef.current:Cancel()
			end
		end
	end, { target, speed, easingStyle, easingDirection })

	if formatType then
		return formatNumber(animated, formatType, decimalPlaces)
	end

	return tostring(animated)
end

return {
	useNumberTween = useNumberTween,
}
