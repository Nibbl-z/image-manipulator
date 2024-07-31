local image = nil
local pixels = {}
local sizeX = 10
local sizeY = 10
local spacing = 1

local physicsInstace = require("yan.instance.physics_instance")
local uimgr = require("yan.uimanager")
local toolbar = require("toolbar")

function love.load()
    world = love.physics.newWorld(0,300,true)
    
    wall = physicsInstace:New(nil, world, "static", "rectangle", {X = 2000, Y = 50}, 0, 0, {X = 0, Y = 500})
    wall.body:setX(0)
    wall.body:setY(500)
    wall:SetColor(1,1,1,1)
    wall.Shape = "rectangle"
    wall.Size = {X = 2000, Y = 50}

    toolbar:Init()
end

function love.update(dt)
    if toolbar.running then 
        world:update(dt) 
    end
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
    
    uimgr:Update()
end

function love.draw()
    for _, x in ipairs(pixels) do
        x:Draw()
    end
    
    wall:Draw()

    uimgr:Draw()
end

function love.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(1) and toolbar.tool == "move" then
        for _, pixel in ipairs(pixels) do
            pixel.body:setX(pixel.body:getX() + dx)
            pixel.body:setY(pixel.body:getY() + dy)
        end
    end
    
    
end

function love.filedropped(file)
    pixels = {}
    
    file:open("r")
    fileData = file:read("data")
    image = love.image.newImageData(fileData)
    
    local i = 1
    
    local mX, mY = love.mouse.getPosition()
    
    local imageWidth = image:getWidth() * spacing * sizeX
    local imageHeight = image:getHeight() * spacing * sizeY
    
    for x = 0, image:getWidth() - 1 do
        for y = 0, image:getHeight() - 1 do
            local r, g, b, a = image:getPixel(x,y)
            
            pixels[i] = physicsInstace:New(nil, world, "dynamic", "rectangle", {X = sizeX, Y = sizeY}, 0, 0, 
            {
                X = x * sizeX * spacing + mX - imageWidth / 2, 
                Y = y * sizeY * spacing + mY - imageHeight / 2
            })
            pixels[i]:SetColor(r,g,b,a)
            pixels[i].Shape = "rectangle"
            pixels[i].Size = {X = sizeX, Y = sizeY}
            i = i + 1
        end
    
        
    end

    

    print("done")
end