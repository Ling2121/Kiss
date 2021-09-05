local dkjson = require"library/dkjson"

local utilities = {}

FILE_TYPE_IMAGE = 0
FILE_TYPE_AUDIO = 1
FILE_TYPE_FONT = 2
FILE_TYPE_TILESET = 3
FILE_TYPE_LUAFILE = 4

local match_table = {
    -- lua文件
    {"([0-9a-zA-z_]+)%.lua", FILE_TYPE_LUAFILE,".lua"},

    -- 图像文件
    {"([0-9a-zA-z_]+)%.png", FILE_TYPE_IMAGE,".png"},
    {"([0-9a-zA-z_]+)%.jpg", FILE_TYPE_IMAGE,".jpg"},
    {"([0-9a-zA-z_]+)%.jpeg",FILE_TYPE_IMAGE,".jpeg"},

    -- 音频
    {"([0-9a-zA-z_]+)%.ogg", FILE_TYPE_AUDIO,".ogg"},
    {"([0-9a-zA-z_]+)%.mp3", FILE_TYPE_AUDIO,".mp3"},
    {"([0-9a-zA-z_]+)%.wav", FILE_TYPE_AUDIO,".wav"},

    -- 字体
    {"([0-9a-zA-z_]+)%.otf", FILE_TYPE_FONT,".otf"},
    {"([0-9a-zA-z_]+)%.ttf", FILE_TYPE_FONT,".ttf"},

    --瓷砖集
    {"([0-9a-zA-z_]+)%.tileset%.json", FILE_TYPE_TILESET,".tileset.json"},
}

function utilities.getAllFileItem(dir,tb)
    tb = tb or {}
    local fitem = love.filesystem.getDirectoryItems(dir)

    for k,name in ipairs(fitem) do
        local p = dir.."/"..name
        local type =  love.filesystem.getInfo(p).type

        for i,matstr in ipairs(match_table) do
            local mat = matstr[1]
            local t = matstr[2]
			local n = name:match(mat) 
			if n then
                table.insert(tb,{
                    name = n,
                    type = t,
                    path = dir .. "/" .. name,--带拓展名的路径
                    path2 = dir .."/" ..n,--不带拓展名的路径
                    dir = dir,
				})
				break
            end
        end

        if type == "directory" then
            utilities.getAllFileItem(p,tb)
        end
	end

    return tb
end

function utilities.PPCenter(p1x,p1y,p2x,p2y)
    return math.floor((p1x + p2x) / 2),math.floor((p1y + p2y) / 2)
end

function utilities.PPRadian(p1x,p1y,p2x,p2y)
    if p1x==p2x and p1y==p2y then return 0 end 
	local r = - math.atan((p2x-p1x)/(p2y-p1y))
	if p1y-p2y<0 then r=r+math.pi end
	if r<0 then r=r+2*math.pi end
	return r
end

function utilities.loadJsonToTable(path)
    local json_str = love.filesystem.read(path,love.filesystem.getInfo(path).size)
    return dkjson.decode(json_str)
end

local lm_noise = love.math.noise
function utilities.noise3D(x,y,z,frequency,exponent,scale)
    local freq = frequency
    local nx,ny,nz = frequency * (x / scale - 0.5),
        frequency * (y / scale - 0.5),
        frequency * (z / scale - 0.5)
    local n = lm_noise(1 * nx,1 * ny,1 * nz,1 * nz)
        +0.5 *lm_noise(2 * nx,2 * ny,2 * nz,2 * nz)
        +0.25*lm_noise(4 * nx,4 * ny,4 * nz,4 * nz)
    n = n / 1.75
    return math.pow(n,exponent) -- [0 - 1]
end

return utilities