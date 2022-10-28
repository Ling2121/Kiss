local ffi = require"ffi"

return {
    initThreadRegionLoad = function()
        core.Thread:createThread("sanbox_region_thread",'loop',function()
            
        end)
        
    end
}