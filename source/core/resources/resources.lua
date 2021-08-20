local utilities = require"library/utilities"

return function(path)
    local items = utilities.getAllFileItem(path)
    local resources = {}

    for i,item in ipairs(items) do
        if item.type == FILE_TYPE_IMAGE then
            resources[item.path] = {
                item = love.graphics.newImage(item.path),
                get = function(self)
                    return self.item
                end
            }
        end

        if items.type == FILE_TYPE_AUDIO then
            resources[item.path] = {
                item = love.graphics.newImage(item.path),
                get = function(self)
                    return self.item
                end
            }
        end

        if item.type == FILE_TYPE_FONT then
            resources[item.path] = {
                path = item.path,
                fonts = {},--各个大小的字体
                get = function(self,size)
                    if self.fonts[size] == nil then
                        self.fonts[size] = love.graphics.newFont(self.path,size)
                    end
                    return self.fonts[size]
                end
            }
        end
    end

    function resources:get(path,...)
        local item = self[path]
        if not item then
            return nil
        end
        return item:get(...)
    end

    return resources
end

