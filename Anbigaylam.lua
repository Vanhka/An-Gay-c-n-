-- [[ SCRIPT: ĐỨC AN THÍCH GAY - V18 (BẢN GỐC - MẶC ĐỊNH SẴN) ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local HttpService = game:GetService("HttpService")

-- --- THÔNG SỐ MẶC ĐỊNH BẠN MUỐN ---
local DefaultP1 = {-370, -250, 310} -- Tọa độ mặc định
local DefaultCamSettings = {65, 20, -60} -- Cao 65, Lệch 20, Nghiêng -60

-- FILE LƯU TRỮ (Để lưu nếu bạn có ghi đè cái mới)
local FileName = "DucAnThichGay_V18.json"
local Data = {P1 = DefaultP1, P2 = {0, 0, 0}}

local function Save() writefile(FileName, HttpService:JSONEncode(Data)) end
local function Load() 
    if isfile(FileName) then 
        pcall(function() Data = HttpService:JSONDecode(readfile(FileName)) end)
    end 
end
Load()

-- --- GIAO DIỆN ---
ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Size = UDim2.new(0, 220, 0, 420)
MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
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
ToggleBtn.Position = UDim2.new(0.7, -40, 0.3, 0)
Instance.new("UICorner", ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "ĐỨC AN THÍCH GAY 🌈"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = "SourceSansBold"
Title.TextSize = 18

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = "Center"
UIListLayout.Padding = UDim.new(0, 8)
Instance.new("UIPadding", MainFrame).PaddingTop = UDim.new(0, 50)

local function NewBtn(txt, col)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0.9, 0, 0, 32)
    b.BackgroundColor3 = col or Color3.new(1,1,1)
    b.Text = txt
    b.Font = "SourceSansBold"
    b.TextColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", b)
    return b
end

-- --- CÁC NÚT BẤM (GIỮ NGUYÊN BẢN CŨ) ---

-- TELE 1
local t1 = NewBtn("TELEPORT VỊ TRÍ 1", Color3.new(1,1,1))
local g1 = NewBtn("Ghi Đè Tọa Độ 1", Color3.fromRGB(150, 255, 150))

-- TELE 2
local t2 = NewBtn("TELEPORT VỊ TRÍ 2", Color3.new(1,1,1))
local g2 = NewBtn("Ghi Đè Tọa Độ 2", Color3.fromRGB(150, 255, 150))

-- CAMERA MẶC ĐỊNH
local Script2 = NewBtn("An Bị Gay thật - Camera", Color3.new(1,1,1))
local mc = NewBtn("MỞ KHÓA CAMERA", Color3.fromRGB(255, 160, 50))

-- RESET
local rt = NewBtn("RESET VỀ MẶC ĐỊNH CODE", Color3.fromRGB(255, 100, 100))
rt.TextColor3 = Color3.new(1,1,1)

-- --- LOGIC ---
t1.MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P1))
end)

g1.MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.P1 = {math.floor(p.X), math.floor(p.Y), math.floor(p.Z)}; Save()
end)

t2.MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P2))
end)

g2.MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.P2 = {math.floor(p.X), math.floor(p.Y), math.floor(p.Z)}; Save()
end)

-- Logic Camera Mặc Định
local camL
Script2.MouseButton1Click:Connect(function()
    if camL then camL:Disconnect() end
    camL = game:GetService("RunService").RenderStepped:Connect(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        local charPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        workspace.CurrentCamera.CFrame = CFrame.new(charPos + Vector3.new(0, DefaultCamSettings[1], DefaultCamSettings[2])) * CFrame.Angles(math.rad(DefaultCamSettings[3]), 0, 0)
    end)
end)

mc.MouseButton1Click:Connect(function()
    if camL then camL:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end)

rt.MouseButton1Click:Connect(function()
    Data.P1 = DefaultP1; Data.P2 = {0,0,0}; Save()
end)
