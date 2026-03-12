local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - FIX CỬA TUYỆT ĐỐI",
   LoadingTitle = "Đang loại bỏ cửa nhà khỏi bộ nhớ...",
   LoadingSubtitle = "Chỉ tập trung nâng cấp nút thật",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoBuild = false  
_G.UseNoclip = false

_G.WaitAtDrill = 300   
_G.DrillRest = 2       
_G.BuildTime = 20      
_G.BuildRest = 10      
_G.FlyHeight = 225     
_G.MoveSpeed = 7      

-- DANH SÁCH TÊN NÚT ƯU TIÊN (ĐÃ BỎ FRONT DOOR)
local TargetNames = {
    "Rookie Armor", 
    "ACS_NoDamage", 
    "UraniumButton", 
    "Dropper1", 
    "Wall1", 
    "Base Paths"
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

-- HÀM KIỂM TRA "MÙ CỬA"
local function isLegitButton(obj)
    -- Nếu tên là Front Door hoặc chứa chữ Door/Toggle thì bỏ qua luôn
    local name = obj.Name:lower()
    if name:find("door") or name:find("toggle") or name:find("tank") or name:find("help") then
        return false
    end
    -- Nút thật phải có bảng hiện chữ BillboardGui
    if obj:FindFirstChildOfClass("BillboardGui") then
        return true
    end
    return false
end

-- HÀM BAY LƯỚT CHỐNG KẸT
local function safeGlide(targetPos)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    
    -- Bay vọt lên trời
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and (_G.AutoFarm or _G.AutoBuild) do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
        task.wait()
        if hrp.Position.Y > _G.FlyHeight then break end
    end

    -- Lướt ngang
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 4 and (_G.AutoFarm or _G.AutoBuild) do
        local direction = (Vector3.new(targetPos.X, _G.FlyHeight, targetPos.Z) - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * _G.MoveSpeed)
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    
    -- Đáp xuống
    if _G.AutoBuild or _G.AutoFarm then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.2, targetPos.Z)
        task.wait(0.2)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- VÒNG LẶP KHOAN
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                if drill and giver then
                    safeGlide(drill.Position)
                    local drillStart = tick()
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then fireproximityprompt(drill.ProximityPrompt, 1, true) end
                        task.wait(0.2)
                    end
                    task.wait(_G.DrillRest)
                    if _G.AutoFarm then safeGlide(giver.Position); task.wait(2) end
                end
            end
        end
    end
end)

-- VÒNG LẶP NÂNG CẤP (QUÉT CHẶT CHẼ HƠN)
task.spawn(function()
    while task.wait() do
        if _G.AutoBuild then
            local myBase = getMyBase()
            if myBase then
                toggleNoclip(_G.UseNoclip)
                local buildStart = tick()
                while (tick() - buildStart < _G.BuildTime) and _G.AutoBuild do
                    local target = nil
                    
                    -- CHỈ TÌM THEO DANH SÁCH TÊN AN TOÀN
                    for _, name in ipairs(TargetNames) do
                        for _, obj in ipairs(myBase:GetDescendants()) do
                            if obj.Name == name and obj:IsA("BasePart") and obj.Transparency < 1 and isLegitButton(obj) then
                                target = obj; break
                            end
                        end
                        if target then break end
                    end

                    if target then 
                        safeGlide(target.Position)
                        task.wait(1) 
                    end
                    task.wait(0.5)
                end
                if not _G.UseNoclip then toggleNoclip(false) end
                task.wait(_G.BuildRest)
            end
        end
    end
end)

-- GIAO DIỆN
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Bật Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Bật Auto Nâng Cấp", CurrentValue = false, Callback = function(v) _G.AutoBuild = v end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateInput({Name = "Thời gian khoan", PlaceholderText = "300", Callback = function(t) _G.WaitAtDrill = tonumber(t) or 300 end})
ConfigTab:CreateInput({Name = "Thời gian đi nâng", PlaceholderText = "20", Callback = function(t) _G.BuildTime = tonumber(t) or 20 end})
ConfigTab:CreateInput({Name = "Độ cao lướt", PlaceholderText = "225", Callback = function(t) _G.FlyHeight = tonumber(t) or 225 end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
