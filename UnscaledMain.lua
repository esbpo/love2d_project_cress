local debugstring = "Hello World"

function love.load()
    Window = {
        width = love.graphics.getWidth(),
        height = love.graphics.getHeight(),
        background = love.graphics.newImage("textures/baggrund_vindue.png"),
    }

    Plant = {
        image = {
            basic = {love.graphics.newImage("textures/Karse_0.png"), love.graphics.newImage("textures/Karse_1.png"), love.graphics.newImage("textures/Karse_2.png"), love.graphics.newImage("textures/Karse_3.png"),}
        },
        growth_stage = 1, -- 1 for not sown, 2 for seeds, 3 for half grown, 4 for fully grown
        water = 0,
        time_to_grow = 0,
        quality = {}
    }

    Player = {
        score = 0,
        unlocked_skins = {Plant.image.basic},
        selected_skin = Plant.image.basic
    }

    Buttons = {
        image = love.graphics.newImage("textures/Knapper.png"),
        width = 27 * 8,
        height = 8 * 8,
    }
    -- 27 * 8 pixels wide, 8 * 8 pixels high
    -- "Plant" button begins 2 * 8 pixels in, "Vand" button begins 40 * 8 pixels in, "Høst" button begins 71 * 8 pixels in
    -- Buttons begin 88 * 8 pixels down
    Buttons.seeds = {
        x = 2 * 8,
        y = 88 * 8,
        width = 27 * 8,
        height = 8 * 8,
    }

    Buttons.water = {
        x = 40 * 8,
        y = 88 * 8,
        width = 27 * 8,
        height = 8 * 8,
    }

    Buttons.harvest = {
        x = 71 * 8,
        y = 88 * 8,
        width = 27 * 8,
        height = 8 * 8,
    }

    UI = {
        water_marker = {
            image = love.graphics.newImage("textures/water_marker.png")
        },

        score_marker = {
            image = love.graphics.newImage("textures/score_marker.png")
        }
    }

    Audio = {
        background = love.audio.newSource("audio/background.mp3", "static"),
        plant = love.audio.newSource("audio/plant.mp3", "static"),
        water = love.audio.newSource("audio/water.mp3", "static"),
        harvest = love.audio.newSource("audio/harvest.mp3", "static"),
        play = true
    }
    Audio.background:setVolume(0.2)

end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end

    if key == "m" then
        if Audio.play == true then
            Audio.play = false
            love.audio.pause()
        else
            Audio.play = true
        end
    end
end

-- function love.resize(w, h)
--     Plant.x = w/2 - Plant.image.basic:getWidth()/2
--     Plant.y = h/2 - Plant.image.basic:getHeight()/2
-- end

local function collision(l1 --[[list with x, y, width and height]], l2--[[list with x, y, width and height]])
    if not l1.width then
        l1.width = 0
    end

    if not l1.height then
        l1.height = 0
    end

    if not l2.width then
        l2.width = 0
    end

    if not l2.height then
        l2.height = 0
    end
    debugstring = "l1: x: "..l1.x.." y: "..l1.y.." w: "..l1.width.." h: "..l1.height.." l2: x: "..l2.x.." y: "..l2.y.." w: "..l2.width.." h: "..l2.height.."     "

    -- debugstring = ""..l2.x.." "..l2.y
    local a_left = l1.x
    local a_right = l1.x + l1.width
    local a_top = l1.y
    local a_bottom = l1.y + l1.width

    local b_left = l2.x
    local b_right = l2.x + l2.width
    local b_top = l2.y
    local b_bottom = l2.y + l2.height

    return a_right > b_left
    and a_left < b_right
    and a_top < b_bottom
    and a_bottom > b_top
end

function love.mousepressed(x, y, button, istouch, presses)
    local mouselocation = {x = x, y = y}
    if button == 1 then
        if collision(mouselocation, Buttons.seeds) then
            debugstring = "seeds pressed"
            if Plant.growth_stage == 1 then
                Plant.growth_stage = 2
                love.audio.play(Audio.plant)
            end
        elseif collision(mouselocation, Buttons.water) then
            debugstring = "water pressed"
            Plant.water = 1
            love.audio.play(Audio.water)
        elseif collision(mouselocation, Buttons.harvest) then
            debugstring = "harvest pressed"
            if Plant.growth_stage == 4 then
                Plant.growth_stage = 1
                Player.score = Player.score + Plant.quality[2]
                Plant.quality = {}
                love.audio.play(Audio.harvest)
            end
        end

        debugstring = debugstring.."x: "..x.." y: "..y.."    "..tostring(collision(mouselocation, Buttons.seeds))
    end
end

function love.update(dt)
    if Audio.play then
        local success = love.audio.play(Audio.background)
    end
    if Plant.water > 0 then
        Plant.water = Plant.water - dt * 0.01
    end

    if Plant.water < 0 then
        Plant.water = 0
    end
    if Plant.water > 0 then
        if (not (Plant.growth_stage == 1)) and (not (Plant.growth_stage == 4)) then
            if Plant.time_to_grow == 0 then
                Plant.time_to_grow = math.random(3, 6) -- Random time to grow in seconds
                -- debugstring = tostring(Plant.time_to_grow).."   "..tostring(1*dt)
            end

            Plant.time_to_grow = Plant.time_to_grow - dt
            debugstring = tostring(Plant.time_to_grow).."   "..tostring(1*dt)
            if Plant.time_to_grow <= 0 then
                Plant.growth_stage = Plant.growth_stage + 1
                Plant.time_to_grow = 0
            end

            if Plant.growth_stage == 4 then

                local chance = math.random()
                if chance < 0.05 then
                    Plant.quality = {"Perfekt", 8}
                elseif chance < 0.2 then
                    Plant.quality = {"God", 4}
                elseif chance < 0.9 then
                    Plant.quality = {"Normal", 2}
                else
                    Plant.quality = {"Vissen", 1}
                end
            end
        end
    end
end

local border = 0
local font = love.graphics.newFont("default_font.ttf", 60)
function love.draw()
    love.graphics.draw(Window.background, border, border)
    love.graphics.draw(Plant.image.basic[Plant.growth_stage], border, border)
    love.graphics.draw(Buttons.image, border, border)
    love.graphics.draw(UI.water_marker.image, border, border)
    love.graphics.draw(UI.score_marker.image, border, border)
    love.graphics.setColor(0,0,0)
    love.graphics.print(tostring(math.floor(Plant.water*100 + 0.5)).."%", font, 280, 16, 0, 1, 1)
    love.graphics.print(tostring(Player.score), font, 528, 16)
    if Plant.quality[1] then
        love.graphics.print(Plant.quality[1], font, 360, 400)
    end
    love.graphics.print(debugstring, 0, 0, 0, 1, 1)
    love.graphics.setColor(255,255,255)
end