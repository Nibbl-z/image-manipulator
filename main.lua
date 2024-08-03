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
local camSpeed = 500
local defaultRestitution = 0
local pixelCount = 0

local movingImages = {}

function Reset()
    for ii, image in ipairs(pixels) do
        for i, pixel in ipairs(image) do
            pixel.body:setActive(false)
            pixel.SceneEnabled = false
        end
    end

    for i, platform in ipairs(platforms) do
        platform.body:setActive(false)
        platform.SceneEnabled = false
    end

    pixelCount = 0
    
    --world = love.physics.newWorld(0,300,true)
    --pixels = {}
    --imageIndex = 1
end

function SetXGravity(gravity)
    local _, y = world:getGravity()
    world:setGravity(gravity, y)
end

function SetYGravity(gravity)
    local x, _ = world:getGravity()
    world:setGravity(x,gravity)
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

function SetBounciness(restitution)
    for ii, image in ipairs(pixels) do
        for i, pixel in ipairs(image) do
            pixel.fixture:setRestitution(restitution)
        end
    end

    for i, platform in ipairs(platforms) do
        platform.fixture:setRestitution(restitution)
    end

    defaultRestitution = restitution
end

function love.load()
    love.window.setMode(800, 600, {resizable = true})
    love.window.setTitle("Image Playground")

    world = love.physics.newWorld(0,300,true)

    toolbar:Init(Reset, SetXGravity, SetYGravity, SetExplosionForce, SetXScale, SetYScale, SetBounciness)

    bgImage = love.graphics.newImage("/img/bg.png")
    bgImage:setWrap("repeat", "repeat")
    bgQuad = love.graphics.newQuad(0, 0, 200000, 200000, 100, 100)
    
    placeSfx = love.audio.newSource("/audio/place.wav", "static")
    explosionSfx = love.audio.newSource("/audio/explosion.wav", "static")
    deleteSfx = love.audio.newSource("/audio/delete.wav", "static")
    pixelDeleteSfx = love.audio.newSource("/audio/pixelDelete.wav", "static")
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
                if utils:Distance(mX, mY, pixel.body:getX() - cameraX, pixel.body:getY() - cameraY) <= brushSize then
                    local forceX, forceY = 0,0 
                    
                    if pixel.body:getX() < mX - cameraX then
                        forceX = grabSpeed
                    end
                    
                    if pixel.body:getX() > mX - cameraX then
                        forceX = -grabSpeed
                    end
                    
                    if pixel.body:getY() < mY - cameraY then
                        forceY = grabSpeed
                    end
                    
                    if pixel.body:getY() > mY - cameraY then
                        forceY = -grabSpeed
                    end
                    pixel.body:setGravityScale(0)
                    pixel.body:setLinearVelocity(forceX, forceY)
                else
                    pixel.body:setGravityScale(1)
                end
            end
        end
    else
        for _, image in ipairs(pixels) do
            for _, pixel in ipairs(image) do
                pixel.body:setGravityScale(1)
            end
        end
    end

    if toolbar.tool == "delete" and love.mouse.isDown(1)  then
        local didDelete = false
        for _, image in ipairs(pixels) do
            for i, pixel in ipairs(image) do
                if utils:Distance(mX - cameraX, mY - cameraY, pixel.body:getX(), pixel.body:getY()) <= brushSize then
                    table.remove(image, i)
                    pixel.body:destroy()
                    pixel.body:release()
                    pixel.body = nil
                    pixel = nil
                    didDelete = true
                    pixelCount = pixelCount - 1
                    --break
                end
            end
        end

        if didDelete then
            pixelDeleteSfx:play()
        end
    end
    
    if love.keyboard.isDown("lshift") then
        camSpeed = 1000
    else
        camSpeed = 500
    end
    
    for key, data in pairs(directions) do 
        if love.keyboard.isDown(key) then 
            cX = cX + camSpeed * data[1] * dt
            cY = cY + camSpeed * data[2] * dt
        end
    end

    cameraX = cameraX + cX
    cameraY = cameraY + cY

    for _, image in ipairs(movingImages) do
        for _, pixel in ipairs(image) do
            pixel.body:setX(pixel.body:getX() - cX)
            pixel.body:setY(pixel.body:getY() - cY)
        end
    end
    
    cX, cY = 0,0
    
    toolbar.FPSLabel.Text = "FPS: "..love.timer.getFPS()
    toolbar.PixelCountLabel.Text = "Pixels: "..pixelCount
end

function love.draw()
    love.graphics.draw(bgImage, bgQuad, -100000 + cameraX, -100000 + cameraY)
    
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

    if toolbar.tool == "delete" or toolbar.tool == "grab" or toolbar.tool == "explosion" or toolbar.tool == "deleteimage" then
        local mX, mY = love.mouse.getPosition()
        love.graphics.setColor(1,1,1,1)
        love.graphics.circle("line", mX, mY, brushSize)
    end

    uimgr:Draw()
end
local imagesToScale = {}
function love.mousemoved(x, y, dx, dy)
    for _, button in ipairs(toolbar.toolbuttons) do
        local pX, pY, sX, sY = button:GetDrawingCoordinates()
        if utils:CheckCollision(pX, pY, sX, sY, x, y, 2, 2) then
            return
        end
    end

    for _, button in ipairs(toolbar.inputfields) do
        local pX, pY, sX, sY = button:GetDrawingCoordinates()
        if utils:CheckCollision(pX, pY, sX, sY, x, y, 2, 2) then
            return
        end
    end

    if love.mouse.isDown(1) then
        if toolbar.tool == "move" then

            for _, image in ipairs(pixels) do
                for _, pixel in ipairs(image) do
                    if utils:CheckCollision(x - cameraX - 2, y - cameraY - 2, 4, 4, pixel.body:getX(), pixel.body:getY(), sizeX, sizeY) then
                        if utils:TableFind(movingImages, image) == false then
                            table.insert(movingImages, image)
                        end
                        
                        break
                    end
                end
            end
            for _, image in ipairs(movingImages) do
                for _, pixel in ipairs(image) do
                    pixel.body:setX(pixel.body:getX() + dx)
                    pixel.body:setY(pixel.body:getY() + dy)
                end
            end
        end
        
        if toolbar.tool == "delete" then
            local didDelete = false
            
            for _, image in ipairs(pixels) do
                for i, pixel in ipairs(image) do
                    if utils:Distance(x - cameraX, y - cameraY, pixel.body:getX(), pixel.body:getY()) <= brushSize then
                        table.remove(image, i)
                        pixel.body:destroy()
                        pixel.body:release()
                        pixel.body = nil
                        pixel = nil
                        didDelete = true
                        pixelCount = pixelCount - 1
                        --break
                    end
                end
            end
            
            if didDelete then
                pixelDeleteSfx:play()
            end
        end
        
        if toolbar.tool == "deleteimage" then
            local toDelete = {}
            
            for _, image in ipairs(pixels) do
                for i, pixel in ipairs(image) do
                    if utils:Distance(x - cameraX, y - cameraY, pixel.body:getX(), pixel.body:getY()) <= brushSize then
                        if pixel.body:isActive() then
                            table.insert(toDelete, image)
                            break
                        end
                    end
                end
            end
            if #toDelete >= 1 then
                deleteSfx:clone():play()
            end
            for _, image in ipairs(toDelete) do
                for i, pixel in ipairs(image) do
                    if pixel.body:isActive() then
                        pixel.body:setActive(false)
                        pixel.SceneEnabled = false
                        pixelCount = pixelCount - 1
                    end
                end
            end
        end

        if toolbar.tool == "scale" then
            if #imagesToScale == 0 then
                for _, image in ipairs(pixels) do
                    for _, pixel in ipairs(image) do
                        if utils:Distance(x - cameraX, y - cameraY, pixel.body:getX(), pixel.body:getY()) <= brushSize then
                            
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
                    
                    pixel.body:setX(pixel.PixelPosition.X * pixel.Size.X * spacing + x - imageWidth / 2 - cameraX)
                    pixel.body:setY(pixel.PixelPosition.Y * pixel.Size.Y * spacing + y - imageHeight / 2 - cameraY)
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
    for _, button in ipairs(toolbar.toolbuttons) do
        local pX, pY, sX, sY = button:GetDrawingCoordinates()
        if utils:CheckCollision(pX, pY, sX, sY, x, y, 2, 2) then
            return
        end
    end

    for _, button in ipairs(toolbar.inputfields) do
        local pX, pY, sX, sY = button:GetDrawingCoordinates()
        if utils:CheckCollision(pX, pY, sX, sY, x, y, 2, 2) then
            return
        end
    end

    if button ~= 1 then return end
    
    if toolbar.tool == "explosion" then
        for _, image in ipairs(pixels) do
            for _, pixel in ipairs(image) do
                if utils:Distance(x - cameraX, y - cameraY, pixel.body:getX(), pixel.body:getY()) <= brushSize then
                    local forceX, forceY = 0,0 
                    
                    if pixel.body:getX() < x - cameraX then
                        forceX = -explosionForce
                    end
                    
                    if pixel.body:getX() > x - cameraX  then
                        forceX = explosionForce
                    end
                    
                    if pixel.body:getY() < y - cameraY then
                        forceY = -explosionForce
                    end
                    
                    if pixel.body:getY() > y - cameraY then
                        forceY = explosionForce
                    end
                    
                    pixel.body:applyForce(forceX, forceY)
                end
            end
        end

        explosionSfx:clone():play()
    end
    
    if toolbar.tool == "build" then
        if currentPlatform == nil then
            currentPlatform = {X = x, Y = y, W = 1, H = 1}
        end
    end
    
    if toolbar.tool == "deleteplatform" then
        local didDelete = false
        
        for i, platform in ipairs(platforms) do
            if utils:CheckCollision(x - cameraX, y - cameraY, 1, 1, platform.body:getX() - platform.Size.X / 2, platform.body:getY() - platform.Size.Y / 2, platform.Size.X, platform.Size.Y) then
                didDelete = true
                table.remove(platforms, i)
                platform.body:destroy()
                platform.body:release()
                platform.body = nil
                platform = nil
                break
            end
        end
        
        if didDelete then
            deleteSfx:clone():play()
        end
    end

    if toolbar.tool == "delete" then
        local didDelete = false
        for _, image in ipairs(pixels) do
            for i, pixel in ipairs(image) do
                if utils:Distance(x - cameraX, y - cameraY, pixel.body:getX(), pixel.body:getY()) <= brushSize then
                    table.remove(image, i)
                    pixel.body:destroy()
                    pixel.body:release()
                    pixel.body = nil
                    pixel = nil
                    didDelete = true
                    pixelCount = pixelCount - 1
                    --break
                end
            end
        end

        if didDelete then
            pixelDeleteSfx:play()
        end
    end
    
    if toolbar.tool == "deleteimage" then
        local toDelete = {}
        
        for _, image in ipairs(pixels) do
            for i, pixel in ipairs(image) do
                if utils:Distance(x - cameraX, y - cameraY, pixel.body:getX(), pixel.body:getY()) <= brushSize then
                    if pixel.body:isActive() then
                        table.insert(toDelete, image)
                        break
                    end
                end
            end
        end
        if #toDelete >= 1 then
            deleteSfx:clone():play()
        end
        for _, image in ipairs(toDelete) do
            for i, pixel in ipairs(image) do
                if pixel.body:isActive() then
                    pixel.body:setActive(false)
                    pixel.SceneEnabled = false
                    pixelCount = pixelCount - 1
                end
            end
        end
    end
end

function love.mousereleased()
    movingImages = {}

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
            placeSfx:clone():play()

            if currentPlatform.W <= 0 then
                currentPlatform.X = currentPlatform.X + currentPlatform.W
                currentPlatform.W = math.abs(currentPlatform.W)
            end

            if currentPlatform.H <= 0 then
                currentPlatform.Y = currentPlatform.Y + currentPlatform.H
                currentPlatform.H = math.abs(currentPlatform.H)
            end
            
            newPlatform = physicsInstace:New(nil, world, "static", "rectangle", 
            {X = currentPlatform.W, Y = currentPlatform.H}, defaultRestitution, 0, {X = currentPlatform.X + currentPlatform.W / 2 - cameraX, Y = currentPlatform.Y  + currentPlatform.H / 2 - cameraY})
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
    if toolbar.tool == "delete" or toolbar.tool == "grab" or toolbar.tool == "explosion" or toolbar.tool == "deleteimage" then
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
                pixelCount = pixelCount + 1
                pixels[imageIndex][i] = physicsInstace:New(nil, world, "dynamic", "rectangle", {X = sizeX, Y = sizeY}, defaultRestitution, 0, 
                {
                    X = x * sizeX * spacing + mX - imageWidth / 2 - cameraX, 
                    Y = y * sizeY * spacing + mY - imageHeight / 2 - cameraY
                })
                pixels[imageIndex][i].PixelPosition = {
                    X = x,
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

    placeSfx:play()

    print("done")
end

function love.keypressed(key, scancode, rep)
    uimgr:KeyPressed(key, scancode, rep)
end

function love.textinput(t)
    uimgr:TextInput(t)
end