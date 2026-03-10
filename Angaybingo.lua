local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==========================================================
-- SCRIPT AN GAY: BẢN PRO V5 (GIAO DIỆN TRỰC TIẾP - CHỐNG LỖI)
-- ==========================================================
local TARGET_GAME_ID = 7920018625 
local FILE_NAME = "AnGay_CCTV_Data_Final.json"

-- 1. FAKE BAN (CHỈ HIỆN KHI SAI GAME)
if game.PlaceId ~= TARGET_GAME_ID then
    local trollGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    local bg = Instance.new("Frame", trollGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    local msg = Instance.new("TextLabel", bg)
    msg.Size = UDim2.new(1, 0, 0, 50)
    msg.Position = UDim2.new(0, 0, 0.5, -25)
    msg.BackgroundTransparency = 1
    msg.TextColor3 = Color3.new(1, 0, 0)
    msg.TextSize = 40
    msg.Font = Enum.Font.SourceSansBold
    msg.Text = "You banned"
    return 
end

-- 2. DỮ LIỆU & AUTO-SAVE
local cameraList = {}
local currentCamIndex = 0 
local function SaveCams()
    local data = {}
    for i, cf in ipairs(cameraList) do table.insert(data, {cf:GetComponents()}) end
    if writefile then writefile(FILE_NAME, HttpService:JSONEncode(data)) end
end
local function LoadCams()
    if isfile and isfile(FILE_NAME) then
        local success, content = pcall(readfile, FILE_NAME)
        if success then
            local data = HttpService:JSONDecode(content)
            cameraList = {}
            for i, cfData in ipairs(data) do table.insert(cameraList, CFrame.new(unpack(cfData))) end
        end
    end
end
LoadCams()

-- 3. GIAO DIỆN CHÍNH
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "An_Gay_Direct_Access"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 280, 0, 350)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

-- --- LỚP LOGIN (HIỆN NGAY KHI BẬT) ---
local loginF = Instance.new("Frame", mainFrame)
loginF.Size = UDim2.new(1, 0, 1, 0)
loginF.BackgroundTransparency = 1
loginF.Visible = true

local title = Instance.new("TextLabel", loginF)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "AN GAY SECURITY"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1

-- PHẦN USER (Ở TRÊN)
local uIn = Instance.new("TextBox", loginF)
uIn.Size = UDim2.new(0, 200, 0, 35) uIn.Position = UDim2.new(0.5, -100, 0, 60)
uIn.PlaceholderText = "Nhập mã USER..." uIn.Text = "" uIn.BackgroundColor3 = Color3.fromRGB(30,30,30) uIn.TextColor3 = Color3.new(1,1,1)

local uBtn = Instance.new("TextButton", loginF)
uBtn.Size = UDim2.new(0, 200, 0, 35) uBtn.Position = UDim2.new(0.5, -100, 0, 100)
uBtn.Text = "VÀO USER" uBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180) uBtn.TextColor3 = Color3.new(1,1,1)

-- PHẦN ADMIN (Ở DƯỚI)
local aIn = Instance.new("TextBox", loginF)
aIn.Size = UDim2.new(0, 200, 0, 35) aIn.Position = UDim2.new(0.5, -100, 0, 170)
aIn.PlaceholderText = "Nhập mã ADMIN..." aIn.Text = "" aIn.BackgroundColor3 = Color3.fromRGB(30,30,30) aIn.TextColor3 = Color3.new(1,1,1)

local aBtn = Instance.new("TextButton", loginF)
aBtn.Size = UDim2.new(0, 200, 0, 35) aBtn.Position = UDim2.new(0.5, -100, 0, 210)
aBtn.Text = "VÀO ADMIN" aBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150) aBtn.TextColor3 = Color3.new(1,1,1)

-- --- LỚP NỘI DUNG (KHÓA CỨNG) ---
local contentF = Instance.new("Frame", mainFrame)
contentF.Size = UDim2.new(1, 0, 1, 0)
contentF.BackgroundTransparency = 1
contentF.Visible = false

local minBtn = Instance.new("TextButton", mainFrame)
minBtn.Size = UDim2.new(0, 35, 0, 35) minBtn.Position = UDim2.new(1, -40, 0, 5)
minBtn.Text = "-" minBtn.Visible = false

-- LOGIC XÁC NHẬN
uBtn.MouseButton1Click:Connect(function()
    if uIn.Text:gsub("%s+", "") == "anbigay" then
        loginF.Visible = false
        contentF.Visible = true
        minBtn.Visible = true
    else
        uBtn.Text = "SAI MÃ!" task.wait(0.8) uBtn.Text = "VÀO USER"
    end
end)

aBtn.MouseButton1Click:Connect(function()
    if aIn.Text:gsub("%s+", "") == "AKA777aka" then
        loginF.Visible = false
        contentF.Visible = true
        minBtn.Visible = true
    else
        aBtn.Text = "SAI MÃ!" task.wait(0.8) aBtn.Text = "VÀO ADMIN"
    end
end)

-- --- CHỨC NĂNG CAMERA ---
local function upCam()
    if currentCamIndex == 0 then camera.CameraType = Enum.CameraType.Custom return "Tự do"
    else camera.CameraType = Enum.CameraType.Scriptable camera.CFrame = cameraList[currentCamIndex] return "Cam: "..currentCamIndex end
end

local bAdd = Instance.new("TextButton", contentF) bAdd.Size = UDim2.new(0, 220, 0, 40) bAdd.Position = UDim2.new(0.5, -110, 0, 60) bAdd.Text = "GHI CAMERA" bAdd.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
bAdd.MouseButton1Click:Connect(function() table.insert(cameraList, camera.CFrame) SaveCams() bAdd.Text = "Đã Lưu!" task.wait(0.5) bAdd.Text = "GHI CAMERA" end)

local bReset = Instance.new("TextButton", contentF) bReset.Size = UDim2.new(0, 220, 0, 40) bReset.Position = UDim2.new(0.5, -110, 0, 110) bReset.Text = "VỀ NHÂN VẬT" bReset.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
bReset.MouseButton1Click:Connect(function() currentCamIndex = 0 upCam() end)

local bDel = Instance.new("TextButton", contentF) bDel.Size = UDim2.new(0, 220, 0, 40) bDel.Position = UDim2.new(0.5, -110, 0, 160) bDel.Text = "XÓA MẮT CAM" bDel.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
bDel.MouseButton1Click:Connect(function() if currentCamIndex > 0 then table.remove(cameraList, currentCamIndex) SaveCams() currentCamIndex = 0 upCam() end end)

local ctrl = Instance.new("Frame", contentF) ctrl.Size = UDim2.new(0, 220, 0, 50) ctrl.Position = UDim2.new(0.5, -110, 0, 220) ctrl.BackgroundTransparency = 1
local bP = Instance.new("TextButton", ctrl) bP.Size = UDim2.new(0, 50, 1, 0) bP.Text = "<"
local bN = Instance.new("TextButton", ctrl) bN.Size = UDim2.new(0, 50, 1, 0) bN.Position = UDim2.new(1, -50, 0, 0) bN.Text = ">"
local info = Instance.new("TextLabel", ctrl) info.Size = UDim2.new(1, -110, 1, 0) info.Position = UDim2.new(0, 55, 0, 0) info.TextColor3 = Color3.new(1,1,1); info.Text = "CCTV: Tự do"; info.BackgroundTransparency = 1

bP.MouseButton1Click:Connect(function() if #cameraList > 0 then currentCamIndex = (currentCamIndex <= 1) and #cameraList or currentCamIndex - 1 info.Text = upCam() end end)
bN.MouseButton1Click:Connect(function() if #cameraList > 0 then currentCamIndex = (currentCamIndex >= #cameraList) and 1 or currentCamIndex + 1 info.Text = upCam() end end)
RunService.RenderStepped:Connect(function() if currentCamIndex > 0 then camera.CameraType = Enum.CameraType.Scriptable camera.CFrame = cameraList[currentCamIndex] end end)

minBtn.MouseButton1Click:Connect(function()
    isM = not isM
    mainFrame:TweenSize(isM and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 350), "Out", "Quad", 0.2, true)
    contentF.Visible = not isM
    minBtn.Text = isM and "+" or "-"
end)
