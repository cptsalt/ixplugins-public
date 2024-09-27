local PLUGIN = PLUGIN
PLUGIN.name = "Roll Gathering Entities"
PLUGIN.author = "salt"
PLUGIN.description = "Adds a system for gathering based on rolling and entities."
PLUGIN.license = [[This plugin is being released under MPL 2.0 https://www.mozilla.org/en-US/MPL/2.0/, also view license.txt]]

if (CLIENT) then
    ix.option.Add("Notify on Gathering Recharge", ix.type.bool, false, {
        category = "Gathering",
        bNetworked = true
    })

    ix.option.Add("Notify on Gathered Item", ix.type.bool, true, {
        category = "Gathering",
        bNetworked = true
    })
end

ix.option.Add("Notify on Gathering Recharge", ix.type.bool, false, {
    category = "Gathering",
    bNetworked = true
})

ix.option.Add("Notify on Gathered Item", ix.type.bool, true, {
    category = "Gathering",
    bNetworked = true
})

ix.config.Add("Gathering Recharge Delay", 1, "The time it takes in minutes for you to regain a gathering charge.", function(oldValue, newValue)
    for _, v in ipairs(player.GetAll()) do
        timer.Adjust("rollGather" .. v:UniqueID(), newValue * 60, 0)
    end
end, {
    data = {
        min = 0.01,
        max = 60,
        decimals = 1
    },
    category = "Gathering",
})

ix.config.Add("Enable Gathering Notifications", true, "Globally allow or disallow gathering notifications on recharge.", nil, {
    category = "Gathering"
})

ix.config.Add("Gathering Time", 5, "How long it takes in seconds to gather an item.", nil, {
    data = {
        min = 0.01,
        max = 30,
        decimals = 1
    },
    category = "Gathering"
})

ix.config.Add("Gathering Charges", 5, "The amount of times you can gather before the cooldown starts.", nil, {
    data = {
        min = 1,
        max = 10
    },
    category = "Gathering"
})

ix.config.Add("Gathering Threshold", 15, "The minimum roll you need to find an item.", nil, {
    data = {
        min = 0,
        max = 90
    },
    category = "Gathering"
})

ix.config.Add("Uncommon Item Threshold", 80, "The minimum roll you need to find an uncommon item.", nil, {
    data = {
        min = 0,
        max = 200
    },
    category = "Gathering"
})

ix.config.Add("Rare Item Threshold", 90, "The minimum roll you need to find a rare item.", nil, {
    data = {
        min = 0,
        max = 200
    },
    category = "Gathering"
})

ix.config.Add("Rare Gathering Time", 20, "The time it takes in seconds to gather from a rare node.", nil, {
    data = {
        min = 1,
        max = 300
    },
    category = "Gathering"
})

ix.config.Add("Hit Sounds Per Gather", 5, "The amount of times a sound will play before you gather an item.", nil, {
    data = {
        min = 0,
        max = 30
    },
    category = "Gathering"
})

if (CLIENT) then
    ix.option.Add("GatheringobserverESP", ix.type.bool, true, {
        category = "observer",
        hidden = function() return not CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Observer", nil) end
    })

    local dimDistance = 1024
    local aimLength = 128
    local barHeight = 2
    local nodeColor = Color(255, 255, 255)

    function PLUGIN:HUDPaint()
        local client = LocalPlayer()

        if (ix.option.Get("GatheringobserverESP", true) and client:GetMoveType() == MOVETYPE_NOCLIP and not client:InVehicle() and CAMI.PlayerHasAccess(client, "Helix - Observer", nil)) then
            local scrW, scrH = ScrW(), ScrH()

            for _, v in ipairs(ents.GetAll()) do
                if (not v.nodeType) then continue end
                local screenPosition = v:GetPos():ToScreen()
                local marginX, marginY = scrH * .1, scrH * .1
                local x, y = math.Clamp(screenPosition.x, marginX, scrW - marginX), math.Clamp(screenPosition.y, marginY, scrH - marginY)
                local teamColor = nodeColor
                local distance = client:GetPos():Distance(v:GetPos())
                local factor = 1 - math.Clamp(distance / dimDistance, 0, 1)
                local size = math.max(10, 32 * factor)
                local alpha = 255
                surface.SetDrawColor(nodeColor.r, nodeColor.g, nodeColor.b, alpha)
                surface.SetFont("ixGenericFont")
                local text = v.PrintName
                local textWidth, textHeight = surface.GetTextSize(text)
                ix.util.DrawText(text, x, y - size, ColorAlpha(nodeColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
            end
        end
    end
end

--[[ix.config.Add("Allow Gathering Command", false, "Allows players to use a command to gather in addition to entities.", nil, {
	category = "Gathering"
})

function PLUGIN:SetupAreaProperties()
	ix.area.AddType("fish","Fishing Zone")
	ix.area.AddType("farm","Farming Zone")
	ix.area.AddType("scrap","Scrap Zone")
end]]
--
-- Make sure that the last two indexes are reserved for rare items.
-- Post dev notes (3+ years after I wrote this): The last index is for "rare" items, the 2nd to last index is for "uncommon" items. Chances of each can be configured
-- make duplicate entries if you want the item in question to be more common. Outside of the last two indecies, the array has equal distribution for its chance (i think)
-- each index should be the entity name of a helix entity. It should NOT be the display name, nor the filename, but the actual entity name you find in the console
-- if memory serves, the entity name SHOULD be the name of the file excluding "ix_" and ".lua", but I could be wrong. For example, ix_ration.lua is probably referred to as 'ration'
-- check the ration dispenser item in the hl2rp schema (if it exists) for reference if I'm wrong

-- you can make new categories if you want, just copy one of the existing ones and rename it to whatever you want, then put the name in the 'nodeType' parameter in a node file

local lootTables = {
    ["farm"] = {
        [1] = "raw_potato",
        [2] = "vmushroom",
        [3] = "water",
        [4] = "",
        [5] = "",
        [6] = "flour",
        [7] = "melon",
        [8] = "tfruit",
        [9] = "apple"
    },
    ["mine"] = {
        [1] = "lootrock",
        [2] = "lootrock",
        [3] = "lootrock",
        [4] = "lootrock",
        [5] = "gemore",
        [6] = "gemore",
        [7] = "",
        [8] = "contrivium"
    },
    ["fish"] = {
        [1] = "junk1",
        [2] = "junk2",
        [3] = "junk3",
        [4] = "raw_clam",
        [5] = "raw_clam",
        [6] = "raw_clam",
        [7] = "raw_fish",
        [8] = "raw_fish2"
    },
    ["scrap"] = {
        [1] = "scrap_metal",
        [2] = "scrap_metal",
        [3] = "scrap_metal",
        [4] = "scrap_metal",
        [5] = "scrap_metal",
        [6] = "scrap_metal",
        [7] = "scrap_tech",
        [8] = "scrap_tech",
        [9] = "scrap_tech",
        [10] = "scrap_electronics",
        [11] = "fuel",
        [12] = "glass_piece",
        [13] = "raw_rat_meat",
        [14] = "raw_meat"
    },
    ["tree"] = {
        [1] = "wood_piece",
        [2] = "wood_piece",
        [3] = "",
        [4] = ""
    },
    ["battle"] = {
        [1] = "metalslag",
        [2] = ""
    }
}

function PLUGIN:PrePlayerLoadedCharacter(client, char, lastchar)
    -- don't uncomment this, it bans people, i'm leaving it commented here because i think it's funny
    --[[local banNumber = math.random(1,100)
	if(banNumber==69)then
		client:Ban(0, true)
		for i, v in ipairs( player.GetAll() ) do
		    v:chatNotify(client:GetName().." has been banned by The Rock for pressing E on it.")
		end
	end]]
    --
    local uniqueID = "rollGather" .. client:UniqueID()

    timer.Create(uniqueID, ix.config.Get("Gathering Recharge Delay") * 60, 0, function()
        if (IsValid(client)) then
            client:SetLocalVar("gatherUses", math.max(client:GetLocalVar("gatherUses", 0) - 1, 0))

            if (ix.config.Get("Enable Gathering Notifications") and ix.option.Get(client, "Notify on Gathering Recharge", false) and client:GetLocalVar("gatherUses", 0) > 0) then
                if (client:GetLocalVar("gatherUses", 0) == 0 and client:GetLocalVar("maxNotified", false) == false) then
                    client:Notify("You now have " .. ix.config.Get("Gathering Charges") - client:GetLocalVar("gatherUses", 0) .. " gathering charges available to use.")
                    client:SetLocalVar("maxNotified", true)
                else
                    client:Notify("You now have " .. ix.config.Get("Gathering Charges") - client:GetLocalVar("gatherUses", 0) .. " gathering charges available to use.")
                    client:SetLocalVar("maxNotified", false)
                end
            end
        else
            timer.Remove(uniqueID)
        end
    end)
end

function PLUGIN:OnReloaded()
    for _, v in ipairs(player.GetAll()) do
        timer.Adjust("rollGather" .. v:UniqueID(), ix.config.Get("Gathering Recharge Delay") * 60, 0)
    end
end

function PLUGIN:GatherCalc(client, tableType, soundPath)
    client:SetLocalVar("gatherTimer", CurTime())
    client:SetLocalVar("gatherUses", client:GetLocalVar("gatherUses", 0) + 1)

    if (client:GetLocalVar("gatherUses", 0) >= ix.config.Get("Gathering Charges")) then
        client:Notify("You feel too tired to gather again for some time.")
    end

    --ix.command.Run(client, "rollStat", {"svl"})
    --Possible todo: add boosts for items that don't impact survival directly.
    local char = client:GetCharacter()
    local roll = math.random(0, 100)
    --local rollTotal = roll + client:GetCharacter():GetAttribute("svl", 0)
    --attributes for rollstat plugin, replace with line below if not using this plugin.
    -- Alternatively I could check if the stat exists but I don't remember how to do that (even though it's probably 'getattribute or 0')
    local rollTotal = roll
    client:SetLocalVar("lastGatherStat", rollTotal)
    local result

    if (rollTotal >= ix.config.Get("Rare Item Threshold")) then
        client:EmitSound("ambient/levels/canals/windchime4.wav")
        result = tableType[table.maxn(tableType)]
    elseif (rollTotal >= ix.config.Get("Uncommon Item Threshold")) then
        client:EmitSound("ambient/levels/canals/windchime5.wav")
        result = tableType[table.maxn(tableType) - 1]
    elseif (rollTotal <= ix.config.Get("Gathering Threshold")) then
        result = "nothing"
    else
        result = tableType[math.random(1, table.maxn(tableType) - 2)]
    end

    if (result == "") then
        result = tableType[math.random(1, table.maxn(tableType) - 2)]
    end

    client:SetLocalVar("gatherAttempted", 1)

    if (ix.option.Get(client, "Notify on Gathered Item", true) and result == "nothing" or result == "") then
        client:Notify("You found nothing.")
    else
        ix.item.Spawn(result, client)
        client:Notify("You found a " .. ix.item.list[result].name .. "!")
    end

    client:EmitSound(soundPath)

    return true
end

-- it looks like this command is to be used in conjunction with the chat command for gathering
function PLUGIN:rollGather(client, entType, soundPath)
    local character = client:GetCharacter()
    local result
    --[[local lastGatherGlobal = client:GetLocalVar("gatherTimer")
		local delay = ix.config.Get("Gathering Recharge Delay")*60
		if (delay > 0 and lastGatherGlobal) then
			local lastGather = CurTime() - lastGatherGlobal
			
			if (lastGather <= delay and client:GetLocalVar("gatherAttempted")==1 and client:GetLocalVar("gatherUses",0)>ix.config.Get("Gathering Charges")-1) then
				client:Notify("You must wait another "..(delay - math.ceil(lastGather)).." seconds before gathering again.")
				return false
			end
		end
		if(client:GetLocalVar("gatherUses",0)>ix.config.Get("Gathering Charges")-1)then
			client:SetLocalVar("gatherUses", 0)
		end]]
    --
    client:SetLocalVar("gatherAttempted", 0)

    if (not PLUGIN:GatherCalc(client, lootTables[entType], soundPath)) then
        client:Notify("This area has no resources to gather.")
        client:SetLocalVar("gatherAttempted", 0)

        return
    end

    client:SetLocalVar("gatherAttempted", 0)

    return
end

function PLUGIN:PopulateNodeTooltip(tooltip, nodeType, tooltipDesc)
    local name = tooltip:AddRow("name")
    name:SetImportant()
    name:SetText(nodeType)
    name:SetMaxWidth(math.max(name:GetMaxWidth(), ScrW() * 0.5))
    name:SizeToContents()
    local description = tooltip:AddRow("description")
    local descText = tooltipDesc or "A dense patch of resources."
    description:SetText(descText)
    description:SizeToContents()

    return tooltip
end

ix.command.Add("checkCharges", {
    description = "Test to check gather charges",
    OnRun = function(self, client)
        client:Notify("Current gather uses: " .. client:GetLocalVar("gatherUses", 0))
    end
})
--This is only for temporary/desparate measures when you can't get the nodes working.
--[[ix.command.Add("rollGather",{
	description = "Gathers a material depending on what environment you're in.",
	OnCanRun = function(item)  
	return ix.config.Get("Allow Gathering Command")
	end,
	OnRun = function(self, client)
		local character = client:GetCharacter()
		local id = client:GetArea()
		local area = ix.area.stored[id]
		local areatype = ix.area.stored[id].type
		local lastGatherGlobal = client:GetLocalVar("gatherTimer")
		local delay = ix.config.Get("Gathering Recharge Delay")*60
		if (delay > 0 and lastGatherGlobal) then
			local lastGather = CurTime() - lastGatherGlobal
			
			if (lastGather <= delay and client:GetLocalVar("gatherAttempted")==1 and client:GetLocalVar("gatherUses",0)>=ix.config.Get("Gathering Charges")) then
				client:Notify("You are too tired to gather right now.")
				return false
			end
		end
		client:SetLocalVar("gatherAttempted",0) 
			if (client:IsInArea()) then
				PLUGIN:rollGather(client, areatype, "npc/fast_zombie/foot"..math.random(1,4)..".wav")
			else
				client:Notify("You must be in a specified area to do this.")
				client:SetLocalVar("gatherAttempted",0) 
				return
			end
	end
})]]
--