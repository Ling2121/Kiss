return {
    name = "image",

    has = function(res,path,...) return res.item ~= nil end;

    load = function(res,path,setting)
        if res.item ~= nil then return end;

        res.item = love.graphics.newImage(path)
    end;

    get = function(res,path)
        return res.item
    end
}