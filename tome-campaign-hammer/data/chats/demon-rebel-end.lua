local p = game.party:findMember{main=true}
newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*The General of Urh'Rok has fallen before you.*#WHITE#
#LIGHT_GREEN#*Across the fearscape, demons listen in confusion to their new orders - the invasion is over.*#WHITE#
#LIGHT_GREEN#*This world will be spared, and for the first time in millenia, your people can dream of something other than vengeance.*#WHITE#

You have won the game!]],
	answers = {
		{_t"[leave]"},
	}
}
return "welcome"
