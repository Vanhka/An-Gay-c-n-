-- [[ SCRIPT: ĐỨC AN CCTV & CRAFT MANAGER - V26 (FIX XÓA TỪNG MỤC) ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local HttpService = game:GetService("HttpService")

-- --- HỆ THỐNG LƯU TRỮ ---
local FileName = "AnGay_CCTV_V26.json"
local Data = { SavedCams = {}, SavedCrafts = {} }

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
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 260, 0, 560)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -280)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 0, 0)

ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 35, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleBtn.Text = "V"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Position = UDim2.new(0.5, 135, 0.5, -280)
Instance.new("UICorner", ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ĐỨC AN CCTV 🌈"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = "SourceSansBold"
Title.TextSize = 18

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = "Center"
UIListLayout.Padding = UDim.new(0, 6)
Instance.new("UIPadding", MainFrame).PaddingTop = UDim.new(0, 45)

local function NewBtn(txt, col)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0.9, 0, 0, 32)
    b.BackgroundColor3 = col or Color3.new(1,1,1)
    b.Text = txt
    b.Font = "SourceSansBold"
    Instance.new("UICorner", b)
    return b
end

-- --- [PHẦN 1: CCTV CAMERA] ---
local CamStatus = Instance.new("TextLabel", MainFrame)
CamStatus.Size = UDim2.new(0.9, 0, 0, 20); CamStatus.BackgroundTransparency = 1
CamStatus.TextColor3 = Color3.new(0, 1, 0); CamStatus.Text = "CAM TỰ DO"

local ControlFrame = Instance.new("Frame", MainFrame)
ControlFrame.Size = UDim2.new(0.9, 0, 0, 35); ControlFrame.BackgroundTransparency = 1
local cfL = Instance.new("UIListLayout", ControlFrame); cfL.FillDirection = "Horizontal"; cfL.HorizontalAlignment = "Center"; cfL.Padding = UDim.new(0, 20)

local PrevBtn = Instance.new("TextButton", ControlFrame); PrevBtn.Text = "<"; PrevBtn.Size = UDim2.new(0, 40, 0, 32); Instance.new("UICorner", PrevBtn)
local NextBtn = Instance.new("TextButton", ControlFrame); NextBtn.Text = ">"; NextBtn.Size = UDim2.new(0, 40, 0, 32); Instance.new("UICorner", NextBtn)

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
        if CurCamIdx > #Data.SavedCams then CurCamIdx = 1 end
        CamStatus.Text = "ĐANG XEM CAM: " .. CurCamIdx
        ApplyLock(Data.SavedCams[CurCamIdx])
    else
        if CamLoop then CamLoop:Disconnect() end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        CamStatus.Text = "CHƯA CÓ CAMERA"
    end
end

NextBtn.MouseButton1Click:Connect(function() if #Data.SavedCams > 0 then CurCamIdx = CurCamIdx % #Data.SavedCams + 1; UpdateCamDisplay() end end)
PrevBtn.MouseButton1Click:Connect(function() if #Data.SavedCams > 0 then CurCamIdx = (CurCamIdx - 2) % #Data.SavedCams + 1; UpdateCamDisplay() end end)

NewBtn("GHI GÓC CAM HIỆN TẠI", Color3.fromRGB(150, 255, 150)).MouseButton1Click:Connect(function()
    table.insert(Data.SavedCams, {workspace.CurrentCamera.CFrame:GetComponents()})
    CurCamIdx = #Data.SavedCams; Save(); UpdateCamDisplay()
end)

-- NÚT MỚI: XÓA CHỈ 1 CAMERA ĐANG XEM
NewBtn("XÓA CAMERA HIỆN TẠI", Color3.fromRGB(255, 100, 100)).MouseButton1Click:Connect(function()
    if #Data.SavedCams > 0 then
        table.remove(Data.SavedCams, CurCamIdx)
        if CurCamIdx > #Data.SavedCams and CurCamIdx > 1 then CurCamIdx = #Data.SavedCams end
        Save(); UpdateCamDisplay()
    end
end)

NewBtn("MỞ KHÓA CAMERA (CUSTOM)", Color3.fromRGB(255, 160, 50)).MouseButton1Click:Connect(function()
    if CamLoop then CamLoop:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    CamStatus.Text = "CAM TỰ DO"
end)

-- --- [PHẦN 2: CRAFT & NHẬT KÝ] ---
local craftInput = Instance.new("TextBox", MainFrame)
craftInput.Size = UDim2.new(0.9, 0, 0, 35); craftInput.PlaceholderText = "Nhập tên..."; craftInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40); craftInput.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", craftInput)

local ScrollCraft = Instance.new("ScrollingFrame", MainFrame)
ScrollCraft.Size = UDim2.new(0.9, 0, 0, 150); ScrollCraft.BackgroundColor3 = Color3.new(0,0,0); ScrollCraft.BackgroundTransparency = 0.6; Instance.new("UIListLayout", ScrollCraft).Padding = UDim.new(0, 5)

local function UpdateCraftList()
    for _, v in pairs(ScrollCraft:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for i, name in pairs(Data.SavedCrafts) do
        local f = Instance.new("Frame", ScrollCraft)
        f.Size = UDim2.new(1, 0, 0, 30); f.BackgroundTransparency = 1
        
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0.8, 0, 1, 0); b.Text = "⭐ " .. name; b.BackgroundColor3 = Color3.fromRGB(60, 60, 60); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() craftInput.Text = name end)
        
        local del = Instance.new("TextButton", f)
        del.Size = UDim2.new(0.15, 0, 1, 0); del.Position = UDim2.new(0.85, 0, 0, 0); del.Text = "X"; del.BackgroundColor3 = Color3.fromRGB(150, 0, 0); del.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", del)
        del.MouseButton1Click:Connect(function() table.remove(Data.SavedCrafts, i); Save(); UpdateCraftList() end)
    end
end

NewBtn("LƯU TÊN CRAFT", Color3.fromRGB(150, 255, 150)).MouseButton1Click:Connect(function()
    if craftInput.Text ~= "" then table.insert(Data.SavedCrafts, craftInput.Text); Save(); UpdateCraftList(); craftInput.Text = "" end
end)

UpdateCraftList()
