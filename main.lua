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

local currentPlatform = nil
local platforms = {}

local cX, cY = 0, 0
local cameraX, cameraY = 0, 0
local camSpeed = 300

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

function SetGravity(gravity)
    world:setGravity(0,gravity)
end

function SetExplosionForce(force)
    explosionForce = force
end

function SetXScale(scale)
    sizeX = scale
end

function SetYScale(scale)
    sizeY = scale
end

function love.load()
    love.window.setMode(800, 600, {resizable = true})
    love.window.setTitle("Image Playground")

    world = love.physics.newWorld(0,300,true)

    toolbar:Init(Reset, SetGravity, SetExplosionForce, SetXScale, SetYScale)
end
local directions = {a = {1,0}, d = {-1,0}, w = {0,1}, s = {0,-1}}
function love.update(dt)
    if toolbar.running then 
        world:update(dt) 
    end
    --wall:Update()
    
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

    for key, data in pairs(directions) do 
        if love.keyboard.isDown(key) then 
            cX = cX + camSpeed * data[1] * dt
            cY = cY + camSpeed * data[2] * dt
        end
    end

    cameraX = cameraX + cX
    cameraY = cameraY + cY
    
    cX, cY = 0,0
end

function love.draw()
    for _, image in ipairs(pixels) do
        for _, pixel in ipairs(image) do
            pixel:Draw(cameraX, cameraY)
        end
    end
    
    for _, platform in ipairs(platforms) do
        platform:Draw(cameraX, cameraY)
    end

    if currentPlatform ~= nil then
        love.graphics.setColor(1,1,1,0.5)
        love.graphics.rectangle("fill", currentPlatform.X, currentPlatform.Y, currentPlatform.W, currentPlatform.H)
    end

    uimgr:Draw()
    
    if toolbar.tool == "delete" or toolbar.tool == "grab" or toolbar.tool == "explosion" or toolbar.tool == "deleteimage" or toolbar.tool == "deleteplatform" then
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
                    if utils:CheckCollision(x - cameraX, y - cameraY, 4, 4, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
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
                    if utils:CheckCollision(x - cameraX, y - cameraY, brushSize, brushSize, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
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
        
        if toolbar.tool == "deleteimage" then
            local toDelete = {}
            
            for _, image in ipairs(pixels) do
                for i, pixel in ipairs(image) do
                    if utils:CheckCollision(x - cameraX, y - cameraY, brushSize, brushSize, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
                        table.insert(toDelete, image)
                        break
                    end
                end
            end
            
            for _, image in ipairs(toDelete) do
                for i, pixel in ipairs(image) do
                    pixel.body:setActive(false)
                    pixel.SceneEnabled = false
                end
            end
        end
        
        if toolbar.tool == "scale" then
            if #imagesToScale == 0 then
                for _, image in ipairs(pixels) do
                    for _, pixel in ipairs(image) do
                        if utils:CheckCollision(x - cameraX, y - cameraY, 4, 4, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
                            
                            table.insert(imagesToScale, image)
                            break
                        end
                    end
                end
            end
            
            for _, image in ipairs(imagesToScale) do
                for _, pixel in ipairs(image) do
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

        if toolbar.tool == "build" then
            if currentPlatform ~= nil then
                currentPlatform.W = currentPlatform.W + dx
                currentPlatform.H = currentPlatform.H + dy
            end
        end
    end
end

function love.mousepressed(x,y,button)
    if button ~= 1 then return end
    
    if toolbar.tool == "explosion" then
        for _, image in ipairs(pixels) do
            for _, pixel in ipairs(image) do
                if utils:CheckCollision(x - cameraX, y - cameraY, brushSize, brushSize, pixel.body:getX(), pixel.body:getY(), pixel.Size.X, pixel.Size.Y) then
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
    
    if toolbar.tool == "build" then
        if currentPlatform == nil then
            currentPlatform = {X = x, Y = y, W = 1, H = 1}
        end
    end
    
    if toolbar.tool == "deleteplatform" then
        for i, platform in ipairs(platforms) do
            if utils:CheckCollision(x - cameraX, y - cameraY, brushSize, brushSize, platform.body:getX(), platform.body:getY(), platform.Size.X, platform.Size.Y) then
                table.remove(platforms, i)
                platform.body:destroy()
                platform.body:release()
                platform.body = nil
                platform = nil
                break
            end
        end
    end

    if toolbar.tool == "delete" then
        for _, image in ipairs(pixels) do
            for i, pixel in ipairs(image) do
                if utils:CheckCollision(x - cameraX, y - cameraY, brushSize, brushSize, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
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

    if toolbar.tool == "deleteimage" then
        local toDelete = {}
        
        for _, image in ipairs(pixels) do
            for i, pixel in ipairs(image) do
                if utils:CheckCollision(x - cameraX, y - cameraY, brushSize, brushSize, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
                    table.insert(toDelete, image)
                    break
                end
            end
        end

        for _, image in ipairs(toDelete) do
            for i, pixel in ipairs(image) do
                pixel.body:setActive(false)
                pixel.SceneEnabled = false
            end
        end
    end
end

function love.mousereleased()
    if toolbar.tool == "scale" then
        if #imagesToScale > 0 then
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

    if toolbar.tool == "build" then
        if currentPlatform ~= nil then
            if currentPlatform.W <= 0 then
                currentPlatform.X = currentPlatform.X + currentPlatform.W
                currentPlatform.W = math.abs(currentPlatform.W)
            end

            if currentPlatform.H <= 0 then
                currentPlatform.Y = currentPlatform.Y + currentPlatform.H
                currentPlatform.H = math.abs(currentPlatform.H)
            end
            
            newPlatform = physicsInstace:New(nil, world, "static", "rectangle", 
            {X = currentPlatform.W, Y = currentPlatform.H}, 0, 0, {X = currentPlatform.X + currentPlatform.W / 2 - cameraX, Y = currentPlatform.Y  + currentPlatform.H / 2 - cameraY})
            newPlatform.body:setX(currentPlatform.X + currentPlatform.W / 2 - cameraX)
            newPlatform.body:setY(currentPlatform.Y + currentPlatform.H / 2 - cameraY)
            newPlatform:SetColor(1,1,1,1)
            newPlatform.Shape = "rectangle"
            newPlatform.Size = {X = currentPlatform.W, Y = currentPlatform.H}
            
            table.insert(platforms, newPlatform)

            currentPlatform = nil
        end
    end

    imagesToScale = {}
end

function love.wheelmoved(x, y)
    if toolbar.tool == "delete" or toolbar.tool == "grab" or toolbar.tool == "explosion" or toolbar.tool == "deleteimage" or toolbar.tool == "deleteplatform"  then
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
                    X = x * sizeX * spacing + mX - imageWidth / 2 - cameraX, 
                    Y = y * sizeY * spacing + mY - imageHeight / 2 - cameraY
                })
                pixels[imageIndex][i].PixelPosition = {
                    X = x - cameraX,
                    Y = y - cameraY,
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

function love.keypressed(key, scancode, rep)
    uimgr:KeyPressed(key, scancode, rep)
end

function love.textinput(t)
    uimgr:TextInput(t)
end