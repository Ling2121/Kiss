--返回用于创建实体构造器的函数

local callback_list = require"source/core/scene/callback_list"

local function IsHaveCallback(object,callback_name)
    return object[callback_name] ~= nil
end

return function(type_name,t)
    t.type_name = type_name
    t.make = t.make or function(self,entity,...)end
    t.create = function(self,...)
        local entity = {
            _cb_channels = {},
        }
        
        entity._getCallbackChannel = function(self,cname)
            local cb_channel =  self._cb_channels[cname]
            if cb_channel == nil then
                cb_channel = {}
                self._cb_channels[cname] = cb_channel
                self[cname] = function(self,...)
                    for i,c in ipairs(cb_channel) do
                        c[cname](c,self,...)
                    end
                end
            end
            cb_channel.idx_hash = cb_channel.idx_hash or {}
            return cb_channel
        end

        entity._addObjectToCallbackChannel = function(self,callback_name,object)
            local cb_channel = self:_getCallbackChannel(callback_name)
            local next_idx = #cb_channel + 1
            cb_channel[next_idx] = object
            cb_channel.idx_hash[object] = next_idx
        end

        entity._removeObjectFromCallbackChannel = function(self,callback_name,object)
            local cb_channel = self:_getCallbackChannel(callback_name)
            local idx = cb_channel.idx_hash[object]
            if idx ~= nil then
                table.remove(cb_channel,idx)

                for i = idx + 1,#cb_channel do
                    local object = cb_channel[idx]
                    cb_channel.idx_hash[object] = i - 1
                end
            end
        end

        entity.addComponent = function(self,component,...)
            if component.__is_constructor__ == true then
                component = component(...)
            end
        
            local name = component.__comp_name__
            if self.components[name] ~= nil then
                return
            end

            --添加组件的回调到实体（callback_list内支持的）
            for i,cname in ipairs(callback_list) do
                if IsHaveCallback(component,cname) then
                    self:_addObjectToCallbackChannel(cname,component)
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
                if IsHaveCallback(component,cname) then
                    self:_removeObjectFromCallbackChannel(cname,component)
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