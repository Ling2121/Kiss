return {
    name = "font",

    has = function(res,path,size) 
        res.fonts = res.fonts or {}
        if size ~= nil then
            return res.fonts[size] ~= nil 
        end
        return res.fonts[DEFINE_FONT_SIZE] ~= nil
    end;

    load = function(res,path,setting,size)
        size = size or DEFINE_FONT_SIZE
        res.fonts = res.fonts or {}
        if res.fonts[size] then return end

        res.fonts[size] = love.graphics.newFont(path,size)
    end;

    get = function(res,path,size)
        res.fonts = res.fonts or {}
        return res.fonts[size]
    end
}