--返回用于创建实体构造器的函数

local callback_list = require"source/core/scene/callback_list"

return function(type_name,t)
    t.type_name = type_name
    t.make = t.make or function(self,entity,...)end
    t.create = function(self,...)
        local entity = {
            _cb_channels = {},
        }
        
        entity.addComponent = function(self,component,...)
            if component.__is_constructor__ == true then
                component = component(...)
            end
        
            local name = component.__comp_name__
            if self.components[name] ~= nil then
                return
            end

            for i,cname in ipairs(callback_list) do
                if component[cname] then
                    local cb_channel =  self._cb_channels[cname]
                    if cb_channel == nil then
                        cb_channel = {}
                        self._cb_channels[cname] = cb_channel
                        self[cname] = function(self,...)
                            for i,c in pairs(cb_channel) do
                                c[cname](c,self,...)
                            end
                        end
                    end
                    cb_channel[component] = component
                end
            end
            self.components[name] = component

            return component
        end
        
        entity.removeComponent = function(self,component_name)
            if self.components[component_name] == nil then
                return
            end
            local c = self.components[component_name]
        
            for i,cname in ipairs(callback_list) do
                if component[cname] then
                    local cb_channel =  self._cb_channels[cname]
                    cb_channel[c] = nil
                end
            end
        
            self.components[component_name] = nil

            return c
        end

        entity.getComponent = function(self,name)
            return self.components[name]
        end

        entity.hasComponent = function(self,name)
            return self.components[component_name] ~= nil
        end


        local new_entity = {
            name = "",
            --请勿直接对其进行操作
            --要添加和删除需要使用 addComponent以及removeComponent 方法
            components = {},
        }

        --这样设置主要是为了数据与逻辑分离
        setmetatable(new_entity,{__index = entity})
        
        self:make(new_entity,...)
        return new_entity
    end
    
    return setmetatable(t,{__call = t.create})
end