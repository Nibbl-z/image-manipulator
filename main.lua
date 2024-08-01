local image = nil
local pixels = {}
local sizeX = 10
local sizeY = 10
local spacing = 1
local grabSpeed = 200
local explosionForce = 250000
local physicsInstace = require("yan.instance.physics_instance")
local uimgr = require("yan.uimanager")
local toolbar = require("toolbar")
local utils = require("yan.utils")
local imageIndex = 1

local toClear = {}

local brushSize = 50

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
    
    local mX, mY = love.mouse.getPosition()
    
    if toolbar.tool == "grab" and love.mouse.isDown(1) then
        for _, image in ipairs(pixels) do
            for _, pixel in ipairs(image) do
                if utils:CheckCollision(mX, mY, brushSize, brushSize, pixel.body:getX(), pixel.body:getY(), pixel.Size.X, pixel.Size.Y) then
                    local forceX, forceY = 0,0 
                    
                    if pixel.body:getX() < mX then
                        forceX = grabSpeed
                    end
                    
                    if pixel.body:getX() > mX then
                        forceX = -grabSpeed
                    end
                    
                    if pixel.body:getY() < mY then
                        forceY = grabSpeed
                    end
                    
                    if pixel.body:getY() > mY then
                        forceY = -grabSpeed
                    end
                    pixel.body:setGravityScale(0)
                    pixel.body:applyForce(forceX, forceY)
                else
                    pixel.body:setGravityScale(1)
                end
            end
        end
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
    
    if toolbar.tool == "delete" or toolbar.tool == "grab" or toolbar.tool == "explosion" then
        local mX, mY = love.mouse.getPosition()
        love.graphics.setColor(1,1,1,1)
        love.graphics.circle("line", mX, mY, brushSize)
    end
end
local imagesToScale = {}
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
                    if utils:CheckCollision(x, y, brushSize, brushSize, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
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
        
        if toolbar.tool == "scale" then
            if #imagesToScale == 0 then
                for _, image in ipairs(pixels) do
                    for _, pixel in ipairs(image) do
                        if utils:CheckCollision(x, y, 4, 4, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
                            
                            table.insert(imagesToScale, image)
                            break
                        end
                    end
                end
            end
            
            for _, image in ipairs(imagesToScale) do
                for _, pixel in ipairs(image) do
                    print("literaly image")
                    pixel.Scaling = true
                    pixel.Size.X = pixel.Size.X + dx / pixel.ImageSize.X * 2
                    pixel.Size.Y = pixel.Size.Y + dy / pixel.ImageSize.Y * 2
                    
                    local imageWidth = pixel.ImageSize.X * spacing * pixel.Size.X
                    local imageHeight = pixel.ImageSize.Y * spacing * pixel.Size.Y 
                    
                    pixel.body:setX(pixel.PixelPosition.X * pixel.Size.X * spacing + x - imageWidth / 2)
                    pixel.body:setY(pixel.PixelPosition.Y * pixel.Size.Y * spacing + y - imageHeight / 2)
                end
            end
        end
    end
end

function love.mousepressed(x,y,button)
    if button ~= 1 then return end
    
    if toolbar.tool == "explosion" then
        for _, image in ipairs(pixels) do
            for _, pixel in ipairs(image) do
                if utils:CheckCollision(x, y, brushSize, brushSize, pixel.body:getX(), pixel.body:getY(), pixel.Size.X, pixel.Size.Y) then
                    local forceX, forceY = 0,0 
                    
                    if pixel.body:getX() < x then
                        forceX = -explosionForce
                    end
                    
                    if pixel.body:getX() > x then
                        forceX = explosionForce
                    end
                    
                    if pixel.body:getY() < y then
                        forceY = -explosionForce
                    end
                    
                    if pixel.body:getY() > y then
                        forceY = explosionForce
                    end
                    
                    pixel.body:applyForce(forceX, forceY)
                end
            end
        end
    end
end

function love.mousereleased()
    if toolbar.tool == "scale" then
        if #imagesToScale > 0 then
            print("HAI")
            for _, image in ipairs(imagesToScale) do
                for _, pixel in ipairs(image) do
                    pixel.Scaling = false
                    pixel.shape = love.physics.newRectangleShape(math.abs(pixel.Size.X), math.abs(pixel.Size.Y))
                    pixel.fixture = love.physics.newFixture(pixel.body, pixel.shape)
                    pixel.fixture:setUserData(pixel.Name)
                end
            end
        end
    end

    imagesToScale = {}
end

function love.wheelmoved(x, y)
    if toolbar.tool == "delete" or toolbar.tool == "grab" or toolbar.tool == "explosion" then
        brushSize = utils:Clamp(brushSize + y, 5, 10000)
    end
end

function love.filedropped(file)
    local i = 1

    pixels[imageIndex] = {}
 
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
        local result = love.window.showMessageBox(
            "Beware!", 
            "This image is quite large! It will probably lag a lot! \n Are you sure you want to import this image?", 
            {"Cancel", "Import Anyway"},
            "warning",
            false
        )
        
        if result == 1 then return end
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
                pixels[imageIndex][i].PixelPosition = {
                    X = x ,
                    Y = y,
                }
                pixels[imageIndex][i].ImageSize = {X = image:getWidth(), Y = image:getHeight()}
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