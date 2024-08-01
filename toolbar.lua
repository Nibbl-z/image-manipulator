local toolbar = {}

local screen = require("yan.instance.ui.screen")
local imagebutton = require("yan.instance.ui.imagebutton")
local list = require("yan.instance.ui.list")
local thememgr = require("yan.thememanager")

toolbar.tool = ""
toolbar.running = false

function toolbar:Init(resetFunc)
    defaultTheme = thememgr:NewTheme()
    
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

    resetTool = imagebutton:New(nil, tools, "/img/reset.png")
    resetTool:SetSize(0,50,0,50)
    resetTool:SetPosition(0,5,0,170)
    resetTool.ZIndex = 3
    resetTool:ApplyTheme(defaultTheme)
    
    resetTool.MouseDown = function ()
        resetFunc()
    end
end

function toolbar:UpdateButtons()
    for _, v in ipairs(toolbuttons) do
        v:ApplyTheme(defaultTheme)
    end
    
    if self.tool == "move" then
        moveTool:ApplyTheme(selectedTheme)
    elseif self.tool == "delete" then
        deleteTool:ApplyTheme(selectedTheme)
    end
end

return toolbar