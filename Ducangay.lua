local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Script1 = Instance.new("TextButton")
local Script2 = Instance.new("TextButton")
local ExitButton = Instance.new("TextButton")
local UICornerMain = Instance.new("UICorner")

-- Khởi tạo giao diện
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "DucAnMenuV5"

-- 1. Khung Menu (Viền đỏ)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5 
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Position = UDim2.new(0.7, 0, 0.65, 0) 
MainFrame.Size = UDim2.new(0, 200, 0, 110) -- Tăng chiều rộng tí để chữ "Tele/Camera" không bị mất
MainFrame.Active = true
MainFrame.Draggable = true 

UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

-- Nút X để tắt
ExitButton.Name = "ExitButton"
ExitButton.Parent = MainFrame
ExitButton.BackgroundTransparency = 1
ExitButton.Position = UDim2.new(0.88, 0, 0.05, 0)
ExitButton.Size = UDim2.new(0, 20, 0, 20)
ExitButton.Text = "X"
ExitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitButton.Font = Enum.Font.SourceSansBold
ExitButton.TextSize = 18
ExitButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sắp xếp 2 thanh trắng
UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.Padding = UDim.new(0, 10)

local padding = Instance.new("UIPadding", MainFrame)
padding.PaddingBottom = UDim.new(0, 10)

-- 2. Thanh trắng 1: Đức An Bi Gây - Tele
Script1.Name = "Script1"
Script1.Parent = MainFrame
Script1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Script1.BorderSizePixel = 0
Script1.Size = UDim2.new(0.9, 0, 0, 28)
Script1.Text = "Đức An Bi Gây - Tele"
Script1.TextColor3 = Color3.fromRGB(0, 0, 0)
Script1.Font = Enum.Font.SourceSansBold
Script1.TextSize = 14

Script1.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(Vector3.new(-370, -250, 310))
end)

-- 3. Thanh trắng 2: An Bị Gay thật - Camera
Script2.Name = "Script2"
Script2.Parent = MainFrame
Script2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Script2.BorderSizePixel = 0
Script2.Size = UDim2.new(0.9, 0, 0, 28)
Script2.Text = "An Bị Gay thật - Camera"
Script2.TextColor3 = Color3.fromRGB(0, 0, 0)
Script2.Font = Enum.Font.SourceSansBold
Script2.TextSize = 14

Script2.MouseButton1Click:Connect(function()
    local RunService = game:GetService("RunService")
    local camera = workspace.CurrentCamera
    local player = game.Players.LocalPlayer
    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            camera.CameraType = Enum.CameraType.Scriptable
            local charPos = player.Character.HumanoidRootPart.Position
            camera.CFrame = CFrame.new(charPos + Vector3.new(0, 65, 20)) * CFrame.Angles(math.rad(-60), 0, 0)
        end
    end)
end)
