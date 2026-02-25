-- [[ SCRIPT: ĐỨC AN THÍCH GAY - V14 (MAIN & CRAFT SYSTEM) ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TabHolder = Instance.new("Frame")
local ContentHolder = Instance.new("Frame")
local ToggleBtn = Instance.new("TextButton")
local HttpService = game:GetService("HttpService")

-- FILE LƯU TRỮ
local FileName = "DucAnThichGay_V14.json"
local Data = {
    P1 = {-370, -250, 310},
    P2 = {0, 0, 0},
    Cam = nil,
    CraftList = {} -- Lưu các món đồ hoặc hành động đã làm
}

local function Save() writefile(FileName, HttpService:JSONEncode(Data)) end
local function Load() 
    if isfile(FileName) then 
        pcall(function() Data = HttpService:JSONDecode(readfile(FileName)) end)
    end 
end
Load()

-- GIAO DIỆN
ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Size = UDim2.new(0, 250, 0, 450)
MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 0, 0)

-- NÚT THU GỌN V
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 35, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleBtn.Text = "V"
ToggleBtn.Position = UDim2.new(0.7, -40, 0.3, 0)
Instance.new("UICorner", ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- TAB SYSTEM
TabHolder.Parent = MainFrame
TabHolder.Size = UDim2.new(1, 0, 0, 40)
local tabLayout = Instance.new("UIListLayout", TabHolder)
tabLayout.FillDirection = "Horizontal"

ContentHolder.Parent = MainFrame
ContentHolder.Position = UDim2.new(0, 0, 0, 40)
ContentHolder.Size = UDim2.new(1, 0, 1, -40)

local MainTab = Instance.new("ScrollingFrame", ContentHolder)
MainTab.Size = UDim2.new(1, 0, 1, 0)
MainTab.BackgroundTransparency = 1
Instance.new("UIListLayout", MainTab).HorizontalAlignment = "Center"

local CraftTab = Instance.new("ScrollingFrame", ContentHolder)
CraftTab.Size = UDim2.new(1, 0, 1, 0)
CraftTab.BackgroundTransparency = 1
CraftTab.Visible = false
Instance.new("UIListLayout", CraftTab).HorizontalAlignment = "Center"

-- Nút chuyển Tab
local btnMain = Instance.new("TextButton", TabHolder)
btnMain.Size = UDim2.new(0.5, 0, 1, 0)
btnMain.Text = "MAIN"
btnMain.MouseButton1Click:Connect(function() MainTab.Visible = true; CraftTab.Visible = false end)

local btnCraft = Instance.new("TextButton", TabHolder)
btnCraft.Size = UDim2.new(0.5, 0, 1, 0)
btnCraft.Text = "CRAFT / LOG"
btnCraft.MouseButton1Click:Connect(function() MainTab.Visible = false; CraftTab.Visible = true end)

-- --- PHẦN MAIN (Tele & Cam) ---
local function NewBtn(txt, parent, col)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.BackgroundColor3 = col or Color3.new(1,1,1)
    b.Text = txt
    b.Font = "SourceSansBold"
    Instance.new("UICorner", b)
    return b
end

NewBtn("TELEPORT VỊ TRÍ 1", MainTab).MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(Data.P1))
end)

NewBtn("An Bị Gay thật - Camera", MainTab, Color3.new(1,1,1)).MouseButton1Click:Connect(function()
    _G.CamLoop = game:GetService("RunService").RenderStepped:Connect(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        local charPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        workspace.CurrentCamera.CFrame = CFrame.new(charPos + Vector3.new(0, 65, 20)) * CFrame.Angles(math.rad(-60), 0, 0)
    end)
end)

NewBtn("MỞ KHÓA CAMERA", MainTab, Color3.fromRGB(255, 150, 50)).MouseButton1Click:Connect(function()
    if _G.CamLoop then _G.CamLoop:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end)

-- --- PHẦN CRAFT (Lưu kỷ niệm/Hành động) ---
local inputCraft = Instance.new("TextBox", CraftTab)
inputCraft.Size = UDim2.new(0.9, 0, 0, 30)
inputCraft.PlaceholderText = "Nhập tên món đồ vừa làm..."

NewBtn("LƯU VÀO NHẬT KÝ", CraftTab, Color3.fromRGB(150, 255, 150)).MouseButton1Click:Connect(function()
    if inputCraft.Text ~= "" then
        table.insert(Data.CraftList, inputCraft.Text .. " (" .. os.date("%X") .. ")")
        Save()
        inputCraft.Text = ""
        -- Cập nhật danh sách hiển thị (có thể thêm nhãn ở đây)
    end
end)

NewBtn("XÓA HẾT NHẬT KÝ", CraftTab, Color3.fromRGB(255, 100, 100)).MouseButton1Click:Connect(function()
    Data.CraftList = {}
    Save()
end)

-- Tự động Load dữ liệu Craft khi mở
for _, item in pairs(Data.CraftList) do
    local lbl = Instance.new("TextLabel", CraftTab)
    lbl.Size = UDim2.new(0.9, 0, 0, 20)
    lbl.Text = "- " .. item
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
end
