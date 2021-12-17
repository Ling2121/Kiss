--碰撞处理端口
--用于封装任意库，以供框架使用

return function(port)
    port = port or {}

    --创建一个多边形
    port.newPolygon = function(self,...)end
    --创建一个矩形
    port.newRectangle = function(self,x,y,w,h)end
    --创建一个圆形
    port.newCircle = function(self,x,y,r)end
    --创建一个点
    port.newPoint = function(self,x,y,r)end
    --添加形状
    port.addShape = function(self,shape)end
    --删除形状
    port.removeShape = function(self,shape)end
    --移动形状（偏移）
    port.shapeMove = function(self,shape,dx,dy,filter_func)
        --[[
            filter_func(shape,other) 
                return true --返回true表示通过，返回false表示过滤（不进行碰撞计算）
                            --还有一些特殊的返回值，这要看端的实现
            end

        ]]
    end
    --移动形状到指定位置
    port.shapeMoveTo = function(self,shape,x,y,filter_func)end
    --获取形状位置
    port.shapeGetPosition = function(self,shape) return 0,0 end
    --设置形状属性表
    port.shapeSetPropertiy = function(self,shape,k,v) end
    --获取属性表项
    port.shapeGetPropertiy = function(self,shape,k) end

    port.newShape = function(self,type,...)
        if type == "polygon" then
            return self:newPolygonShape(...)
        end
        if type == "rectangle" then
            return self:newRectangle(...)
        end
        if type == "circle" then
            return self:newCircle(...)
        end
        if type == "point" then
            return self:newPoint(...)
        end
        error(string.format("不存在%s类型的Shape对象",type))
    end

    return port
end