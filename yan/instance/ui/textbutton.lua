local textbutton = {}
local guibase = require("yan.instance.ui.guibase")
textbutton.__index = guibase

function textbutton:New(o, screen, text, textSize, align, verticalAlign, fontPath)
    o = o or guibase:New(o, screen)
    setmetatable(o, self)
    
    o.Type = "TextButton"
    o.Text = text
    o.TextSize = textSize
    o.Align = align
    o.VerticalAlign = verticalAlign
    o.CornerRoundness = 5
    
    if fontPath ~= nil then
        o.Font = love.graphics.newFont(fontPath, o.TextSize)
    else
        o.Font = love.graphics.newFont(o.TextSize)
    end
    
    o.TextColor = {
        R = 0, G = 0, B = 0, A = 1
    }

    function o:SetTextColor(r, g, b, a)
        o.TextColor = {
            R = r, G = g, B = b, A = a
        }
    end
    
    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.setColor(o.Color.R, o.Color.G, o.Color.B, o.Color.A)
        
        love.graphics.rectangle("fill", pX, pY, sX, sY, o.CornerRoundness, o.CornerRoundness)
        
        love.graphics.setFont(o.Font)
        love.graphics.setColor(o.TextColor.R, o.TextColor.G, o.TextColor.B, o.TextColor.A)
        
        local yOffset = 0
        
        if o.VerticalAlign == "center" then
            local _, lines = o.Font:getWrap(o.Text, sX)
            yOffset = sY * 0.5 - ((o.Font:getHeight() / 2) * #lines)
        elseif o.VerticalAlign == "bottom" then
            local _, lines = o.Font:getWrap(o.Text, sX)
            yOffset = sY * 1 - ((o.Font:getHeight()) * #lines)
        end
        
        love.graphics.printf(
            o.Text, 
            pX,
            pY + yOffset,
            sX, 
            o.Align
        )
        
        love.graphics.setColor(1,1,1,1)
    end
    
    --[[function o:ApplyTheme(theme)
        o:SetButtonColor(theme:GetColor())
        o:SetColor(theme:GetTextColor())

        function o:MouseEnterDefault()
            print("hi")
            o:SetButtonColor(theme:GetHoverColor())
        end
        
        function o:MouseLeaveDefault()
            print("bye")
            o:SetButtonColor(theme:GetColor())
        end

        function o:MouseDownDefault()
            print("ddown")
            o:SetButtonColor(theme:GetSelectedColor())
        end

        function o:MouseUpDefault()
            print("uppies")
            o:SetButtonColor(theme:GetColor())
        end

        
    end]]

    return o
end

return textbutton