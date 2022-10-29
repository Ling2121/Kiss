local function createFiles(dir,dir_struct)
    if next(dir_struct) == nil then return end

    for name,t in pairs(dir_struct) do
        local d = string.format("%s/%s/",dir,name)
        love.filesystem.createDirectory(d)
        createFiles(d,t or {})
    end
end

return function()
    local self = {}

    function self:init(dir_struct)
        createFiles(dir_struct)
    end

    return self
end