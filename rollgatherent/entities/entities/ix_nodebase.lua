AddCSLuaFile()
local PLUGIN = PLUGIN
PLUGIN.license = [[This plugin is being released under MPL 2.0 https://www.mozilla.org/en-US/MPL/2.0/, also view license.txt]]
ENT.Type = "anim"
ENT.PrintName = "Node Base"
ENT.Category = "Roll Gathering"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = false
ENT.nodeType = "scrap"
ENT.modelType = "models/props_debris/concrete_wallpile01a.mdl"
ENT.tooltipName = "Pile of [RESOURCE]"
ENT.tooltipDesc = "A pile of missing textures."
ENT.soundPath = "npc/fast_zombie/foot"
ENT.endSound = nil
ENT.maxSound = 4
ENT.isRare = nil --use this if you're making a rare node

if (SERVER) then
    function ENT:Initialize()
        self:SetModel(self.modelType)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        if (self.mat) then
            self:SetMaterial(self.mat)
        end

        timer.Simple(60, function()
            self:SetNetVar("Persistent", true)
        end)
    end

    function ENT:Use(client)
        local rareGatherVar

        if (self.isRare) then
            rareGatherVar = ix.config.Get("Rare Gathering Time")
        else
            rareGatherVar = ix.config.Get("Gathering Time")
        end

        local lastGatherGlobal = client:GetLocalVar("gatherTimer")
        local delay = ix.config.Get("Gathering Recharge Delay") * 60

        if (delay > 0 and lastGatherGlobal) then
            local lastGather = CurTime() - lastGatherGlobal

            if (lastGather <= delay and client:GetLocalVar("gatherAttempted") == 1 and client:GetLocalVar("gatherUses", 0) >= ix.config.Get("Gathering Charges")) then
                client:Notify("You are too tired to gather right now.")

                return false
            end
        end

        local actionName = self.actionName or self.PrintName:match("^([%w]+)")
        client:EmitSound(self.soundPath .. math.random(1, self.maxSound) .. ".wav")
        client:SetLocalVar("playGatherSound", true)

        timer.Create(client:GetName() .. "gatherProgress", rareGatherVar / (ix.config.Get("Hit Sounds Per Gather")), ix.config.Get("Hit Sounds Per Gather") - 1, function()
            if (client:GetLocalVar("playGatherSound", true)) then
                client:EmitSound(self.soundPath .. math.random(1, self.maxSound or 1) .. ".wav")
            end
        end)

        client:SetAction(actionName .. "...", rareGatherVar)

        client:DoStaredAction(self, function()
            PLUGIN:rollGather(client, self.nodeType, self.endSound or self.soundPath .. math.random(1, self.maxSound) .. ".wav")
            timer.Remove(client .. "gatherProgress")
        end, rareGatherVar, function()
            client:Notify("Gathering cancelled.")
            client:SetLocalVar("playGatherSound", false)
            client:SetAction()
            timer.Stop(client:GetName() .. "gatherProgress")
            timer.Remove(client:GetName() .. "gatherProgress")
        end)
    end
else
    ENT.PopulateEntityInfo = true

    function ENT:OnPopulateEntityInfo(tooltip)
        local tip = PLUGIN:PopulateNodeTooltip(tooltip, self.tooltipName or self.PrintName, self.tooltipDesc)
    end
end