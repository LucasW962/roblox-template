local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local VisibilityHook = require(ReplicatedStorage.Shared.Client.ReactVisibilityHook)

return function(props)
	local fullValues = VisibilityHook(props.states.RodShop, 1.5)

	local uiProps = {}

	uiProps.states = {
		open = {
			value = fullValues.isOpen,
		},
	}

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = fullValues.style.position,
		Size = UDim2.fromScale(0.635938, 0.608897),
		Visible = fullValues.isVisible,
	}, {
		UiScale = React.createElement("UIScale", {
			Scale = fullValues.style.scale:getValue(),
		}),
		glow = React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://139049235612373",
			Position = UDim2.fromScale(0.499181, 0.528158),
			Size = UDim2.fromScale(0.972154, 1.0137),
			ZIndex = 0,
		}),

		contents = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
		}, {
			holder = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://91449780239881",
				Position = UDim2.fromScale(0.498771, 0.527397),
				Size = UDim2.fromScale(0.951679, 0.975647),
				ZIndex = 0,
			}, {
				rods = React.createElement("ScrollingFrame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					AutomaticCanvasSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					CanvasSize = UDim2.fromScale(0.566667, 0.456905),
					Position = UDim2.fromScale(0.5, 0.559282),
					ScrollBarThickness = 0,
					ScrollingDirection = Enum.ScrollingDirection.X,
					Size = UDim2.fromScale(0.936317, 0.769111),
					ZIndex = 0,
				}, {
					uIListLayout = React.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0.0147059, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				}),
			}),

			header = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.285422, 0.087519),
				Size = UDim2.fromScale(0.570844, 0.165906),
				ZIndex = 2,
			}, {
				glow = React.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://111002469909947",
					Position = UDim2.fromScale(0.464849, 0.495413),
					Size = UDim2.fromScale(0.989957, 1.3945),
					ZIndex = 0,
				}),

				inside = React.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://139250503426652",
					Position = UDim2.fromScale(0.467719, 0.5),
					Size = UDim2.fromScale(0.915352, 1),
				}, {
					graphic = React.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = "rbxassetid://72975373337026",
						Position = UDim2.fromScale(1.0431, 0.490826),
						Size = UDim2.fromScale(0.130094, 1.29358),
						ZIndex = 0,
					}),

					text = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
						Position = UDim2.fromScale(0.271944, 0.5),
						RichText = true,
						Size = UDim2.fromScale(0.396552, 0.559633),
						Text = "ROD SHOP",
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}, {
						uIStroke = React.createElement("UIStroke", {
							Color = Color3.fromRGB(0, 73, 40),
							Thickness = 4,
						}),
					}),
				}),
			}),

			exitButton = React.createElement("ImageButton", {
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.952907, 0.087519),
				Size = UDim2.fromScale(0.0941851, 0.175038),
			}, {
				glow = React.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://87300532263484",
					Position = UDim2.fromScale(0.504348, 0.495652),
					Size = UDim2.fromScale(1.3913, 1.3913),
					ZIndex = 0,
				}),

				inside = React.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://87836362357416",
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
				}),
			}),
		}),

		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.85845,
		}),
	})
end
