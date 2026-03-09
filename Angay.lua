local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Dữ liệu hệ thống
local savedPos1, savedPos2 = nil, nil
local cameraList = {}
local currentCamIndex = 0

-- TẠO MENU CHÍNH
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "An_Dual_Login_System"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 350)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

-- --- GIAO DIỆN CHỌN ĐƯỜNG ĐI (CHOOSE PATH) ---
local choiceFrame = Instance.new("Frame")
choiceFrame.Size = UDim2.new(1, 0, 1, 0)
choiceFrame.BackgroundTransparency = 1
choiceFrame.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "CHỌN QUYỀN TRUY CẬP"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.BackgroundTransparency = 1
title.Parent = choiceFrame

local btnGoUser = Instance.new("TextButton")
btnGoUser.Size = UDim2.new(0, 220, 0, 40)
btnGoUser.Position = UDim2.new(0.5, -110, 0, 80)
btnGoUser.Text = "CHO NGƯỜI DÙNG (USER)"
btnGoUser.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
btnGoUser.Parent = choiceFrame

local btnGoAdmin = Instance.new("TextButton")
btnGoAdmin.Size = UDim2.new(0, 220, 0, 40)
btnGoAdmin.Position = UDim2.new(0.5, -110, 0, 140)
btnGoAdmin.Text = "CHO ADMIN (ĐỨC AN)"
btnGoAdmin.BackgroundColor3 = Color3.fromRGB(120, 0, 120)
btnGoAdmin.Parent = choiceFrame

-- --- CÁC FRAME CHỨC NĂNG (ẨN MẶC ĐỊNH) ---
local userFrame = Instance.new("Frame", mainFrame)
userFrame.Size = UDim2.new(1, 0, 1, 0)
userFrame.BackgroundTransparency = 1
userFrame.Visible = false

local adminFrame = Instance.new("Frame", mainFrame)
adminFrame.Size = UDim2.new(1, 0, 1, 0)
adminFrame.BackgroundTransparency = 1
adminFrame.Visible = false

local mainContent = Instance.new("Frame", mainFrame)
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = false

-- --- LOGIC CHUYỂN ĐƯỜNG ---
btnGoUser.MouseButton1Click:Connect(function() choiceFrame.Visible = false userFrame.Visible = true end)
btnGoAdmin.MouseButton1Click:Connect(function() choiceFrame.Visible = false adminFrame.Visible = true end)

-- --- 1. ĐƯỜNG USER ---
local uPass = Instance.new("TextBox", userFrame)
uPass.Size = UDim2.new(0, 200, 0, 35)
uPass.Position = UDim2.new(0.5, -100, 0, 60)
uPass.PlaceholderText = "Nhập MK User..."

local btnDongY = Instance.new("TextButton", userFrame)
btnDongY.Size = UDim2.new(0, 200, 0, 35)
btnDongY.Position = UDim2.new(0.5, -100, 0, 110)
btnDongY.Text = "tuidongtinh"
btnDongY.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

local btnKoDongY = Instance.new("TextButton", userFrame)
btnKoDongY.Size = UDim2.new(0, 200, 0, 35)
btnKoDongY.Position = UDim2.new(0.5, -100, 0, 160)
btnKoDongY.Text = "tuikodongtinh"
btnKoDongY.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

btnKoDongY.MouseButton1Click:Connect(function() player:Kick("Bạn không đồng ý!") end)
btnDongY.MouseButton1Click:Connect(function()
    if uPass.Text:lower() == "anbigay" then
        userFrame.Visible = false
        mainContent.Visible = true
    else uPass.Text = "Sai MK!" end
end)

-- --- 2. ĐƯỜNG ADMIN ---
local aPass = Instance.new("TextBox", adminFrame)
aPass.Size = UDim2.new(0, 200, 0, 35)
aPass.Position = UDim2.new(0.5, -100, 0, 80)
aPass.PlaceholderText = "Mã Admin: AKA777aka"

local btnXacNhan = Instance.new("TextButton", adminFrame)
btnXacNhan.Size = UDim2.new(0, 200, 0, 40)
btnXacNhan.Position = UDim2.new(0.5, -100, 0, 130)
btnXacNhan.Text = "XÁC NHẬN ADMIN"
btnXacNhan.BackgroundColor3 = Color3.fromRGB(0, 80, 180)

btnXacNhan.MouseButton1Click:Connect(function()
    if aPass.Text == "AKA777aka" then
        adminFrame.Visible = false
        mainContent.Visible = true
    else aPass.Text = "Sai mã Admin!" end
end)

-- --- 3. MENU CHÍNH (CCTV & TELE) ---
local function createBtn(text, yPos, color)
    local btn = Instance.new("TextButton", mainContent)
    btn.Size = UDim2.new(0, 220, 0, 30)
    btn.Position = UDim2.new(0.5, -110, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    return btn
end

local bT1 = createBtn("Tele 1 (R-Click to Save)", 60, Color3.fromRGB(0, 100, 200))
local bT2 = createBtn("Tele 2 (R-Click to Save)", 100, Color3.fromRGB(0, 100, 200))
local bAdd = createBtn("Ghi Camera", 150, Color3.fromRGB(100, 0, 150))
local bDel = createBtn("Xóa Cam hiện tại", 190, Color3.fromRGB(150, 0, 0))

-- Control Cam < >
local ctrl = Instance.new("Frame", mainContent)
ctrl.Size = UDim2.new(0, 220, 0, 40)
ctrl.Position = UDim2.new(0.5, -110, 0, 235)
ctrl.BackgroundTransparency = 1

local bP = Instance.new("TextButton", ctrl) bP.Size = UDim2.new(0, 40, 1, 0) bP.Text = "<"
local bN = Instance.new("TextButton", ctrl) bN.Size = UDim2.new(0, 40, 1, 0) bN.Position = UDim2.new(1, -40, 0, 0) bN.Text = ">"
local info = Instance.new("TextLabel", ctrl) info.Size = UDim2.new(1, -90, 1, 0) info.Position = UDim2.new(0, 45, 0, 0) info.Text = "Cam: Tự do"

-- Nút Thu nhỏ Menu
local min = Instance.new("TextButton", mainFrame)
min.Size = UDim2.new(0, 30, 0, 30)
min.Position = UDim2.new(1, -35, 0, 5)
min.Text = "-"
min.Visible = false

-- Logic CCTV & Tele (Giữ nguyên từ bản trước)
local function upCam()
    if currentCamIndex == 0 then camera.CameraType = Enum.CameraType.Custom info.Text = "Cam: Tự do"
    else camera.CameraType = Enum.CameraType.Scriptable camera.CFrame = cameraList[currentCamIndex] info.Text = "Cam: "..currentCamIndex end
end

bAdd.MouseButton1Click:Connect(function() table.insert(cameraList, camera.CFrame) currentCamIndex = #cameraList upCam() min.Visible = true end)
bDel.MouseButton1Click:Connect(function() if currentCamIndex > 0 then table.remove(cameraList, currentCamIndex) currentCamIndex = math.max(0, #cameraList) upCam() end end)
bP.MouseButton1Click:Connect(function() if #cameraList > 0 then currentCamIndex = (currentCamIndex <= 0) and #cameraList or currentCamIndex - 1 upCam() end end)
bN.MouseButton1Click:Connect(function() if #cameraList > 0 then currentCamIndex = (currentCamIndex >= #cameraList) and 0 or currentCamIndex + 1 upCam() end end)
bT1.MouseButton1Click:Connect(function() if savedPos1 then player.Character.HumanoidRootPart.CFrame = savedPos1 end end)
bT1.MouseButton2Click:Connect(function() savedPos1 = player.Character.HumanoidRootPart.CFrame bT1.Text = "Tele 1 (Lưu OK)" end)
bT2.MouseButton1Click:Connect(function() if savedPos2 then player.Character.HumanoidRootPart.CFrame = savedPos2 end end)
bT2.MouseButton2Click:Connect(function() savedPos2 = player.Character.HumanoidRootPart.CFrame bT2.Text = "Tele 2 (Lưu OK)" end)

RunService.RenderStepped:Connect(function() if currentCamIndex > 0 then camera.CameraType = Enum.CameraType.Scriptable camera.CFrame = cameraList[currentCamIndex] end end)

-- Nút thu gọn
local isM = false
min.MouseButton1Click:Connect(function()
    isM = not isM
    mainFrame.Size = isM and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 350)
    mainContent.Visible = not isM
    min.Text = isM and "+" or "-"
end)
