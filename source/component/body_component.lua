return core.ComponentConstructor("BodyComponent",{
    make = function(_,self,slots)
        --[[
            part : {
                depth = 0,   //depth
                draw_object = ...//所有love.graphics.draw可绘制的对象
                x = 0,
                y = 0,
                ox = 0, //origin X
                oy = 0, //origin Y
                r = 0,   //rotate (angle)
                sx = 1,   //scale X
                sy = 1,   //scale Y
            }
        ]]
        -- 5
        self.parts = {}
        self._update_parts = {}
        if parts ~= null then
            for name,part in pairs(parts) do
                part.name = tostring(name)
                table.insert(self.parts,part)
                self.parts[part.name] = part

                if part.update ~= nil then
                    self._update_parts[part] = part
                end
            end
            table.sort(self.parts,function(a,b)
                assert(a.d ~= nil,string.format("部件%s,未定义d属性(深度值)",a.name))
                assert(b.d ~= nil,string.format("部件%s,未定义d属性(深度值)",b.name))
                return a.d > b.d
            end)
        end

        function self:getPart(name)
            return self.parts[name]
        end

        function self:draw()
            for i,part in ipairs(self.parts) do
                local type = parts.draw_object:type()
                local x,y = part.x,part.y
                if type == "Tile" then
                    part.draw_object:draw(part.x,part.y,part.r,part.sx,part.sy,part.ox,part.oy)
                elseif type == "TileSet" then
                    love.graphics.draw(part.draw_object.image,part.x,part.y,part.r,part.sx,part.sy,part.ox,part.oy)
                else
                    love.graphics.draw(part.draw_object,part.x,part.y,part.r,part.sx,part.sy,part.ox,part.oy)
                end
            end
        end
    end
})