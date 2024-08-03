local toolbar = {}

local screen = require("yan.instance.ui.screen")
local imagebutton = require("yan.instance.ui.imagebutton")
local list = require("yan.instance.ui.list")
local textinput = require("yan.instance.ui.textinput")
local label = require("yan.instance.ui.label")
local thememgr = require("yan.thememanager")

toolbar.tool = ""
toolbar.running = false

function toolbar:Init(resetFunc, setXGravityFunc, setYGravityFunc, setExplosionForce, setXScale, setYScale, setRestitutionFunc, setGrabSpeed)
    clickSfx = love.audio.newSource("/audio/select.wav", "static")
    enterSfx = love.audio.newSource("/audio/onEnter.wav", "static")
    defaultTheme = thememgr:NewTheme()
    defaultTheme.CornerRoundness = 4
    
    selectedTheme = thememgr:NewTheme()
    selectedTheme:SetColor(0.5,0.5,0.5,1)
    selectedTheme:SetHoverColor(0.4,0.4,0.4,1)
    selectedTheme:SetSelectedColor(0.25,0.25,0.25,1)
    
    tools = screen:New(nil) 
    tools.Enabled = true
    
    --[[buttonList = list:New(nil, tools, 5, "left", "vertical")
    buttonList:SetPosition(0,5,0,5)
    buttonList:SetSize(0,60,1,0)
    buttonList:SetPadding(0,5,0,5)
    buttonList.ZIndex = -1]]

    self.toolbuttons = {}
    self.inputfields = {}
    
    local playImg = love.graphics.newImage("/img/play.png")
    local pauseImg = love.graphics.newImage("/img/pause.png")

    playTool = imagebutton:New(nil, tools, "/img/play.png")
    playTool:SetSize(0,50,0,50)
    playTool:SetPosition(0,5,0,5)
    playTool.ZIndex = 3
    playTool:ApplyTheme(defaultTheme)
    
    playTool.MouseDown = function ()
        clickSfx:play()
        self.running = not self.running

        if self.running then
            playTool.Image = pauseImg
        else
            playTool.Image = playImg
        end
    end
    
    moveTool = imagebutton:New(nil, tools, "/img/move.png")
    moveTool:SetSize(0,50,0,50)
    moveTool:SetPosition(0,5,0,60)
    moveTool.ZIndex = 3
    moveTool:ApplyTheme(defaultTheme)

    moveTool.MouseDown = function ()
        clickSfx:play()
        if self.tool == "move" then
            self.tool = ""
        else
            self.tool = "move"
        end

        self:UpdateButtons()
    end
    
    table.insert(self.toolbuttons, moveTool)
    
    deleteTool = imagebutton:New(nil, tools, "/img/delete.png")
    deleteTool:SetSize(0,50,0,50)
    deleteTool:SetPosition(0,5,0,115)
    deleteTool.ZIndex = 3
    deleteTool:ApplyTheme(defaultTheme)
    
    deleteTool.MouseDown = function ()
        clickSfx:play()
        if self.tool == "delete" then
            self.tool = ""
        else
            self.tool = "delete"
        end
        self:UpdateButtons()
    end

    table.insert(self.toolbuttons, deleteTool)

    deleteImgTool = imagebutton:New(nil, tools, "/img/delete_image.png")
    deleteImgTool:SetSize(0,50,0,50)
    deleteImgTool:SetPosition(0,5,0,170)
    deleteImgTool.ZIndex = 3
    deleteImgTool:ApplyTheme(defaultTheme)
    
    deleteImgTool.MouseDown = function ()
        clickSfx:play()
        if self.tool == "deleteimage" then
            self.tool = ""
        else
            self.tool = "deleteimage"
        end
        self:UpdateButtons()
    end

    table.insert(self.toolbuttons, deleteImgTool)

    scaleTool = imagebutton:New(nil, tools, "/img/scale.png")
    scaleTool:SetSize(0,50,0,50)
    scaleTool:SetPosition(0,5,0,225)
    scaleTool.ZIndex = 3
    scaleTool:ApplyTheme(defaultTheme)
    
    scaleTool.MouseDown = function ()
        clickSfx:play()

        if self.tool == "scale" then
            self.tool = ""
        else
            self.tool = "scale"
        end
        self:UpdateButtons()
    end
    
    table.insert(self.toolbuttons, scaleTool)

    grabTool = imagebutton:New(nil, tools, "/img/grab.png")
    grabTool:SetSize(0,50,0,50)
    grabTool:SetPosition(0,5,0,280)
    grabTool.ZIndex = 3
    grabTool:ApplyTheme(defaultTheme)
    
    grabTool.MouseDown = function ()
        clickSfx:play()
        if self.tool == "grab" then
            self.tool = ""
        else
            self.tool = "grab"
        end
        self:UpdateButtons()
    end
    
    table.insert(self.toolbuttons, grabTool)
    
    explosionTool = imagebutton:New(nil, tools, "/img/explosion.png")
    explosionTool:SetSize(0,50,0,50)
    explosionTool:SetPosition(0,5,0,335)
    explosionTool.ZIndex = 3
    explosionTool:ApplyTheme(defaultTheme)
    
    explosionTool.MouseDown = function ()
        clickSfx:play()
        if self.tool == "explosion" then
            self.tool = ""
        else
            self.tool = "explosion"
        end
        self:UpdateButtons()
    end
    
    table.insert(self.toolbuttons, explosionTool)

    buildTool = imagebutton:New(nil, tools, "/img/build_platform.png")
    buildTool:SetSize(0,50,0,50)
    buildTool:SetPosition(0,5,0,390)
    buildTool.ZIndex = 3
    buildTool:ApplyTheme(defaultTheme)
    
    buildTool.MouseDown = function ()
        clickSfx:play()
        if self.tool == "build" then
            self.tool = ""
        else
            self.tool = "build"
        end
        self:UpdateButtons()
    end
    
    table.insert(self.toolbuttons, buildTool)
    
    deletePlatformTool = imagebutton:New(nil, tools, "/img/delete_platform.png")
    deletePlatformTool:SetSize(0,50,0,50)
    deletePlatformTool:SetPosition(0,5,0,445)
    deletePlatformTool.ZIndex = 3
    deletePlatformTool:ApplyTheme(defaultTheme)
    
    deletePlatformTool.MouseDown = function ()
        clickSfx:play()
        if self.tool == "deleteplatform" then
            self.tool = ""
        else
            self.tool = "deleteplatform"
        end
        self:UpdateButtons()
    end
    
    table.insert(self.toolbuttons, deletePlatformTool)
    
    resetTool = imagebutton:New(nil, tools, "/img/reset.png")
    resetTool:SetSize(0,50,0,50)
    resetTool:SetPosition(0,5,0,500)
    resetTool.ZIndex = 3
    resetTool:ApplyTheme(defaultTheme)
    
    resetTool.MouseDown = function ()
        clickSfx:play()
        resetFunc()
    end

    table.insert(self.toolbuttons, resetTool)
    
    gravityXInput = textinput:New(nil, tools, "0", 16, "left", "center")
    gravityXInput:SetAnchorPoint(1,0)
    gravityXInput:SetPosition(1,-5,0,5)
    gravityXInput:SetSize(0,100,0,50)
    gravityXInput:ApplyTheme(defaultTheme)
    
    gravityXInput.MouseDown = function ()
        gravityXInput.Text = ""
        clickSfx:play()
    end
    
    gravityXInput.OnEnter = function ()
        if tonumber(gravityXInput.Text) ~= nil then
            setXGravityFunc(tonumber(gravityXInput.Text))
        else
            gravityXInput.Text = "Invalid Input"
        end

        enterSfx:play()
    end

    table.insert(self.inputfields, gravityXInput)
    
    gravityXTitle = label:New(nil, tools, "Set X Gravity", 16, "right", "center")
    gravityXTitle:SetAnchorPoint(1,0)
    gravityXTitle:SetPosition(1,-110,0,5)
    gravityXTitle:SetSize(0,100,0,50)
    gravityXTitle:SetTextColor(1,1,1,1)

    gravityYInput = textinput:New(nil, tools, "300", 16, "left", "center")
    gravityYInput:SetAnchorPoint(1,0)
    gravityYInput:SetPosition(1,-5,0,60)
    gravityYInput:SetSize(0,100,0,50)
    gravityYInput:ApplyTheme(defaultTheme)
    
    gravityYInput.MouseDown = function ()
        gravityYInput.Text = ""
        clickSfx:play()
    end
    
    gravityYInput.OnEnter = function ()
        if tonumber(gravityYInput.Text) ~= nil then
            setYGravityFunc(tonumber(gravityYInput.Text))
        else
            gravityYInput.Text = "Invalid Input"
        end

        enterSfx:play()
    end

    table.insert(self.inputfields, gravityYInput)
    
    gravityYTitle = label:New(nil, tools, "Set Y Gravity", 16, "right", "center")
    gravityYTitle:SetAnchorPoint(1,0)
    gravityYTitle:SetPosition(1,-110,0,60)
    gravityYTitle:SetSize(0,100,0,50)
    gravityYTitle:SetTextColor(1,1,1,1)
    
    
    explosionForceInput = textinput:New(nil, tools, "250000", 16, "left", "center")
    explosionForceInput:SetAnchorPoint(1,0)
    explosionForceInput:SetPosition(1,-5,0,115)
    explosionForceInput:SetSize(0,100,0,50)
    explosionForceInput:ApplyTheme(defaultTheme)
    
    explosionForceInput.MouseDown = function ()
        explosionForceInput.Text = ""
        clickSfx:play()
    end

    explosionForceInput.OnEnter = function ()
        if tonumber(explosionForceInput.Text) ~= nil then
            setExplosionForce(tonumber(explosionForceInput.Text))
        else
            explosionForceInput.Text = "Invalid Input"
        end

        enterSfx:play()
    end

    table.insert(self.inputfields, explosionForceInput)
    
    explosionForceTitle = label:New(nil, tools, "Set Explosion Force", 16, "right", "center")
    explosionForceTitle:SetAnchorPoint(1,0)
    explosionForceTitle:SetPosition(1,-110,0,115)
    explosionForceTitle:SetSize(0,100,0,50)
    explosionForceTitle:SetTextColor(1,1,1,1)
    
    grabSpeedInput = textinput:New(nil, tools, "200", 16, "left", "center")
    grabSpeedInput:SetAnchorPoint(1,0)
    grabSpeedInput:SetPosition(1,-5,0,170)
    grabSpeedInput:SetSize(0,100,0,50)
    grabSpeedInput:ApplyTheme(defaultTheme)
    
    grabSpeedInput.MouseDown = function ()
        grabSpeedInput.Text = ""
        clickSfx:play()
    end
    
    grabSpeedInput.OnEnter = function ()
        if tonumber(grabSpeedInput.Text) ~= nil then
            setGrabSpeed(tonumber(grabSpeedInput.Text))
        else
            grabSpeedInput.Text = "Invalid Input"
        end

        enterSfx:play()
    end
    
    table.insert(self.inputfields, grabSpeedInput)
    
    grabSpeedTitle = label:New(nil, tools, "Set Grab Speed", 16, "right", "center")
    grabSpeedTitle:SetAnchorPoint(1,0)
    grabSpeedTitle:SetPosition(1,-110,0,170)
    grabSpeedTitle:SetSize(0,100,0,50)
    grabSpeedTitle:SetTextColor(1,1,1,1)
    
    sizeXInput = textinput:New(nil, tools, "10", 16, "left", "center")
    sizeXInput:SetAnchorPoint(1,0)
    sizeXInput:SetPosition(1,-5,0,225)
    sizeXInput:SetSize(0,100,0,50)
    sizeXInput:ApplyTheme(defaultTheme)
    
    sizeXInput.MouseDown = function ()
        sizeXInput.Text = ""
        clickSfx:play()
    end

    sizeXInput.OnEnter = function ()
        if tonumber(sizeXInput.Text) ~= nil then
            if tonumber(sizeXInput.Text) <= 0 then
                sizeXInput.Text = "Must be above 0"
                return
            end
            setXScale(tonumber(sizeXInput.Text))
        else
            sizeXInput.Text = "Invalid Input"
        end

        enterSfx:play()
    end
    table.insert(self.inputfields, sizeXInput)
    sizeXTitle = label:New(nil, tools, "Default X Scale", 16, "right", "center")
    sizeXTitle:SetAnchorPoint(1,0)
    sizeXTitle:SetPosition(1,-110,0,225)
    sizeXTitle:SetSize(0,100,0,50)
    sizeXTitle:SetTextColor(1,1,1,1)
    
    sizeYInput = textinput:New(nil, tools, "10", 16, "left", "center")
    sizeYInput:SetAnchorPoint(1,0)
    sizeYInput:SetPosition(1,-5,0,280)
    sizeYInput:SetSize(0,100,0,50)
    sizeYInput:ApplyTheme(defaultTheme)
    
    sizeYInput.OnEnter = function ()
        if tonumber(sizeYInput.Text) ~= nil then
            if tonumber(sizeYInput.Text) <= 0 then
                sizeYInput.Text = "Must be above 0"
                return
            end
            setYScale(tonumber(sizeYInput.Text))
        else
            sizeYInput.Text = "Invalid Input"
        end

        enterSfx:play()
    end
    
    sizeYInput.MouseDown = function ()
        sizeYInput.Text = ""
        clickSfx:play()
    end
    
    sizeYTitle = label:New(nil, tools, "Default Y Scale", 16, "right", "center")
    sizeYTitle:SetAnchorPoint(1,0)
    sizeYTitle:SetPosition(1,-110,0,280)
    sizeYTitle:SetSize(0,100,0,50)
    sizeYTitle:SetTextColor(1,1,1,1)
    
    table.insert(self.inputfields, sizeYInput)

    bouncinessInput = textinput:New(nil, tools, "0.0", 16, "left", "center")
    bouncinessInput:SetAnchorPoint(1,0)
    bouncinessInput:SetPosition(1,-5,0,335)
    bouncinessInput:SetSize(0,100,0,50)
    bouncinessInput:ApplyTheme(defaultTheme)
    
    bouncinessInput.OnEnter = function ()  
        if tonumber(bouncinessInput.Text) ~= nil then
            if tonumber(bouncinessInput.Text) < 0 then
                bouncinessInput.Text = "Must be 0 or above"
                return
            end
    
            if tonumber(bouncinessInput.Text) > 1 then
                bouncinessInput.Text = "Must be below 1"
                return
            end
            setRestitutionFunc(tonumber(bouncinessInput.Text))
        else
            bouncinessInput.Text = "Invalid Input"
        end

        enterSfx:play()
    end
    
    bouncinessInput.MouseDown = function ()
        bouncinessInput.Text = ""
        clickSfx:play()
    end
    
    bouncinessTitle = label:New(nil, tools, "Bounciness", 16, "right", "center")
    bouncinessTitle:SetAnchorPoint(1,0)
    bouncinessTitle:SetPosition(1,-110,0,335)
    bouncinessTitle:SetSize(0,100,0,50)
    bouncinessTitle:SetTextColor(1,1,1,1)
    
    table.insert(self.inputfields, bouncinessInput)

    self.FPSLabel = label:New(nil, tools, "FPS: 0", 16, "right", "center")
    self.FPSLabel:SetAnchorPoint(1,1)
    self.FPSLabel:SetPosition(1,-10,1,-10)
    self.FPSLabel:SetSize(0,300,0,25)
    self.FPSLabel:SetTextColor(1,1,1,1)

    self.PixelCountLabel = label:New(nil, tools, "Pixels: 0", 16, "right", "center")
    self.PixelCountLabel:SetAnchorPoint(1,1)
    self.PixelCountLabel:SetPosition(1,-10,1,-40)
    self.PixelCountLabel:SetSize(0,300,0,25)
    self.PixelCountLabel:SetTextColor(1,1,1,1)
end

function toolbar:UpdateButtons()
    for _, v in ipairs(self.toolbuttons) do
        v:ApplyTheme(defaultTheme)
    end
    
    if self.tool == "move" then
        moveTool:ApplyTheme(selectedTheme)
    elseif self.tool == "delete" then
        deleteTool:ApplyTheme(selectedTheme)
    elseif self.tool == "deleteimage" then
        deleteImgTool:ApplyTheme(selectedTheme)
    elseif self.tool == "scale" then
        scaleTool:ApplyTheme(selectedTheme)
    elseif self.tool == "grab" then
        grabTool:ApplyTheme(selectedTheme)
    elseif self.tool == "explosion" then
        explosionTool:ApplyTheme(selectedTheme)
    elseif self.tool == "build" then
        buildTool:ApplyTheme(selectedTheme)
    elseif self.tool == "deleteplatform" then
        deletePlatformTool:ApplyTheme(selectedTheme)
    end
end

return toolbar