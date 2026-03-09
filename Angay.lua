local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Dữ liệu hệ thống
local cameraList = {}
local currentCamIndex = 0 -- 0 có nghĩa là camera tự do

-- TẠO MENU CHÍNH
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "An_CCTV_Final_System"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 350)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

-- CÁC FRAME PHÂN LUỒNG
local choiceFrame = Instance.new("Frame", mainFrame)
choiceFrame.Size = UDim2.new(1, 0, 1, 0)
choiceFrame.BackgroundTransparency = 1

local userLoginFrame = Instance.new("Frame", mainFrame)
userLoginFrame.Size = UDim2.new(1, 0, 1, 0)
userLoginFrame.BackgroundTransparency = 1
userLoginFrame.Visible = false

local adminLoginFrame = Instance.new("Frame", mainFrame)
adminLoginFrame.Size = UDim2.new(1, 0, 1, 0)
adminLoginFrame.BackgroundTransparency = 1
adminLoginFrame.Visible = false

local mainContent = Instance.new("Frame", mainFrame)
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = false

-- --- 1. GIAO DIỆN LỰA CHỌN BAN ĐẦU ---
local title = Instance.new("TextLabel", choiceFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "HỆ THỐNG CCTV ĐỨC AN"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1

local bUser = Instance.new("TextButton", choiceFrame)
bUser.Size = UDim2.new(0, 220, 0, 45)
bUser.Position = UDim2.new(0.5, -110, 0, 100)
bUser.Text = "USER ACCESS"
bUser.BackgroundColor3 = Color3.fromRGB(0, 100, 180)

local bAdmin = Instance.new("TextButton", choiceFrame)
bAdmin.Size = UDim2.new(0, 220, 0, 45)
bAdmin.Position = UDim2.new(0.5, -110, 0, 160)
bAdmin.Text = "ADMIN ACCESS"
bAdmin.BackgroundColor3 = Color3.fromRGB(100, 0, 150)

-- --- HÀM TẠO NÚT BACK ---
local function createBackBtn(parent, targetFrame)
	local back = Instance.new("TextButton", parent)
	back.Size = UDim2.new(0, 60, 0, 25)
	back.Position = UDim2.new(0, 5, 0, 5)
	back.Text = "< BACK"
	back.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	back.TextColor3 = Color3.new(1, 1, 1)
	back.MouseButton1Click:Connect(function()
		parent.Visible = false
		targetFrame.Visible = true
	end)
end

createBackBtn(userLoginFrame, choiceFrame)
createBackBtn(adminLoginFrame, choiceFrame)

-- --- 2. XỬ LÝ LOGIN USER ---
local uInput = Instance.new("TextBox", userLoginFrame)
uInput.Size = UDim2.new(0, 200, 0, 35)
uInput.Position = UDim2.new(0.5, -100, 0, 70)
uInput.PlaceholderText = "MK: anbigay"

local bDongY = Instance.new("TextButton", userLoginFrame)
bDongY.Size = UDim2.new(0, 180, 0, 35)
bDongY.Position = UDim2.new(0.5, -90, 0, 120)
bDongY.Text = "tuidongtinh"
bDongY.BackgroundColor3 = Color3.fromRGB(0, 120, 0)

local bKoDongY = Instance.new("TextButton", userLoginFrame)
bKoDongY.Size = UDim2.new(0, 180, 0, 35)
bKoDongY.Position = UDim2.new(0.5, -90, 0, 165)
bKoDongY.Text = "tuikodongtinh"
bKoDongY.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

bDongY.MouseButton1Click:Connect(function()
	if uInput.Text:lower() == "anbigay" then userLoginFrame.Visible = false mainContent.Visible = true end
end)
bKoDongY.MouseButton1Click:Connect(function() player:Kick("Bye bye!") end)

-- --- 3. XỬ LÝ LOGIN ADMIN ---
local aInput = Instance.new("TextBox", adminLoginFrame)
aInput.Size = UDim2.new(0, 200, 0, 35)
aInput.Position = UDim2.new(0.5, -100, 0, 90)
aInput.PlaceholderText = "Mã Admin: AKA777aka"

local bVerify = Instance.new("TextButton", adminLoginFrame)
bVerify.Size = UDim2.new(0, 150, 0, 40)
bVerify.Position = UDim2.new(0.5, -75, 0, 140)
bVerify.Text = "XÁC NHẬN"
bVerify.BackgroundColor3 = Color3.fromRGB(0, 80, 200)

bVerify.MouseButton1Click:Connect(function()
	if aInput.Text == "AKA777aka" then adminLoginFrame.Visible = false mainContent.Visible = true end
end)

-- Sự kiện chuyển đổi nút ban đầu
bUser.MouseButton1Click:Connect(function() choiceFrame.Visible = false userLoginFrame.Visible = true end)
bAdmin.MouseButton1Click:Connect(function() choiceFrame.Visible = false adminLoginFrame.Visible = true end)

-- --- 4. GIAO DIỆN CHÍNH (CCTV CHỈNH SỬA) ---
local function upCam()
	if currentCamIndex == 0 then
		camera.CameraType = Enum.CameraType.Custom
		return "Tự do"
	else
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = cameraList[currentCamIndex]
		return "Cam số: "..currentCamIndex
	end
end

local btnAdd = Instance.new("TextButton", mainContent)
btnAdd.Size = UDim2.new(0, 220, 0, 40)
btnAdd.Position = UDim2.new(0.5, -110, 0, 60)
btnAdd.Text = "GHI CAMERA (Không lock)"
btnAdd.BackgroundColor3 = Color3.fromRGB(100, 0, 150)

local btnReset = Instance.new("TextButton", mainContent)
btnReset.Size = UDim2.new(0, 220, 0, 40)
btnReset.Position = UDim2.new(0.5, -110, 0, 110)
btnReset.Text = "TRỞ LẠI MẮT (TỰ DO)"
btnReset.BackgroundColor3 = Color3.fromRGB(0, 150, 100)

local btnDel = Instance.new("TextButton", mainContent)
btnDel.Size = UDim2.new(0, 220, 0, 40)
btnDel.Position = UDim2.new(0.5, -110, 0, 160)
btnDel.Text = "XÓA CAM HIỆN TẠI"
btnDel.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- Điều khiển < >
local ctrl = Instance.new("Frame", mainContent)
ctrl.Size = UDim2.new(0, 220, 0, 50)
ctrl.Position = UDim2.new(0.5, -110, 0, 220)
ctrl.BackgroundTransparency = 1

local bP = Instance.new("TextButton", ctrl) bP.Size = UDim2.new(0, 50, 1, 0) bP.Text = "<"
local bN = Instance.new("TextButton", ctrl) bN.Size = UDim2.new(0, 50, 1, 0) bN.Position = UDim2.new(1, -50, 0, 0) bN.Text = ">"
local info = Instance.new("TextLabel", ctrl) info.Size = UDim2.new(1, -110, 1, 0) info.Position = UDim2.new(0, 55, 0, 0) info.Text = "Cam: Tự do"
info.BackgroundColor3 = Color3.fromRGB(40, 40, 40) info.TextColor3 = Color3.new(1,1,1)

-- LOGIC CCTV MỚI
btnAdd.MouseButton1Click:Connect(function()
	table.insert(cameraList, camera.CFrame)
	btnAdd.Text = "Đã ghi Cam " .. #cameraList
	task.wait(1)
	btnAdd.Text = "GHI CAMERA (Không lock)"
end)

btnReset.MouseButton1Click:Connect(function()
	currentCamIndex = 0
	info.Text = upCam()
end)

btnDel.MouseButton1Click:Connect(function()
	if currentCamIndex > 0 then
		table.remove(cameraList, currentCamIndex)
		currentCamIndex = #cameraList -- Về cam cuối hoặc 0
		info.Text = upCam()
	end
end)

bP.MouseButton1Click:Connect(function()
	if #cameraList > 0 then
		currentCamIndex = (currentCamIndex <= 1) and #cameraList or currentCamIndex - 1
		info.Text = upCam()
	end
end)

bN.MouseButton1Click:Connect(function()
	if #cameraList > 0 then
		currentCamIndex = (currentCamIndex >= #cameraList) and 1 or currentCamIndex + 1
		info.Text = upCam()
	end
end)

-- Duy trì khóa Camera
RunService.RenderStepped:Connect(function()
	if currentCamIndex > 0 and cameraList[currentCamIndex] then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = cameraList[currentCamIndex]
	end
end)

-- Nút thu gọn menu
local min = Instance.new("TextButton", mainFrame)
min.Size = UDim2.new(0, 30, 0, 30)
min.Position = UDim2.new(1, -35, 0, 5)
min.Text = "-"
min.Visible = false
mainContent:GetPropertyChangedSignal("Visible"):Connect(function() min.Visible = mainContent.Visible end)

local isM = false
min.MouseButton1Click:Connect(function()
	isM = not isM
	mainFrame.Size = isM and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 350)
	mainContent.Visible = not isM
	min.Text = isM and "+" or "-"
end)
