return {
    name = "audio",
    
    type_tag = "audio",
    extension = {
        "ogg",
        "mp3",
        "wav"
    },

    has = function(res,path,...) return res.item ~= nil end;

    load = function(res,path,setting)
        if res.item ~= nil then return end;
        res.item = love.audio.newSource(path,"stream")
    end;

    get = function(res,path)
        return res.item
    end
}