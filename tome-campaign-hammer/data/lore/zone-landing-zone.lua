newLore{
	id = "landing-site-note-3",
	category = "landing-site",
	name = _t"tattered(?) paper(?) scrap(?)",
	lore = function(is_lore_popup)
		if is_lore_popup then
		return _t[[#{italic}#You find a tattered page scrap. Perhaps this is part of a diary entry.#{normal}#
"As far as we can tell, Norgos's Lair is safe again, but the wilder we sent to deal with it never came back.  For a while, it seemd like just a symptom, but now the eastern woods -
So tired.
Gotta finish this report though.  Where was I-
-The eastern woods..."]]
		else
			return _t[[
"...not one but four Extinguishers confirmed still on not-far-away-enough lines, so that's it for the bell.  Just as soon as we find that last exo, everything's getting shut down.  Shame, while it lasted, this really..."]]
		end
	end,
}

newLore{
	id = "landing-site-note-2",
	category = "landing-site",
	name = _t"tattered(?) paper(?) scrap",
	lore = function(is_lore_popup)
		if is_lore_popup then
			return _t[[#{italic}#You find a tattered page scrap. Perhaps this is part of a diary entry.#{normal}#
"...Norgos is dead, and the madness has left this glade.  Snakes that were trying to choke me a moment before sltihered away, and the unnatural ice storm came to a sudden end.  But I still feel that, well, something is wrong..."]]
		else
			return _t[[
"...site really is the best, though.  No Sparklers, no Geegees, and it's so delicately balanced on account of the .... Got to remind them not to overload the bell...Had another problem with an exo terminal today.  There was a living disruption in the ether attached to all the native terminals, and a couple folks got locked in, on opposite sides of ...  One of the exos found a great new pattern today. The basis is a central column, anchor-mouths at one end, collectors at the other.  They put a neat spin on the collectors though.  We'll have to try it in other bells."]]
		end
	end,
}

newLore{
	id = "landing-site-note-1",
	category = "landing-site",
	name = _t"tattered paper(?) scrap",
	lore = function(is_lore_popup)
		if is_lore_popup then
			return _t[[#{italic}#You find a tattered page scrap. Perhaps this is part of a diary entry.#{normal}#
"...is a gorgeous glade, but I could swear that looked like a part of a human femur.

...

Saw an absolutely gigantic troll, but fortunately I threw him off my scent."]]
		else
			return _t[[
"...careful out here, everybody. At the edge of the bell you can run into reflectors, suitclones, and even doppelers.  We've even had one report of an Extinguisher, although it was unsubstantiated.  I don't need to tell you that that's no fun.  At bell actual, we'..."]]
		end
	end,
}
