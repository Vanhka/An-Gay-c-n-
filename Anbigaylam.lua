-- [[ SCRIPT: ĐỨC AN THÍCH GAY - V20 (ADVANCED CRAFT LOG) ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TabHolder = Instance.new("Frame")
local ContentHolder = Instance.new("Frame")
local ToggleBtn = Instance.new("TextButton")
local HttpService = game:GetService("HttpService")

-- --- CẤU HÌNH MẶC ĐỊNH ---
local FileName = "DucAnThichGay_V20.json"
local Data = {
    P1 = {-370, -250, 310},
    P2 = {0, 0, 0},
    CustomCam = nil,
    SavedCrafts = {} -- Danh sách các tên đã lưu
}

local function Save() writefile(FileName, HttpService:JSONEncode(Data)) end
local function Load() 
    if isfile(FileName) then 
        pcall(function() Data = HttpService:JSONDecode(readfile(FileName)) end)
    end 
end
Load()

-- --- GIAO DIỆN CHÍNH ---
ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 260, 0, 450)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -225)
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
ToggleBtn.Position = UDim2.new(0.5, 135, 0.5, -225)
Instance.new("UICorner", ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- TAB SYSTEM
TabHolder.Parent = MainFrame
TabHolder.Size = UDim2.new(1, 0, 0, 40)
local tL = Instance.new("UIListLayout", TabHolder)
tL.FillDirection = "Horizontal"

ContentHolder.Parent = MainFrame
ContentHolder.Position = UDim2.new(0, 0, 0, 40)
ContentHolder.Size = UDim2.new(1, 0, 1, -40)

local MainTab = Instance.new("ScrollingFrame", ContentHolder)
MainTab.Size = UDim2.new(1, 0, 1, 0)
MainTab.BackgroundTransparency = 1
MainTab.Visible = true
Instance.new("UIListLayout", MainTab).HorizontalAlignment = "Center"

local CraftTab = Instance.new("ScrollingFrame", ContentHolder)
CraftTab.Size = UDim2.new(1, 0, 1, 0)
CraftTab.BackgroundTransparency = 1
CraftTab.Visible = false
Instance.new("UIListLayout", CraftTab).HorizontalAlignment = "Center"

local function NewTabBtn(txt)
    local b = Instance.new("TextButton", TabHolder)
    b.Size = UDim2.new(0.5, 0, 1, 0)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = "SourceSansBold"
    return b
end

local btnM = NewTabBtn("MAIN")
local btnC = NewTabBtn("CRAFT / LƯU")

btnM.MouseButton1Click:Connect(function() MainTab.Visible = true; CraftTab.Visible = false end)
btnC.MouseButton1Click:Connect(function() MainTab.Visible = false; CraftTab.Visible = true end)

local function NewBtn(txt, parent, col)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9, 0, 0, 32)
    b.BackgroundColor3 = col or Color3.new(1,1,1)
    b.Text = txt
    b.Font = "SourceSansBold"
    Instance.new("UICorner", b)
    local p = Instance.new("UIPadding", parent); p.PaddingTop = UDim.new(0,10)
    return b
end

-- --- [TAB MAIN] ---
NewBtn("TELEPORT VỊ TRÍ 1", MainTab).MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P1))
end)
NewBtn("An Bị Gay thật - Camera", MainTab).MouseButton1Click:Connect(function()
    if _G.L then _G.L:Disconnect() end
    _G.L = game:GetService("RunService").RenderStepped:Connect(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        workspace.CurrentCamera.CFrame = CFrame.new(p + Vector3.new(0, 65, 20)) * CFrame.Angles(math.rad(-60), 0, 0)
    end)
end)
NewBtn("MỞ KHÓA CAMERA", MainTab, Color3.fromRGB(255, 160, 50)).MouseButton1Click:Connect(function()
    if _G.L then _G.L:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end)

-- --- [TAB CRAFT - HỆ THỐNG LƯU TÊN] ---
local craftInput = Instance.new("TextBox", CraftTab)
craftInput.Size = UDim2.new(0.9, 0, 0, 35)
craftInput.PlaceholderText = "Nhập tên cần lưu..."
craftInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
craftInput.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", craftInput)

local listFrame = Instance.new("Frame", CraftTab)
listFrame.Size = UDim2.new(0.9, 0, 0, 200)
listFrame.BackgroundTransparency = 1
local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.Padding = UDim.new(0, 5)

local function UpdateList()
    for _, child in pairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for i, name in pairs(Data.SavedCrafts) do
        local b = Instance.new("TextButton", listFrame)
        b.Size = UDim2.new(1, 0, 0, 25)
        b.Text = "⭐ " .. name
        b.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        b.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", b)
        
        -- Bấm vào tên để chọn lại (hiện lên ô nhập)
        b.MouseButton1Click:Connect(function()
            craftInput.Text = name
        end)
    end
end

NewBtn("BẤM ĐỂ LƯU TÊN", CraftTab, Color3.fromRGB(150, 255, 150)).MouseButton1Click:Connect(function()
    if craftInput.Text ~= "" then
        table.insert(Data.SavedCrafts, craftInput.Text)
        Save()
        UpdateList()
        craftInput.Text = ""
    end
end)

NewBtn("XÓA TẤT CẢ TÊN", CraftTab, Color3.fromRGB(255, 100, 100)).MouseButton1Click:Connect(function()
    Data.SavedCrafts = {}
    Save()
    UpdateList()
end)

UpdateList() -- Load danh sách khi bật script
