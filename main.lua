local image = nil
local pixels = {}
local sizeX = 15
local sizeY = 15
local spacing = 1

local physicsInstace = require("yan.instance.physics_instance")

function love.load()
    world = love.physics.newWorld(0,300,true)

    wall = physicsInstace:New(nil, world, "static", "rectangle", {X = 2000, Y = 50}, 0, 0, {X = 0, Y = 500})
    wall.body:setX(0)
    wall.body:setY(500)
    wall:SetColor(1,1,1,1)
    wall.Shape = "rectangle"
    wall.Size = {X = 2000, Y = 50}
end

function love.update(dt)
    world:update(dt)
    wall:Update()
    
    for _, x in ipairs(pixels) do
        x:Update()
    end
    
    if love.keyboard.isDown("space") then
        for _, x in ipairs(pixels) do
            x:ApplyForce(0,-1000)
        end
    end

    if love.keyboard.isDown("a") then
        for _, x in ipairs(pixels) do
            x:ApplyForce(-500, 0)
        end
    end
    
    if love.keyboard.isDown("d") then
        for _, x in ipairs(pixels) do
            x:ApplyForce(500, 0)
        end
    end
end

function love.draw()
    for _, x in ipairs(pixels) do
        x:Draw()
    end
    
    wall:Draw()
end

function love.filedropped(file)
    pixels = {}
    
    file:open("r")
    fileData = file:read("data")
    image = love.image.newImageData(fileData)
    
    local i = 1
    
    for x = 0, image:getWidth() - 1 do
        for y = 0, image:getHeight() - 1 do
            local r, g, b, a = image:getPixel(x,y)
            
            pixels[i] = physicsInstace:New(nil, world, "dynamic", "rectangle", {X = sizeX, Y = sizeY}, 0, 0, {X = x * sizeX * spacing, Y = y * sizeY * spacing})
            pixels[i]:SetColor(r,g,b,a)
            pixels[i].Shape = "rectangle"
            pixels[i].Size = {X = sizeX, Y = sizeY}
            i = i + 1
        end
    
        
    end

    

    print("done")
end