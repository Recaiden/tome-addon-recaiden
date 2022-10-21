local subclasses = {"Sawbutcher", "Gunslinger", "Psyshot", "Annihilator"}

for i, subclass in ipairs(subclasses) do
	local class = getBirthDescriptor("subclass", subclass)

	class.power_source = class.power_source or {steam=true}
	class.power_source["technique"] = nil
	class.power_source["technique_ranged"] = nil
end
