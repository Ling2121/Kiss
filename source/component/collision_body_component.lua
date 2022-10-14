return core.ComponentConstructor("CollisionBodyComponent",{
    --[[
        参数说明
            entities : 实体本身
            collision_world : 碰撞世界
            shape_type : 形状类型
                'polygon' 多边形
                    后续参数
                        points ：table {p1x,p1y,p2x,p2y,pnx,pny,...} 顶点数组
                ’rectangle‘ 矩形
                    后续参数
                        x : number x轴位置
                        y ：number y轴位置
                        w ：number 宽
                        h ：number 高
                ‘circle’ 原型
                    后续参数
                        x : number x轴位置
                        y ：number y轴位置
                        r : number 半径
                'point'
                    后续参数
                        x : number x轴位置
                        y ：number y轴位置
        示例
        创建一个多边形组件
            local polygon  = CollisionBodyComponent('polygon',{100,100,300,300,200,200,150,150})
        创建一个矩形组件
            local rectangle = CollisionBodyComponent("rectangle",100,100,50,50)

    ]]
    make = function(self,component,collision_world,shape_type,...)
        component.collision_world = collision_world

        component.ready = function(self)
            self.collision_world:shapeToWorld(self.shape_idx)
        end

        component.bindShape = function(self,shape_type,...)
            self.shape_idx = self.collision_world:createShapeToBuffer(shape_type,...)
            return self
        end

        component.bindEntity = function(self,entity)
            self.collision_world:shapeSetPropertiy(self.shape_idx,"entity",entity)
            return self
        end

        component.bindPositionComponent = function(self,p)
            self.position_component = p
            return self
        end

        component.getBindEntity = function(self)
            return self.collision_world:shapeGetPropertiy(self.shape_idx,"entity")
        end

        component.move = function(self,dx,dy,filter_func)
            if dx == 0 and dy == 0 then return nil end
            return self.collision_world:shapeMove(self.shape_idx,dx,dy,filter_func)
        end

        --移动并且同步到Position组件（必须通过bindPositionComponent函数绑定Position组件）
        component.moveAndSyncToPosition = function(self,dx,dy,filter_func)
            local c = self:move(dx,dy,filter_func)
            self.position_component.x,self.position_component.y = self.collision_world:shapeGetPosition(self.shape_idx)
            return c
        end


        if shape_type ~= nil then
            component:bindShape(shape_type,...)
        end
    end
})