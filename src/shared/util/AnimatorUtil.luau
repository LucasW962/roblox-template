local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets :: Folder
local Animations = Assets.Animations :: Folder

type CachedAnimator = {
	animations: { [string]: AnimationTrack },
}

local cachedAnimators: { [Animator]: CachedAnimator } = {}

local function createAnimation(animator: Animator, id: string): AnimationTrack
	print(id)
	local animation = Instance.new("Animation")
	animation.AnimationId = `rbxassetid://{id}`

	local track = animator:LoadAnimation(animation)
	if not cachedAnimators[animator] then
		cachedAnimators[animator] = { animations = {} }
	end
	cachedAnimators[animator].animations[id] = track
	return track
end

local function preload(animator: Animator, ids: { string | Animation })
	if not cachedAnimators[animator] then
		cachedAnimators[animator] = { animations = {} }
	end

	print(ids)

	for _, id in ids do
		if type(id) == "string" then
			createAnimation(animator, id :: string)
		else
			local animation = id :: Animation
			local animationId = animation.AnimationId
			local prefix = "rbxassetid://"
			local assetId = string.sub(animationId, 1, #prefix) == prefix and string.sub(animationId, #prefix + 1)
				or animationId
			createAnimation(animator, assetId)
		end
	end
end

local function play(animator: Animator, id: number | Animation | string, settings: { [string]: any }?): AnimationTrack
	if not cachedAnimators[animator] then
		cachedAnimators[animator] = { animations = {} }
	end

	local assetId: string
	local prefix = "rbxassetid://"

	if type(id) == "number" then
		assetId = tostring(id)
	elseif type(id) == "string" then
		local converted = id :: string
		if string.sub(converted, 1, #prefix) == prefix then
			assetId = string.sub(converted, #prefix + 1)
		else
			assetId = converted
		end
	else
		local animation = id :: Animation
		local animationId = animation.AnimationId
		if string.sub(animationId, 1, #prefix) == prefix then
			assetId = string.sub(animationId, #prefix + 1)
		else
			assetId = animationId
		end
	end

	local cachedAnimator = cachedAnimators[animator]
	local cachedAnimation = cachedAnimator.animations[assetId]
	if cachedAnimation then
		if settings then
			for key, value in settings do
				(cachedAnimation :: any)[key] = value
			end
		end
		cachedAnimation:Play()
		return cachedAnimation
	end

	local track = createAnimation(animator, assetId)

	if settings then
		for key, value in settings do
			(track :: any)[key] = value
		end
	end

	track:Play()
	return track
end

return {
	preload = preload,
	play = play,
}
