local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==========================================================
-- THIẾT LẬP: AN GAY SCRIPT (DÀNH CHO NUKE TYCOON)
-- ==========================================================
local TARGET_GAME_ID = 7920018625 
local FILE_NAME = "AnGay_CCTV_Data.json"

-- 1. THÔNG BÁO FAKE BAN (CHỈ HIỆN KHI SAI GAME)
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
    msg.Text = "You banned" -- Nội dung theo ý bạn
    
    warn("Wrong Game! You banned.")
    return 
end

-- 2. DỮ LIỆU CAMERA & AUTO-SAVE
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

-- 3. GIAO DIỆN MENU "AN GAY"
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "An_Gay_CCTV"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 280, 0, 350)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true

local minBtn = Instance.new("TextButton", mainFrame)
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -40, 0, 5)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.ZIndex = 10
minBtn.Visible = false

local choiceF = Instance.new("Frame", mainFrame) choiceF.Size = UDim2.new(1,0,1,0) choiceF.BackgroundTransparency = 1
local userF = Instance.new("Frame", mainFrame) userF.Size = UDim2.new(1,0,1,0) userF.BackgroundTransparency = 1 userF.Visible = false
local adminF = Instance.new("Frame", mainFrame) adminF.Size = UDim2.new(1,0,1,0) adminF.BackgroundTransparency = 1 adminF.Visible = false
local contentF = Instance.new("Frame", mainFrame) contentF.Size = UDim2.new(1,0,1,0) contentF.BackgroundTransparency = 1 contentF.Visible = false

local function addBack(p, t)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(0, 60, 0, 25) b.Position = UDim2.new(0, 5, 0, 5)
    b.Text = "< BACK" b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() p.Visible = false t.Visible = true end)
end
addBack(userF, choiceF) addBack(adminF, choiceF)

-- LỰA CHỌN
local bUser = Instance.new("TextButton", choiceF)
bUser.Size = UDim2.new(0, 200, 0, 45) bUser.Position = UDim2.new(0.5, -100, 0, 80)
bUser.Text = "USER ACCESS" bUser.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
bUser.MouseButton1Click:Connect(function() choiceF.Visible = false userF.Visible = true end)

local bAdmin = Instance.new("TextButton", choiceF)
bAdmin.Size = UDim2.new(0, 200, 0, 45) bAdmin.Position = UDim2.new(0.5, -100, 0, 140)
bAdmin.Text = "ADMIN ACCESS" bAdmin.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
bAdmin.MouseButton1Click:Connect(function() choiceF.Visible = false adminF.Visible = true end)

-- MK LOGIN
local uIn = Instance.new("TextBox", userF) uIn.Size = UDim2.new(0, 180, 0, 30) uIn.Position = UDim2.new(0.5, -90, 0, 60) uIn.PlaceholderText = "MK: anbigay"
local bUok = Instance.new("TextButton", userF) bUok.Size = UDim2.new(0, 180, 0, 35) bUok.Position = UDim2.new(0.5, -90, 0, 100) bUok.Text = "tuidongtinh" bUok.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
bUok.MouseButton1Click:Connect(function() if uIn.Text:lower() == "anbigay" then userF.Visible = false contentF.Visible = true minBtn.Visible = true end end)

local aIn = Instance.new("TextBox", adminF) aIn.Size = UDim2.new(0, 180, 0, 30) aIn.Position = UDim2.new(0.5, -90, 0, 80) aIn.PlaceholderText = "Admin: AKA777aka"
local bAok = Instance.new("TextButton", adminF) bAok.Size = UDim2.new(0, 180, 0, 35) bAok.Position = UDim2.new(0.5, -90, 0, 120) bAok.Text = "XÁC NHẬN" bAok.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
bAok.MouseButton1Click:Connect(function() if aIn.Text == "AKA777aka" then adminF.Visible = false contentF.Visible = true minBtn.Visible = true end end)

-- CCTV
local function upCam()
    if currentCamIndex == 0 then camera.CameraType = Enum.CameraType.Custom return "Tự do"
    else camera.CameraType = Enum.CameraType.Scriptable camera.CFrame = cameraList[currentCamIndex] return "Cam: "..currentCamIndex end
end

local bAdd = Instance.new("TextButton", contentF) bAdd.Size = UDim2.new(0, 220, 0, 40) bAdd.Position = UDim2.new(0.5, -110, 0, 60) bAdd.Text = "GHI CAMERA (Auto-Save)" bAdd.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
bAdd.MouseButton1Click:Connect(function() table.insert(cameraList, camera.CFrame) SaveCams() bAdd.Text = "Đã Lưu!" task.wait(0.5) bAdd.Text = "GHI CAMERA" end)

local bReset = Instance.new("TextButton", contentF) bReset.Size = UDim2.new(0, 220, 0, 40) bReset.Position = UDim2.new(0.5, -110, 0, 110) bReset.Text = "VỀ NHÂN VẬT" bReset.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
bReset.MouseButton1Click:Connect(function() currentCamIndex = 0 upCam() end)

local bDel = Instance.new("TextButton", contentF) bDel.Size = UDim2.new(0, 220, 0, 40) bDel.Position = UDim2.new(0.5, -110, 0, 160) bDel.Text = "XÓA MẮT CAM" bDel.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
bDel.MouseButton1Click:Connect(function() if currentCamIndex > 0 then table.remove(cameraList, currentCamIndex) SaveCams() currentCamIndex = 0 upCam() end end)

local ctrl = Instance.new("Frame", contentF) ctrl.Size = UDim2.new(0, 220, 0, 50) ctrl.Position = UDim2.new(0.5, -110, 0, 220) ctrl.BackgroundTransparency = 1
local bP = Instance.new("TextButton", ctrl) bP.Size = UDim2.new(0, 50, 1, 0) bP.Text = "<"
local bN = Instance.new("TextButton", ctrl) bN.Size = UDim2.new(0, 50, 1, 0) bN.Position = UDim2.new(1, -50, 0, 0) bN.Text = ">"
local info = Instance.new("TextLabel", ctrl) info.Size = UDim2.new(1, -110, 1, 0) info.Position = UDim2.new(0, 55, 0, 0) info.Text = "An Gay CCTV: Tự do"

bP.MouseButton1Click:Connect(function() if #cameraList > 0 then currentCamIndex = (currentCamIndex <= 1) and #cameraList or currentCamIndex - 1 info.Text = upCam() end end)
bN.MouseButton1Click:Connect(function() if #cameraList > 0 then currentCamIndex = (currentCamIndex >= #cameraList) and 1 or currentCamIndex + 1 info.Text = upCam() end end)
RunService.RenderStepped:Connect(function() if currentCamIndex > 0 then camera.CameraType = Enum.CameraType.Scriptable camera.CFrame = cameraList[currentCamIndex] end end)

-- THU NHỎ / PHÓNG TO
local isM = false
minBtn.MouseButton1Click:Connect(function()
    isM = not isM
    mainFrame:TweenSize(isM and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 350), "Out", "Quad", 0.2, true)
    contentF.Visible = not isM
    minBtn.Text = isM and "+" or "-"
end)
