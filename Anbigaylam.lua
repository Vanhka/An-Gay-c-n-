-- [[ SCRIPT: ĐỨC AN THÍCH GAY - V19 (FULL SETTINGS & SAVE) ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local HttpService = game:GetService("HttpService")

-- --- THÔNG SỐ MẶC ĐỊNH (PHẦN TÍM) ---
local DefaultP1 = {-370, -250, 310} 
local DefaultCam = {65, 20, -60} -- Cao, Lệch, Nghiêng

-- FILE LƯU TRỮ VĨNH VIỄN
local FileName = "DucAnThichGay_V19.json"
local Data = {
    P1 = DefaultP1, 
    P2 = {0, 0, 0}, 
    CustomCam = nil,
    CraftName = "" -- Lưu lại cái tên bạn nhập
}

local function Save() writefile(FileName, HttpService:JSONEncode(Data)) end
local function Load() 
    if isfile(FileName) then 
        pcall(function() Data = HttpService:JSONDecode(readfile(FileName)) end)
    end 
end
Load()

-- --- GIAO DIỆN CHUẨN ---
ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Size = UDim2.new(0, 250, 0, 520) -- Cao hơn để đủ chỗ
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -260)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 0, 0)

-- Nút V thu gọn
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 35, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleBtn.Text = "V"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Position = UDim2.new(0.5, 130, 0.5, -260)
Instance.new("UICorner", ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ĐỨC AN THÍCH GAY 🌈"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = "SourceSansBold"
Title.TextSize = 18

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = "Center"
UIListLayout.Padding = UDim.new(0, 6)
Instance.new("UIPadding", MainFrame).PaddingTop = UDim.new(0, 45)

local function NewBtn(txt, col)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.BackgroundColor3 = col or Color3.new(1,1,1)
    b.Text = txt
    b.Font = "SourceSansBold"
    b.TextSize = 13
    Instance.new("UICorner", b)
    return b
end

local function NewLbl(txt)
    local l = Instance.new("TextLabel", MainFrame)
    l.Size = UDim2.new(0.9, 0, 0, 15)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(180, 150, 255) -- Màu tím nhẹ
    l.TextSize = 10
    l.Font = "SourceSansItalic"
    return l
end

-- --- PHẦN XANH LÁ (CHỨC NĂNG) & PHẦN TÍM (THÔNG SỐ) ---

-- Tele 1
local infoP1 = NewLbl("X: "..Data.P1[1].." Y: "..Data.P1[2].." Z: "..Data.P1[3])
NewBtn("TELEPORT VỊ TRÍ 1", Color3.new(1,1,1)).MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P1))
end)
NewBtn("Ghi Đè Tọa Độ 1", Color3.fromRGB(150, 255, 150)).MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.P1 = {math.floor(p.X), math.floor(p.Y), math.floor(p.Z)}
    infoP1.Text = "X: "..Data.P1[1].." Y: "..Data.P1[2].." Z: "..Data.P1[3]; Save()
end)

-- Tele 2
local infoP2 = NewLbl("X: "..Data.P2[1].." Y: "..Data.P2[2].." Z: "..Data.P2[3])
NewBtn("TELEPORT VỊ TRÍ 2", Color3.new(1,1,1)).MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P2))
end)
NewBtn("Ghi Đè Tọa Độ 2", Color3.fromRGB(150, 255, 150)).MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.P2 = {math.floor(p.X), math.floor(p.Y), math.floor(p.Z)}
    infoP2.Text = "X: "..Data.P2[1].." Y: "..Data.P2[2].." Z: "..Data.P2[3]; Save()
end)

-- Camera
local infoCam = NewLbl("Góc: "..DefaultCam[1]..", "..DefaultCam[2]..", "..DefaultCam[3])
NewBtn("An Bị Gay thật - Camera", Color3.new(1,1,1)).MouseButton1Click:Connect(function()
    if _G.L then _G.L:Disconnect() end
    _G.L = game:GetService("RunService").RenderStepped:Connect(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        workspace.CurrentCamera.CFrame = CFrame.new(p + Vector3.new(0, DefaultCam[1], DefaultCam[2])) * CFrame.Angles(math.rad(DefaultCam[3]), 0, 0)
    end)
end)

NewBtn("Ghi Góc Cam Tùy Chỉnh", Color3.fromRGB(150, 150, 255)).MouseButton1Click:Connect(function()
    Data.CustomCam = {workspace.CurrentCamera.CFrame:GetComponents()}; Save()
end)

NewBtn("Khóa Góc Cam Đã Ghi", Color3.fromRGB(200, 200, 255)).MouseButton1Click:Connect(function()
    if not Data.CustomCam then return end
    if _G.L then _G.L:Disconnect() end
    _G.L = game:GetService("RunService").RenderStepped:Connect(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        workspace.CurrentCamera.CFrame = CFrame.new(unpack(Data.CustomCam))
    end)
end)

NewBtn("MỞ KHÓA CAMERA", Color3.fromRGB(255, 160, 50)).MouseButton1Click:Connect(function()
    if _G.L then _G.L:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end)

-- --- PHẦN CRAFT (LƯU TÊN) ---
local craftInput = Instance.new("TextBox", MainFrame)
craftInput.Size = UDim2.new(0.9, 0, 0, 30)
craftInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
craftInput.TextColor3 = Color3.new(1,1,1)
craftInput.PlaceholderText = "Đặt tên để lưu lại..."
craftInput.Text = Data.CraftName
Instance.new("UICorner", craftInput)

craftInput.FocusLost:Connect(function()
    Data.CraftName = craftInput.Text
    Save()
end)

NewBtn("RESET VỀ MẶC ĐỊNH CODE", Color3.fromRGB(255, 100, 100)).MouseButton1Click:Connect(function()
    Data.P1 = DefaultP1; Data.P2 = {0,0,0}; Data.CustomCam = nil; Data.CraftName = ""
    craftInput.Text = ""; infoP1.Text = "X: -370 Y: -250 Z: 310"; Save()
end)
