local toolbar = {}

local screen = require("yan.instance.ui.screen")
local imagebutton = require("yan.instance.ui.imagebutton")
local list = require("yan.instance.ui.list")
local thememgr = require("yan.thememanager")

toolbar.tool = ""
toolbar.running = false

function toolbar:Init()
    defaultTheme = thememgr:NewTheme()
    
    tools = screen:New(nil) 
    tools.Enabled = true
    
    --[[buttonList = list:New(nil, tools, 5, "left", "vertical")
    buttonList:SetPosition(0,5,0,5)
    buttonList:SetSize(0,60,1,0)
    buttonList:SetPadding(0,5,0,5)
    buttonList.ZIndex = -1]]
    
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
    end
end

return toolbar