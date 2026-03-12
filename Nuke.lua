local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - AUTO SWITCH LOGIC",
   LoadingTitle = "Đang nạp quy trình ngắt/bật tự động...",
   LoadingSubtitle = "Khoan <-> Nâng Cấp (Chính Xác 100%)",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   -- Nút tổng (Bắt đầu chu trình)
_G.AutoBuild = false  -- Có kèm nâng cấp hay không
_G.UseNoclip = false

_G.WaitAtDrill = 300   
_G.BuildDuration = 20  
_G.FlyHeight = 195     
_G.MoveSpeed = 5      -- Tốc độ lướt từ script bạn đưa

-- DANH SÁCH TÊN NÚT CHÍNH XÁC (Cập nhật từ bản của bạn)
local TargetNames = {
    "ACS_NoDamage",
    "UraniumButton",
    "Dropper1",
    "Wall1",
    "Base Paths",
    "Front Door",
    "Rookie Armor"
}

local noclipConnection

local function getMyBase()
    for _, b in ipairs(workspace["The Nuke Tycoon Entirely Model"].Tycoons:GetChildren()) do
        if b:FindFirstChild("Owner") and b.Owner.Value == game.Players.LocalPlayer then return b end
    end
    return nil
end

local function toggleNoclip(state)
    if state then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                if game.Players.LocalPlayer.Character then
                    for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        end
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    end
end

-- HÀM LƯỚT CHỈ ĐỊNH (TỪ SCRIPT BẠN ĐƯA)
local function glideTo(targetPart)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    local hum = game.Players.LocalPlayer.Character.Humanoid
    local targetPos = targetPart.Position
    
    local dist = (hrp.Position - targetPos).Magnitude
    while dist > 2 and _G.AutoFarm do
        local direction = (targetPos - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * _G.MoveSpeed)
        
        dist = (hrp.Position - targetPos).Magnitude
        task.wait()
        if dist > 400 then break end
    end
    -- Dẫm lún theo logic lì lợm
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, -1.2, 0))
    task.wait(0.15)
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(0.2)
end

-- QUY TRÌNH TỰ ĐỘNG NGẮT/BẬT (AUTO SWITCH)
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart

                if drill and giver then
                    -- ==========================================
                    -- BƯỚC 1: BẬT KHOAN - NGẮT NÂNG CẤP
                    -- ==========================================
                    local isCurrentlyBuilding = false -- Trạng thái nội bộ
                    hrp.CFrame = CFrame.new(drill.Position.X, _G.FlyHeight, drill.Position.Z)
                    
                    local drillStart = tick()
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(drill.ProximityPrompt, 1, true)
                        end
                        task.wait(0.2)
                    end

                    -- ==========================================
                    -- BƯỚC 2: NHẬN TIỀN (NGẮT CẢ KHOAN LẪN NÂNG)
                    -- ==========================================
                    if _G.AutoFarm then
                        hrp.CFrame = CFrame.new(giver.Position.X, _G.FlyHeight, giver.Position.Z)
                        task.wait(1)
                        hrp.CFrame = giver.CFrame
                        task.wait(1.5)
                    end

                    -- ==========================================
                    -- BƯỚC 3: NGẮT KHOAN - BẬT NÂNG CẤP (NẾU CÀI)
                    -- ==========================================
                    if _G.AutoFarm and _G.AutoBuild then
                        toggleNoclip(_G.UseNoclip)
                        local buildStart = tick()
                        
                        while (tick() - buildStart < _G.BuildDuration) and _G.AutoFarm do
                            local foundTarget = nil
                            
                            -- Quét danh sách tên chính xác bạn đưa
                            for _, nameToFind in ipairs(TargetNames) do
                                for _, obj in ipairs(myBase:GetDescendants()) do
                                    if obj.Name == nameToFind and obj:IsA("BasePart") and obj.Transparency < 1 then
                                        foundTarget = obj
                                        break
                                    end
                                end
                                if foundTarget then break end
                            end

                            -- Nếu không thấy tên trong danh sách, quét mắt thần (nút có chữ)
                            if not foundTarget then
                                for _, obj in ipairs(myBase:GetDescendants()) do
                                    if obj:IsA("BasePart") and obj.Transparency == 0 and obj:FindFirstChildOfClass("BillboardGui") then
                                        foundTarget = obj
                                        break
                                    end
                                end
                            end

                            if foundTarget then
                                glideTo(foundTarget)
                                task.wait(0.5)
                            else
                                task.wait(1) -- Đợi quét lại
                            end
                        end
                        toggleNoclip(false)
                    end
                    -- Kết thúc 1 vòng: Tự động quay về Bước 1 (Bật lại Khoan)
                end
            end
        end
    end
end)

-- GIAO DIỆN RAYFIELD (GÕ SỐ - KHÔNG KÉO)
local MainTab = Window:CreateTab("Treo Máy", 4483362458)

MainTab:CreateToggle({
    Name = "1. Bật Auto Chu Trình (Auto Farm)",
    CurrentValue = false,
    Callback = function(v) _G.AutoFarm = v end
})

MainTab:CreateToggle({
    Name = "2. Kèm Auto Nâng Cấp (Auto Switch)",
    CurrentValue = false,
    Callback = function(v) _G.AutoBuild = v end
})

MainTab:CreateToggle({
    Name = "Bật Noclip (Xuyên tường)",
    CurrentValue = false,
    Callback = function(v) _G.UseNoclip = v; toggleNoclip(v) end
})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)

ConfigTab:CreateInput({
    Name = "Thời gian ở máy khoan (s)",
    PlaceholderText = "300",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) _G.WaitAtDrill = tonumber(t) or 300 end
})

ConfigTab:CreateInput({
    Name = "Thời gian đi nâng cấp (s)",
    PlaceholderText = "20",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) _G.BuildDuration = tonumber(t) or 20 end
})

ConfigTab:CreateInput({
    Name = "Độ cao bay",
    PlaceholderText = "195",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) _G.FlyHeight = tonumber(t) or 195 end
})

ConfigTab:CreateInput({
    Name = "Tốc độ di chuyển",
    PlaceholderText = "5",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) _G.MoveSpeed = tonumber(t) or 5 end
})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
