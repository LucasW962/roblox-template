local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)

type SpringConfig = {
	tension: number?,
	friction: number?,
	clamp: boolean?,
	precision: number?,
	velocity: number?,
}

type StyleParams = {
	transparency: number?,
	bgTransparency: number?,
	bg2Transparency: number?,
	scale: number?,
	position: UDim2?,
}

return function(
	initialStyle: StyleParams?,
	springConfig: SpringConfig?
): (StyleParams & { config: SpringConfig }, ReactSpring.ControllerApi)
	local style, api = ReactSpring.useSpring(function()
		return {
			transparency = if initialStyle and initialStyle.transparency then initialStyle.transparency else 1,
			bgTransparency = if initialStyle and initialStyle.bgTransparency then initialStyle.bgTransparency else 1,
			bg2Transparency = if initialStyle and initialStyle.bg2Transparency then initialStyle.bg2Transparency else 1,
			scale = if initialStyle and initialStyle.scale then initialStyle.scale else 0.7,
			position = if initialStyle and initialStyle.position
				then initialStyle.position
				else UDim2.fromScale(0.5, 0.7),

			config = {
				tension = if springConfig and springConfig.tension then springConfig.tension else 500,
				friction = if springConfig then springConfig.friction else nil,
				clamp = if springConfig and springConfig.clamp ~= nil then springConfig.clamp else true,
				precision = if springConfig then springConfig.precision else nil,
				velocity = if springConfig then springConfig.velocity else nil,
			},
		}
	end)

	return style, api
end
