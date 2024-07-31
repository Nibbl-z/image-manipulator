local image = nil
local pixels = {}
local sizeX = 5
local sizeY = 20
local spacing = 0.1

function love.load()
     
end

function love.update()
    
end

function love.draw()
    if pixels ~= nil then
        for _, x in ipairs(pixels) do
            for _, y in ipairs(x) do
                love.graphics.setColor(y[1], y[2], y[3], y[4])
                love.graphics.rectangle("fill", y[5] * sizeX * spacing, y[6] * sizeY * spacing, sizeX, sizeY)
            end
        end
    end
end

function love.filedropped(file)
    pixels = {}

    file:open("r")
    fileData = file:read("data")
    image = love.image.newImageData(fileData)

    for x = 0, image:getWidth() - 1 do
        pixels[x + 1] = {}
        for y = 0, image:getHeight() - 1 do
           
            local r, g, b, a = image:getPixel(x,y)
            
            pixels[x + 1][y + 1] = {r, g, b, a, x, y}
        end
    end

    print("done")
end