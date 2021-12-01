local lm_noise = love.math.noise

return function(x,y,frequency,exponent,scale,w,h,seed)
    local nx,ny,nz = frequency * (x / scale - 0.5),
        frequency * (y / scale - 0.5)
    local n = lm_noise(1 * nx,1 * ny,seed)
        +0.5 *lm_noise(2 * nx,2 * ny,seed)
        --+0.25*lm_noise(4 * nx,4 * ny,seed)
    n = n / 1.75
    return math.pow(n,math.sin(exponent))
end

