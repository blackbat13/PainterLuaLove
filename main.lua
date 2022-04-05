function love.load()

    Const = {width = 1000, height = 1000, margin = 50, framerate = 60}

    ColorCanvas = love.graphics.newCanvas(Const.width, Const.height)
    love.graphics.setCanvas(ColorCanvas)
    love.graphics.clear()
    love.graphics.setCanvas()

    Blue = {
        x = Const.margin,
        y = Const.margin,
        angle = 0,
        drawable = love.graphics.newImage("images/blue.png"),
        name = "Blue",
        color = {33, 132, 211, 255},
        keys = {left = "q", right = "e", power = "w"},
        velocity = 10,
        radius = 20,
        power = false,
        powerTimeour = 45,
        percent = 0,
        pixels = 0
    }

    Red = {
        x = Const.width - Const.margin,
        y = Const.margin,
        angle = 0,
        drawable = love.graphics.newImage("images/red.png"),
        name = "Red",
        color = {221, 78, 84, 255},
        keys = {left = "i", right = "p", power = "o"},
        velocity = 20,
        radius = 12,
        power = false,
        powerTimeour = 5,
        percent = 0,
        pixels = 0
    }

    Green = {
        x = Const.margin,
        y = Const.height - Const.margin,
        angle = 0,
        drawable = love.graphics.newImage("images/green.png"),
        name = "Green",
        color = {73, 180, 126, 255},
        keys = {left = "left", right = "right", power = "up"},
        velocity = 10,
        radius = 20,
        power = false,
        powerTimeour = 30,
        percent = 0,
        pixels = 0
    }

    Grey = {
        x = Const.width - Const.margin,
        y = Const.height - Const.margin,
        angle = 0,
        drawable = love.graphics.newImage("images/grey.png"),
        name = "Grey",
        color = {147, 127, 124, 255},
        keys = {left = "kp7", right = "kp9", power = "kp8"},
        velocity = 5,
        radius = 40,
        power = false,
        powerTimeour = 15,
        percent = 0,
        pixels = 0
    }

    Players = {Blue, Green, Red, Grey}

    Timer = {elapsed = 0, value = 60}

    Fonts = {
        timer = love.graphics.newFont("fonts/kenney_bold.ttf", 50), 
        results = love.graphics.newFont("fonts/kenney_future_square.ttf", 60),
        winner = love.graphics.newFont("fonts/kenney_bold.ttf", 110)
    }

    GameStateEnum = {Menu = 0, Playing = 1, End = 2}

    GameState = GameStateEnum.Playing

    Winner = ""
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(ColorCanvas)
    DrawPlayers()

    love.graphics.setColor(love.math.colorFromBytes(235, 238, 11))
    DrawCenteredText(Const.width / 2, Const.margin, Timer.value, Fonts.timer)

    if GameState == GameStateEnum.End then
        for i = 1, #(Players) do
            DrawCenteredText(Const.width / 2, Const.margin * 2 * (i + 1), string.format("%s: %.2f%%", Players[i].name, Players[i].percent), Fonts.results)
        end
        
        DrawCenteredText(Const.width / 2, Const.margin * 2 * 7, string.format("%s wins!", Winner), Fonts.winner)
    end
end

function DrawCenteredText(x, y, text, font)
	local textWidth  = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print(text, font, x, y, 0, 1, 1, textWidth/2, textHeight/2)
end

function DrawPlayers()
    for i = 1, #(Players) do
        love.graphics.draw(Players[i].drawable, Players[i].x, Players[i].y, math.rad(Players[i].angle), 1, 1, 20, 20)
    end
end

function love.update(dt)
    if GameState == GameStateEnum.Playing then
        for i = 1, #(Players) do
            UpdatePlayer(Players[i], dt)
        end

        UpdateTimer(dt)
    end
end

function UpdatePlayer(player, dt)
    if love.keyboard.isDown(player.keys.left) then
        player.angle = (player.angle + player.velocity / 2) % 360
    end
    if love.keyboard.isDown(player.keys.right) then
        player.angle = (player.angle - player.velocity / 2) % 360
    end

    player.x = player.x + math.sin(math.rad(player.angle + 90)) * player.velocity * dt * Const.framerate
    player.y = player.y + math.cos(math.rad(player.angle + 90)) * player.velocity * dt * Const.framerate

    if player.x < 0 or player.x >= Const.width or player.y < 0 or player.y >= Const.height then
        player.x = player.x - math.sin(math.rad(player.angle + 90)) * player.velocity * dt * Const.framerate
        player.y = player.y - math.cos(math.rad(player.angle + 90)) * player.velocity * dt * Const.framerate
        player.angle = (player.angle + math.random(100, 250)) % 360
    end

    love.graphics.setCanvas(ColorCanvas)
    love.graphics.setColor(love.math.colorFromBytes(player.color))
    love.graphics.circle("fill", player.x, player.y, player.radius)
    love.graphics.setCanvas()

    for i = 1, #(Players) do
        if Players[i] ~= player and Distance(Players[i], player) < 20 then
            player.angle = (player.angle + 180) % 360
        end
    end
end

function UpdateTimer(dt)
    Timer.elapsed = Timer.elapsed + dt
    if Timer.elapsed >= 1 then
        Timer.value = Timer.value - 1
        Timer.elapsed = Timer.elapsed - 1
    end

    if Timer.value == 0 then
        GameState = GameStateEnum.End
        ComputeWinner()
    end
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