local IndexPool = require"source/core/base/index_pool"
local HCPort = require"source/core/collision/ports/collision_port_hc"
local BumpPort = require"source/core/collision/ports/collision_port_bump"

local port_table = {
    ["HC"] = HCPort,
    ["Bump"] = BumpPort,
}

local function createPort(name,config)
    local port_fn = port_table[name]
    assert(port_fn ~= nil,string.format("不存在名为%s的碰撞处理端",name))
    return port_fn(config)
end

local function defaultCollisionFilterFunc(shape1,shape2)
    return "slide"
end

return function(config)
    config.CollisionFilterFunc = config.CollisionFilterFunc or defaultCollisionFilterFunc

    local CellSize = config.CellSize or 256
    local CollisionFilterFunc = config.CollisionFilterFunc
    local Port = config.Port or "Bump"

    local collsion_world = {
        _port = createPort(Port,config),
        _objects = {},
        _objects_buffer = {},
        _idx_pool = IndexPool(),
    }

    function collsion_world:createShapeToBuffer(type,...)
        local idx = self._idx_pool:allocIndex()
        local shape = self._port:newShape(type,...)
        self._objects_buffer[idx] = shape
        shape._CWID = idx
        return idx
    end

    function collsion_world:createShapeToWorld(type,...)
        local idx = self._idx_pool:allocIndex()
        local shape = self._port:newShape(type,...)
        shape._CWID = idx
        self._objects[idx] = shape
        self._port:addShape(shape)
        return idx
    end

    function collsion_world:removeShape(idx)
        local shape = self._objects[idx]
        if shape == nil then
            shape = self._objects_buffer[idx]
            if shape == nil then
                return false
            end
            self._objects_buffer[idx] = nil
            return shape
        end

        self._objects[idx] = nil
        self._idx_pool:freeIndex(idx)
        self._port:removeShape(shape)
        return shape
    end

    function collsion_world:getShape(idx)
        local shape = self._objects[idx]
        if shape == nil then
            shape = self._objects_buffer[idx]
        end
        return shape
    end

    function collsion_world:shapeToBuffer(idx)
        local shape = self._objects[idx]
        if shape == nil then return false end
        self._port:removeShape(shape)
        self._objects_buffer[idx] = shape
        self._objects[idx] = nil
        return true
    end

    function collsion_world:shapeToWorld(idx)
        local shape = self._objects_buffer[idx]
        if shape == nil then return false end
        self._objects[idx] = shape
        self._objects_buffer[idx] = nil
        self._port:addShape(shape)
        return true
    end

    function collsion_world:shapeMove(idx,dx,dy,filter_func)
        filter_func = filter_func or defaultCollisionFilterFunc
        local shape = self._objects[idx]
        if shape == nil then return nil end
        return self._port:shapeMove(shape,dx,dy,filter_func)
    end

    function collsion_world:shapeMoveTo(idx,x,y,filter_func)
        local shape = self._objects[idx]
        if shape == nil then return nil end
        return self._port:shapeMoveTo(shape,dx,dy)
    end

    function collsion_world:shapeGetPosition(idx)
        local shape = self._objects[idx]
        if shape == nil then return nil end
        return self._port:shapeGetPosition(shape)
    end

    function collsion_world:shapeSetPropertiy(idx,name,value)
        local shape = self:getShape(idx)
        if not shape then return end
        self._port:shapeSetPropertiy(shape,name,value)
    end

    function collsion_world:shapeGetPropertiy(idx,name)
        local shape = self:getShape(idx)
        if not shape then return nil end
        return self._port:shapeGetPropertiy(shape,value)
    end

    return collsion_world
end