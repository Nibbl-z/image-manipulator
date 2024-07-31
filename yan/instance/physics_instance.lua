local physicsInstance = {}



local instance = require("yan.instance.instance")
physicsInstance.__index = instance

function physicsInstance:New(o, world, bodyType, shape, size, restitution, damping, pos)
    o = o or instance:New(o)
    setmetatable(o, self)
    o.Type = "PhysicsInstance"
    o.body = love.physics.newBody(world, pos.X, pos.Y, bodyType)
    
    if shape == "rectangle" then
        o.shape = love.physics.newRectangleShape(size.X, size.Y)
    end
    
    o.fixture = love.physics.newFixture(o.body, o.shape)
    o.fixture:setUserData(o.Name)
    o.fixture:setRestitution(restitution)
    o.body:setLinearDamping(damping)
    
    function o:Update()
        if o.SceneEnabled == false then return end

        o.Position.X = o.body:getX()
        o.Position.Y = o.body:getY()
    end 

    function o:ApplyForce(x, y)
        if o.SceneEnabled == false then return end
        o.body:applyForce(x, y)
    end

    function o:ApplyLinearImpulse(x, y, maxX, maxY)
        if o.SceneEnabled == false then return end
        o.body:applyLinearImpulse(x, y)
        
        if maxX and maxY then
            local vX, vY = o.body:getLinearVelocity()

            if vX > maxX then 
                vX = maxX
            elseif vX < -maxX then 
                vX = -maxX 
            end

            o.body:setLinearVelocity(vX, vY)
        end
    end
    
    function o:Draw()
        if o.SceneEnabled == false then return end
        love.graphics.setColor(
            o.Color.R,
            o.Color.G,
            o.Color.B,
            o.Color.A
        )
        
        love.graphics.polygon("fill", o.body:getWorldPoints(o.shape:getPoints()))
        
        if o.Shape == "rectangle" then
            --[[love.graphics.rectangle(
                "fill",
                o.body:getX(),
                o.body:getY(),
                size.X,
                size.Y
            )]]
        end
    end
    
    return o
end

return physicsInstance