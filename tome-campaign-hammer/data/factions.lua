engine.Faction:add{ name="Duathedlen", reaction={}, }
engine.Faction:add{ name="???", short_name="realm-divers", reaction={}, }

engine.Faction:setInitialReaction("fearscape", "duathedlen", 100, true)
engine.Faction:setInitialReaction("duathedlen", "rhalore", 10, true)
engine.Faction:setInitialReaction("fearscape", "rhalore", -50, true)

