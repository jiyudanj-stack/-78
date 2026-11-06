local Players = game:GetService("\080\108\097\121\101\114\115")
local ReplicatedStorage = game:GetService("\082\101\112\108\105\099\097\116\101\100\083\116\111\114\097\103\101")
local UserInputService = game:GetService("\085\115\101\114\073\110\112\117\116\083\101\114\118\105\099\101")

local Player = Players.LocalPlayer
local Event = ReplicatedStorage.Events.RemoteFunction.SandboxSpawn

local IsPC = UserInputService.KeyboardEnabled
    and not UserInputService.TouchEnabled

local Money = 600
local Level = 0
local MaxMoney = 70000
local MaxLevel = 9
local Running = true

local UpgradeCosts = {
    440,880,1320,1760,2200,
    2640,3080,3520,3960
}

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

local Units = {

    {Name="\231\156\159\231\144\134\233\185\136\233\185\149",ID=151,Rank="\066",Amount=8,Price=20000,Cooldown=200,Image=102009551876604,Category="\230\153\174\233\128\154",Args={Health=10000,Damage=2000}},
    {Name="\231\148\159\229\140\150\228\186\186\230\163\141\230\163\146\230\136\152\230\150\151",ID=109,Rank="\066",Amount=8,Price=10000,Cooldown=100,Image=81963847967960,Category="\230\153\174\233\128\154",Args={Health=2800,Damage=95}},
    {Name="\233\187\145\230\154\151\232\189\176\231\130\184\230\156\186\230\136\152\229\163\171",ID=22,Rank="\066",Amount=4,Price=1000,Cooldown=25,Image=93022672755160,Category="\230\153\174\233\128\154",Args={Health=30,Damage=150}},
    {Name="\233\173\148\230\179\149\231\148\159\230\136\144\229\153\168",ID=24,Rank="\066",Amount=4,Price=1600,Cooldown=50,Image=101930259026845,Category="\230\153\174\233\128\154",Args={Health=300,Damage=20}},
    {Name="\231\136\177\229\155\189\232\128\133\229\188\185\229\164\180",ID=108,Rank="\066",Amount=8,Price=15000,Cooldown=300,Image=71963794967775,Category="\230\153\174\233\128\154",Args={Health=4000,Damage=100}},

    {Name="\228\191\157\230\140\129\229\190\174\231\172\145",ID=144,Rank="\065",Amount=2,Price=1000,Cooldown=35,Image=134391460910247,Category="\229\131\181\229\176\184",Args={Health=600}},
    {Name="\230\138\171\232\144\168",ID=136,Rank="\065",Amount=2,Price=500,Cooldown=50,Image=76810868926793,Category="\229\131\181\229\176\184",Args={Health=400,Damage=50}},
    {Name="\228\191\157\230\138\164\229\131\181\229\176\184",ID=135,Rank="\065",Amount=2,Price=900,Cooldown=70,Image=117471233334728,Category="\229\131\181\229\176\184",Args={Health=300,Damage=20}},

    {Name="\232\175\186\230\155\188",ID=104,Rank="\066",Amount=2,Price=800,Cooldown=60,Image=76163313488934,Category="\229\164\169\228\189\191",Args={Health=300,Damage=50}},
    {Name="\229\174\161\229\136\164",ID=115,Rank="\066",Amount=6,Price=2000,Cooldown=50,Image=76008989733506,Category="\229\164\169\228\189\191",Args={Health=300,Damage=60}},
    {Name="\229\133\139\231\189\151\232\175\186\230\150\175",ID=122,Rank="\066",Amount=5,Price=22500,Cooldown=600,Image=125817598848664,Category="\229\164\169\228\189\191",Args={Health=3000,Damage=50}},
    {Name="\080\119\110\115\097\108\111\116",ID=101,Rank="\066",Amount=5,Price=1200,Cooldown=15,Image=100746586925732,Category="\229\164\169\228\189\191",Args={Health=80,Damage=100}},

    {Name="\077\099\066\108\097\115\116",ID=116,Rank="\066",Amount=4,Price=300,Cooldown=30,Image=83665706736688,Category="\230\173\187\228\186\161",Args={Health=60,Damage=20}},
    {Name="\231\178\137\231\162\142\230\156\186",ID=121,Rank="\066",Amount=4,Price=8000,Cooldown=800,Image=132780898159572,Category="\230\173\187\228\186\161",Args={Health=4000,Damage=1000}},
    {Name="\230\158\129\233\153\144",ID=72,Rank="\066",Amount=4,Price=20000,Cooldown=500,Image=90530027731674,Category="\230\173\187\228\186\161",Args={Health=3000,Damage=40}},
    {Name="\229\183\168\233\173\148\232\162\173\229\135\187",ID=105,Rank="\066",Amount=4,Price=200,Cooldown=25,Image=119281801828499,Category="\230\173\187\228\186\161",Args={Health=40,Damage=60}},
    {Name="\230\157\159\231\188\154\231\138\182\230\128\129",ID=69,Rank="\066",Amount=4,Price=1200,Cooldown=20,Image=90355776344408,Category="\230\173\187\228\186\161",Args={Health=40,Damage=100}},
    {Name="\229\143\140\233\187\145\230\154\151\228\185\139\229\191\131",ID=54,Rank="\066",Amount=10,Price=300,Cooldown=10,Image=90816086906198,Category="\230\173\187\228\186\161",Args={Health=50,Damage=20}},
    {Name="\232\180\157\232\146\130",ID=56,Rank="\066",Amount=10,Price=300,Cooldown=15,Image=112152174802483,Category="\230\173\187\228\186\161",Args={Health=60,Damage=30}},
    {Name="\232\161\128\232\167\146",ID=65,Rank="\066",Amount=10,Price=800,Cooldown=20,Image=73907201693668,Category="\230\173\187\228\186\161",Args={Health=200,Damage=30}},
    {Name="\229\142\159\229\173\144",ID=118,Rank="\066",Amount=10,Price=500,Cooldown=20,Image=72643510567320,Category="\230\173\187\228\186\161",Args={Health=50}},
    {Name="\233\161\182\231\186\167",ID=94,Rank="\066",Amount=10,Price=1000,Cooldown=25,Image=103544184383951,Category="\230\173\187\228\186\161",Args={Health=50,Damage=10}},
    {Name="\233\151\170\232\128\128",ID=92,Rank="\066",Amount=2,Price=400,Cooldown=20,Image=78409354291455,Category="\230\173\187\228\186\161",Args={Health=40,Damage=10}},
    {Name="\229\188\185\229\164\180",ID=70,Rank="\066",Amount=4,Price=1000,Cooldown=100,Image=98839631179168,Category="\230\173\187\228\186\161",Args={Health=400,Damage=100}},

    {Name="\229\156\176\231\139\177",ID=39,Rank="\066",Amount=8,Price=2000,Cooldown=50,Image=113366045982105,Category="\229\156\176\231\139\177",Args={Health=600,Damage=20}},
    {Name="\229\164\169\230\137\141",ID=89,Rank="\066",Amount=4,Price=1200,Cooldown=60,Image=139624564209954,Category="\229\156\176\231\139\177",Args={Health=60}},
    {Name="\231\150\175\231\139\130\229\140\150\229\173\166\229\174\182",ID=60,Rank="\066",Amount=4,Price=3000,Cooldown=100,Image=134686338431581,Category="\229\156\176\231\139\177",Args={Health=200,Damage=75}},
    {Name="\083\112\101\101\100\100\101\109\111\110",ID=150,Rank="\066",Amount=4,Price=2400,Cooldown=70,Image=73440841269995,Category="\229\156\176\231\139\177",Args={Health=100,Damage=60}},
    {Name="\231\155\190\231\137\140\230\136\152\229\163\171",ID=29,Rank="\066",Amount=4,Price=300,Cooldown=30,Image=87500073270346,Category="\229\156\176\231\139\177",Args={Health=90,Damage=0}},
    {Name="\229\144\137\228\187\150\232\139\177\233\155\132",ID=35,Rank="\066",Amount=4,Price=2000,Cooldown=100,Image=117913123207840,Category="\229\156\176\231\139\177",Args={Health=60}},
    {Name="\229\156\176\231\139\177\231\129\171",ID=40,Rank="\066",Amount=4,Price=12000,Cooldown=500,Image=95516325060350,Category="\229\156\176\231\139\177",Args={Health=6000,Damage=20}},
    {Name="\233\155\135\228\189\163\229\133\181",ID=32,Rank="\066",Amount=5,Price=300,Cooldown=10,Image=121186955802358,Category="\229\156\176\231\139\177",Args={Health=60,Damage=6}},
    {Name="\231\147\182\232\163\133",ID=88,Rank="\066",Amount=8,Price=600,Cooldown=15,Image=109161080608846,Category="\229\156\176\231\139\177",Args={Health=80,Damage=15}}
}

local Slots = {}
local SlotCards = {}
local WarehouseCards = {}
local SelectedUnit = nil

for i=1,8 do
    Slots[i] = {Unit=nil}
end

local Gui = Instance.new("\083\099\114\101\101\110\071\117\105")
Gui.Name = "\066\097\110\107\065\110\100\073\110\118\101\110\116\111\114\121"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
Gui.Parent = Player:WaitForChild("\080\108\097\121\101\114\071\117\105")

local function Corner(obj,radius)
    local c = Instance.new("\085\073\067\111\114\110\101\114")
    c.CornerRadius = UDim.new(0,radius or 7)
    c.Parent = obj
end

local function Button(parent,name,text,size,pos,z)
    local b = Instance.new("\084\101\120\116\066\117\116\116\111\110")
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
    local l = Instance.new("\084\101\120\116\076\097\098\101\108")
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

local Bank = Instance.new("\070\114\097\109\101")
Bank.Name = "\066\097\110\107"
Bank.Size = UDim2.new(0,230,0,155)
Bank.Position = UDim2.new(0,15,0,45)
Bank.BackgroundColor3 = Color3.fromRGB(20,20,20)
Bank.BorderSizePixel = 0
Bank.ZIndex = 100
Bank.Parent = Gui
Corner(Bank,10)

Label(Bank,"\084\105\116\108\101","\233\147\182\232\161\140",
    UDim2.new(1,0,0,30),
    UDim2.new(0,0,0,3))

local MoneyLabel = Label(Bank,"\077\111\110\101\121","\232\181\132\233\135\145\239\188\154\054\048\048",
    UDim2.new(1,-10,0,28),
    UDim2.new(0,5,0,35))

local LevelLabel = Label(Bank,"\076\101\118\101\108","\231\173\137\231\186\167\239\188\154\048",
    UDim2.new(1,-10,0,25),
    UDim2.new(0,5,0,65))

local UpgradeButton = Button(Bank,"\085\112\103\114\097\100\101","\229\141\135\231\186\167\233\147\182\232\161\140",
    UDim2.new(0.94,0,0,35),
    UDim2.new(0.03,0,0,105))

local function UpdateMoney()
    MoneyLabel.Text = "\232\181\132\233\135\145\239\188\154"..math.floor(Money)
    LevelLabel.Text = "\231\173\137\231\186\167\239\188\154"..Level

    if Level >= MaxLevel then
        UpgradeButton.Text = "\231\173\137\231\186\167\229\183\178\230\187\161"
    else
        UpgradeButton.Text = "\229\141\135\231\186\167\239\188\154"..UpgradeCosts[Level+1]
    end
end

local StartButton = Button(Gui,"\083\116\097\114\116","\229\188\128\229\167\139",
    UDim2.new(0,85,0,38),
    UDim2.new(1,-190,0,45))

local StopButton = Button(Gui,"\083\116\111\112","\229\129\156\230\173\162",
    UDim2.new(0,85,0,38),
    UDim2.new(1,-95,0,45))

local WarehouseButton = Button(Gui,"\087\097\114\101\104\111\117\115\101\066\117\116\116\111\110","\228\187\147\229\186\147",
    UDim2.new(0,85,0,38),
    UDim2.new(1,-95,0,90))

local SlotArea = Instance.new("\070\114\097\109\101")
SlotArea.Name = "\069\113\117\105\112\109\101\110\116\083\108\111\116\115"
SlotArea.Size = UDim2.new(0.54,0,0,112)
SlotArea.Position = UDim2.new(0.5,0,1,-115)
SlotArea.AnchorPoint = Vector2.new(0.5,0)
SlotArea.BackgroundTransparency = 1
SlotArea.ZIndex = 100
SlotArea.Parent = Gui

local SlotGrid = Instance.new("\085\073\071\114\105\100\076\097\121\111\117\116")
SlotGrid.CellSize = UDim2.new(0.235,0,0,48)
SlotGrid.CellPadding = UDim2.new(0.01,0,0,6)
SlotGrid.FillDirectionMaxCells = 4
SlotGrid.SortOrder = Enum.SortOrder.LayoutOrder
SlotGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
SlotGrid.VerticalAlignment = Enum.VerticalAlignment.Center
SlotGrid.Parent = SlotArea

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
            data.Icon.Image = "\114\098\120\097\115\115\101\116\105\100\058\047\047"..unit.Image
            data.Icon.Visible = true
            data.NameText.Text = unit.Name
            data.NameText.Visible = true
            data.PriceText.Text = "\036"..GetUnitPrice(unit)
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

local Warehouse = Instance.new("\070\114\097\109\101")
Warehouse.Name = "\087\097\114\101\104\111\117\115\101\080\097\110\101\108"
Warehouse.Size = UDim2.new(0,370,0,420)
Warehouse.Position = UDim2.new(0.5,-185,0.5,-210)
Warehouse.BackgroundColor3 = Color3.fromRGB(20,20,20)
Warehouse.BorderSizePixel = 0
Warehouse.Visible = false
Warehouse.ZIndex = 120
Warehouse.Parent = Gui
Corner(Warehouse,10)

local WarehouseScale = Instance.new("\085\073\083\099\097\108\101")
WarehouseScale.Scale = 1
WarehouseScale.Parent = Warehouse

Label(Warehouse,"\084\105\116\108\101","\229\141\149\228\189\141\228\187\147\229\186\147",
    UDim2.new(0.7,0,0,35),
    UDim2.new(0,5,0,3),121)

local CloseButton = Button(Warehouse,"\067\108\111\115\101","\088",
    UDim2.new(0,35,0,30),
    UDim2.new(1,-42,0,5),130)

CloseButton.MouseButton1Click:Connect(function()
    Warehouse.Visible = false
end)

WarehouseButton.MouseButton1Click:Connect(function()
    Warehouse.Visible = not Warehouse.Visible
end)

local ScaleButton = Button(Warehouse,"\083\099\097\108\101\066\117\116\116\111\110","\226\136\146",
    UDim2.new(0,32,0,30),
    UDim2.new(1,-80,0,5),130)

local IsSmall = false

ScaleButton.MouseButton1Click:Connect(function()
    IsSmall = not IsSmall
    WarehouseScale.Scale = IsSmall and 0.75 or 1
    ScaleButton.Text = IsSmall and "\043" or "\226\136\146"
end)

local DragBar = Instance.new("\084\101\120\116\066\117\116\116\111\110")
DragBar.Name = "\068\114\097\103\066\097\114"
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

local Categories = {
    "\229\133\168\233\131\168","\230\153\174\233\128\154","\229\156\176\231\139\177","\230\173\187\228\186\161","\229\164\169\228\189\191","\229\131\181\229\176\184"
}

local CurrentCategory = "\229\133\168\233\131\168"
local CurrentRank = "\229\133\168\233\131\168"

local CategoryFrame = Instance.new("\070\114\097\109\101")
CategoryFrame.Size = UDim2.new(1,-10,0,32)
CategoryFrame.Position = UDim2.new(0,5,0,42)
CategoryFrame.BackgroundTransparency = 1
CategoryFrame.ZIndex = 121
CategoryFrame.Parent = Warehouse

local CategoryGrid = Instance.new("\085\073\071\114\105\100\076\097\121\111\117\116")
CategoryGrid.CellSize = UDim2.new(1/6,-3,1,0)
CategoryGrid.CellPadding = UDim2.new(0,2,0,0)
CategoryGrid.Parent = CategoryFrame

local CategoryButtons = {}

local RankFrame = Instance.new("\070\114\097\109\101")
RankFrame.Size = UDim2.new(1,-10,0,30)
RankFrame.Position = UDim2.new(0,5,0,78)
RankFrame.BackgroundTransparency = 1
RankFrame.ZIndex = 121
RankFrame.Parent = Warehouse

local RankA = Button(RankFrame,"\082\097\110\107\065","\065",
    UDim2.new(0.5,-3,1,0),
    UDim2.new(0,0,0,0),122)

local RankB = Button(RankFrame,"\082\097\110\107\066","\066",
    UDim2.new(0.5,-3,1,0),
    UDim2.new(0.5,3,0,0),122)

local Scroll = Instance.new("\083\099\114\111\108\108\105\110\103\070\114\097\109\101")
Scroll.Name = "\085\110\105\116\076\105\115\116"
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

local WarehouseGrid = Instance.new("\085\073\071\114\105\100\076\097\121\111\117\116")
WarehouseGrid.CellSize = UDim2.new(0,75,0,75)
WarehouseGrid.CellPadding = UDim2.new(0,7,0,7)
WarehouseGrid.SortOrder = Enum.SortOrder.LayoutOrder
WarehouseGrid.Parent = Scroll

local EmptyLabel = Label(Warehouse,"\069\109\112\116\121","\230\178\161\230\156\137\231\172\166\229\144\136\230\157\161\228\187\182\231\154\132\229\141\149\228\189\141",
    UDim2.new(1,-20,0,50),
    UDim2.new(0,10,0,250),140)

EmptyLabel.Visible = false

local function IsUnitEquipped(unit)
    for _,slot in ipairs(Slots) do
        if slot.Unit == unit then
            return true
        end
    end

    return false
end

local function UpdateWarehouse()
    for _,card in ipairs(WarehouseCards) do
        card:Destroy()
    end

    table.clear(WarehouseCards)

    local count = 0

    for _,unit in ipairs(Units) do
        local categoryMatch =
            CurrentCategory == "\229\133\168\233\131\168"
            or unit.Category == CurrentCategory

        local rankMatch =
            CurrentRank == "\229\133\168\233\131\168"
            or unit.Rank == CurrentRank

        if categoryMatch and rankMatch then
            count += 1

            local equipped = IsUnitEquipped(unit)

            local card = Button(Scroll,unit.Name,"",
                UDim2.new(0,75,0,75),
                UDim2.new(0,0,0,0),122)

            local icon = Instance.new("\073\109\097\103\101\076\097\098\101\108")
            icon.Name = "\085\110\105\116\073\109\097\103\101"
            icon.Size = UDim2.new(1,0,1,0)
            icon.BackgroundTransparency = 1
            icon.Image = "\114\098\120\097\115\115\101\116\105\100\058\047\047"..unit.Image
            icon.ScaleType = Enum.ScaleType.Fit
            icon.ZIndex = 123
            icon.Parent = card
            Corner(icon,8)

            if equipped then
                card.BackgroundColor3 = Color3.fromRGB(65,65,65)

                local mask = Instance.new("\070\114\097\109\101")
                mask.Size = UDim2.new(1,0,1,0)
                mask.BackgroundColor3 = Color3.new(0,0,0)
                mask.BackgroundTransparency = 0.45
                mask.BorderSizePixel = 0
                mask.ZIndex = 125
                mask.Parent = card
                Corner(mask,8)

                Label(mask,"\069\113\117\105\112\112\101\100","\229\183\178\232\163\133\229\164\135",
                    UDim2.new(1,0,0,25),
                    UDim2.new(0,0,0.5,-12),126)
            end

            if SelectedUnit == unit thenlocal stroke = Instance.new("\085\073\083\116\114\111\107\101")
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

CategoryButtons["\229\133\168\233\131\168"].BackgroundColor3 =
    Color3.fromRGB(40,130,70)

RankA.MouseButton1Click:Connect(function()
    CurrentRank = CurrentRank == "\065" and "\229\133\168\233\131\168" or "\065"

    RankA.BackgroundColor3 =
        CurrentRank == "\065"
        and Color3.fromRGB(40,130,70)
        or Color3.fromRGB(45,45,45)

    RankB.BackgroundColor3 = Color3.fromRGB(45,45,45)

    UpdateWarehouse()
end)

RankB.MouseButton1Click:Connect(function()
    CurrentRank = CurrentRank == "\066" and "\229\133\168\233\131\168" or "\066"

    RankB.BackgroundColor3 =
        CurrentRank == "\066"
        and Color3.fromRGB(40,130,70)
        or Color3.fromRGB(45,45,45)

    RankA.BackgroundColor3 = Color3.fromRGB(45,45,45)

    UpdateWarehouse()
end)

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
                "\069\110\101\109\121",
                unit.ID,
                unit.Rank,
                unit.Amount,
                GetScaledArgs(unit)
            )
        end)

        if not success then
            warn("\229\143\172\229\148\164\229\164\177\232\180\165\239\188\154",err)
        end
    end)
end

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

for i=1,8 do
    local card = Button(SlotArea,"\083\108\111\116"..i,"",
        UDim2.new(0,0,0,0),
        UDim2.new(0,0,0,0),101)

    card.LayoutOrder = i
    card.BackgroundColor3 = Color3.fromRGB(20,35,50)

    local border = Instance.new("\085\073\083\116\114\111\107\101")
    border.Color = Color3.fromRGB(0,190,220)
    border.Thickness = 2
    border.Parent = card

    local icon = Instance.new("\073\109\097\103\101\076\097\098\101\108")
    icon.Name = "\073\099\111\110"
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Crop
    icon.Visible = false
    icon.ZIndex = 102
    icon.Parent = card
    Corner(icon,7)

    local nameText = Label(card,"\078\097\109\101\084\101\120\116","",
        UDim2.new(1,0,0,15),
        UDim2.new(0,0,0,0),107)
    nameText.BackgroundColor3 = Color3.fromRGB(0,0,0)
    nameText.BackgroundTransparency = 0.25
    nameText.TextColor3 = Color3.new(1,1,1)
    nameText.Visible = false

    local priceText = Instance.new("\084\101\120\116\076\097\098\101\108")
    priceText.Name = "\080\114\105\099\101\084\101\120\116"
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

    local cooldownMask = Instance.new("\070\114\097\109\101")
    cooldownMask.Name = "\067\111\111\108\100\111\119\110\077\097\115\107"
    cooldownMask.Size = UDim2.new(1,0,1,0)
    cooldownMask.BackgroundColor3 = Color3.fromRGB(0,0,0)
    cooldownMask.BackgroundTransparency = 0.48
    cooldownMask.BorderSizePixel = 0
    cooldownMask.ClipsDescendants = true
    cooldownMask.Visible = false
    cooldownMask.ZIndex = 104
    cooldownMask.Parent = card
    Corner(cooldownMask,7)

    local cooldownFill = Instance.new("\070\114\097\109\101")
    cooldownFill.Size = UDim2.new(1,0,1,0)
    cooldownFill.BackgroundColor3 = Color3.fromRGB(130,130,130)
    cooldownFill.BackgroundTransparency = 0.25
    cooldownFill.BorderSizePixel = 0
    cooldownFill.ZIndex = 105
    cooldownFill.Parent = cooldownMask

    local cooldownText = Label(cooldownMask,"\067\111\111\108\100\111\119\110\084\101\120\116","",
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

local SettingsButton = Button(Gui,"\083\101\116\116\105\110\103\115\066\117\116\116\111\110","\232\174\190\231\189\174",
    UDim2.new(0,85,0,35),
    UDim2.new(1,-185,0,90),1000)

local SettingsPanel = Instance.new("\070\114\097\109\101")
SettingsPanel.Name = "\083\101\116\116\105\110\103\115\080\097\110\101\108"
SettingsPanel.Size = UDim2.new(0,300,0,520)
SettingsPanel.Position = UDim2.new(0.5,-150,0.5,-260)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(20,20,20)
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Visible = false
SettingsPanel.ZIndex = 200
SettingsPanel.Parent = Gui
Corner(SettingsPanel,10)

Label(SettingsPanel,"\084\105\116\108\101","\232\174\190\231\189\174",
    UDim2.new(1,-45,0,38),UDim2.new(0,8,0,5),201)

local CloseSettings = Button(SettingsPanel,"\067\108\111\115\101\083\101\116\116\105\110\103\115","\088",
    UDim2.new(0,35,0,30),UDim2.new(1,-40,0,5),205)

CloseSettings.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = false
end)

local StarColors = {
    Color3.fromRGB(0,190,255),
    Color3.fromRGB(255,160,0),
    Color3.fromRGB(255,45,45)
}

local function SetStarLevel(level)
    if Running then return end
    if not StarMultipliers[level] then return end

    StarLevel = level
    MaxMoney = 70000
    Money = math.min(Money,MaxMoney)

    UpdateStars()
    UpdateMoney()
    UpdateSlots()
    UpdateWarehouse()
end

for i=1,3 do
    local button = Button(
        SettingsPanel,
        "\083\116\097\114"..i,
        string.rep("\226\152\133",i),
        UDim2.new(0,85,0,38),
        UDim2.new(0,10+(i-1)*95,0,48),
        202
    )

    button.BackgroundColor3 = StarColors[i]
    StarButtons[i] = button

    button.MouseButton1Click:Connect(function()
        SetStarLevel(i)
    end)
end

local SandboxOnly = true
local SpawnSwapEnabled = false

local TextureAsset = "\114\098\120\097\115\115\101\116\105\100\058\047\047\049\049\052\053\048\052\048\057\051\048\048\051\056\057\055"
local OriginalTextures = {}
local TexturePatched = false

local function PatchOneTexture(obj)
    if not TexturePatched then return end
    if not (obj:IsA("\068\101\099\097\108") or obj:IsA("\084\101\120\116\117\114\101")) then return end
    if OriginalTextures[obj] ~= nil then return end

    local ok,oldTexture = pcall(function()
        return obj.Texture
    end)

    if not ok then return end

    OriginalTextures[obj] = oldTexture

    pcall(function()
        obj.Texture = TextureAsset
    end)
end

local function SetLocalTexturePatch(enabled)
    if enabled and not TexturePatched then
        TexturePatched = true
        table.clear(OriginalTextures)

        for _,obj in ipairs(workspace:GetDescendants()) do
            PatchOneTexture(obj)
        end

    elseif not enabled and TexturePatched then
        TexturePatched = false

        for obj,oldTexture in pairs(OriginalTextures) do
            if obj and obj.Parent then
                pcall(function()
                    obj.Texture = oldTexture
                end)
            end
        end

        table.clear(OriginalTextures)
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if TexturePatched then
        PatchOneTexture(obj)
    end
end)

local SandboxOnlyButton = Button(
    SettingsPanel,
    "\083\097\110\100\098\111\120\079\110\108\121\084\111\103\103\108\101",
    "\230\178\153\231\155\146\228\184\147\229\177\158\239\188\154\229\188\128\229\144\175",
    UDim2.new(1,-20,0,34),
    UDim2.new(0,10,0,96),
    202
)

local SpawnSwapButton = Button(
    SettingsPanel,
    "\083\112\097\119\110\083\119\097\112\084\111\103\103\108\101",
    "\228\186\164\230\141\162\233\152\159\228\188\141\233\135\141\231\148\159\231\130\185\239\188\154\229\133\179\233\151\173",
    UDim2.new(1,-20,0,36),
    UDim2.new(0,10,0,137),
    202
)

local function UpdateSandboxButtons()
    SandboxOnlyButton.Text =
        SandboxOnly and "\230\178\153\231\155\146\228\184\147\229\177\158\239\188\154\229\188\128\229\144\175" or "\230\178\153\231\155\146\228\184\147\229\177\158\239\188\154\229\133\179\233\151\173"

    SandboxOnlyButton.BackgroundColor3 =
        SandboxOnly
        and Color3.fromRGB(45,125,65)
        or Color3.fromRGB(45,45,45)

    SpawnSwapButton.Text =
        SpawnSwapEnabled
        and "\228\186\164\230\141\162\233\152\159\228\188\141\233\135\141\231\148\159\231\130\185\239\188\154\229\188\128\229\144\175"
        or "\228\186\164\230\141\162\233\152\159\228\188\141\233\135\141\231\148\159\231\130\185\239\188\154\229\133\179\233\151\173"

    SpawnSwapButton.BackgroundColor3 =
        SpawnSwapEnabled
        and Color3.fromRGB(45,125,65)
        or Color3.fromRGB(45,45,45)
end

UpdateSandboxButtons()

SandboxOnlyButton.MouseButton1Click:Connect(function()
    SandboxOnly = not SandboxOnly
    UpdateSandboxButtons()

    if SandboxOnly then
        SetLocalTexturePatch(false)
    end
end)

local SpawnSwapApplied = false

local function GetSandboxSettingsRemote()
    local events = ReplicatedStorage:FindFirstChild("\069\118\101\110\116\115")
    local remoteFolder = events and events:FindFirstChild("\082\101\109\111\116\101\070\117\110\099\116\105\111\110")
    local remote = remoteFolder and remoteFolder:FindFirstChild("\083\097\110\100\098\111\120\083\101\116\116\105\110\103\115")

    if remote and remote:IsA("\082\101\109\111\116\101\070\117\110\099\116\105\111\110") then
        return remote
    end

    return nil
end

local function ApplySpawnSwap(enabled)
    if enabled == SpawnSwapApplied then
        return
    end

    local remote = GetSandboxSettingsRemote()
    if not remote then return end

    local success,result = pcall(function()
        return remote:InvokeServer("\083\112\097\119\110\084\101\097\109\115\083\119\097\112",enabled)
    end)

    if success and result ~= false then
        SpawnSwapApplied = enabled
    elseif not success then
        warn("\228\186\164\230\141\162\233\152\159\228\188\141\233\135\141\231\148\159\231\130\185\232\174\190\231\189\174\229\164\177\232\180\165\239\188\154",result)
    end
end

local function SetSpawnSwap(enabled)
    SpawnSwapEnabled = enabled
    UpdateSandboxButtons()

    if not enabled then
        ApplySpawnSwap(false)
        SetLocalTexturePatch(false)
    end
end

SpawnSwapButton.MouseButton1Click:Connect(function()
    SetSpawnSwap(not SpawnSwapEnabled)
end)

local UpdateLogButton = Button(
    SettingsPanel,
    "\085\112\100\097\116\101\076\111\103\066\117\116\116\111\110",
    "\230\155\180\230\150\176\230\151\165\229\191\151",
    UDim2.new(1,-20,0,34),
    UDim2.new(0,10,0,180),
    202
)

local UpdateLogFrame = Instance.new("\070\114\097\109\101")
UpdateLogFrame.Name = "\085\112\100\097\116\101\076\111\103\070\114\097\109\101"
UpdateLogFrame.Size = UDim2.new(0,280,0,220)
UpdateLogFrame.Position = UDim2.new(0.5,-140,0.5,-110)
UpdateLogFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
UpdateLogFrame.BorderSizePixel = 0
UpdateLogFrame.Visible = false
UpdateLogFrame.ZIndex = 400
UpdateLogFrame.Parent = Gui
Corner(UpdateLogFrame,10)

Label(UpdateLogFrame,"\076\111\103\084\105\116\108\101","\230\155\180\230\150\176\230\151\165\229\191\151",
    UDim2.new(1,-45,0,35),UDim2.new(0,8,0,5),401)

local CloseLog = Button(UpdateLogFrame,"\067\108\111\115\101\076\111\103","\088",
    UDim2.new(0,35,0,28),UDim2.new(1,-40,0,5),405)

local LogText = Label(
    UpdateLogFrame,
    "\076\111\103\084\101\120\116",
    "\229\189\147\229\137\141\231\137\136\230\156\172\230\155\180\230\150\176\010\010"
    .."\049\046\032\230\152\159\231\186\167\233\128\137\230\139\169\231\167\187\229\133\165\232\174\190\231\189\174\233\157\162\230\157\191\010"
    .."\050\046\032\228\184\128\230\152\159\227\128\129\228\186\140\230\152\159\227\128\129\228\184\137\230\152\159\229\177\158\230\128\167\229\128\141\231\142\135\228\184\186\032\195\151\049\227\128\129\195\151\050\227\128\129\195\151\051\010"
    .."\051\046\032\230\137\128\230\156\137\230\152\159\231\186\167\232\181\132\233\135\145\228\184\138\233\153\144\232\176\131\230\149\180\228\184\186\032\055\048\048\048\048\010"
    .."\052\046\032\230\178\153\231\155\146\231\138\182\230\128\129\230\140\129\231\187\173\230\163\128\230\181\139\010"
    .."\053\046\032\230\178\153\231\155\146\228\184\147\229\177\158\228\184\142\228\186\164\230\141\162\233\152\159\228\188\141\233\135\141\231\148\159\231\130\185\232\129\148\229\138\168\010"
    .."\054\046\032\228\191\157\231\149\153\233\147\182\232\161\140\227\128\129\228\187\147\229\186\147\229\146\140\056\228\184\170\232\163\133\229\164\135\229\141\161\230\167\189",
    UDim2.new(1,-20,1,-50),
    UDim2.new(0,10,0,42),
    401
)

LogText.TextWrapped = true
LogText.TextYAlignment = Enum.TextYAlignment.Top

UpdateLogButton.MouseButton1Click:Connect(function()
    UpdateLogFrame.Visible = not UpdateLogFrame.Visible
end)

CloseLog.MouseButton1Click:Connect(function()
    UpdateLogFrame.Visible = false
end)

local KeyButtons = {}

if IsPC then
    Label(
        SettingsPanel,
        "\075\101\121\068\101\115\099\114\105\112\116\105\111\110",
        "\229\141\161\230\167\189\230\149\176\229\173\151\233\148\174\232\174\190\231\189\174\239\188\154\231\130\185\229\135\187\230\140\137\233\146\174\232\189\174\230\141\162\230\149\176\229\173\151\233\148\174",
        UDim2.new(1,-20,0,28),
        UDim2.new(0,10,0,220),
        201
    )

    local function RefreshKeyButtons()
        for i=1,8 do
            KeyButtons[i].Text =
                "\229\141\161\230\167\189\032"..i.."\032\032\032\032\032\230\149\176\229\173\151\233\148\174\032"..SlotKeys[i]
        end
    end

    for i=1,8 do
        local keyButton = Button(
            SettingsPanel,
            "\075\101\121"..i,
            "",
            UDim2.new(1,-20,0,27),
            UDim2.new(0,10,0,250+(i-1)*31),
            202
        )

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

            if otherSlot then
                SlotKeys[otherSlot] = current
            end

            SlotKeys[i] = nextKey
            RefreshKeyButtons()
        end)
    end

    RefreshKeyButtons()
end

SettingsButton.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = not SettingsPanel.Visible
end)

task.spawn(function()
    while Gui.Parent do
        local stateOK,gameValues = pcall(function()
            return require(ReplicatedStorage.Modules.GameValues)
        end)

        if stateOK and type(gameValues) == "\116\097\098\108\101" then
            local isSandbox = gameValues.IsSandbox == true
            local inStage = gameValues.InStage == true

            if SpawnSwapEnabled and isSandbox and inStage then

                SetLocalTexturePatch(false)
                ApplySpawnSwap(true)
            else

                ApplySpawnSwap(false)

                if SpawnSwapEnabled and not isSandbox and not SandboxOnly then
                    SetLocalTexturePatch(true)
                else
                    SetLocalTexturePatch(false)
                end
            end
        else

            SetLocalTexturePatch(false)
            ApplySpawnSwap(false)
        end

        task.wait(1)
    end

    SetLocalTexturePatch(false)
    ApplySpawnSwap(false)
end)

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

StopButton.MouseButton1Click:Connect(function()
    Running = false
    Level = 0
    Money = 600
    MaxMoney = 70000
    SelectedUnit = nil

    for _,unit in ipairs(Units) do
        unit.Last = nil
    end

    UpdateMoney()
    UpdateSlots()
    UpdateWarehouse()
    UpdateStars()
end)

StartButton.MouseButton1Click:Connect(function()
    if Running then return end

    Running = true
    SelectedUnit = nil

    for _,unit in ipairs(Units) do
        if unit.Name == "\231\178\137\231\162\142\230\156\186" then
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

local Hidden = false

local HideButton = Button(Gui,"\072\105\100\101\066\117\116\116\111\110","\233\154\144\232\151\143",
    UDim2.new(0,85,0,35),
    UDim2.new(1,-95,0,135),1000000)
HideButton.ZIndex = 1000000

HideButton.MouseButton1Click:Connect(function()
    Hidden = not Hidden

    Bank.Visible = not Hidden
    StartButton.Visible = not Hidden
    StopButton.Visible = not Hidden
    WarehouseButton.Visible = not Hidden
    SlotArea.Visible = not Hidden

    if SettingsButton then
        SettingsButton.Visible = not Hidden
    end

    Warehouse.Visible = false

    SettingsPanel.Visible = false
    UpdateLogFrame.Visible = false

    HideButton.Text = Hidden and "\230\152\190\231\164\186" or "\233\154\144\232\151\143"
end)

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

task.spawn(function()
    while Gui.Parent do
        UpdateSlots()
        task.wait(0.1)
    end
end)

UpdateMoney()
UpdateSlots()
UpdateWarehouse()
UpdateStars()

print("\233\147\182\232\161\140\032\043\032\228\187\147\229\186\147\032\043\032\056\229\141\161\230\167\189\032\043\032\230\152\159\231\186\167\231\179\187\231\187\159\229\138\160\232\189\189\229\174\140\230\136\144")
print("\229\141\149\228\189\141\230\128\187\230\149\176\239\188\154"..#Units)
