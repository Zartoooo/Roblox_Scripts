local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Cam = workspace.CurrentCamera

local targetline = Drawing.new("Line")
targetline.Color = Color3.new(255,0,0)
targetline.Thickness = 1

local Pressed = true

local function GetClosest()
    local closestRoot = nil
    local closestDistance = math.huge

    for _, player in next, Players:GetPlayers() do
        if player == Players.LocalPlayer then continue end
        local char = player.Character
        if char and char:FindFirstChild("Head") then
            local root = char:FindFirstChild("Head")

            if root then
                local pos, vis = Cam:WorldToViewportPoint(root.Position)
                if vis then
                    local dist = (Vector2.new(pos.X,pos.Y) - (Cam.ViewportSize/2)).Magnitude

                    if dist < closestDistance then
                        closestDistance = dist
                        closestRoot = root
                    end
                end
            end
        end
    end

    return closestRoot
end

local oldNM = nil
oldNM = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
    local namecallMethod = getnamecallmethod()
    local args = {...}
    if #args == 3 then
        local origin, direction, params = args[1], args[2], args[3]
        if not checkcaller() and Pressed and Self == workspace and namecallMethod == "Raycast" then
            local filter = params.FilterDescendantsInstances
            if #filter == 4 then
                local closestHead = GetClosest()
                if closestHead then
                    return {
                        Position = closestHead.Position,
                        Instance = closestHead,
                        Material = closestHead.Material or Enum.Material.Plastic,
              
                        Normal = -direction.Unit,
                        Distance = (origin - closestHead.Position).Magnitude,
                        TextureID = nil,
                        FaceID = nil,
                        Transparency = closestHead.Transparency
                    }
                end
            end
        end
    end
    return oldNM(Self, ...)
end))

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        Pressed = true
    end
end)


UIS.InputEnded:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        Pressed = true
    end
end)

RunService.RenderStepped:Connect(function()
    local target = GetClosest()

    if target then
        local pos, vis = Cam:WorldToViewportPoint(target.Position)
        if vis then
            targetline.From = Cam.ViewportSize / 2
            targetline.To = Vector2.new(pos.X, pos.Y)

            targetline.Visible = true
        end
    else
        targetline.Visible = false
    end
end)