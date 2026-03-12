local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - ANTI-NAME SCAN",
   LoadingTitle = "Đang loại bỏ tên 'kha28950'...",
   LoadingSubtitle = "Chỉ lướt theo số tiền xanh lá",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoBuild = false  
_G.WaitAtDrill = 300   
_G.DrillRest = 2       
_G.BuildTime = 20      
_G.BuildRest = 10      
_G.FlyHeight = 225     
_G.MoveSpeed = 8      

local function getMyBase()
    for _, b in ipairs(workspace["The Nuke Tycoon Entirely Model"].Tycoons:GetChildren()) do
        if b:FindFirstChild("Owner") and b.Owner.Value == game.Players.LocalPlayer then return b end
    end
    return nil
end

-- HÀM KIỂM TRA MÀU XANH LÁ (TIỀN) & NÉ TÊN NGƯỜI CHƠI
local function isLegitMoney(gui)
    if gui:IsA("TextLabel") or gui:IsA("TextBox") then
        local text = gui.Text:lower()
        local color = gui.TextColor3
        
        -- 1. NÉ TÊN CỦA KHA (Rất quan trọng)
        if text:find("kha") or text:find("28950") or text:find("base") then
            return false
        end
        
        -- 2. CHỈ NHẬN MÀU XANH LÁ (Bỏ qua màu trắng của tên)
        if color.G > 0.5 and color.R < 0.5 and color.B < 0.5 then
            return true
        end
    end
    return false
end

local function safeGlide(targetPos)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and (_G.AutoFarm or _G.AutoBuild) do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
        task.wait()
        if hrp.Position.Y > _G.FlyHeight then break end
    end
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 4 and (_G.AutoFarm or _G.AutoBuild) do
        local direction = (Vector3.new(targetPos.X, _G.FlyHeight, targetPos.Z) - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * _G.MoveSpeed)
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    if _G.AutoBuild or _G.AutoFarm then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.2, targetPos.Z)
        task.wait(0.3)
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

-- VÒNG LẶP NÂNG CẤP (QUÉT MÀU XANH & NÉ TÊN)
task.spawn(function()
    while task.wait() do
        if _G.AutoBuild then
            local myBase = getMyBase()
            if myBase then
                local buildStart = tick()
                while (tick() - buildStart < _G.BuildTime) and _G.AutoBuild do
                    local target = nil
                    for _, obj in ipairs(myBase:GetDescendants()) do
                        if obj:IsA("BillboardGui") then
                            for _, child in ipairs(obj:GetDescendants()) do
                                if isLegitMoney(child) and obj.Parent:IsA("BasePart") then
                                    target = obj.Parent
                                    break
                                end
                            end
                        end
                        if target then break end
                    end
                    if target then safeGlide(target.Position); task.wait(1) end
                    task.wait(0.5)
                end
                task.wait(_G.BuildRest)
            end
        end
    end
end)

local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Bật Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Bật Auto Nâng Cấp (Né Tên)", CurrentValue = false, Callback = function(v) _G.AutoBuild = v end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateInput({Name = "Nghỉ nâng (s)", PlaceholderText = "10", Callback = function(t) _G.BuildRest = tonumber(t) or 10 end})
ConfigTab:CreateInput({Name = "Độ cao bay", PlaceholderText = "225", Callback = function(t) _G.FlyHeight = tonumber(t) or 225 end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
