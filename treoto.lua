-- [[ SCRIPT: ĐỨC AN THÍCH GAY - V23 (CCTV & CRAFT SAVER) ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local HttpService = game:GetService("HttpService")

-- --- HỆ THỐNG LƯU TRỮ FILE ---
local FileName = "DucAnThichGay_V23.json"
local Data = {
    SavedCams = {},   -- Danh sách tọa độ Camera
    SavedCrafts = {}  -- Danh sách tên Craft đã lưu
}

local function Save() writefile(FileName, HttpService:JSONEncode(Data)) end
local function Load() 
    if isfile(FileName) then 
        pcall(function() Data = HttpService:JSONDecode(readfile(FileName)) end)
    end 
end
Load()

-- --- CẤU HÌNH GIAO DIỆN ---
ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 260, 0, 550) -- Cao để chứa danh sách
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -275)
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
ToggleBtn.Position = UDim2.new(0.5, 135, 0.5, -275)
Instance.new("UICorner", ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "ĐỨC AN CCTV & CRAFT 🌈"
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
    Instance.new("UICorner", b)
    return b
end

-- --- [PHẦN 1: CAMERA AN NINH (CCTV)] ---
local CamStatus = Instance.new("TextLabel", MainFrame)
CamStatus.Size = UDim2.new(0.9, 0, 0, 20)
CamStatus.Text = "CHẾ ĐỘ: CAMERA TỰ DO"
CamStatus.TextColor3 = Color3.new(0, 1, 0)
CamStatus.BackgroundTransparency = 1

local ControlFrame = Instance.new("Frame", MainFrame)
ControlFrame.Size = UDim2.new(0.9, 0, 0, 40)
ControlFrame.BackgroundTransparency = 1
local cfL = Instance.new("UIListLayout", ControlFrame)
cfL.FillDirection = "Horizontal"
cfL.HorizontalAlignment = "Center"
cfL.Padding = UDim.new(0, 20)

local PrevBtn = Instance.new("TextButton", ControlFrame)
PrevBtn.Text = "<"
PrevBtn.Size = UDim2.new(0, 40, 0, 35)
Instance.new("UICorner", PrevBtn)

local NextBtn = Instance.new("TextButton", ControlFrame)
NextBtn.Text = ">"
NextBtn.Size = UDim2.new(0, 40, 0, 35)
Instance.new("UICorner", NextBtn)

local CurCamIdx = 1
local CamLoop

local function ApplyLock(cfComponents)
    if CamLoop then CamLoop:Disconnect() end
    CamLoop = game:GetService("RunService").RenderStepped:Connect(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        workspace.CurrentCamera.CFrame = CFrame.new(unpack(cfComponents))
    end)
end

local function UpdateCamDisplay()
    if #Data.SavedCams > 0 then
        CamStatus.Text = "ĐANG XEM CAM SỐ: " .. CurCamIdx
        ApplyLock(Data.SavedCams[CurCamIdx])
    else
        CamStatus.Text = "CHƯA CÓ CAMERA NÀO"
    end
end

NextBtn.MouseButton1Click:Connect(function()
    if #Data.SavedCams > 0 then
        CurCamIdx = CurCamIdx + 1
        if CurCamIdx > #Data.SavedCams then CurCamIdx = 1 end
        UpdateCamDisplay()
    end
end)

PrevBtn.MouseButton1Click:Connect(function()
    if #Data.SavedCams > 0 then
        CurCamIdx = CurCamIdx - 1
        if CurCamIdx < 1 then CurCamIdx = #Data.SavedCams end
        UpdateCamDisplay()
    end
end)

NewBtn("GHI GÓC CAM HIỆN TẠI", Color3.fromRGB(150, 255, 150)).MouseButton1Click:Connect(function()
    local cf = {workspace.CurrentCamera.CFrame:GetComponents()}
    table.insert(Data.SavedCams, cf)
    CurCamIdx = #Data.SavedCams
    Save(); UpdateCamDisplay()
end)

NewBtn("MỞ KHÓA (VỀ MẶC ĐỊNH)", Color3.fromRGB(255, 150, 50)).MouseButton1Click:Connect(function()
    if CamLoop then CamLoop:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    CamStatus.Text = "CHẾ ĐỘ: CAMERA TỰ DO"
end)

-- --- [PHẦN 2: CRAFT & LƯU TÊN] ---
local craftInput = Instance.new("TextBox", MainFrame)
craftInput.Size = UDim2.new(0.9, 0, 0, 35)
craftInput.PlaceholderText = "Nhập tên món đồ/việc đã làm..."
craftInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
craftInput.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", craftInput)

local ScrollCraft = Instance.new("ScrollingFrame", MainFrame)
ScrollCraft.Size = UDim2.new(0.9, 0, 0, 150)
ScrollCraft.BackgroundTransparency = 0.5
ScrollCraft.BackgroundColor3 = Color3.new(0,0,0)
Instance.new("UIListLayout", ScrollCraft).Padding = UDim.new(0, 5)

local function UpdateCraftList()
    for _, v in pairs(ScrollCraft:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for i, name in pairs(Data.SavedCrafts) do
        local b = Instance.new("TextButton", ScrollCraft)
        b.Size = UDim2.new(1, 0, 0, 25)
        b.Text = "⭐ " .. name
        b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(function() craftInput.Text = name end)
    end
end

NewBtn("LƯU TÊN VÀO DANH SÁCH", Color3.fromRGB(150, 255, 150)).MouseButton1Click:Connect(function()
    if craftInput.Text ~= "" then
        table.insert(Data.SavedCrafts, craftInput.Text)
        Save(); UpdateCraftList(); craftInput.Text = ""
    end
end)

NewBtn("XÓA HẾT DỮ LIỆU", Color3.fromRGB(255, 100, 100)).MouseButton1Click:Connect(function()
    Data.SavedCams = {}; Data.SavedCrafts = {}; Save()
    UpdateCraftList(); UpdateCamDisplay()
end)

UpdateCraftList()
