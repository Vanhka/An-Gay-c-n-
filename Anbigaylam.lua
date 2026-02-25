-- [[ SCRIPT: ĐỨC AN THÍCH GAY - FIX RESET CAMERA ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")
local HttpService = game:GetService("HttpService")

-- HỆ THỐNG LƯU TRỮ
local FileName = "DucAnThichGay_Config.json"
local Data = {P1 = {-370, -250, 310}, P2 = {0, 0, 0}, Cam = nil}

local function Save() writefile(FileName, HttpService:JSONEncode(Data)) end
local function Load() 
    if isfile(FileName) then 
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if success then Data = decoded end
    end 
end
pcall(Load)

-- GIAO DIỆN
ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Size = UDim2.new(0, 240, 0, 480) -- Tăng xíu để thêm nút
MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ĐỨC AN THÍCH GAY 🌈"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 5)
local pad = Instance.new("UIPadding", MainFrame)
pad.PaddingTop = UDim.new(0, 45)

local function NewBtn(txt, col)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.BackgroundColor3 = col or Color3.new(1,1,1)
    b.Text = txt
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    Instance.new("UICorner", b)
    return b
end

local function NewLbl(t)
    local l = Instance.new("TextLabel", MainFrame)
    l.Size = UDim2.new(0.9, 0, 0, 18)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(0, 1, 1)
    l.TextSize = 10
    l.Text = t
    return l
end

-- --- CÁC NÚT BẤM ---
local l1 = NewLbl("P1: "..table.concat(Data.P1, ", "))
local g1 = NewBtn("GHI VỊ TRÍ 1", Color3.fromRGB(150, 255, 150))
local t1 = NewBtn("TELEPORT VỊ TRÍ 1", Color3.new(1,1,1))

local l2 = NewLbl("P2: "..table.concat(Data.P2, ", "))
local g2 = NewBtn("GHI VỊ TRÍ 2", Color3.fromRGB(150, 255, 150))
local t2 = NewBtn("TELEPORT VỊ TRÍ 2", Color3.new(1,1,1))

local btnResetTele = NewBtn("RESET TỌA ĐỘ VỀ MẶC ĐỊNH", Color3.fromRGB(255, 100, 100))

local lc = NewLbl(Data.Cam and "Cam: Đã lưu góc treo ✅" or "Cam: Trống")
local gc = NewBtn("GHI GÓC NHÌN HIỆN TẠI", Color3.fromRGB(150, 150, 255))
local ac = NewBtn("KHÓA GÓC ĐỂ TREO MÁY", Color3.fromRGB(255, 255, 150))
local btnResetCam = NewBtn("MỞ KHÓA CAMERA (MẶC ĐỊNH)", Color3.fromRGB(255, 150, 50))

-- --- LOGIC ---
g1.MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.P1 = {math.floor(p.X), math.floor(p.Y), math.floor(p.Z)}
    l1.Text = "P1: "..table.concat(Data.P1, ", "); Save()
end)

t1.MouseButton1Click:Connect(function() 
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P1)) 
end)

g2.MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.P2 = {math.floor(p.X), math.floor(p.Y), math.floor(p.Z)}
    l2.Text = "P2: "..table.concat(Data.P2, ", "); Save()
end)

t2.MouseButton1Click:Connect(function() 
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P2)) 
end)

-- RESET TELE RIÊNG
btnResetTele.MouseButton1Click:Connect(function()
    Data.P1 = {-370, -250, 310}
    Data.P2 = {0, 0, 0}
    l1.Text = "P1: Default"; l2.Text = "P2: 0,0,0"; Save()
end)

-- CAMERA LOGIC
gc.MouseButton1Click:Connect(function()
    Data.Cam = {workspace.CurrentCamera.CFrame:GetComponents()}
    Save(); lc.Text = "Cam: ĐÃ LƯU GÓC ✅"
end)

local isLock = false
local camConn
ac.MouseButton1Click:Connect(function()
    if not Data.Cam then return end
    isLock = true
    ac.Text = "ĐANG KHÓA GÓC 🔒"
    if camConn then camConn:Disconnect() end
    camConn = game:GetService("RunService").RenderStepped:Connect(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        workspace.CurrentCamera.CFrame = CFrame.new(unpack(Data.Cam))
    end)
end)

-- MỞ KHÓA CAM (Về mặc định của Game)
btnResetCam.MouseButton1Click:Connect(function()
    isLock = false
    ac.Text = "KHÓA GÓC ĐỂ TREO MÁY"
    if camConn then camConn:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    workspace.CurrentCamera.FieldOfView = 70
end)

local Exit = NewBtn("TẮT MENU", Color3.new(0,0,0))
Exit.TextColor3 = Color3.new(1,1,1)
Exit.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
