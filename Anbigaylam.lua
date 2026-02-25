-- [[ SCRIPT: DUC AN THICH GAY - PRO VERSION ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")
local HttpService = game:GetService("HttpService")

-- HỆ THỐNG LƯU TRỮ VĨNH VIỄN
local FileName = "DucAnThichGay_Config.json"
local Data = {P1 = {-370, -250, 310}, P2 = {0,0,0}, Cam = nil}

local function Save() writefile(FileName, HttpService:JSONEncode(Data)) end
local function Load() if isfile(FileName) then Data = HttpService:JSONDecode(readfile(FileName)) end end
pcall(Load)

-- GIAO DIỆN MENU
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "DucAnThichGayMenu"

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Size = UDim2.new(0, 230, 0, 420)
MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Tiêu đề cho "oai"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "ĐỨC AN THÍCH GAY 🌈"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 6)
local pad = Instance.new("UIPadding", MainFrame)
pad.PaddingTop = UDim.new(0, 40)

local function NewBtn(txt, col)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0.9, 0, 0, 32)
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

-- --- THIẾT LẬP NÚT ---
local l1 = NewLbl("Vị trí 1: "..table.concat(Data.P1, ", "))
local g1 = NewBtn("GHI TỌA ĐỘ 1", Color3.fromRGB(200, 255, 200))
local t1 = NewBtn("TELE TỚI VỊ TRÍ 1", Color3.new(1,1,1))

local l2 = NewLbl("Vị trí 2: "..table.concat(Data.P2, ", "))
local g2 = NewBtn("GHI TỌA ĐỘ 2", Color3.fromRGB(200, 255, 200))
local t2 = NewBtn("TELE TỚI VỊ TRÍ 2", Color3.new(1,1,1))

local lc = NewLbl(Data.Cam and "Cam: Đã có góc lưu 📸" or "Cam: Chưa ghi góc")
local gc = NewBtn("GHI GÓC NHÌN CAMERA", Color3.fromRGB(200, 200, 255))
local ac = NewBtn("KHÓA VÀO GÓC ĐÃ GHI", Color3.fromRGB(150, 255, 150))
local rc = NewBtn("RESET TẤT CẢ (MẶC ĐỊNH)", Color3.fromRGB(255, 100, 100))

-- --- LOGIC VẬN HÀNH ---
g1.MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.P1 = {math.floor(p.X), math.floor(p.Y), math.floor(p.Z)}
    l1.Text = "Vị trí 1: "..table.concat(Data.P1, ", "); Save()
    g1.Text = "ĐÃ LƯU P1 ✅" task.wait(0.5) g1.Text = "GHI TỌA ĐỘ 1"
end)

t1.MouseButton1Click:Connect(function() 
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P1)) 
end)

g2.MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.P2 = {math.floor(p.X), math.floor(p.Y), math.floor(p.Z)}
    l2.Text = "Vị trí 2: "..table.concat(Data.P2, ", "); Save()
    g2.Text = "ĐÃ LƯU P2 ✅" task.wait(0.5) g2.Text = "GHI TỌA ĐỘ 2"
end)

t2.MouseButton1Click:Connect(function() 
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P2)) 
end)

gc.MouseButton1Click:Connect(function()
    Data.Cam = {workspace.CurrentCamera.CFrame:GetComponents()}
    Save(); lc.Text = "Cam: ĐÃ LƯU GÓC ✅"
end)

local locking = false
local conn
ac.MouseButton1Click:Connect(function()
    if not Data.Cam then lc.Text = "LỖI: CHƯA GHI GÓC!" return end
    locking = not locking
    ac.Text = locking and "ĐANG KHÓA GÓC 🔒" or "KHÓA VÀO GÓC ĐÃ GHI"
    if locking then
        conn = game:GetService("RunService").RenderStepped:Connect(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            workspace.CurrentCamera.CFrame = CFrame.new(unpack(Data.Cam))
        end)
    else
        if conn then conn:Disconnect() end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end)

rc.MouseButton1Click:Connect(function()
    if conn then conn:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    if isfile(FileName) then delfile(FileName) end
    Data = {P1 = {-370, -250, 310}, P2 = {0,0,0}, Cam = nil}
    l1.Text = "Vị trí 1: Default"; l2.Text = "Vị trí 2: 0,0,0"; lc.Text = "Cam: Trống"
    print("Đã Reset sạch sẽ")
end)

-- Nút tắt menu (X)
local Close = NewBtn("ĐÓNG MENU (TẮT HẾT)", Color3.new(0,0,0))
Close.TextColor3 = Color3.new(1,1,1)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
