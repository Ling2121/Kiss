--注意：引用的bump库的经过修改的,详细请查看“library/bump/bump.lua”
--只对item的添加和删除做了改动，以便更容易整合
local CollisionPort = require"source/core/collision/collision_port"
local bump = require"library/bump/bump"

local function getPolygonBbox(...)
    local points = {...}
    local min_x,min_y = points[1],points[2]
    local max_x,max_y = min_x,min_y
    for i = 1,#points,2 do
        local x = points[i]
        local y = points[i + 1]
        if x < min_x then min_x = x end
        if y < min_y then min_y = y end
        if x > max_x then max_x = x end
        if y > max_y then max_y = y end
    end
    return min_x,min_y,max_x,max_y
end

return function(config)
    local cell_size = config.CellSize or 256
    local port = CollisionPort{
        world = bump.newWorld(cell_size)
    }
    --创建一个多边形
    port.newPolygon = function(self,...)
        local min_x,min_y,max_x,max_y = getPolygonBbox(...)
        local x,y,w,h = min_x,min_y,max_x - min_x,max_y - min_y
        return self:newRectangle(x,y,w,h)
    end
    --创建一个矩形
    port.newRectangle = function(self,x,y,w,h)
        local item = self.world:newItem(x,y,w,h)
        item._properties = {}
        return item
    end
    --创建一个圆形
    port.newCircle = function(self,x,y,r)
        return self:newRectangle(x,y,r,r)
    end
    --创建一个点
    port.newPoint = function(self,x,y,r)
        return self:newRectangle(x,y,2,2)
    end
    --添加形状
    port.addShape = function(self,shape)
        self.world:add(shape)
    end
    --删除形状
    port.removeShape = function(self,shape)
        self.world:remove(shape)
    end
    --移动形状（偏移）
    port.shapeMove = function(self,shape,dx,dy,filter_func)
        local x,y,c = self.world:move(shape,shape.x + dx,shape.y + dy,filter_func)
        return c
    end
    --移动形状到指定位置
    port.shapeMoveTo = function(self,shape,x,y,filter_func)
        return self.world:update(shape,x,y)
    end
    --获取形状位置
    port.shapeGetPosition = function(self,shape) 
        return shape.x,shape.y
    end
    --设置形状属性表
    port.shapeSetPropertiy = function(self,shape,k,v) 
        shape._properties[k] = v
    end
    --获取属性表项
    port.shapeGetPropertiy = function(self,shape,k)
        return shape._properties[k]
    end

    return port
end