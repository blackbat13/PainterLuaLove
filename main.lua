------------ INITIALIZATION ------------

function love.load()
    math.randomseed(os.time())

    Const = {width = 1000, height = 1000, margin = 50, framerate = 60}
    Timer = {elapsed = 0, value = 60}
    Winner = ""
    Settings = {sounds = true, music = true}

    InitColorCanvas()
    InitPlayers()
    InitFonts()
    InitGameState()
    InitItem()
    InitMusic()
    InitSounds()
    InitButtons()
end

function InitColorCanvas()
    ColorCanvas = love.graphics.newCanvas(Const.width, Const.height)
    love.graphics.setCanvas(ColorCanvas)
    love.graphics.clear()
    love.graphics.setCanvas()
end

function InitPlayers()
    Blue = {
        drawable = love.graphics.newImage("images/blue.png"),
        name = "Blue",
        color = {33, 132, 211, 255},
        keys = {left = "q", right = "e", power = "w"}
    }

    Red = {
        drawable = love.graphics.newImage("images/red.png"),
        name = "Red",
        color = {221, 78, 84, 255},
        keys = {left = "i", right = "p", power = "o"}
    }

    Green = {
        drawable = love.graphics.newImage("images/green.png"),
        name = "Green",
        color = {73, 180, 126, 255},
        keys = {left = "z", right = "c", power = "x"}
    }

    Grey = {
        drawable = love.graphics.newImage("images/grey.png"),
        name = "Grey",
        color = {147, 127, 124, 255},
        keys = {left = "left", right = "right", power = "up"}
    }

    Players = {Blue, Green, Red, Grey}
end

function InitFonts()
    Fonts = {
        timer = love.graphics.newFont("fonts/kenney_bold.ttf", 50),
        results = love.graphics.newFont("fonts/kenney_future_square.ttf", 60),
        winner = love.graphics.newFont("fonts/kenney_bold.ttf", 110),
        button = love.graphics.newFont("fonts/kenney_bold.ttf", 25),
        menu = love.graphics.newFont("fonts/kenney_future_square.ttf", 40)
    }
end

function InitGameState()
    GameStateEnum = {Menu = 1, Playing = 2, End = 3}
    GameState = GameStateEnum.Menu
end

function InitItem()
    ItemTypeEnum = {Bomb = 1, Coin = 2, Gem = 3, Star = 4}

    ItemTypes = {
        {drawable = love.graphics.newImage("images/bomb.png"), type = ItemTypeEnum.Bomb},
        {drawable = love.graphics.newImage("images/coin.png"), type = ItemTypeEnum.Coin},
        -- {drawable = love.graphics.newImage("images/gem.png"), type = ItemTypeEnum.Gem},
        {drawable = love.graphics.newImage("images/star.png"), type = ItemTypeEnum.Star}
    }

    Item = {
        drawable = ItemTypes[1].drawable,
        type = ItemTypes[1].type,
        x = 0,
        y = 0,
        time = Const.framerate * 2,
        active = false
    }
end

function InitMusic()
    Music = {
        menu = love.audio.newSource("music/menu.ogg", "stream"),
        game = love.audio.newSource("music/game.ogg", "stream"),
        results = love.audio.newSource("music/results.ogg", "stream")
    }

    Music.menu:setLooping(true)
    Music.game:setLooping(true)
    Music.results:setLooping(true)

    love.audio.play(Music.menu)
end

function InitSounds()
    Sounds = {
        item = {
            coin = love.audio.newSource("sounds/coin.ogg", "static"),
            bomb = love.audio.newSource("sounds/explosion.ogg", "static"),
            star = love.audio.newSource("sounds/star.ogg", "static")
        },
        number = {
            love.audio.newSource("sounds/one.ogg", "static"),
            love.audio.newSource("sounds/two.ogg", "static"),
            love.audio.newSource("sounds/three.ogg", "static"),
            love.audio.newSource("sounds/four.ogg", "static"),
            love.audio.newSource("sounds/five.ogg", "static"),
            love.audio.newSource("sounds/six.ogg", "static"),
            love.audio.newSource("sounds/seven.ogg", "static"),
            love.audio.newSource("sounds/eight.ogg", "static"),
            love.audio.newSource("sounds/nine.ogg", "static"),
            love.audio.newSource("sounds/ten.ogg", "static")
        },
        timeOver = love.audio.newSource("sounds/time_over.ogg", "static"),
        impact = love.audio.newSource("sounds/impact.ogg", "static"),
        hurryUp = love.audio.newSource("sounds/hurry_up.ogg", "static")
    }
end

function InitButtons()
    StartButton = {
        x = Const.width / 2,
        y = Const.height - 50,
        xOffset = 190 /2,
        yOffset = 49 / 2,
        width = 190,
        height = 49,
        drawable = {
            standard = love.graphics.newImage("images/button.png"),
            hover = love.graphics.newImage("images/button_hover.png")
        }
    }
end

------------ DRAW ------------

function love.draw()
    if GameState == GameStateEnum.Playing or GameState == GameStateEnum.End then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(ColorCanvas)
        DrawPlayers()
        DrawItem()
        DrawTimer()
    end
    
    if GameState == GameStateEnum.Menu then
        DrawMenu()
        DrawStartButton()
    end

    if GameState == GameStateEnum.End then
        DrawResults()
        DrawStartButton()
    end
end

function DrawCenteredText(x, y, text, font)
	local textWidth  = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print(text, font, x, y, 0, 1, 1, textWidth/2, textHeight/2)
end

function DrawPlayers()
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, #(Players) do
        if Players[i].power then
            love.graphics.circle("fill", Players[i].x, Players[i].y, 25)
        end

        love.graphics.draw(Players[i].drawable, Players[i].x, Players[i].y, math.rad(Players[i].angle), 1, 1, 20, 20)
    end
end

function DrawItem()
    love.graphics.setColor(1, 1, 1, 1)
    if Item.active then
        love.graphics.draw(Item.drawable, Item.x, Item.y, 0, 1, 1, 35, 35)
    end
end

function DrawTimer()
    love.graphics.setColor(love.math.colorFromBytes(235, 238, 11))
    DrawCenteredText(Const.width / 2, Const.margin, Timer.value, Fonts.timer)
end

function DrawResults()
    love.graphics.setColor(love.math.colorFromBytes(235, 238, 11))
    for i = 1, #(Players) do
        DrawCenteredText(Const.width / 2, Const.margin * 2 * (i + 1), string.format("%s: %.2f%%", Players[i].name, Players[i].percent), Fonts.results)
    end

    DrawCenteredText(Const.width / 2, Const.margin * 2 * 7, string.format("%s wins!", Winner), Fonts.winner)
end

function DrawMenu()
    love.graphics.setColor(1,1,1,1)

    local textMargin = 40
    local paragraphMargin = 80

    DrawCenteredText(Const.width / 2, Const.margin, "Blue", Fonts.menu)
    DrawCenteredText(Const.width / 2, Const.margin + 1 * textMargin, "Turn: Q/E", Fonts.menu)
    DrawCenteredText(Const.width / 2, Const.margin + 2 * textMargin, "Power: W", Fonts.menu)

    DrawCenteredText(Const.width / 2, Const.margin + 2 * textMargin + paragraphMargin, "Red", Fonts.menu)
    DrawCenteredText(Const.width / 2, Const.margin + 2 * textMargin + paragraphMargin + 1 * textMargin, "Turn: I/P", Fonts.menu)
    DrawCenteredText(Const.width / 2, Const.margin + 2 * textMargin + paragraphMargin + 2 * textMargin, "Power: O", Fonts.menu)

    DrawCenteredText(Const.width / 2, Const.margin + 4 * textMargin + 2 * paragraphMargin, "Green", Fonts.menu)
    DrawCenteredText(Const.width / 2, Const.margin + 4 * textMargin + 2 * paragraphMargin + 1 * textMargin, "Turn: Z/C", Fonts.menu)
    DrawCenteredText(Const.width / 2, Const.margin + 4 * textMargin + 2 * paragraphMargin + 2 * textMargin, "Power: X", Fonts.menu)

    DrawCenteredText(Const.width / 2, Const.margin + 6 * textMargin + 3 * paragraphMargin, "Grey", Fonts.menu)
    DrawCenteredText(Const.width / 2, Const.margin + 6 * textMargin + 3 * paragraphMargin + 1 * textMargin, "Turn: left/right", Fonts.menu)
    DrawCenteredText(Const.width / 2, Const.margin + 6 * textMargin + 3 * paragraphMargin + 2 * textMargin, "Power: up", Fonts.menu)

    DrawCenteredText(Const.width / 2, Const.margin + 8 * textMargin + 5 * paragraphMargin, "Start: space", Fonts.menu)
end

function DrawStartButton()
    love.graphics.setColor(1, 1, 1, 1)

    local mouseX, mouseY = love.mouse.getPosition()

    if PointInRect(mouseX, mouseY, StartButton) then
        love.graphics.draw(StartButton.drawable.hover, StartButton.x, StartButton.y, 0, 1, 1, StartButton.xOffset, StartButton.yOffset)
        love.graphics.setColor(0, 0, 0, 1)
        DrawCenteredText(StartButton.x, StartButton.y, "START", Fonts.button)
    else
        love.graphics.draw(StartButton.drawable.standard, StartButton.x, StartButton.y, 0, 1, 1, StartButton.xOffset, StartButton.yOffset)
        DrawCenteredText(StartButton.x, StartButton.y, "START", Fonts.button)
    end
end

------------ UPDATE ------------

function love.update(dt)
    if GameState == GameStateEnum.Playing then
        for i = 1, #(Players) do
            UpdatePlayer(Players[i], dt)
        end

        UpdateTimer(dt)
        UpdateItem(dt)
    end
end

function UpdatePlayer(player, dt)
    MovePlayer(player, dt)
    UpdatePlayerPower(player, dt)
    CheckPlayerCollisions(player, dt)
    LeavePlayerTrace(player)

    if Item.active and Distance(Item, player) < 55 then
        PickItem(Item, player)
    end
end

function UpdatePlayerPower(player, dt)
    if not player.power then
        player.powerTimer = player.powerTimer + dt
        if player.powerTimer >= player.powerTimeout then
            player.powerTimer = 0
            player.power = true
        end
    end

    if player.power and love.keyboard.isDown(player.keys.power) then
        UsePower(player)
    end
end

function UpdateTimer(dt)
    Timer.elapsed = Timer.elapsed + dt
    if Timer.elapsed >= 1 then
        Timer.value = Timer.value - 1
        Timer.elapsed = Timer.elapsed - 1

        if Settings.sounds then
            if Timer.value == 20 then
                love.audio.play(Sounds.hurryUp)
            end

            if Timer.value <= 10 and Timer.value >= 1 then
                love.audio.play(Sounds.number[Timer.value])
            end
        end
    end

    if Timer.value == 0 then
        GameState = GameStateEnum.End
        love.audio.stop()
        if Settings.sounds then
            love.audio.play(Sounds.timeOver)
        end
        love.audio.play(Music.results)
        ComputeWinner()
    end
end

function UpdateItem(dt)
    if not Item.active then
        Item.time = Item.time - dt * Const.framerate
        if Item.time <= 0 then
            SpawnItem()
        end
    end
end

------------ EVENTS ------------

function love.keypressed(key, scancode, isrepeat)
    if (GameState == GameStateEnum.End or GameState == GameStateEnum.Menu) and key == "space" then
        Reset()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if (GameState == GameStateEnum.Menu or GameState == GameStateEnum.End) and PointInRect(x, y, StartButton) then
        Reset()
    end
end

------------ HELPERS ------------

function SpawnItem()
    local itemId = math.random(1, #(ItemTypes))
    Item.active = true
    Item.drawable = ItemTypes[itemId].drawable
    Item.type = ItemTypes[itemId].type
    Item.x = math.random(Const.margin, Const.width - Const.margin)
    Item.y = math.random(Const.margin, Const.height - Const.margin)
end

function ComputeWinner()
    local imageData = ColorCanvas.newImageData(ColorCanvas)
    for x = 1, Const.width do
        for y = 1, Const.width do
            local color = imageData:getPixel(x - 1, y - 1)
            for i = 1, #(Players) do
                if color == love.math.colorFromBytes(Players[i].color) then
                    Players[i].pixels = Players[i].pixels + 1
                end
            end
        end
    end

    local mx = 0
    for i = 1, #(Players) do
        Players[i].percent = (100 * Players[i].pixels) / (Const.width * Const.height)
        if Players[i].percent > mx then
            mx = Players[i].percent
            Winner = Players[i].name
        end
    end
end

function Distance(pl1, pl2)
    return math.sqrt((pl1.x - pl2.x) * (pl1.x - pl2.x) + (pl1.y - pl2.y) * (pl1.y - pl2.y))
end

function Reset()
    for i = 1, #(Players) do
        Players[i].angle = 0
        Players[i].power = false
        Players[i].percent = 0
        Players[i].pixels = 0
        Players[i].powerTimer = 0
    end

    Blue.x = Const.margin
    Blue.y = Const.margin
    Blue.velocity = 10
    Blue.radius = 20
    Blue.powerTimeout = 45
    
    Red.x = Const.width - Const.margin
    Red.y = Const.margin
    Red.velocity = 20
    Red.radius = 12
    Red.powerTimeout = 5

    Green.x = Const.margin
    Green.y = Const.height - Const.margin
    Green.velocity = 10
    Green.radius = 20
    Green.powerTimeout = 30
    
    Grey.x = Const.width - Const.margin
    Grey.y = Const.height - Const.margin
    Grey.velocity = 5
    Grey.radius = 40
    Grey.powerTimeout = 15

    Timer.elapsed = 0
    Timer.value = 60

    GameState = GameStateEnum.Playing

    Winner = ""

    Item.time = Const.framerate * 2
    Item.active = false

    GameState = GameStateEnum.Playing

    love.audio.stop()
    love.audio.play(Music.game)

    love.graphics.setCanvas(ColorCanvas)
    love.graphics.clear()
    love.graphics.setCanvas()
end

function PointInRect(px, py, rect)
    return px >= (rect.x - rect.xOffset) and px <= (rect.x - rect.xOffset + rect.width) and py >= (rect.y - rect.yOffset) and py <= (rect.y - rect.yOffset + rect.width)
end

function MovePlayer(player, dt)
    if love.keyboard.isDown(player.keys.left) then
        player.angle = (player.angle + player.velocity / 2) % 360
    end
    if love.keyboard.isDown(player.keys.right) then
        player.angle = (player.angle - player.velocity / 2) % 360
    end

    player.x = player.x + math.sin(math.rad(player.angle + 90)) * player.velocity * dt * Const.framerate
    player.y = player.y + math.cos(math.rad(player.angle + 90)) * player.velocity * dt * Const.framerate
end

function CheckPlayerCollisions(player, dt)
    if player.x < 0 or player.x >= Const.width or player.y < 0 or player.y >= Const.height then
        player.x = player.x - math.sin(math.rad(player.angle + 90)) * player.velocity * dt * Const.framerate
        player.y = player.y - math.cos(math.rad(player.angle + 90)) * player.velocity * dt * Const.framerate
        player.angle = (player.angle + math.random(100, 250)) % 360
        if Settings.sounds then
            love.audio.play(Sounds.impact)
        end
    end

    for i = 1, #(Players) do
        if Players[i] ~= player and Distance(Players[i], player) < 20 then
            player.angle = (player.angle + 180) % 360
        end
    end
end

function LeavePlayerTrace(player)
    love.graphics.setCanvas(ColorCanvas)
    love.graphics.setColor(love.math.colorFromBytes(player.color))
    love.graphics.circle("fill", player.x, player.y, player.radius)
    love.graphics.setCanvas()
end

function PickItem(item, player)
    if item.type == ItemTypeEnum.Bomb then
        love.graphics.setCanvas(ColorCanvas)
        love.graphics.setColor(love.math.colorFromBytes(player.color))
        love.graphics.circle("fill", player.x, player.y, 250)
        love.graphics.setCanvas()
        if Settings.sounds then
            love.audio.play(Sounds.item.bomb)
        end
    end

    if item.type == ItemTypeEnum.Star then
        love.graphics.setCanvas(ColorCanvas)
        love.graphics.setColor(love.math.colorFromBytes(player.color))
        for _ = 1, 20 do
            love.graphics.circle("fill", math.random(0, Const.width - 1), math.random(0, Const.height - 1), 50)
        end

        love.graphics.setCanvas()
        if Settings.sounds then
            love.audio.play(Sounds.item.star)
        end
    end

    if item.type == ItemTypeEnum.Coin then
        player.radius = player.radius + 5
        if Settings.sounds then
            love.audio.play(Sounds.item.coin)
        end
    end

    item.active = false
    item.time = math.random(Const.framerate, Const.framerate * 5)
end

function UsePower(player)
    if player.name == "Blue" then
        love.graphics.setCanvas(ColorCanvas)
        love.graphics.clear()
        love.graphics.setCanvas()
    end

    if player.name == "Red" then
        player.velocity = player.velocity + 5
    end

    if player.name == "Green" then
        love.graphics.setCanvas(ColorCanvas)
        
        for _ = 1, 150 do
            local index = math.random(1, #(Players))
            love.graphics.setColor(love.math.colorFromBytes(Players[index].color))
            love.graphics.circle("fill", math.random(0, Const.width - 1), math.random(0, Const.height - 1), 50)
        end

        love.graphics.setCanvas()
    end

    if player.name == "Grey" then
        player.radius = player.radius + 15
        player.velocity = player.velocity - 1
    end

    player.power = false
end