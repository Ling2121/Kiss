local LoveFrames = require"library/LoveFrames/loveframes"

local ww = love.graphics.getWidth()
local wh = love.graphics.getHeight()

local PWw = ww * 0.2
local PWh = wh

local Canvas1_x = PWw + 40
local Canvas1_y = math.floor(wh * 0.02)
local Canvas1_w = math.floor(wh * 0.9)
local Canvas1_h = math.floor(wh * 0.9)
local Canvas1_max_x = Canvas1_x + Canvas1_w
local Canvas1_max_y = Canvas1_y + Canvas1_h
local Canvas1 = love.graphics.newCanvas(Canvas1_w,Canvas1_h)
local Canvas1_ImageData = Canvas1:newImageData()
local MouseColor = {1,1,1,1}
local MouseColorFloatString = "Gray : 1"
local MouseColorByteString = "Gray : 255"
local Seed = 233
local Colors = {}
local SelectColor = {1,1,1,1}
local SelectColorFloatString = "Gray : 1"
local SelectColorByteString = "Gray : 255"
local DisplayMode = "gray" -- single : 单色模式   gray ：灰度模式  

local 
    SeedInput,
    SizeInput,
    FrequencyInput,
    ExponentInput,
    ScaleInput,
    GenerateButton,
    ItemList,
    PropertyWindow,
    PushProperty,
    NoiseFunc,
    ColorList

PushProperty = function(ItemList,name,defaut_value,is_drag,max,min)
    local Label = LoveFrames.Create("text")
    Label:SetText(name)
    ItemList:AddItem(Label)

    local Input = LoveFrames.Create("textinput")
    ItemList:AddItem(Input)
    Input:SetText(defaut_value)
    if is_drag then
        local Slider = LoveFrames.Create("slider")
        Slider:SetMinMax(max or 2048,min or -2048)
        Slider.OnValueChanged = function(self,v)
            Input:SetText(self.value)
            UpdateCanvas()
        end

        Input.OnTextChanged = function(self,v)
            v = tonumber(v)
            if v then
                if self.OnTextChanged2 then
                    self:OnTextChanged2(v)
                end
                Slider:SetValue(tonumber(v),true)
                UpdateCanvas()
            end
        end

        ItemList:AddItem(Slider)
    else
        Input.OnTextChanged = function(self,v)
            v = tonumber(self:GetText())
            if v then
                if self.OnTextChanged2 then
                    self:OnTextChanged2(v)
                end
                UpdateCanvas()
            end
        end
    end
    return Input
end
 

NoiseFunc = require"noise_func"

UpdateCanvas = function(mode)
    Canvas1_ImageData:release()

    local size = tonumber(SizeInput:GetText())
    local f = tonumber(FrequencyInput:GetText())
    local e = tonumber(ExponentInput:GetText())
    local s = tonumber(ScaleInput:GetText())
    local pix_size = math.ceil(Canvas1_w / size)
    love.graphics.setCanvas(Canvas1)
    love.graphics.clear()
    love.graphics.rectangle("line",0,0,Canvas1_w,Canvas1_h)
    local sg = math.floor(SelectColor[2] * 255)
    local is_s = mode == "single"
    for y = 0,size + 1 do
        for x = 0,size + 1 do
            local n = 1 - NoiseFunc(x,y,f,e,s,Canvas1_w,Canvas1_h,Seed)
            if is_s then
                if math.floor(n * 255) == sg then
                    love.graphics.setColor(n,n,n)
                    love.graphics.rectangle("fill",x * pix_size,y * pix_size,pix_size,pix_size)
                    love.graphics.setColor(1,1,1,1) 
                end
            else
                love.graphics.setColor(n,n,n)
                    love.graphics.rectangle("fill",x * pix_size,y * pix_size,pix_size,pix_size)
                    love.graphics.setColor(1,1,1,1) 
            end
        end
    end
    love.graphics.setCanvas()

    Canvas1_ImageData = Canvas1:newImageData()
end

function love.load()
    PropertyWindow = LoveFrames.Create("frame")
    PropertyWindow.name = "Property"
    PropertyWindow.width = PWw
    PropertyWindow.height = PWh
    PropertyWindow.draggable = false
    PropertyWindow.showclose = false
    PropertyWindow.allowclose = false

    ItemList = LoveFrames.Create("list",PropertyWindow)
    ItemList:SetPos(5,30)
    ItemList:SetSize(PWw - 10,PWh - 40)
    ItemList:SetPadding(5)
    ItemList:SetSpacing(5)


    GenerateButton = LoveFrames.Create("button")
    GenerateButton:SetText("Generate")
    ItemList:AddItem(GenerateButton)

    SeedInput = PushProperty(ItemList,"Seed",233)
    SizeInput = PushProperty(ItemList,"Size",256)
    FrequencyInput = PushProperty(ItemList,"Frequency",2.7,true,0,10)
    ExponentInput = PushProperty(ItemList,"Exponent",0.6,true,0,10)
    ScaleInput = PushProperty(ItemList,"Scale",128,true,0,2048)

    SeedInput.OnTextChanged2 = function(self,v)
        v = tonumber(self:GetText())
        if v then
            Seed = v
        end
    end

    love.graphics.setCanvas(Canvas1)
    love.graphics.rectangle("fill",0,0,Canvas1_w,Canvas1_h)
    love.graphics.setCanvas()
    love.graphics.setBackgroundColor(0,0,0,1)

    UpdateCanvas()

end

function love.update(dt)
	LoveFrames.update(dt)
end

local function DrawColorBox(x,y,box_c,t1,t2)
    local font = love.graphics.getFont()
    local w,h = 40,40
    local fw = math.max(font:getWidth(t1),font:getWidth(t2))
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line",x - 2,y - 2,fw + w + 14,h + 4)
    love.graphics.print(t1,x + w + 5,y)
    love.graphics.print(t2,x + w + 5,y + 20)

    love.graphics.setColor(box_c,box_c,box_c,box_c)
	love.graphics.rectangle("fill",x,y,w,h)
    love.graphics.setColor(1,1,1,1)
end

function love.draw()
    local size = tonumber(SizeInput:GetText()) or 1
    local pix_size = math.floor(Canvas1_w / size)
    local mx,my = love.mouse.getPosition()
    mx,my = math.ceil((mx - Canvas1_x) / pix_size) - 1,math.ceil((my - Canvas1_y) / pix_size) - 1
    love.graphics.draw(Canvas1,Canvas1_x,Canvas1_y)
	LoveFrames.draw()
    local x,y = ww * 0.23,wh * 0.93
    DrawColorBox(x,y,MouseColor[2],MouseColorFloatString,MouseColorByteString)
    DrawColorBox(x + 180,y,SelectColor[2],SelectColorFloatString,SelectColorByteString)
    love.graphics.print(string.format("Mouse(%d : %d)",mx,my),x + 360,y)
    love.graphics.print(string.format("Mode : %s",DisplayMode),x +360,y + 20)
end

function love.mousepressed(x, y, button)
	LoveFrames.mousepressed(x, y, button)

    if x < Canvas1_x or y < Canvas1_y 
    or x > Canvas1_max_x or y > Canvas1_max_y
    then
        return
    end
    local size = tonumber(SizeInput:GetText())
    local pix_size = math.floor(Canvas1_w / size)
    --local px,py = math.ceil((x - Canvas1_x) / pix_size) - 1,math.ceil((y - Canvas1_y) / pix_size) - 1
    local px,py = x - Canvas1_x,y - Canvas1_y
    local r,g,b,a = Canvas1_ImageData:getPixel(px,py)

    if button == 1 then
        MouseColor[1] = r
        MouseColor[2] = g
        MouseColor[3] = b
        MouseColor[4] = a
        MouseColorFloatString = string.format("Gray : %.2f",g)
        MouseColorByteString = string.format("Gray : %d",math.ceil(g* 255))
    end

    if button == 2 then
        SelectColor[1] = r
        SelectColor[2] = g
        SelectColor[3] = b
        SelectColor[4] = a
        SelectColorFloatString = string.format("Gray : %.2f",g)
        SelectColorByteString = string.format("Gray : %d",math.ceil(g* 255))
    end
end

function love.mousereleased(x, y, button)
	LoveFrames.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
	LoveFrames.wheelmoved(x, y)
end

function love.keypressed(key, isrepeat)
    if key == "return" then
        UpdateCanvas()
    elseif key == "s" then--单色模式
        UpdateCanvas("single")
        DisplayMode = "single"
    elseif key == "g" then--灰度模式
        UpdateCanvas("gray")
        DisplayMode = "gray"
    end
	LoveFrames.keypressed(key, isrepeat)
end

function love.keyreleased(key)
	LoveFrames.keyreleased(key)
end

function love.textinput(text)
	LoveFrames.textinput(text)
end