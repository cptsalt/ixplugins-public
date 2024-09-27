Here's how to make nodes:

Make a file called ix_[type]node.lua (or anything else, just keep ix_[name].lua)

Paste the following and fill in with real data:

AddCSLuaFile()

local PLUGIN = PLUGIN

ENT.Base = "ix_nodebase"
ENT.Type = "anim"
ENT.PrintName = "[[Display name of the spawn icon]]"
ENT.actionName = "[[Text that appears on the progress bar]]" 
ENT.Category = "Roll Gathering"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = false --set this to true if you don't want the node to persist
ENT.nodeType = "[[category]]" --this determines the loot table set in sh_plugin
ENT.modelType = "[[path to the model for the node]]"
ENT.tooltipName = "[[Display name for the node entity]]"
ENT.tooltipDesc = "[[Description for the node entity]]"
ENT.soundPath = "[[path to the sound that plays while you gather]]"
ENT.endSound = "[[sound that plays when you finish gathering]]"
ENT.maxSound = 4 --how many times the sound should play at most while you gather
ENT.isRare = false --rare nodes have a different gathering time than normal ones, set to true if desired