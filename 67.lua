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
local MaxMoney = 22500
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
    [2] = 2,
    [3] = 3
}

local StarButtons = {}

local function GetUnitPrice(unit)
    return math.floor(
        unit.Price * StarMultipliers[StarLevel]
    )
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
    {Name="真理鹈鹕",ID=151,Rank="B",Amount=8,Price=20000,Cooldown=200,Image=102009551876604,Category="普通"},
    {Name="棍子",ID=109,Rank="B",Amount=8,Price=10000,Cooldown=100,Image=81963847967960,Category="普通"},
    {Name="黑暗轰炸机战士",ID=22,Rank="B",Amount=4,Price=1000,Cooldown=25,Image=93022672755160,Category="普通"},
    {Name="魔法生成器",ID=24,Rank="B",Amount=4,Price=1600,Cooldown=50,Image=101930259026845,Category="普通"},
    {Name="爱国者弹头",ID=108,Rank="B",Amount=8,Price=15000,Cooldown=300,Image=71963794967775,Category="普通"},

    -- 僵尸
    {Name="保持微笑",ID=144,Rank="A",Amount=2,Price=1000,Cooldown=35,Image=134391460910247,Category="僵尸",Args={Health=600}},
    {Name="披萨",ID=136,Rank="A",Amount=2,Price=500,Cooldown=50,Image=76810868926793,Category="僵尸"},
    {Name="保护僵尸",ID=135,Rank="A",Amount=2,Price=900,Cooldown=70,Image=117471233334728,Category="僵尸"},

    -- 天使
    {Name="诺曼",ID=104,Rank="B",Amount=2,Price=800,Cooldown=60,Image=76163313488934,Category="天使"},
    {Name="审判",ID=115,Rank="B",Amount=6,Price=2000,Cooldown=50,Image=76008989733506,Category="天使"},
    {Name="克罗诺斯",ID=122,Rank="B",Amount=5,Price=22500,Cooldown=600,Image=125817598848664,Category="天使"},
    {Name="Pwnsalot",ID=101,Rank="B",Amount=5,Price=1200,Cooldown=15,Image=100746586925732,Category="天使"},

    -- 死亡
    {Name="McBlast",ID=116,Rank="B",Amount=4,Price=300,Cooldown=30,Image=83665706736688,Category="死亡"},
    {Name="粉碎机",ID=121,Rank="B",Amount=4,Price=8000,Cooldown=800,Image=132780898159572,Category="死亡"},
    {Name="极限",ID=72,Rank="B",Amount=4,Price=20000,Cooldown=500,Image=90530027731674,Category="死亡"},
    {Name="巨魔袭击",ID=105,Rank="B",Amount=4,Price=200,Cooldown=25,Image=119281801828499,Category="死亡"},
    {Name="束缚状态",ID=69,Rank="B",Amount=4,Price=1200,Cooldown=20,Image=90355776344408,Category="死亡"},
    {Name="双黑暗之心",ID=54,Rank="B",Amount=10,Price=300,Cooldown=10,Image=90816086906198,Category="死亡"},
    {Name="贝蒂",ID=56,Rank="B",Amount=10,Price=300,Cooldown=15,Image=112152174802483,Category="死亡"},
    {Name="血角",ID=65,Rank="B",Amount=10,Price=800,Cooldown=20,Image=73907201693668,Category="死亡"},
    {Name="原子",ID=118,Rank="B",Amount=10,Price=500,Cooldown=20,Image=72643510567320,Category="死亡",Args={Health=50}},
    {Name="顶级",ID=94,Rank="B",Amount=10,Price=1000,Cooldown=25,Image=103544184383951,Category="死亡"},
    {Name="闪耀",ID=92,Rank="B",Amount=2,Price=400,Cooldown=20,Image=78409354291455,Category="死亡"},
    {Name="弹头",ID=70,Rank="B",Amount=4,Price=1000,Cooldown=100,Image=98839631179168,Category="死亡"},

    -- 地狱
    {Name="地狱",ID=39,Rank="B",Amount=8,Price=2000,Cooldown=50,Image=113366045982105,Category="地狱"},
    {Name="天才",ID=89,Rank="B",Amount=4,Price=1200,Cooldown=60,Image=139624564209954,Category="地狱"},
    {Name="疯狂化学家",ID=60,Rank="B",Amount=4,Price=3000,Cooldown=100,Image=134686338431581,Category="地狱"},
    {Name="Speeddemon",ID=150,Rank="B",Amount=4,Price=2400,Cooldown=70,Image=73440841269995,Category="地狱"},
    {Name="盾牌战士",ID=29,Rank="B",Amount=4,Price=300,Cooldown=30,Image=87500073270346,Category="地狱"},
    {Name="吉他英雄",ID=35,Rank="B",Amount=4,Price=2000,Cooldown=100,Image=117913123207840,Category="地狱"},
    {Name="地狱火",ID=40,Rank="B",Amount=4,Price=12000,Cooldown=500,Image=95516325060350,Category="地狱"},
    {Name="雇佣兵",ID=32,Rank="B",Amount=5,Price=300,Cooldown=10,Image=121186955802358,Category="地狱"},
    {Name="瓶装",ID=88,Rank="B",Amount=8,Price=600,Cooldown=15,Image=109161080608846,Category="地狱"}
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
-- 星级按钮：左上角
--==================================================

local StarFrame = Instance.new("Frame")
StarFrame.Name = "StarSelector"
StarFrame.Size = UDim2.new(0,180,0,42)
StarFrame.Position = UDim2.new(0,15,0,10)
StarFrame.BackgroundTransparency = 1
StarFrame.ZIndex = 500
StarFrame.Parent = Gui

local StarLayout = Instance.new("UIGridLayout")
StarLayout.CellSize = UDim2.new(0,52,0,38)
StarLayout.CellPadding = UDim2.new(0,5,0,0)
StarLayout.FillDirection = Enum.FillDirection.Horizontal
StarLayout.Parent = StarFrame

local StarColors = {
    Color3.fromRGB(0,190,255),
    Color3.fromRGB(255,160,0),
    Color3.fromRGB(255,45,45)
}

for i=1,3 do
    local button = Button(
        StarFrame,
        "Star"..i,
        string.rep("★",i),
        UDim2.new(0,52,0,38),
        UDim2.new(0,0,0,0),
        501
    )

    button.BackgroundColor3 = StarColors[i]
    button.TextColor3 = Color3.new(1,1,1)

    StarButtons[i] = button

    button.MouseButton1Click:Connect(function()
        if Running then return end

        StarLevel = i
        UpdateStars()
        UpdateSlots()
    end)
end

--==================================================
-- PC按键设置按钮
--==================================================

local SettingsButton

if IsPC then
    SettingsButton = Button(Gui,"KeySettings","按键设置",
        UDim2.new(0,100,0,35),
        UDim2.new(1,-205,0,90),1000)
end

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
                mask.BackgroundColor3 = Color3.new(0,0,0)mask.BackgroundTransparency = 0.45
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
                unit.Args or {}
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

    -- 青蓝色边框
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
    Corner(icon,7)

    local nameText = Label(card,"NameText","",
        UDim2.new(1,0,0,15),
        UDim2.new(0,0,0,0),107)
    nameText.BackgroundColor3 = Color3.fromRGB(0,0,0)
    nameText.BackgroundTransparency = 0.25
    nameText.TextColor3 = Color3.new(1,1,1)
    nameText.Visible = false

    local priceText = Instance.new("TextLabel")
    priceText.Name = "PriceText"
    priceText.Size = UDim2.new(1,0,0,18)
    priceText.Position = UDim2.new(0,0,1,-18)
    priceText.BackgroundColor3 = Color3.fromRGB(0,0,0)
    priceText.BackgroundTransparency = 0.2
    priceText.TextColor3 = Color3.fromRGB(255,190,35)
    priceText.TextStrokeTransparency = 0
    priceText.TextScaled = true
    priceText.Font = Enum.Font.GothamBold
    priceText.ZIndex = 107
    priceText.Visible = false
    priceText.Parent = card

    local cooldownMask = Instance.new("Frame")
    cooldownMask.Name = "CooldownMask"
    cooldownMask.Size = UDim2.new(1,0,1,0)
    cooldownMask.BackgroundColor3 = Color3.fromRGB(0,0,0)
    cooldownMask.BackgroundTransparency = 0.48
    cooldownMask.BorderSizePixel = 0
    cooldownMask.ClipsDescendants = true
    cooldownMask.Visible = false
    cooldownMask.ZIndex = 104
    cooldownMask.Parent = card
    Corner(cooldownMask,7)

    local cooldownFill = Instance.new("Frame")
    cooldownFill.Size = UDim2.new(1,0,1,0)
    cooldownFill.BackgroundColor3 = Color3.fromRGB(130,130,130)
    cooldownFill.BackgroundTransparency = 0.25
    cooldownFill.BorderSizePixel = 0
    cooldownFill.ZIndex = 105
    cooldownFill.Parent = cooldownMask

    local cooldownText = Label(cooldownMask,"CooldownText","",
        UDim2.new(1,0,0,25),
        UDim2.new(0,0,0.5,-12),106)

    cooldownText.TextStrokeTransparency = 0

    SlotCards[i] = {
        Button = card,
        Icon = icon,
        NameText = nameText,
        PriceText = priceText,
        CooldownMask = cooldownMask,
        CooldownFill = cooldownFill,
        CooldownText = cooldownText
    }

    card.MouseButton1Click:Connect(function()
        ActivateSlot(i)
    end)
end

--==================================================
-- 设置面板：按键设置 + 沙盒选项 + 更新日志
--==================================================

local SettingsButton = Button(Gui,"SettingsButton","设置",
    UDim2.new(0,85,0,35),
    UDim2.new(1,-185,0,90),1000)

local SettingsPanel = Instance.new("Frame")
SettingsPanel.Name = "SettingsPanel"
SettingsPanel.Size = UDim2.new(0,300,0,520)
SettingsPanel.Position = UDim2.new(0.5,-150,0.5,-260)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(20,20,20)
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Visible = false
SettingsPanel.ZIndex = 200
SettingsPanel.Parent = Gui
Corner(SettingsPanel,10)

Label(SettingsPanel,"Title","设置",
    UDim2.new(1,-45,0,38),UDim2.new(0,8,0,5),201)

local CloseSettings = Button(SettingsPanel,"CloseSettings","X",
    UDim2.new(0,35,0,30),UDim2.new(1,-40,0,5),205)
CloseSettings.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = false
end)

-- 沙盒专属开关：默认开启
-- 开启：交换队伍重生点只在沙盒战斗中工作
-- 关闭：非沙盒时允许客户端本地替换贴图
local SandboxOnly = true
local TextureAsset = "rbxassetid://114504093003897"
local OriginalTextures = {}
local TexturePatched = false

local SandboxOnlyButton = Button(SettingsPanel,"SandboxOnlyToggle",
    "沙盒专属：开启",
    UDim2.new(1,-20,0,34),UDim2.new(0,10,0,48),202)

local function SetLocalTexturePatch(enabled)
    if enabled and not TexturePatched then
        table.clear(OriginalTextures)
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                OriginalTextures[obj] = obj.Texture
                obj.Texture = TextureAsset
            end
        end
        TexturePatched = true
    elseif not enabled and TexturePatched then
        for obj,oldTexture in pairs(OriginalTextures) do
            if obj and obj.Parent then
                pcall(function() obj.Texture = oldTexture end)
            end
        end
        table.clear(OriginalTextures)
        TexturePatched = false
    end
end

SandboxOnlyButton.MouseButton1Click:Connect(function()
    SandboxOnly = not SandboxOnly
    SandboxOnlyButton.Text = SandboxOnly and "沙盒专属：开启" or "沙盒专属：关闭"
    SandboxOnlyButton.BackgroundColor3 = SandboxOnly
        and Color3.fromRGB(45,125,65)
        or Color3.fromRGB(45,45,45)

    if SandboxOnly then
        SetLocalTexturePatch(false)
    else
        pcall(function()
            local gv = require(ReplicatedStorage.Modules.GameValues)
            if not gv.IsSandbox then
                SetLocalTexturePatch(true)
            end
        end)
    end
end)

-- 沙盒：循环保持交换队伍重生点
local SpawnSwapEnabled = false
local SpawnSwapButton = Button(SettingsPanel,"SpawnSwapToggle",
    "交换队伍重生点：关闭",
    UDim2.new(1,-20,0,36),UDim2.new(0,10,0,88),202)

local function SetSpawnSwap(enabled)
    SpawnSwapEnabled = enabled
    SpawnSwapButton.Text = enabled and "交换队伍重生点：开启" or "交换队伍重生点：关闭"
    SpawnSwapButton.BackgroundColor3 = enabled
        and Color3.fromRGB(45,125,65)
        or Color3.fromRGB(45,45,45)

    if not enabled then
        SetLocalTexturePatch(false)
        pcall(function()
            local gv = require(ReplicatedStorage.Modules.GameValues)
            if gv.IsSandbox and gv.InStage then
                local rf = ReplicatedStorage.Events.RemoteFunction:FindFirstChild("SandboxSettings")
                if rf then rf:InvokeServer("SpawnTeamsSwap", false) end
            end
        end)
    end
end

SpawnSwapButton.MouseButton1Click:Connect(function()
    SetSpawnSwap(not SpawnSwapEnabled)
end)

-- 更新日志入口也放在设置面板内
local UpdateLogButton = Button(SettingsPanel,"UpdateLogButton","更新日志",
    UDim2.new(1,-20,0,34),UDim2.new(0,10,0,131),202)

local UpdateLogFrame = Instance.new("Frame")
UpdateLogFrame.Name = "UpdateLogFrame"
UpdateLogFrame.Size = UDim2.new(0,280,0,220)
UpdateLogFrame.Position = UDim2.new(0.5,-140,0.5,-110)
UpdateLogFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
UpdateLogFrame.BorderSizePixel = 0
UpdateLogFrame.Visible = false
UpdateLogFrame.ZIndex = 400
UpdateLogFrame.Parent = Gui
Corner(UpdateLogFrame,10)

Label(UpdateLogFrame,"LogTitle","更新日志",
    UDim2.new(1,-45,0,35),UDim2.new(0,8,0,5),401)

local CloseLog = Button(UpdateLogFrame,"CloseLog","X",
    UDim2.new(0,35,0,28),UDim2.new(1,-40,0,5),405)

local LogText = Label(UpdateLogFrame,"LogText",
    "当前版本更新\n\n1. 新增设置面板\n2. 新增交换队伍重生点开关（仅沙盒战斗生效）\n3. 更新日志整合到设置面板\n4. 保留原有银行、仓库和卡槽功能",
    UDim2.new(1,-20,1,-50),UDim2.new(0,10,0,42),401)
LogText.TextWrapped = true
LogText.TextYAlignment = Enum.TextYAlignment.Top

UpdateLogButton.MouseButton1Click:Connect(function()
    UpdateLogFrame.Visible = not UpdateLogFrame.Visible
end)
CloseLog.MouseButton1Click:Connect(function()
    UpdateLogFrame.Visible = false
end)

-- PC端卡槽数字键设置
local KeyButtons = {}
if IsPC then
    Label(SettingsPanel,"KeyDescription","卡槽数字键设置：点击按钮轮换数字键",
        UDim2.new(1,-20,0,28),UDim2.new(0,10,0,175),201)

    local function RefreshKeyButtons()
        for i=1,8 do
            KeyButtons[i].Text = "卡槽 "..i.."     数字键 "..SlotKeys[i]
        end
    end

    for i=1,8 do
        local keyButton = Button(SettingsPanel,"Key"..i,"",
            UDim2.new(1,-20,0,27),
            UDim2.new(0,10,0,205+(i-1)*31),202)
        KeyButtons[i] = keyButton

        keyButton.MouseButton1Click:Connect(function()
            local current = SlotKeys[i]
            local nextKey = current % 8 + 1
            local otherSlot
            for j=1,8 do
                if j ~= i and SlotKeys[j] == nextKey then
                    otherSlot = j
                    break
                end
            end
            if otherSlot then SlotKeys[otherSlot] = current end
            SlotKeys[i] = nextKey
            RefreshKeyButtons()
        end)
    end
    RefreshKeyButtons()
end

SettingsButton.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = not SettingsPanel.Visible
end)

-- 每秒检查一次；只有用户开启且处于沙盒战斗时才请求服务器
_G.LYY_SpawnSwap = task.spawn(function()
    while Gui.Parent do
        task.wait(1)
        if SpawnSwapEnabled then
            pcall(function()
                local gv = require(ReplicatedStorage.Modules.GameValues)
                if gv.IsSandbox and gv.InStage then
                    -- 沙盒：调用原本的服务器设置
                    local battle = Player.PlayerGui:FindFirstChild("BattleScreen")
                    local btn = battle and battle:FindFirstChild("SpawnTeamsSwap",true)
                    if not btn or btn:GetAttribute("Enabled") == true then return end
                    local rf = ReplicatedStorage.Events.RemoteFunction:FindFirstChild("SandboxSettings")
                    if not rf then return end
                    if rf:InvokeServer("SpawnTeamsSwap",true) then
                        btn:SetAttribute("Enabled",true)
                        btn.BackgroundColor3 = Color3.fromRGB(100,255,100)
                    end
                elseif not SandboxOnly then
                    -- 非沙盒：只修改本地 Decal / Texture，不调用服务器
                    SetLocalTexturePatch(true)
                end
            end)
        elseif TexturePatched then
            SetLocalTexturePatch(false)
        end
    end
end)

--==================================================
-- PC数字键监听
--==================================================

if IsPC then
    UserInputService.InputBegan:Connect(function(input,gameProcessed)
        if gameProcessed then return end
        if UserInputService:GetFocusedTextBox() then return end
        if SettingsPanel.Visible then return end
        if Warehouse.Visible then return end

        for i=1,8 do
            if input.KeyCode == SlotKeyCodes[SlotKeys[i]] then
                ActivateSlot(i)
                return
            end
        end
    end)
end

--==================================================
-- 银行升级
--==================================================

UpgradeButton.MouseButton1Click:Connect(function()
    if not Running then return end
    if Level >= MaxLevel then return end

    local cost = UpgradeCosts[Level+1]

    if Money >= cost then
        Money -= cost
        Level += 1
        UpdateMoney()
    end
end)

--==================================================
-- 停止
--==================================================

StopButton.MouseButton1Click:Connect(function()
    Running = false
    Level = 0
    Money = 600
    SelectedUnit = nil

    for _,unit in ipairs(Units) do
        unit.Last = nil
    end

    UpdateMoney()
    UpdateSlots()
    UpdateWarehouse()
    UpdateStars()
end)

--==================================================
-- 开始
--==================================================

StartButton.MouseButton1Click:Connect(function()
    if Running then return end

    Running = true
    SelectedUnit = nil

    for _,unit in ipairs(Units) do
        if unit.Name == "粉碎机" then
            unit.Last = os.clock()
        else
            unit.Last = nil
        end
    end

    UpdateMoney()
    UpdateSlots()
    UpdateWarehouse()
    UpdateStars()
end)

--==================================================
-- 隐藏 / 显示
--==================================================

local Hidden = false

local HideButton = Button(Gui,"HideButton","隐藏",
    UDim2.new(0,85,0,35),
    UDim2.new(1,-95,0,135),1000000)

HideButton.MouseButton1Click:Connect(function()
    Hidden = not Hidden

    Bank.Visible = not Hidden
    StartButton.Visible = not Hidden
    StopButton.Visible = not Hidden
    WarehouseButton.Visible = not Hidden
    SlotArea.Visible = not Hidden
    StarFrame.Visible = not Hidden

    if SettingsButton then
        SettingsButton.Visible = not Hidden
    end

    Warehouse.Visible = false

    SettingsPanel.Visible = false
    UpdateLogFrame.Visible = false

    HideButton.Text = Hidden and "显示" or "隐藏"
end)

--==================================================
-- 银行收入
--==================================================

task.spawn(function()
    while Gui.Parent do
        task.wait(0.1)

        if Running then
            Money = math.min(
                MaxMoney,
                Money + 1 + Level*10
            )

            UpdateMoney()
        end
    end
end)

--==================================================
-- 冷却刷新
--==================================================

task.spawn(function()
    while Gui.Parent do
        UpdateSlots()
        task.wait(0.1)
    end
end)

--==================================================
-- 初始化
--==================================================

UpdateMoney()
UpdateSlots()
UpdateWarehouse()
UpdateStars()

print("银行 + 仓库 + 8卡槽 + 星级系统加载完成")
print("单位总数："..#Units)
