local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReactSpring = require(game:GetService("ReplicatedStorage").Packages.ReactSpring)
--local React = require(game:GetService("ReplicatedStorage").Packages.React)
local TypeFunctions = require(ReplicatedStorage.Shared.TypeFunctions)
local VisibilityHook = require(ReplicatedStorage.Shared.Client.ReactVisibilityHook)

export type AnimationStyle<T> = {
	value: T,
	map: (self: AnimationStyle<T>, fn: (T) -> T) -> AnimationStyle<T>,
	getValue: (self: AnimationStyle<T>) -> T,
}

export type BaseAnimations = {
	transparency: AnimationStyle<number>,
	bgTransparency: AnimationStyle<number>,
	bg2Transparency: AnimationStyle<number>?,
	bg3Transparency: AnimationStyle<number>?,
	scale: AnimationStyle<number>,
	position: AnimationStyle<number>,
}

export type BaseOpenState = {
	value: boolean,
	set: ((boolean) -> ())?,
}

export type EventCallback = (any) -> ()

export type BaseEvents = {
	[any]: EventCallback,
}

export type BaseStates = {
	open: BaseOpenState,
}

export type BaseProps = {
	animations: BaseAnimations,
	states: BaseStates,
}

export type SpringStyle = TypeFunctions.Partial<{
	transparency: AnimationStyle<number>,
	bgTransparency: AnimationStyle<number>,
	bg2Transparency: AnimationStyle<number>,
	bg3Transparency: AnimationStyle<number>,
	scale: AnimationStyle<number>,
	position: AnimationStyle<number>,
}>

export type SpringStyleFull = SpringStyle & {
	scaleEnter: number,
	scaleDown: number,
	scaleUp: number,
}

export type VisbilityHook = typeof(VisibilityHook(true, 1.5))

export type SpringCallback = {
	start: (style: { SpringStyle }) -> (),
	stop: () -> (),
	pause: (keys: { string }) -> (),
}

return {}
