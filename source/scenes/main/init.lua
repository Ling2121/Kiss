local SandboxObjectComponent = require"source/core/scene/components/sandbox_object_component"
local CollisionBodyComponent = require"source/component/collision_body_component"

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
            local str = string.format("Love2D Game  |   fps : %d   dt: %f",love.timer.getFPS(),love.timer.getDelta())
            love.window.setTitle(str)
        end
    end
})

local MoveComponent = core.ComponentCountructor("MoveComponent",{
    make = function(self,c,speed)
        c.speed = speed or 150

        c.update = function(self,e,dt)
            --local dt = love.timer.getDelta()
            local position = e:getComponent("PositionComponent")
            local collision_body = e:getComponent("CollisionBodyComponent")


            local vx,vy = 0,0

            if love.keyboard.isDown("w") then
                vy = -c.speed * dt
            end
            if love.keyboard.isDown("s") then
                vy = c.speed * dt
            end

            if love.keyboard.isDown("a") then
                vx = -c.speed * dt
            end
            
            if love.keyboard.isDown("d") then
                vx = c.speed * dt
            end


            if collision_body ~= nil then
                collision_body:moveAndSyncToPosition(vx,vy)
            else
                position.x = position.x + vx
                position.y = position.y + vy
            end

            local depth = e:getComponent("SandboxObjectComponent")
            if depth ~= nil then
                depth.depth = -math.ceil(position.y)
            end
        end
    end
})

local ColorBox = core.EntityCountructor("ColorBox",{
    make = function(self,e,collision_world,x,y,w,h,r,g,b,a)
        local w2,h2 = w / 2,h / 2

        local p = e:addComponent(PositionComponent,(x or 0),(y or 0))
        e:addComponent(BoxComponent,w or 10,h or 10)
        e:addComponent(ColorComponent,r or 1,g or 1,b or 1,a or 1)
        e:addComponent(SandboxObjectComponent,
            -math.ceil(p.y)
        )
        e:addComponent(ColorBoxDrawComponent)

        e:addComponent(CollisionBodyComponent,collision_world,"rectangle",x,y,w,h)
            :bindEntity(e)
            :bindPositionComponent(p)
    end
})

local RandomColorBox = core.EntityCountructor("RandomColorBox",{
    make = function(self,e,collision_world,min_x,min_y,max_x,max_y)

        ColorBox.make(self,e,collision_world,
            love.math.random(min_x,max_x),love.math.random(min_y,max_y),
            love.math.random(50,80),love.math.random(50,80),
            love.math.random(0.1,1.0),love.math.random(0.1,1.0),love.math.random(0.1,1.0),love.math.random(0.2,0.8)
        )
    end
})

local CameraFollowComponent = core.ComponentCountructor("CameraFollowComponent",{
    make = function(self,c,position_component,camera)
        c.camera = camera
        c.position_component = position_component
        c.update = function(self)
            self.camera:lockPosition(position_component.x,position_component.y, self.camera.smooth.damped(5))
            --self.camera:lookAt(position_component.x,position_component.y)
        end
    end
})

local KeyboardControlRandomColorBox = core.EntityCountructor("KeyboardControlRandomColor",{
    make = function(self,e,sandbox,collision_world,x,y)
        ColorBox.make(self,e,collision_world,x,y,30,30,1,1,1,1)
        e:addComponent(CameraFollowComponent,e:getComponent("PositionComponent"),sandbox.camera)
        e:addComponent(MoveComponent,100)
    end
})

local Debug = core.EntityCountructor("RandomColorBox",{
    make = function(self,e)
        e:addComponent(DebugComponent)
    end
})



local sanbox = core.Sandbox()

function sanbox:load(args)
    love.math.setRandomSeed(2333)

    local wd_w,wd_h = love.graphics.getDimensions()
    local wd_w2,wd_h2 = wd_w / 2,wd_h / 2

    local player = KeyboardControlRandomColorBox(sanbox,game.CollisionWorld,-50,-50)

    local colorbox_1 = ColorBox(game.CollisionWorld,100,100,50,50,1.0,1.0,1.0,1.0)
    sanbox:addEntity(colorbox_1)

    local colorbox_2 = ColorBox(game.CollisionWorld,120,150,50,50,1.0,1.0,0.0,1.0)
    sanbox:addEntity(colorbox_2)

    local colorbox_3 = ColorBox(game.CollisionWorld,120,200,50,50,1.0,1.0,0.0,1.0)
    sanbox:addEntity(colorbox_3)

    sanbox:addEntity(Debug(),"Debug")
    sanbox:addEntity(player,"Player")

    local box_number = 10

    for i = 1,box_number do
        sanbox:addEntity(RandomColorBox(game.CollisionWorld,-wd_w2,-wd_h2,wd_w2,wd_h2))
    end

    local TileMap = require"source/entity/tilemap"
    local Utilities = require("source/core/base/utilities")

    local tile_map = TileMap(128,128,16)

    local BlockTileset = core.Resources:get("assets/image/tilesets/block/block.tileset.json")
    local GrassTile = BlockTileset:getTile("grass")
    local WaterTile = BlockTileset:getTile("water")
    local SandTile = BlockTileset:getTile("sand")

    local tile_map_comp = tile_map:getComponent("TileMapComponent")
    sanbox.camera.scale = 2
    sanbox:addEntity(tile_map)

    for y = 0,128 do
        for x = 0,128 do
            local n = Utilities.noise3D(x,y,0,2.33,2.23,128)
            if n > 0.17 then
                tile_map_comp:setTile(BlockTileset,"grass",x,y)
            elseif n > 0.15 then
                tile_map_comp:setTile(BlockTileset,"sand",x,y)
            else
                tile_map_comp:setTile(BlockTileset,"water",x,y)
            end
        end
    end
end

return sanbox