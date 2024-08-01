local image = nil
local pixels = {}
local sizeX = 10
local sizeY = 10
local spacing = 1

local physicsInstace = require("yan.instance.physics_instance")
local uimgr = require("yan.uimanager")
local toolbar = require("toolbar")
local utils = require("yan.utils")
local imageIndex = 1

local toClear = {}

function Reset()
    for ii, image in ipairs(pixels) do
        for i, pixel in ipairs(image) do
            pixel.body:setActive(false)
            pixel.SceneEnabled = false
        end
    end
    --world = love.physics.newWorld(0,300,true)
    --pixels = {}
    --imageIndex = 1
end

function love.load()
    world = love.physics.newWorld(0,300,true)
    
    wall = physicsInstace:New(nil, world, "static", "rectangle", {X = 2000, Y = 50}, 0, 0, {X = 0, Y = 500})
    wall.body:setX(0)
    wall.body:setY(500)
    wall:SetColor(1,1,1,1)
    wall.Shape = "rectangle"
    wall.Size = {X = 2000, Y = 50}

    toolbar:Init(Reset)
end

function love.update(dt)
    if toolbar.running then 
        world:update(dt) 
    end
    wall:Update()
    
    for _, image in ipairs(pixels) do
        for _, pixel in ipairs(image) do
            pixel:Update()
        end
    end
    
    uimgr:Update()

    for _, v in ipairs(toClear) do
        v.body:destroy()
    end
end

function love.draw()
    for _, image in ipairs(pixels) do
        for _, pixel in ipairs(image) do
            pixel:Draw()
        end
    end
    
    wall:Draw()
    uimgr:Draw()
end

function love.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(1) then
        if toolbar.tool == "move" then
            local imagesToDrag = {}

            for _, image in ipairs(pixels) do
                for _, pixel in ipairs(image) do
                    if utils:CheckCollision(x, y, 4, 4, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
                        table.insert(imagesToDrag, image)
                        break
                    end
                end
            end
            for _, image in ipairs(imagesToDrag) do
                for _, pixel in ipairs(image) do
                    pixel.body:setX(pixel.body:getX() + dx)
                    pixel.body:setY(pixel.body:getY() + dy)
                end
            end
        end
        
        if toolbar.tool == "delete" then
            for _, image in ipairs(pixels) do
                for i, pixel in ipairs(image) do
                    if utils:CheckCollision(x, y, 30, 30, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
                        table.remove(image, i)
                        pixel.body:destroy()
                        pixel.body:release()
                        pixel.body = nil
                        pixel = nil
                        break
                    end
                end
            end
        end
    end
end


function love.filedropped(file)
    local i = 1
    --[[for _, pixel in ipairs(pixels) do
        pixel.body:destroy()
        pixel = nil
    end]]

    pixels[imageIndex] = {}
    
    
    --pixels = {}
    
    file:open("r")
    fileData = file:read("data")
    
    local image
    
    local success, err = pcall(function()
        image = love.image.newImageData(fileData)
    end)
    
    if not success then
        love.window.showMessageBox("Error", "This is not a valid image!", "error", false)
        return
    end

    if image:getWidth() * image:getHeight() >= 50*50 then
        love.window.showMessageBox("Beware!", "This image is quite large! It will probably lag a lot!", "warning", false)
    end
    
    
    
    
    local mX, mY = love.mouse.getPosition()
    
    local imageWidth = image:getWidth() * spacing * sizeX
    local imageHeight = image:getHeight() * spacing * sizeY
    
    for x = 0, image:getWidth() - 1 do
        for y = 0, image:getHeight() - 1 do
            local r, g, b, a = image:getPixel(x,y)
            if a ~= 0 then
                pixels[imageIndex][i] = physicsInstace:New(nil, world, "dynamic", "rectangle", {X = sizeX, Y = sizeY}, 0, 0, 
                {
                    X = x * sizeX * spacing + mX - imageWidth / 2, 
                    Y = y * sizeY * spacing + mY - imageHeight / 2
                })
                pixels[imageIndex][i]:SetColor(r,g,b,a)
                pixels[imageIndex][i].Shape = "rectangle"
                pixels[imageIndex][i].Size = {X = sizeX, Y = sizeY}
                i = i + 1
            end
        end
    end

    imageIndex = imageIndex + 1

    print("done")
end