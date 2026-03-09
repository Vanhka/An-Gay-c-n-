local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Dữ liệu hệ thống
local cameraList = {}
local currentCamIndex = 0 

-- TẠO MENU CHÍNH
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "An_CCTV_Fixed"
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

-- NÚT THU GỌN / BẬT MENU (LUÔN HIỆN)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -40, 0, 5)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.ZIndex = 10 -- Đảm bảo luôn nằm trên cùng
minBtn.Parent = mainFrame
minBtn.Visible = false -- Chỉ hiện sau khi login xong

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

-- --- HÀM BACK ---
local function createBackBtn(parent, targetFrame)
	local back = Instance.new("TextButton", parent)
	back.Size = UDim2.new(0, 60, 0, 25)
	back.Position = UDim2.new(0, 5, 0, 5)
	back.Text = "< BACK"
	back.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	back.TextColor3 = Color3.new(1, 1, 1)
	back.MouseButton1Click:Connect(function()
		parent.Visible = false
		targetFrame.Visible = true
	end)
end

createBackBtn(userLoginFrame, choiceFrame)
createBackBtn(adminLoginFrame, choiceFrame)

-- --- 1. CHỌN PATH ---
local bUser = Instance.new("TextButton", choiceFrame)
bUser.Size = UDim2.new(0, 200, 0, 45)
bUser.Position = UDim2.new(0.5, -100, 0, 80)
bUser.Text = "USER ACCESS"
bUser.BackgroundColor3 = Color3.fromRGB(0, 100, 180)

local bAdmin = Instance.new("TextButton", choiceFrame)
bAdmin.Size = UDim2.new(0, 200, 0, 45)
bAdmin.Position = UDim2.new(0.5, -100, 0, 140)
bAdmin.Text = "ADMIN ACCESS"
bAdmin.BackgroundColor3 = Color3.fromRGB(100, 0, 150)

bUser.MouseButton1Click:Connect(function() choiceFrame.Visible = false userLoginFrame.Visible = true end)
bAdmin.MouseButton1Click:Connect(function() choiceFrame.Visible = false adminLoginFrame.Visible = true end)

-- --- 2. LOGIN USER/ADMIN ---
-- (Giữ nguyên logic mật khẩu cũ cho gọn)
local uInput = Instance.new("TextBox", userLoginFrame)
uInput.Size = UDim2.new(0, 180, 0, 30)
uInput.Position = UDim2.new(0.5, -90, 0, 60)
uInput.PlaceholderText = "MK: anbigay"

local bYes = Instance.new("TextButton", userLoginFrame)
bYes.Size = UDim2.new(0, 180, 0, 35)
bYes.Position = UDim2.new(0.5, -90, 0, 100)
bYes.Text = "tuidongtinh"
bYes.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
bYes.MouseButton1Click:Connect(function()
	if uInput.Text:lower() == "anbigay" then userLoginFrame.Visible = false mainContent.Visible = true minBtn.Visible = true end
end)

local aInput = Instance.new("TextBox", adminLoginFrame)
aInput.Size = UDim2.new(0, 180, 0, 30)
aInput.Position = UDim2.new(0.5, -90, 0, 80)
aInput.PlaceholderText = "MK Admin: AKA777aka"

local bVerify = Instance.new("TextButton", adminLoginFrame)
bVerify.Size = UDim2.new(0, 180, 0, 35)
bVerify.Position = UDim2.new(0.5, -90, 0, 120)
bVerify.Text = "XÁC NHẬN"
bVerify.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
bVerify.MouseButton1Click:Connect(function()
	if aInput.Text == "AKA777aka" then adminLoginFrame.Visible = false mainContent.Visible = true minBtn.Visible = true end
end)

-- --- 3. MENU CCTV CHÍNH ---
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

local ctrl = Instance.new("Frame", mainContent)
ctrl.Size = UDim2.new(0, 220, 0, 50)
ctrl.Position = UDim2.new(0.5, -110, 0, 220)
ctrl.BackgroundTransparency = 1

local bP = Instance.new("TextButton", ctrl) bP.Size = UDim2.new(0, 50, 1, 0) bP.Text = "<"
local bN = Instance.new("TextButton", ctrl) bN.Size = UDim2.new(0, 50, 1, 0) bN.Position = UDim2.new(1, -50, 0, 0) bN.Text = ">"
local info = Instance.new("TextLabel", ctrl) info.Size = UDim2.new(1, -110, 1, 0) info.Position = UDim2.new(0, 55, 0, 0) info.Text = "Cam: Tự do"

-- LOGIC CCTV
local function upCam()
	if currentCamIndex == 0 then camera.CameraType = Enum.CameraType.Custom return "Tự do"
	else camera.CameraType = Enum.CameraType.Scriptable camera.CFrame = cameraList[currentCamIndex] return "Cam số: "..currentCamIndex end
end

btnAdd.MouseButton1Click:Connect(function() table.insert(cameraList, camera.CFrame) btnAdd.Text = "Đã ghi!" task.wait(0.5) btnAdd.Text = "GHI CAMERA" end)
btnReset.MouseButton1Click:Connect(function() currentCamIndex = 0 info.Text = upCam() end)
btnDel.MouseButton1Click:Connect(function() if currentCamIndex > 0 then table.remove(cameraList, currentCamIndex) currentCamIndex = 0 info.Text = upCam() end end)
bP.MouseButton1Click:Connect(function() if #cameraList > 0 then currentCamIndex = (currentCamIndex <= 1) and #cameraList or currentCamIndex - 1 info.Text = upCam() end end)
bN.MouseButton1Click:Connect(function() if #cameraList > 0 then currentCamIndex = (currentCamIndex >= #cameraList) and 1 or currentCamIndex + 1 info.Text = upCam() end end)

RunService.RenderStepped:Connect(function() if currentCamIndex > 0 then camera.CameraType = Enum.CameraType.Scriptable camera.CFrame = cameraList[currentCamIndex] end end)

-- --- FIX LỖI NÚT BẬT/TẮT ---
local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		mainContent.Visible = false
		mainFrame:TweenSize(UDim2.new(0, 280, 0, 45), "Out", "Quad", 0.2, true)
		minBtn.Text = "+"
	else
		mainFrame:TweenSize(UDim2.new(0, 280, 0, 350), "Out", "Quad", 0.2, true)
		task.wait(0.2) -- Đợi hiệu ứng xong mới hiện nội dung
		mainContent.Visible = true
		minBtn.Text = "-"
	end
end)
