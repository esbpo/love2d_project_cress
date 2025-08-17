-- This is the main file for a simple plant growing game using LÖVE framework.
-- The game allows the player to plant, water, and harvest a plant, with audio feedback
-- Current TODO:
-- 1. Implement a shop UI for purchasing different plant skins
-- 2. Add more plant growth stages and animations
-- 3. Improve audio
-- 4. Change several colours throughout the game
-- 5. Add more plant types with different growth times and qualities
-- 6. Implement a save/load system for player progress
-- 7. Create window icon

-- String used for debugging
local debugstring = "Hello World"

-- Load all necessary values
function love.load()
    -- Window variables
    Window = {
        width = love.graphics.getWidth(),
        height = love.graphics.getHeight(),
        background = love.graphics.newImage("textures/baggrund_vindue.png"),
        hscale = 1,
        wscale = 1,
        scale = 1,
        wconst = 0,
        hconst = 0,
    }

    Window.x = Window.width / 2 - (Window.background:getWidth() * Window.scale) / 2
    Window.y = Window.height / 2 - (Window.background:getHeight() * Window.scale) / 2

    -- Plant variables
    -- Contains all images for the plant, current gfrowth stage, water level, time to grow, and quality
    Plant = {
        image = {
            basic = {love.graphics.newImage("textures/Karse_0.png"), love.graphics.newImage("textures/Karse_1.png"), love.graphics.newImage("textures/Karse_2.png"), love.graphics.newImage("textures/Karse_3.png"),}
        },
        growth_stage = 1, -- 1 for not sown, 2 for seeds, 3 for half grown, 4 for fully grown
        water = 0,
        time_to_grow = 0,
        quality = {}
    }

    -- Player variables
    -- Contains score, unlocked skins, and selected skin
    Player = {
        score = 0,
        unlocked_skins = {Plant.image.basic},
        selected_skin = Plant.image.basic
    }

    -- Buttons variables
    -- Contains image for buttons and their sizes
    Buttons = {
        image = love.graphics.newImage("textures/Knapper.png"),
        width = 27 * 8,
        height = 8 * 8,
    }
    -- Size for buttons on 800 * 800 pixels
    -- 27 * 8 pixels wide, 8 * 8 pixels high
    -- "Plant" button begins 2 * 8 pixels in, "Vand" button begins 39 * 8 pixels in, "Høst" button begins 71 * 8 pixels in
    -- Buttons begin 88 * 8 pixels down

    -- Individual button positions and sizes
    -- These are used for collision detection with mouse clicks
    Buttons.seeds = {
        x = 2 * 8,
        y = 88 * 8,
        width = 27 * 8,
        height = 8 * 8,
    }

    Buttons.water = {
        x = 39 * 8,
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

    -- UI variables
    -- Contains images for UI markers and shop
    UI = {
        water_marker = {
            image = love.graphics.newImage("textures/water_marker.png")
        },

        score_marker = {
            image = love.graphics.newImage("textures/score_marker.png")
        },

        shop = {
            active = false,
        },
    }

    -- Audio sources
    -- Contains audio sources for background music, planting, watering, and harvesting sounds
    Audio = {
        background = love.audio.newSource("audio/background.mp3", "static"),
        plant = love.audio.newSource("audio/plant.mp3", "static"),
        water = love.audio.newSource("audio/water.mp3", "static"),
        harvest = love.audio.newSource("audio/harvest.mp3", "static"),
        play = true
    }

    -- Set the backgorund music volume
    -- This is set to a low volume to not overpower the game sounds
    Audio.background:setVolume(0.2)
end

-- Function to handle key presses
-- This function is called when a key is pressed
function love.keypressed(key, scancode, isrepeat)
    -- Close the game if the escape key is pressed
    if key == "escape" then
        love.event.quit()
    end

    -- Toggle audio playback if the 'm' key is pressed
    if key == "m" then
        if Audio.play == true then
            Audio.play = false
            love.audio.pause()
        else
            Audio.play = true
        end
    end

    -- Toggle fullscreen mode if the F11 key is pressed
    if key == "f11" then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
        else
            love.window.setFullscreen(true)
        end
    end

    -- Toggle shop UI if the 's' key is pressed
    if key == "s" then
        if UI.shop.active then 
            UI.shop.active = false
        else
            UI.shop.active = true
        end
    end
end

-- Function to check for collision between two rectangles
-- This function takes two lists with x, y, width, and height as parameters
local function collision(l1 --[[list with x, y, width and height]], l2--[[list with x, y, width and height]])
    -- First ensure that both lists have the required properties
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
    -- Debug setting DEPRECATED
    debugstring = "l1: x: "..l1.x.." y: "..l1.y.." w: "..l1.width.." h: "..l1.height.." l2: x: "..l2.x.." y: "..l2.y.." w: "..l2.width.." h: "..l2.height.."     "

    -- Helper variables for collision detection
    local a_left = l1.x
    local a_right = l1.x + l1.width
    local a_top = l1.y
    local a_bottom = l1.y + l1.width

    local b_left = l2.x
    local b_right = l2.x + l2.width
    local b_top = l2.y
    local b_bottom = l2.y + l2.height

    -- Check if the rectangles overlap
    -- If they do, return true, otherwise return false
    return a_right > b_left
    and a_left < b_right
    and a_top < b_bottom
    and a_bottom > b_top
end

-- Function to handle mouse clicks
-- This function is called when the mouse is pressed
function love.mousepressed(x, y, button, istouch, presses)
    -- mouselocation is a helper table to check for collisions
    local mouselocation = {x = x, y = y}

    -- Check if the left mouse button is pressed
    -- If it is, check for collisions with the buttons
    if button == 1 then
        -- Don't collide with buttons if the shop is open
        if not UI.shop.active then
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
        end

        -- Debugging output for mouse position and collision detection
        debugstring = debugstring.."x: "..x.." y: "..y.."    "..tostring(collision(mouselocation, Buttons.seeds))
    end
end

-- Love update function
-- This function is called every frame and updates the game state
function love.update(dt)
    -- Update the background music if it is set to play
    -- If the audio is set to play, play the background music
    if Audio.play then
        local success = love.audio.play(Audio.background)
    end

    -- Decrease the water level over time
    -- If the water level is greater than 0, decrease it by a small amount
    if Plant.water > 0 then
        Plant.water = Plant.water - dt * 0.01
    end

    -- Ensure water level never goes below 0
    if Plant.water < 0 then
        Plant.water = 0
    end

    -- Update the plant growth stage
    -- If the plant has water and is not in the first or last growth stage, update the growth stage
    if Plant.water > 0 then
        -- If the plant is not in the first or last growth stage, update the time to grow
        if (not (Plant.growth_stage == 1)) and (not (Plant.growth_stage == 4)) then
            -- If time to grow is 0, set it to a random value between 30 and 60 seconds NEEDS TO BE CHANGED
            if Plant.time_to_grow == 0 then
                Plant.time_to_grow = math.random(1, 1) -- Random time to grow in seconds
            end

            -- Decrease the time to grow by the delta time
            -- This ensures each second of growth time takes 1 second in the game
            Plant.time_to_grow = Plant.time_to_grow - dt

            -- Debug
            -- debugstring = tostring(Plant.time_to_grow).."   "..tostring(1*dt)

            -- If time_to_grow is less than or equal to 0, increase the growth stage and reset time_to_grow to 0
            if Plant.time_to_grow <= 0 then
                Plant.growth_stage = Plant.growth_stage + 1
                Plant.time_to_grow = 0
            end

            -- If the plant is fully grown, set the quality and spawn message
            -- This is done by randomly selecting a quality based on a chance (5% for "Perfekt", 15% for "god", 70% for "Normal", and 10% for "Vissen")
            if Plant.growth_stage == 4 then
                MsgSpawnX = math.random(200, 400)
                MsgSpawnY = math.random(280, 460)

                local chance = math.random()
                if chance <= 0.05 then
                    Plant.quality = {"Perfekt", 8}
                elseif chance <= 0.2 then
                    Plant.quality = {"God", 4}
                elseif chance <= 0.9 then
                    Plant.quality = {"Normal", 2}
                else
                    Plant.quality = {"Vissen", 1}
                end
            end
        end
    end
end

-- Resize function to adjust the window and button sizes
-- This function is called when the window is resized
function love.resize(w, h)
    -- Set the scale with default window size og 800x800px
    Window.hscale = h/800
    Window.wscale = w/800

    -- If width is smaller than height, use width scale, otherwise use height scale
    -- This ensures that the window is always centered and scaled correctly
    if w < h then
        Window.scale = Window.wscale
        Window.x = w/2 - (Window.background:getWidth() * Window.wscale)/ 2
        Window.y = h/2 - (Window.background:getHeight() * Window.wscale) / 2
    else
        Window.scale = Window.hscale
        Window.x = w/2 - (Window.background:getWidth() * Window.hscale)/ 2
        Window.y = h/2 - (Window.background:getHeight() * Window.hscale) / 2
    end

    -- Consants used for centering
    Window.wconst = (w - 800 * Window.scale) / 2
    Window.hconst = (h - 800 * Window.scale) / 2

    -- Update the window size and button sizes
    Window.width = w
    Window.height = h
    Buttons.width = 27 * 8 * Window.scale
    Buttons.height = 8 * 8 * Window.scale

    -- Update individual button positions and sizes
    Buttons.seeds.x = 2 * 8 * Window.scale + Window.wconst
    Buttons.seeds.y = 88 * 8 * Window.scale + Window.hconst
    Buttons.seeds.width = Buttons.width
    Buttons.seeds.height = Buttons.height

    Buttons.water.x = 39 * 8 * Window.scale + Window.wconst
    Buttons.water.y = 88 * 8 * Window.scale + Window.hconst
    Buttons.water.width = Buttons.width
    Buttons.water.height = Buttons.height

    Buttons.harvest.x = 71 * 8 * Window.scale + Window.wconst
    Buttons.harvest.y = 88 * 8 * Window.scale + Window.hconst
    Buttons.harvest.width = Buttons.width
    Buttons.harvest.height = Buttons.height
end

-- Set default game font
local font = love.graphics.newFont("default_font.ttf", 60)

function love.draw()
    -- Check if shop is active
    if not UI.shop.active then
        -- Draw background, plant, buttons and UI markers
        love.graphics.draw(Window.background, Window.x, Window.y, 0, Window.scale, Window.scale)
        love.graphics.draw(Plant.image.basic[Plant.growth_stage], Window.x, Window.y, 0, Window.scale, Window.scale)
        love.graphics.draw(Buttons.image, Window.x, Window.y, 0, Window.scale, Window.scale)
        love.graphics.draw(UI.water_marker.image, Window.x, Window.y, 0, Window.scale, Window.scale)
        love.graphics.draw(UI.score_marker.image, Window.x, Window.y, 0, Window.scale, Window.scale)

        -- Set text colour and print text
        love.graphics.setColor(0,0,0)
        love.graphics.print(tostring(math.floor(Plant.water*100 + 0.5)).."%", font, 280 * Window.scale + Window.wconst, 16 * Window.scale + Window.hconst, 0, Window.scale, Window.scale)
        love.graphics.print(tostring(Player.score), font, 528 * Window.scale + Window.wconst, 16 * Window.scale + Window.hconst, 0, Window.scale, Window.scale)
        if Plant.quality[1] then
            love.graphics.print(Plant.quality[1], font, MsgSpawnX * Window.scale + Window.wconst, MsgSpawnY * Window.scale + Window.hconst, 0, Window.scale, Window.scale)
        end
        -- Reset colour to white
        love.graphics.setColor(255,255,255)

        -- Debug
        love.graphics.print(debugstring, 0, 0, 0, 1, 1)
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("line", Buttons.seeds.x, Buttons.seeds.y, Buttons.width, Buttons.height)
        love.graphics.rectangle("line", Buttons.water.x, Buttons.water.y, Buttons.width, Buttons.height)
        love.graphics.rectangle("line", Buttons.harvest.x, Buttons.harvest.y, Buttons.width, Buttons.height)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(Window.wconst, 0, 50)
    else
        -- Draw shop UI
    end
end