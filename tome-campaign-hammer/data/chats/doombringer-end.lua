local p = game.party:findMember{main=true}
newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*The Allied king lies dead before you.*#WHITE#
#LIGHT_GREEN#*The battle rages on outside, but there's little doubt as to the outcome.*#WHITE#
#LIGHT_GREEN#*Maj'Eyal will fall, then the East, the South, the Oceans, and someday the demons will track down the Sher'tul in every corner of the cosmos they have fled to.*#WHITE#

#LIGHT_GREEN#*If you were free to think clearly, you might hope that the war last a very long time, because once their revenge is complete, the demons will have no more use for you...*#WHITE#

You have won the game!]],
	answers = {
		{_t"[leave]"},
	}
}
return "welcome"
