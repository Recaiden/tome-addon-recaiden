local loadIfNot = function(f)
	if loaded[f] then return end
	load(f, entity_mod)
end

loadIfNot("/data/general/objects/objects.lua")
loadIfNot("/data/general/objects/objects-maj-eyal.lua")
loadIfNot("/data/general/objects/world-artifacts-far-east.lua")
loadIfNot("/data/general/objects/boss-artifacts-far-east.lua")

loadIfNot("/data-campaign-hammer/general/objects/boss-artifacts.lua")
