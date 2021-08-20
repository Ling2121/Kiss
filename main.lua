require"source/core/core"

local PositionComponent = core.ComponentCountructor("PositionComponent",{
    make = function(self,c,x,y)
        c.x = x or 0
        c.y = y or 0
    end
})

local BoxComponent = core.ComponentCountructor("BoxComponent",{
    make = function(self,c,w,h)
        c.width = w or 10
        c.height = h or 10
    end
})

local ColorComponent = core.ComponentCountructor("ColorComponent",{
    make = function(self,c,r,g,b,a)
        c.r = r or 255
        c.g = g or 255
        c.b = b or 255
        c.a = a or 255
    end
})

local DepthComponent = core.ComponentCountructor("DepthComponent",{
    make = function(self,c,d)
        c.depth = d or 0
    end
})

local ColorBoxDrawComponent = core.ComponentCountructor("ColorBoxDrawComponent",{
    make = function(self,c)
        c.draw = function(self,entity)
            local position = entity:getComponent("PositionComponent")
            local box = entity:getComponent("BoxComponent")
            local color = entity:getComponent("ColorComponent")
            love.graphics.setColor(color.r,color.g,color.b,color.a)
            love.graphics.rectangle("fill",position.x,position.y,box.width,box.height)
            love.graphics.setColor(1,1,1,1)
        end
    end
})

local DebugComponent = core.ComponentCountructor("DebugComponent",{
    make = function(self,c)
        c.draw = function(self,e,dt)
            local str = string.format("Love2D Game  |   fps : %d",love.timer.getFPS())
            love.window.setTitle(str)
        end
    end
})

local MoveComponent = core.ComponentCountructor("MoveComponent",{
    make = function(self,c,speed)
        c.speed = speed or 150

        c.update = function(self,e,dt)
            local position = e:getComponent("PositionComponent")

            if love.keyboard.isDown("w") then
                position.y = position.y - (c.speed * dt)
            end

            if love.keyboard.isDown("s") then
                position.y = position.y + (c.speed * dt)
            end

            if love.keyboard.isDown("a") then
                position.x = position.x - (c.speed * dt)
            end

            if love.keyboard.isDown("d") then
                position.x = position.x + (c.speed * dt)
            end

            local depth = e:getComponent("DepthComponent")
            if depth ~= nil then
                --local h = e:getComponent("BoxComponent").height
                depth.depth = -math.ceil(position.y)-- + h
            end
        end
    end
})

local ColorBox = core.EntityCountructor("ColorBox",{
    make = function(self,e,x,y,w,h,r,g,b,a)
        e:addComponent(PositionComponent,x or 0,y or 0)
        e:addComponent(BoxComponent,w or 10,h or 10)
        e:addComponent(ColorComponent,r or 1,g or 1,b or 1,a or 1)
        e:addComponent(DepthComponent,
            -math.ceil(e:getComponent("PositionComponent").y)
        )
        e:addComponent(ColorBoxDrawComponent)
    end
})

local RandomColorBox = core.EntityCountructor("RandomColorBox",{
    make = function(self,e,min_x,min_y,max_x,max_y)

        ColorBox.make(self,e,
            love.math.random(min_x,max_x),love.math.random(min_y,max_y),
            love.math.random(50,80),love.math.random(50,80),
            love.math.random(0.1,1.0),love.math.random(0.1,1.0),love.math.random(0.1,1.0),love.math.random(0.2,0.8)
        )
    end
})

local KeyboardControlRandomColorBox = core.EntityCountructor("KeyboardControlRandomColor",{
    make = function(self,e)
        ColorBox.make(self,e,0,0,100,100,1,1,1,1)
        e:addComponent(MoveComponent,150)
    end
})

local Debug = core.EntityCountructor("RandomColorBox",{
    make = function(self,e)
        e:addComponent(DebugComponent)
    end
})

local sanbox = core.Sandbox()

local wd_w,wd_h = love.graphics.getDimensions()
local wd_w2,wd_h2 = wd_w / 2,wd_h / 2

sanbox:addEntity(Debug(),"Debug")
sanbox:addEntity(KeyboardControlRandomColorBox(),"Player")

local box_number = 8000

for i = 1,box_number do
    sanbox:addEntity(RandomColorBox(-wd_w2,-wd_h2,wd_w2,wd_h2))
end

sanbox:applyToLoveCallback()