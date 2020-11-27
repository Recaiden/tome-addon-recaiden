-- ToME - Tales of Maj'Eyal:
-- Copyright (C) 2009 - 2018 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local class = require "class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local NameGenerator = require "engine.NameGenerator"
local Tiles = require "engine.Tiles"
local PartyLore = require "mod.class.interface.PartyLore"

class:bindHook("ToME:load", function(self, data)
	PartyLore:loadDefinition("/data-egressrandlore/lore/egress-artifact-codes.lua")
end)

function hookEntityLoadList(self, data)
	if type(game) ~= "table" then return end

	if data.file == "/data/general/objects/lore/maj-eyal.lua"
	or data.file == "/data-orcs/general/objects/lore.lua" then
	   self:loadList("/data-egressrandlore/lore/egress-artifact-drops.lua",
			 data.no_default, data.res, data.mod, data.loaded)
	end
end

class:bindHook("Entity:loadList", hookEntityLoadList)

--	   self:loadList("/data-cults/general/objects/lore/eyal.lua",



