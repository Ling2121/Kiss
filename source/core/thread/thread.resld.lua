return {
    name = "thread",
    
    type_tag = "thread",
    extension = {"thread.lua"},

    load = function(res,path,setting)
        local thread = loadstring(love.filesystem.read(path))()
        local name = thread.name
        local type = thread.type
        local func = thread.func
        core.Thread:createThread(type,name,func)
    end;

    get = function(res,path)
        
    end
}