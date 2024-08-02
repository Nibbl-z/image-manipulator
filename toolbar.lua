local toolbar = {}

local screen = require("yan.instance.ui.screen")
local imagebutton = require("yan.instance.ui.imagebutton")
local list = require("yan.instance.ui.list")
local textinput = require("yan.instance.ui.textinput")
local label = require("yan.instance.ui.label")
local thememgr = require("yan.thememanager")

toolbar.tool = ""
toolbar.running = false

function toolbar:Init(resetFunc, setGravityFunc, setExplosionForce, setXScale, setYScale)
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

    toolbuttons = {}
    
    local playImg = love.graphics.newImage("/img/play.png")
    local pauseImg = love.graphics.newImage("/img/pause.png")

    playTool = imagebutton:New(nil, tools, "/img/play.png")
    playTool:SetSize(0,50,0,50)
    playTool:SetPosition(0,5,0,5)
    playTool.ZIndex = 3
    playTool:ApplyTheme(defaultTheme)
    
    playTool.MouseDown = function ()
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
        if self.tool == "move" then
            self.tool = ""
        else
            self.tool = "move"
        end

        self:UpdateButtons()
    end
    
    table.insert(toolbuttons, moveTool)
    
    deleteTool = imagebutton:New(nil, tools, "/img/delete.png")
    deleteTool:SetSize(0,50,0,50)
    deleteTool:SetPosition(0,5,0,115)
    deleteTool.ZIndex = 3
    deleteTool:ApplyTheme(defaultTheme)
    
    deleteTool.MouseDown = function ()

        if self.tool == "delete" then
            self.tool = ""
        else
            self.tool = "delete"
        end
        self:UpdateButtons()
    end

    table.insert(toolbuttons, deleteTool)

    scaleTool = imagebutton:New(nil, tools, "/img/scale.png")
    scaleTool:SetSize(0,50,0,50)
    scaleTool:SetPosition(0,5,0,170)
    scaleTool.ZIndex = 3
    scaleTool:ApplyTheme(defaultTheme)
    
    scaleTool.MouseDown = function ()
        self.running = false
        if self.tool == "scale" then
            self.tool = ""
        else
            self.tool = "scale"
        end
        self:UpdateButtons()
    end
    
    table.insert(toolbuttons, scaleTool)

    grabTool = imagebutton:New(nil, tools, "/img/grab.png")
    grabTool:SetSize(0,50,0,50)
    grabTool:SetPosition(0,5,0,225)
    grabTool.ZIndex = 3
    grabTool:ApplyTheme(defaultTheme)
    
    grabTool.MouseDown = function ()
        if self.tool == "grab" then
            self.tool = ""
        else
            self.tool = "grab"
        end
        self:UpdateButtons()
    end
    
    table.insert(toolbuttons, grabTool)
    
    explosionTool = imagebutton:New(nil, tools, "/img/explosion.png")
    explosionTool:SetSize(0,50,0,50)
    explosionTool:SetPosition(0,5,0,280)
    explosionTool.ZIndex = 3
    explosionTool:ApplyTheme(defaultTheme)
    
    explosionTool.MouseDown = function ()
        if self.tool == "explosion" then
            self.tool = ""
        else
            self.tool = "explosion"
        end
        self:UpdateButtons()
    end
    
    table.insert(toolbuttons, explosionTool)

    resetTool = imagebutton:New(nil, tools, "/img/reset.png")
    resetTool:SetSize(0,50,0,50)
    resetTool:SetPosition(0,5,0,335)
    resetTool.ZIndex = 3
    resetTool:ApplyTheme(defaultTheme)
    
    resetTool.MouseDown = function ()
        resetFunc()
    end
    
    gravityInput = textinput:New(nil, tools, "300", 16, "left", "center")
    gravityInput:SetAnchorPoint(1,0)
    gravityInput:SetPosition(1,-5,0,5)
    gravityInput:SetSize(0,100,0,50)
    gravityInput:ApplyTheme(defaultTheme)
    
    gravityInput.OnEnter = function ()
        if tonumber(gravityInput.Text) ~= nil then
            setGravityFunc(tonumber(gravityInput.Text))
        else
            gravityInput.Text = "Invalid Input"
        end
    end

    gravityTitle = label:New(nil, tools, "Set Gravity", 16, "right", "center")
    gravityTitle:SetAnchorPoint(1,0)
    gravityTitle:SetPosition(1,-110,0,5)
    gravityTitle:SetSize(0,100,0,50)
    gravityTitle:SetTextColor(1,1,1,1)

    explosionForceInput = textinput:New(nil, tools, "250000", 16, "left", "center")
    explosionForceInput:SetAnchorPoint(1,0)
    explosionForceInput:SetPosition(1,-5,0,60)
    explosionForceInput:SetSize(0,100,0,50)
    explosionForceInput:ApplyTheme(defaultTheme)
    
    explosionForceInput.OnEnter = function ()
        if tonumber(explosionForceInput.Text) ~= nil then
            setExplosionForce(tonumber(explosionForceInput.Text))
        else
            explosionForceInput.Text = "Invalid Input"
        end
    end
    
    explosionForceTitle = label:New(nil, tools, "Set Explosion Force", 16, "right", "center")
    explosionForceTitle:SetAnchorPoint(1,0)
    explosionForceTitle:SetPosition(1,-110,0,60)
    explosionForceTitle:SetSize(0,100,0,50)
    explosionForceTitle:SetTextColor(1,1,1,1)
    
    sizeXInput = textinput:New(nil, tools, "10", 16, "left", "center")
    sizeXInput:SetAnchorPoint(1,0)
    sizeXInput:SetPosition(1,-5,0,115)
    sizeXInput:SetSize(0,100,0,50)
    sizeXInput:ApplyTheme(defaultTheme)
    
    sizeXInput.OnEnter = function ()
        if tonumber(sizeXInput.Text) ~= nil then
            setXScale(tonumber(sizeXInput.Text))
        else
            sizeXInput.Text = "Invalid Input"
        end
    end
    
    sizeXTitle = label:New(nil, tools, "Default X Scale", 16, "right", "center")
    sizeXTitle:SetAnchorPoint(1,0)
    sizeXTitle:SetPosition(1,-110,0,115)
    sizeXTitle:SetSize(0,100,0,50)
    sizeXTitle:SetTextColor(1,1,1,1)
    
    sizeYInput = textinput:New(nil, tools, "10", 16, "left", "center")
    sizeYInput:SetAnchorPoint(1,0)
    sizeYInput:SetPosition(1,-5,0,170)
    sizeYInput:SetSize(0,100,0,50)
    sizeYInput:ApplyTheme(defaultTheme)
    
    sizeYInput.OnEnter = function ()
        if tonumber(sizeYInput.Text) ~= nil then
            setYScale(tonumber(sizeYInput.Text))
        else
            sizeYInput.Text = "Invalid Input"
        end
    end
    
    sizeYTitle = label:New(nil, tools, "Default Y Scale", 16, "right", "center")
    sizeYTitle:SetAnchorPoint(1,0)
    sizeYTitle:SetPosition(1,-110,0,170)
    sizeYTitle:SetSize(0,100,0,50)
    sizeYTitle:SetTextColor(1,1,1,1)
end

function toolbar:UpdateButtons()
    for _, v in ipairs(toolbuttons) do
        v:ApplyTheme(defaultTheme)
    end
    
    if self.tool == "move" then
        moveTool:ApplyTheme(selectedTheme)
    elseif self.tool == "delete" then
        deleteTool:ApplyTheme(selectedTheme)
    elseif self.tool == "scale" then
        scaleTool:ApplyTheme(selectedTheme)
    elseif self.tool == "grab" then
        grabTool:ApplyTheme(selectedTheme)
    elseif self.tool == "explosion" then
        explosionTool:ApplyTheme(selectedTheme)
    end
end

return toolbar