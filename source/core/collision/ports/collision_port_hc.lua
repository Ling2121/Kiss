local CollisionPort = require"source/core/collision/collision_port"

if not (type(common) == 'table' and common.class and common.instance) then
	assert(common_class ~= false, 'No class commons specification available.')
	require("library.HC.class")
end

local SpaceHash = require"library.HC.spatialhash"
local Shapes = require"library.HC.shapes"
local IndexPool = require"source/core/base/index_pool"

return function(config)
    local cell_size = config.CellSize or 256
    local port = CollisionPort{
        space_hash = SpaceHash(cell_size),
    }

    port._neighbors = function(self,shape,x1,y1,x2,y2)
        if x1 == nil then
            x1,y1,x2,y2 = shape:bbox()
        end
        local neighbors = self.space_hash:inSameCells(x1,y1,x2,y2)
        rawset(neighbors, shape, nil)
        return neighbors
    end

    port._collisions = function(self,shape)
        local candidates = self:_neighbors(shape)
        local c = 0
        for other in pairs(candidates) do
            local collides, dx, dy = shape:collidesWith(other)
            if collides then
                c = c + 1
                rawset(candidates, other, {dx=dx, dy=dy})
            else
                rawset(candidates, other, nil)
            end
        end
        return candidates
    end

    --创建一个多边形
    port.newPolygon = function(self,...)
        return Shapes.newPolygonShape(...)
    end
    --创建一个矩形
    port.newRectangle = function(self,x,y,w,h)
        return Shapes.newPolygonShape(x,y, x+w,y, x+w,y+h, x,y+h)
    end
    --创建一个圆形
    port.newCircle = function(self,x,y,r)
        return Shapes.newCircleShape(x,y,r)
    end
    --创建一个点
    port.newPoint = function(self,x,y)
        return Shapes.newPointShape(x,y)
    end
    --添加形状
    port.addShape = function(self,shape)
        local x1,y1,x2,y2 = shape:bbox()
        self.space_hash:register(shape,x1,y1,x2,y2)
    end
    --删除形状
    port.removeShape = function(self,shape)
        local x1,y1,x2,y2 = shape:bbox()
        self.space_hash:remove(shape,x1,y1,x2,y2)
    end
    --移动形状（偏移）
    port.shapeMove = function(self,shape,dx,dy)
        local old_x1,old_y1,old_x2,old_y2 = shape:bbox()
        shape:move(dx,dy)
        local collisions = self:_collisions(shape)
        local vx,vy = 0,0
        local t = {}
        for _shape,collision in pairs(collisions) do
            local dx,dy = collision.dx,collision.dy
            local hash = math.ceil(dy) * 23333 + math.ceil(dx)
            if t[hash] == nil then
                t[hash] = hash
                vx = vx + dx
                vy = vy + dy
            end
        end
        shape:move(vx,vy)
        self.space_hash:update(shape,old_x1,old_y1,old_x2,old_y2,shape:bbox())
        return collisions
    end
    --移动形状到指定位置
    port.shapeMoveTo = function(self,shape,x,y)
        local old_x1,old_y1,old_x2,old_y2 = shape:bbox()
        shape:moveTo(dx,dy)
        self.space_hash:update(shape,old_x1,old_y1,old_x2,old_y2,shape:bbox())
        return self:_collisions(shape)
    end
    --获取形状位置
    port.shapeGetPosition = function(self,shape) 
        return shape:bbox()
    end
    --设置形状属性表
    port.shapeSetPropertiy = function(self,shape,k,v) 
        shape._properties = shape._properties or {}
        shape._properties[k] = v
    end
    --获取属性表项
    port.shapeGetPropertiy = function(self,shape,k)
        shape._properties = shape._properties or {}
        return shape._properties[k]
    end

    return port
end

