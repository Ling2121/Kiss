-- local HC = require"HC"

-- local world = HC.new(100)

-- local cir1 = world:circle(100,100,40)

-- local rects = {
    -- world:rectangle(150,150,100,100),
    -- world:rectangle(150,180,100,100),
    -- world:rectangle(180,150,100,100),
    -- world:rectangle(150,250,100,100),
-- }

-- world:register(cir1)

-- for k,v in ipairs(rects) do
    -- world:register(v)
-- end


-- local speed = 100

-- function love.update(dt)
    -- local dx,dy = 0,0
    -- if love.keyboard.isDown("w") then
        -- dy = -speed
    -- end
    -- if love.keyboard.isDown("s") then
        -- dy = speed
    -- end
    -- if love.keyboard.isDown("a") then
        -- dx = -speed
    -- end
    -- if love.keyboard.isDown("d") then
        -- dx = speed
    -- end
    -- if dx ~= 0 or dy ~= 0 then
        -- cir1:move(dx * dt,dy * dt)
        -- local collisions = world:collisions(cir1)
        -- for k,v in pairs(collisions) do
            -- cir1:move(v.x,v.y)
            -- print(k,v.x,v.y)
        -- end
    -- end
-- end

-- function love.draw()
    -- world:hash():draw()
    -- cir1:draw()

    -- for k,v in ipairs(rects) do
        -- v:draw()
    -- end
    
-- end

HC = require 'HC'

-- array to hold collision messages
local text = {}

function love.load()
    -- add a rectangle to the scene
    rect = HC.rectangle(200,400,400,20)

    -- add a circle to the scene
    mouse = HC.circle(400,300,20)
    mouse:moveTo(love.mouse.getPosition())
end

function love.update(dt)
    -- move circle to mouse position
    mouse:moveTo(love.mouse.getPosition())

    -- rotate rectangle
    rect:rotate(dt)

    -- check for collisions
    for shape, delta in pairs(HC.collisions(mouse)) do
        text[#text+1] = string.format("Colliding. Separating vector = (%s,%s)",
                                      delta.x, delta.y)
    end

    while #text > 40 do
        table.remove(text, 1)
    end
end

function love.draw()
    -- print messages
    for i = 1,#text do
        love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        love.graphics.print(text[#text - (i-1)], 10, i * 15)
    end

    -- shapes can be drawn to the screen
    love.graphics.setColor(255,255,255)
    rect:draw('fill')
    mouse:draw('fill')
end

