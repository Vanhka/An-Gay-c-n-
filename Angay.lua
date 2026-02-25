local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local ExitButton = Instance.new("TextButton")
local UICornerMain = Instance.new("UICorner")
local HttpService = game:GetService("HttpService")

-- FILE LƯU TRỮ
local FileName = "DucAnConfig_Skibi.json"

-- BIẾN MẶC ĐỊNH
local Data = {
    Pos1 = {-370, -250, 310},
    Pos2 = {0, 0, 0},
    CamCFrame = nil -- Sẽ lưu dưới dạng bảng số
}

-- HÀM LƯU FILE VÀO MÁY
local function SaveData()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Data)
    end)
    if success then
        writefile(FileName, encoded)
    end
end

-- HÀM TẢI FILE TỪ MÁY
local function LoadData()
    if isfile(FileName) then
        local fileContent = readfile(FileName)
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(fileContent)
        end)
        if success then
            Data = decoded
        end
    end
end

LoadData() -- Chạy ngay khi bật Script

-- --- GIAO DIỆN ---
ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.3 
MainFrame.Size = UDim2.new(0, 240, 0, 480)
MainFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame)

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 5)
local padding = Instance.new("UIPadding", MainFrame).PaddingTop = UDim.new(0, 35)

local function CreateLabel(txt)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = MainFrame
    lbl.Size = UDim2.new(0.9, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = txt
    lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    return lbl
end

local function CreateButton(txt, color)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Text = txt
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    return btn
end

-- CÁC NÚT BẤM
local lblP1 = CreateLabel("P1: " .. Data.Pos1[1] .. ", " .. Data.Pos1[2] .. ", " .. Data.Pos1[3])
local btnGhi1 = CreateButton("Ghi & Lưu P1", Color3.fromRGB(200, 255, 200))
local btnTele1 = CreateButton("Tele tới P1", Color3.fromRGB(255, 255, 255))

local lblP2 = CreateLabel("P2: " .. Data.Pos2[1] .. ", " .. Data.Pos2[2] .. ", " .. Data.Pos2[3])
local btnGhi2 = CreateButton("Ghi & Lưu P2", Color3.fromRGB(200, 255, 200))
local btnTele2 = CreateButton("Tele tới P2", Color3.fromRGB(255, 255, 255))

local lblCam = CreateLabel(Data.CamCFrame and "Cam: Đã có dữ liệu lưu" or "Cam: Chưa ghi")
local btnGhiCam = CreateButton("Ghi & Lưu Góc Camera", Color3.fromRGB(170, 170, 255))
local btnLockCam = CreateButton("Khóa Vào Góc Đã Lưu", Color3.fromRGB(100, 255, 100))
local btnResetAll = CreateButton("XÓA HẾT / RESET MẶC ĐỊNH", Color3.fromRGB(255, 80, 80))

-- LOGIC XỬ LÝ
btnGhi1.MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.Pos1 = {p.X, p.Y, p.Z}
    SaveData()
    lblP1.Text = "P1: Saved!"
end)

btnTele1.MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.Pos1))
end)

btnGhi2.MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    Data.Pos2 = {p.X, p.Y, p.Z}
    SaveData()
    lblP2.Text = "P2: Saved!"
end)

btnTele2.MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.Pos2))
end)

-- LOGIC CAMERA LƯU TRỮ
btnGhiCam.MouseButton1Click:Connect(function()
    local c = workspace.CurrentCamera.CFrame
    -- Chuyển CFrame thành bảng số để lưu vào JSON
    Data.CamCFrame = {c:GetComponents()}
    SaveData()
    lblCam.Text = "Cam: Đã lưu vào máy! ✅"
end)

local CamLock = false
local CamConn
btnLockCam.MouseButton1Click:Connect(function()
    if not Data.CamCFrame then return end
    CamLock = not CamLock
    if CamLock then
        btnLockCam.Text = "Đang Khóa Góc Lưu"
        CamConn = game:GetService("RunService").RenderStepped:Connect(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            workspace.CurrentCamera.CFrame = CFrame.new(unpack(Data.CamCFrame))
        end)
    else
        btnLockCam.Text = "Khóa Vào Góc Đã Lưu"
        if CamConn then CamConn:Disconnect() end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end)

btnResetAll.MouseButton1Click:Connect(function()
    if isfile(FileName) then delfile(FileName) end
    Data = {Pos1 = {-370, -250, 310}, Pos2 = {0,0,0}, CamCFrame = nil}
    lblP1.Text = "P1: Default"
    lblP2.Text = "P2: 0,0,0"
    lblCam.Text = "Cam: Reset"
end)
