-- AABB caching for matcha LuaVM by Zarto (@zart0_) 7/14/2026

local workspace = game:GetService("Workspace")

local AABBCaching = {
    Debug = false,
    Paused = false,
    TrackedParts = {}, -- { [uid: number] = Instance }
    Cache = {},        -- { [uid: number] = { Pos: Vector3, Size: Vector3 } }

    Config = {
        YieldInterval = 2000,        
        RescanTime = 2            
    },
    
    _running = false
}

local function Log(self, ...)
    if self.Debug then
        print("[AABB]", ...);
    end
end

local function cachingLoop(AABBCaching)
    while AABBCaching._running do
        if AABBCaching.Paused then
            continue
        end

        local scanned = 0
        local cached = 0
        local ok, descendants = pcall(function() return workspace:GetDescendants() end)
        if ok and descendants then
            for i, obj in ipairs(descendants) do
                if not AABBCaching._running then return end

                if obj:IsA("BasePart") then
                    local uid = obj.Address 
                    
                    if AABBCaching.Cache[uid] == nil then
                        if obj.Size and obj.Position then
                            AABBCaching.Cache[uid] = {
                                Pos = obj.Position,
                                Size = obj.Size
                            }

                            AABBCaching.TrackedParts[uid] = obj
                            cached = cached + 1
                        end
                    end
                end
                
                scanned = scanned + 1
                if i % AABBCaching.Config.YieldInterval == 0 then
                    task.wait() 
                end
            end
        end

        local updated = 0
        local removed = 0
        local i = 0
        for uid, part in pairs(AABBCaching.TrackedParts) do
            if not AABBCaching._running then return end

            if not part or not part.Parent then
                AABBCaching.TrackedParts[uid] = nil
                AABBCaching.Cache[uid] = nil
                removed = removed + 1
            else
                local c = AABBCaching.Cache[uid]
                if c then
                    c.Pos = part.Position
                    c.Size = part.Size
                    updated = updated + 1
                end
            end

            i = i + 1
            if i % AABBCaching.Config.YieldInterval == 0 then
                task.wait()
            end
        end

        task.wait(AABBCaching.Config.RescanTime)
    end
end

function AABBCaching:Init()
    AABBCaching._running = true
    task.spawn(function()
        cachingLoop(AABBCaching)
    end)
end

function AABBCaching:Shutdown()
    AABBCaching._running = false
end

function AABBCaching:ResetCache()
    AABBCaching.Cache = {}
    AABBCaching.TrackedParts = {}
end

function AABBCaching:IsPositionInsideAABB(position: Vector3): boolean
    for _, c in pairs(self.Cache) do
        local half = c.Size / 2
        local min = c.Pos - half
        local max = c.Pos + half
        if position.X >= min.X and position.X <= max.X
           and position.Y >= min.Y and position.Y <= max.Y
           and position.Z >= min.Z and position.Z <= max.Z then
            Log(self, "Position", position, "is inside AABB at", c.Pos)
            return true
        end
    end
    return false
end

return AABBCaching
