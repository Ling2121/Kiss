local ffi = require"ffi"

return function(width,height,tile_size)
    width = width or 32
    height = height or 32
    tile_size = tile_size or 16
    local canvas_width = width * tile_size
    local canvas_height = height * tile_size
    local count = w * h;
    local self = {
        width = w,
        height = h,
        tiles = ffi.new("int[?]",count,0),
        canvas = love.graphics.newCanvas(canvas_width,canvas_height),
    }

    return self;
end