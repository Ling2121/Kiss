local SandboxObjectComponent = require"source/component/sandbox/sandbox_object_component"
local CollisionBodyComponent = require"source/component/collision_body_component"
local CollisionBodyMoveComponent = require"source/component/move_system/move_component/collision_body_move_component"
local MoveClearComponent = require"source/component/move_system/move_component/move_clear_component"
local MoveControlComponent = require"source/component/move_system/move_control_component/move_control_component"
local PositionComponent = require"source/component/position_component"

local Sandbox = require"source/entity/sandbox/sandbox"
local SandboxRegion = require"source/entity/sandbox/sandbox_region"

local ColorComponent = core.ComponentConstructor("ColorComponent",{
    make = function(self,c,r,g,b,a)
        c.r = r or 255
        c.g = g or 255
        c.b = b or 255
        c.a = a or 255
    end
})

local CollisionBodyDrawComponent = core.ComponentConstructor("CollisionBodyDrawComponent",{
    make = function(self,component,body_c,color_c)
        component.body = body_c
        component.color = color_c
        component.draw = function(self,entity)
            love.graphics.setColor(self.color.r,self.color.g,self.color.b,self.color.a)
            love.graphics.rectangle("fill",self.body.x,self.body.y,self.body.w,self.body.h)
            love.graphics.setColor(1,1,1,1)
        end
    end
})

local DebugComponent = core.ComponentConstructor("DebugComponent",{
    make = function(self,c)
        c.draw = function(self,e,dt)
            local str = string.format("Love2D Game  |   fps : %d   dt: %f",love.timer.getFPS(),love.timer.getDelta())
            love.window.setTitle(str)
        end
    end
})

local ColorBox = core.EntityCountructor("ColorBox",{
    make = function(self,e,collision_world,x,y,w,h,r,g,b,a)
        local w2,h2 = w / 2,h / 2

        local position = e:addComponent(PositionComponent,(x or 0),(y or 0))
        local color = e:addComponent(ColorComponent,r or 1,g or 1,b or 1,a or 1)
        local body = e:addComponent(CollisionBodyComponent,collision_world,"rectangle",x,y,w,h)
            :bindEntity(e)
            :bindPositionComponent(position)

        e:addComponent(SandboxObjectComponent,
            -math.ceil(position.y)
        )
        e:addComponent(CollisionBodyDrawComponent,collision_world:getShape(body.shape_idx),color)
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

local CameraFollowComponent = core.ComponentConstructor("CameraFollowComponent",{
    make = function(self,c,position_component,camera)
        c.camera = camera
        c.position_component = position_component
        c.update = function(self)
            self.camera:lockPosition(position_component.x,position_component.y, self.camera.smooth.damped(5))
        end
    end
})

local key = love.keyboard.isDown

local KeyboardControlColorBox = core.EntityCountructor("KeyboardControlColorBox",{
    make = function(self,e,sandbox,collision_world,x,y)
        
        

        ColorBox.make(self,e,collision_world,x,y,30,30,1,1,1,1)
        e:addComponent(CameraFollowComponent,e:getComponent("PositionComponent"),sandbox.camera)
        
        local move_component = CollisionBodyMoveComponent(e:getComponent("CollisionBodyComponent"))
        
        e:addComponent(MoveControlComponent,move_component,200,function(self,dt)
            local vx,vy = 0,0
            local speed = self:getEndSpeed()
            if key("w") then
                vy = -speed * dt
            end
            if key("s") then
                vy = speed * dt
            end

            if key("a") then
                vx = -speed * dt
            end
            
            if key("d") then
                vx = speed * dt
            end

            local PC = e:getComponent("PositionComponent")
            local SOC = e:getComponent("SandboxObjectComponent")

            SOC.depth = -math.ceil(PC.y + vy)

            return vx,vy
        end)

        e:addComponent(move_component)

        e:addComponent(MoveClearComponent,move_component)
    end
})

local Debug = core.EntityCountructor("RandomColorBox",{
    make = function(self,e)
        e:addComponent(DebugComponent)
    end
})


local sandbox = Sandbox()

function sandbox:load(args)
    core.Thread:createTask("load_file",
    function()
        print("loading")
        local file = love.filesystem.newFile("icon.png")
        file:open("r")
        file:read()
        return file
    end,
    function(file)
        print("read :",file:getSize())
    end)

    core.Thread:startTask("load_file")

    -- love.math.setRandomSeed(2333)

    -- local wd_w,wd_h = love.graphics.getDimensions()
    -- local wd_w2,wd_h2 = wd_w / 2,wd_h / 2

    -- local player = KeyboardControlColorBox(sandbox,game.CollisionWorld,-50,-50)

    -- local colorbox_1 = ColorBox(game.CollisionWorld,100,100,50,50,1.0,1.0,1.0,1.0)
    -- sandbox:addEntity(colorbox_1)

    -- local colorbox_2 = ColorBox(game.CollisionWorld,120,150,50,50,1.0,1.0,0.0,1.0)
    -- sandbox:addEntity(colorbox_2)

    -- local colorbox_3 = ColorBox(game.CollisionWorld,120,200,50,50,1.0,1.0,0.0,1.0)
    -- sandbox:addEntity(colorbox_3)

    -- sandbox:addEntity(Debug(),"Debug")
    -- sandbox:addEntity(player,"Player")

    -- local box_number = 10

    -- for i = 1,box_number do
    --     sandbox:addEntity(RandomColorBox(game.CollisionWorld,-wd_w2,-wd_h2,wd_w2,wd_h2))
    -- end

    -- local TileMap = require"source/entity/tilemap"
    -- local Utilities = require("source/core/base/utilities")

    -- local tile_map = TileMap(128,128,16)

    -- local BlockTileset = core.Resources:getFromGroup("TileSets","Blocks")
    -- local GrassTile = BlockTileset:getTile("grass")
    -- local WaterTile = BlockTileset:getTile("water")
    -- local SandTile = BlockTileset:getTile("sand")

    -- local tile_map_comp = tile_map:getComponent("TileMapComponent")
    
    -- sandbox.camera.scale = 2
    -- sandbox:addEntity(tile_map)

    -- local sandbox_component = sandbox:getComponent("SandboxComponent")

    -- local region_width = 16
    -- local region_height = 16
    -- local region_tile_size = 16

    -- local regions = {}
    -- local x1,y1 = 0,0

    -- for y = 0,128 do
    --     for x = 0,128 do
    --         local rx,ry = math.floor(x / region_width),math.floor(y / region_height)

    --         local region = sandbox_component:getRegion(rx,ry)

    --         if region == nil then
    --             region = SandboxRegion(rx,ry,region_width,region_height,region_tile_size)
    --             sandbox_component:addRegion(region,rx,ry)
    --             sandbox:addEntity(region)
    --             table.insert(regions,region)
    --         end

    --         local region_c = region:getComponent("SandboxRegionComponent")

    --         local n = Utilities.noise3D(x,y,0,2.33,2.23,128)
    --         local tile_name = "water"
    --         if n > 0.17 then
    --             tile_name = "grass"
    --         elseif n > 0.15 then
    --             tile_name = "sand"
    --         end

    --         local rlx = x - (rx * region_tile_size)
    --         local rly = y - (ry * region_tile_size)
            
    --         region_c:setTile("Blocks",tile_name,rlx,rly)

    --     end
    -- end

    -- for i,r in ipairs(regions) do
    --     local c = r:getComponent("SandboxRegionComponent");
    --     c:redraw()
    -- end
end

return sandbox