locale "ko_KR"
------------------------------------------------
section "tome-classmartyr/data/birth/classes/demented.lua"

t("Martyr", "순교자", "birth descriptor name")
t("You are a hero of the old ways, a noble #GREEN#monster#LAST# of honor. You stand alone against overwhelming odds, living by your code. You face the monsters and darkness of the world #GREEN#to pave our way#LAST#.", "당신은 고전적인 유형의 영웅입니다. 명예롭고 고결한 #GREEN#괴물#LAST#이죠. 당신은 압도적인 강적들에게 홀로 맞서며, 자신만의 신조를 따라 살아갑니다. 이 세상의 괴물들과 어둠을 상대하며 #GREEN#우리가 함께 나아갈 길을 닦는 것이다#LAST#.", "_t")
t("Grind enemies down with #GREEN#our flesh#LAST# before finishing them with a flash of steel.", "#GREEN#우리의 살점#LAST#으로 적들을 분쇄하고 번뜩이는 검을 휘둘러 마무리를 지으세요.", "_t")
t("#GREEN#Our#LAST# most important stats are Cunning and Strength.", "#GREEN#우리#LAST#에게 가장 중요한 능력치는 교활과 힘입니다.", "_t")
t("#GOLD#Stat modifiers:", "#GOLD#능력치 변경:", "_t")
t("#LIGHT_BLUE# * +3 Strength, +0 Dexterity, +0 Constitution", "#LIGHT_BLUE# * +3 힘, +0 민첩, +0 체격", "_t")
t("#LIGHT_BLUE# * +0 Magic, +5 Willpower, +3 Cunning", "#LIGHT_BLUE# * +0 마법, +5 의지, +3 교활", "_t")
t("#GOLD#Life per level:#LIGHT_BLUE# +0", "#GOLD#레벨 당 생명력:#LIGHT_BLUE# +0", "_t")

------------------------------------------------
section "tome-classmartyr/data/damage_types.lua"

t("warning lights", "경고의 빛", "_t")
t("healing guidance", "치유의 인도", "damage type")
t("energizing guidance", "활력의 인도", "damage type")
t("destructive guidance", "파괴의 인도", "damage type")
-- new text
--[==[
t("mind", "정신", "damage type")
--]==]


------------------------------------------------
section "tome-classmartyr/data/effects.lua"

t("confusion", "혼란", "effect subtype")
t("Unnerved", "불안", "_t")
t("Unable to handle the truth, giving them a %d chance to act randomly, suffering %d damage, and losing %d power, with a %d%% chance for longer cooldowns", "진실을 감당할 수 없음: %d 확률로 무작위로 행동, %d 피해 받음, 각종 위력 %d 만큼 감소, %d%% 확률로 재사용 대기시간 증가.", "tformat")
t("temporal", "시간", "effect subtype")
t("Recently Awakened", "막 깨어남", "_t")
t("Just woke up and is immune to all damage.", "방금 깨어남: 모든 피해에 면역.", "tformat")
t("disease", "질병", "effect subtype")
t("Scorned", "멸시", "_t")
t("The target's self-image has been crushed, and they take %d damage each turn as a Disease effect%s %s %s", "대상의 자아상이 붕괴됨: 질병 효과로 매 턴 %d 피해를 받음%s %s %s", "tformat")
t(" and heal the source for %d%% as much.", ", 또한 그 피해량의 %d%% 만큼 시전자의 생명력이 회복됨.", "tformat")
t("\
The damage's intensity will increase by %d%% per turn.", "\
이 피해량은 매 턴마다 %d%% 씩 상승함.", "tformat")
t("\
The pain causes them to have a %d%% chance to fail to use talents.", "\
대상은 고통으로 인해 %d%% 확률로 기술 사용에 실패함.", "tformat")
t("demented", "광기", "effect subtype")
t("Inspired", "영감", "_t")
t("You are empowered by your madness, increasing  mindpower by %d.", "광기를 통해 강화됨: 정신력 %d 상승.", "tformat")
t("Demented", "광인", "_t")
t("The target cannot think clearly, reducing their damage and increasing their cooldowns by %d%%.", "명확하게 생각할 수 없음: 가하는 피해량 %d%% 감소, 같은 값만큼 재사용 대기시간 증가.", "tformat")
t("haste", "가속", "effect subtype")
t("Manic Speed", "광란의 속도", "_t")
t("The target is moving at infinite speed for %d to %d steps.", "무한대의 속도로 이동 중: 다음 %d - %d 걸음이 턴을 소모하지 않음.", "tformat")
t("#Target# accelerates out of sight!", "#Target1# 엄청난 속도로 가속해 눈앞에서 사라진다!", "_t")
t("+Infinite Speed", "+무한대의 속도", "_t")
t("#Target# has lost their manic speed.", "#Target1# 광란의 속도를 잃었다.", "_t")
t("-Infinite Speed", "-무한대의 속도", "_t")
t("whisper", "속삭임", "effect subtype")
t("Psychic Tunneling", "초능력 연결", "_t")
t("Detects creatures of type %s/%s in radius 15.", "반경 15 칸 이내의 해당 개체 감지: %s/%s.", "tformat")
t("miscellaneous", "기타", "effect subtype")
t("Aura of Confidence", "신뢰의 오라", "_t")
t("Linked to their flag gaining %d%% all damage resistance.", "깃발과 연결됨: 모든 속성 저항 +%d%%.", "tformat")
t("#Target# links closer to his ally!", "#Target#의 광기 공유가 시작된다!", "_t")
t("#Target# no longer seems to be in sync with his ally.", "#Target#의 광기 공유가 끊겨버렸다.", "_t")
t("healing", "회복", "effect subtype")
t("regeneration", "재생", "effect subtype")
t("Guided to Healing", "치유의 인도를 받음", "_t")
t("A light of life shines upon the target, regenerating %0.2f life per turn.", "생명의 빛을 받음: 생명력 재생 %0.2f 상승.", "tformat")
t("#Target# is healing in the light.", "#Target1# 빛속에서 치유되고 있다.", "_t")
t("+Regen", "+재생", "_t")
t("#Target# stops healing.", "#Target#의 치유가 멈췄다.", "_t")
t("-Regen", "-재생", "_t")
t("focus", "집중", "effect subtype")
t("Guided to Destroy", "파괴의 인도를 받음", "_t")
t("The target's damage is improved by +%d%%.", "대상이 가하는 피해량 +%d%%.", "tformat")
t("Seeking the Light", "빛을 찾는 중", "_t")
t("Somewhere nearby is a beam of light this creature is looking for", "근처 어딘가에 대상이 찾는 빛기둥이 있음", "tformat")
t("psionic", "초능력", "effect subtype")
t("Runaway Resonation", "공명 폭주", "_t")
t("The target's subconscious is surging with energy, guaranteeing critical mental attacks and increasing critical power by +%d.", "대상의 잠재의식이 에너지로 충만함: 정신 치명타가 무조건 일어남 / 치명타 피해량 +%d.", "tformat")
t("#Target#'s subconscious surges with power.", "#Target#의 잠재의식이 힘으로 충만해진다.", "_t")
t("+Resonation", "+공명", "_t")
t("#Target#'s subconscious has returned to normal.", "#Target#의 잠재의식이 원래대로 돌아왔다.", "_t")
t("-Resonation", "-공명", "_t")
t("physical", "물리", "effect subtype")
t("Writhing Speed", "뒤틀린 속도", "_t")
t("The target's is making tentacle-assisted archery attacks very quickly.", "대상은 촉수의 도움을 받아 극히 빠른 속도로 사격 중임.", "tformat")
t("block", "방패막기", "effect subtype")
t("Cut Danger", "위험 절단", "_t")
t("The target is countering all attacks, preventing %d damage.", "대상은 모든 공격에 반격하고 있음: 받는 모든 피해량 %d 감소.", "tformat")
t("weapon", "무기", "effect subtype")
t("Cutting Fate", "운명 절단", "_t")
t("The target is wielding the Final Moment as a sword.", "대상은 최후의 순간을 검으로써 쥐고 있음.", "tformat")
t("horror", "공포", "effect subtype")
t("morph", "변화", "effect subtype")
t("Abyssal Form: Luminous", "심연의 형상: 빛나는 공포", "_t")
t("The target is revealed as a luminous horror!", "이 대상의 진짜 모습은 빛나는 공포였다!", "tformat")
t("#Target# returns to their normal guise.", "#Target1# 다시 변장한다.", "_t")
t("Abyssal Form: Umbral", "심연의 형상: 그림자의 공포", "_t")
t("The target is revealed as an umbral horror!", "이 대상의 진짜 모습은 그림자의 공포였다!", "tformat")
t("#PURPLE##Target# is revealed to have been an umbral horror all along!", "#PURPLE##Target#의 진짜 모습이 드러난다. 바로 그림자의 공포였다!", "_t")
t("Abyssal Form: Bloated", "심연의 형상: 부풀어오른 공포", "_t")
t("The target is revealed as a bloated horror!", "이 대상의 진짜 모습은 부풀어오른 공포였다!", "tformat")
t("#PURPLE##Target# is revealed to have been a bloated horror all along!", "#PURPLE##Target#의 진짜 모습이 드러난다. 바로 부풀어오른 공포였다!", "_t")
t("Abyssal Form: Parasitic", "심연의 형상: 기생하는 공포", "_t")
t("The target is revealed as a Parasitic horror!", "이 대상의 진짜 모습은 기생하는 공포였다!", "tformat")
t("#PURPLE##Target# is revealed to have been a Parasitic horror all along!", "#PURPLE##Target#의 진짜 모습이 드러난다. 바로 기생하는 공포였다!", "_t")
t("insanity", "광기", "effect subtype")
t("Sane", "제정신", "_t")
t("You see the world as it truly is.", "진실된 세상의 모습을 보고 있음.", "tformat")
t("Insane", "광기", "_t")
t("slow", "감속", "effect subtype")
t("Tainted Rounds", "오염된 탄환", "_t")
t("Reduces movement speed by %d%% and deals %0.2f mind damge when a new stack is applied.", "이동 속도 %d%% 감소 / 이 효과가 중첩될 때마다 %0.2f 정신 피해 받음.", "tformat")
t("#Target# is slowed by the taint", "#Target# 오염으로 인해 느려졌다.", "_t")
t("+Tainted Slow", "+오염 감속", "_t")
t("#Target# speeds up.", "#Target2# 가속했다.", "_t")
t("-Tainted Slow", "-오염 감속", "_t")

------------------------------------------------
section "tome-classmartyr/data/talents/chivalry.lua"

t("Champion's Focus", "챔피언의 집중", "talent name")
t("You aren't insane enough to use this", "이 기술을 사용하기에는 너무 제정신이다.", "logPlayer")
t([[Each melee attack you land on your target has a %d%% chance to trigger another, similar strike at the cost of #INSANE_GREEN#%d insanity#LAST#.
This works for all blows, even those from other talents and from shield bashes, but this talent can grant at most one attack per weapon per turn.

#INSANE_GREEN#Minimum Insanity: %d#LAST#
This talent will deactivate if it brings you to below its minimum insanity, or upon resting.

Dexterity or Willpower: increases chance]], [[대상에게 근접 공격을 가할 때마다 %d%% 확률로 #INSANE_GREEN#%d 광기#LAST#를 소모하여 비슷한 공격을 추가로 가합니다.
이 효과는 모든 근접 공격에 적용됩니다. 즉 여러가지 다른 근접 공격 기술들과 방패 기술에도 적용되지만, 각 무기는 추가타를 한 턴에 한 번만 가할 수 있습니다.

#INSANE_GREEN#광기 최저치: %d#LAST#
시전자가 휴식을 취하거나, 이 기술로 인해 시전자의 광기가 최저치 이하로 떨어지게 되면 이 기술은 자동적으로 비활성화됩니다.

민첩이나 의지: 확률 상승]], "tformat")
t("Lancer's Charge", "창기병의 돌진", "talent name")
t("You are too close to build up momentum!", "거리가 너무 가까워 가속도를 얻을 수 없다!", "logPlayer")
t("You can only charge to a creature.", "생명체를 대상으로만 돌진할 수 있다.", "logPlayer")
t("Something is blocking your path.", "무엇인가가 경로를 막고 있다.", "logPlayer")
t("Hop astride your noble steed and run down a target at least 3 spaces away, striking with all weapons (including shield) for %d%% damage. A hit will stun them (#SLATE#Physical Power vs. Physical#LAST#) for %d turns and grant you an additional #INSANE_GREEN#15 insanity#LAST#.  All other targets next to your path will be attacked with your mainhand weapon for %d%% damage and dazed (#SLATE#Physical Power vs. Physical#LAST#) for %d turns on a hit.", "애마에 재빨리 올라타고, 최소 3 칸 이상 떨어진 적에게로 달려가 모든 무기로 (방패 포함) 공격하여 %d%% 피해를 가합니다. 이 공격은 대상을 %d 턴 동안 기절시키고 (#SLATE#물리력 vs. 물리 내성#LAST#) 시전자는 #INSANE_GREEN#15 광기#LAST#를 추가로 얻습니다. 돌진 경로의 옆 칸에 있던 다른 대상들 역시 주무기로 공격하여 %d%% 피해를 가하고 %d 턴 동안 혼절시킵니다 (#SLATE#물리력 vs. 물리 내성#LAST#).", "tformat")
t("Executioner's Onslaught", "처형인의 맹공", "talent name")
t([[Throw off a stun, daze, or pin that might stop you from moving, take a step, and then strike a random adjacent enemy for %d%% damage.
This will also attack with your shield if you have one equipped.
]], [[기절, 혼절, 속박 등 시전자를 움직이지 못하게 하는 효과를 해제하고, 한 걸음 나아가며 인접한 적들 중 하나를 공격하여 %d%% 피해를 가합니다.
방패를 들고 있는 경우, 이 기술을 사용하면 방패로도 공격합니다.
]], "tformat")
t("Hero's Resolve", "영웅의 결의", "talent name")
t([[You will not let minor wounds and difficulties stop you from fighting.
		You gain %d%% resistance to blindness, wounds, and being disarmed.]], [[하찮은 상처나 방해들을 무시하고 계속해서 싸웁니다.
		시전자의 실명, 출혈, 무장해제 저항력이 %d%% 상승합니다.]], "tformat")

------------------------------------------------
section "tome-classmartyr/data/talents/crucible.lua"

t("Share Pain", "고통 나누기", "talent name")
t([[Force the pain you've felt out of your mind and into the world, doing %0.2f mind damage to target enemy and all enemies with radius 2 of them.  Each affected target after the first increases damage done to all targets by 10%%.
Mindpower: improves damage.]], [[시전자가 느껴왔던 고통을 세상에 떠밀어, 대상과 그 주변 2 칸 내의 모든 적들에게 %0.2f 정신 피해를 가합니다. 두 번째 적부터 피해량이 10%% 상승합니다.
정신력: 피해량 증가.]], "tformat")
t("Overflow", "범람", "talent name")
t([[Feedback gains beyond your maximum allowed amount will reduce the cooldowns of your feedback talents, using %d excess feedback per turn of cooldown.  You cannot gain more overflow at once than your maximum feedback.
Talents are recharged in this order:
 - Share Pain
 - Memento Mori
 - Runaway Resonation
 - Resonance Field
 - Conversion]], [[최대치 이상으로 반작용을 얻게 되면 반작용 계열 기술들의 재사용 대기시간이 감소합니다. 초과된 반작용 %d 마다 1 턴씩 감소합니다. 최대치 이상의 반작용을 단번에 얻을 수는 없습니다.
재사용 대기시간 감소 시 우선순위는 다음과 같습니다:
 - 고통 나누기
 - 메멘토 모리
 - 공명 폭주
 - 공명 역장
 - 변환]], "tformat")
t("Memento Mori", "메멘토 모리", "talent name")
t([[Meld together your painful feedback with a target's own suffering to form a lethal blade of mental turmoil. 
The target will take mind damage equal to %d%% of the life it already lost (up to %d).
Mindpower: raises the cap.]], [[대상 하나의 고통과 시전자의 반작용을 뒤섞어 정신을 휘젓는 치명적인 칼날을 만들어냅니다. 
대상이 잃은 생명력의 %d%% 에 해당하는 정신 피해를 가합니다 (최대 %d 까지).
정신력: 최대 피해량 상승.]], "tformat")
t("Runaway Resonation", "공명 폭주", "talent name")
t("Focus your feedback in on itself, setting your mind surging with unstoppable power.  For %d turns, your critical power is increased by half your mental critical rate (%d%% => %d), and your mental critical rate becomes 100%%.", "반작용 그 자체에 집중하여, 엄청난 힘으로 정신을 채웁니다. 다음 %d 턴 동안 시전자의 치명타 피해량이 정신 치명타 확률의 절반만큼 상승하고 (%d%% => %d), 시전자의 정신 치명타 확률이 100%%가 됩니다.", "tformat")

------------------------------------------------
section "tome-classmartyr/data/talents/demented.lua"

t("Uses the higher of your Strength or Dexterity", "힘과 민첩 중 더 높은 것을 사용함", "_t")
t("Points in Vagabond talents allow you to learn Chivalry talents", "떠돌이 계열 기술들에 점수를 투자한 만큼 기사도 계열의 기술들을 배울 수 있음", "_t")
t("You are currently disarmed and cannot use this talent.", "현재 무장 해제를 당했으며, 이 기술을 발동할 수 없다.", "_t")
t("You require a %s to use this talent.", "이 기술을 사용하기 위해선 %s 필요합니다.", "tformat", nil, {"가"})
t("You require ammo to use this talent.", "이 기술을 사용하기 위해서는 탄환이 필요하다.", "_t")
t("Your ammo cannot be used.", "탄환을 쓸 수 없다.", "_t")
t("Your ammo is incompatible with your missile launcher.", "당신의 탄환은 투사 무기와 맞지 않는다.", "_t")
t("You require a missile launcher and ammo for this talent.", "이 기술을 사용하기 위해서는 투사 무기와 탄환이 필요하다.", "_t")
t("You do not have enough ammo left!", "남은 탄환이 없다!", "logPlayer")
t("demented", "광기", "talent category")
t("Chivalry", "기사도", "talent type")
t("Onward, to greater challenges, for glory!", "보다 큰 시련을 향해 나아가자! 명예를 위하여!", "_t")
t("Vagabond", "떠돌이", "talent type")
t("I'm not the only one seeing this, right?", "설마 나만 이게 보이는 건가? 아니겠지?", "_t")
t("Beinagrind Whispers", "베이나그린드의 속삭임", "talent type")
t("Exist on the edge of madness", "광기에 살고 광기에 죽는다.", "_t")
t("Unsettling Words", "불안의 언령", "talent type")
t("Distort your enemies' perceptions and fray their sanity.", "놈들의 인지를 뒤틀고 정신을 갉아먹어라.", "_t")
t("Polarity", "양극성", "talent type")
t("Dive into the madness; power comes at the price of sanity", "광기 속으로 뛰어들어라. 이성을 버리면 힘을 얻을 수 있을지니!", "_t")
t("Scourge", "재앙", "talent type")
t("We will fight; you are but a vessel.", "우리는 싸울 것이다. 너는 그저 그릇일 뿐이로다.", "_t")
t("Standard-Bearer", "영도자", "talent type")
t("To he who is victorious, ever more victories will flow!", "승리를 거둔 자여, 더 많은 승리가 따르리라!", "_t")
t("Final Moment", "최후의 순간", "talent type")
t("Wield the blade of the ancient kings, and you will never be late nor lost.", "고대 왕들의 검을 쥐어라. 너는 결단코 늦지 않을 것이며, 잃지도 않을 것이니.", "_t")
t("psionic", "초능력", "talent category")
t("Crucible", "도가니", "talent type")
t("Pain brings clarity.  To see clearly is painful.", "고통이 시야를 깨끗이 한다. 명확하게 보는 것은 고통스럽다.", "_t")
t("Revelation", "계시", "talent type")
t("You see the world as it truly is, Eyal in the Age of Scourge.  The world is horrid, but the truth has power.", "진실된 세상의 모습이 보인다. 재앙의 시대로 접어든 에이알의 모습이. 이 세상은 지독하기 짝이 없지만, 무릇 진실이라는 것은 힘을 가지고 있다.", "_t")

------------------------------------------------
section "tome-classmartyr/data/talents/moment.lua"

t("Cut Time", "시간 절단", "talent name")
t([[You think of the sword.  

					The world stands still. 

You are holding a sword.

					The sword slices through everyone around you (%d%%). 

You are not holding the sword.

					The world is in motion.
#YELLOW#Regain your sanity to better understand this talent.#LAST#

The sword springs from your mind.  Behold!
		%s
]], [[네가 칼을 떠올린다.  

					세상이 고요하다. 

네가 칼을 쥐고 있다.

					칼이 널 둘러싼 모두를 베어가른다 (%d%%). 

네가 칼을 쥐고 있지 않다.

					세상이 움직이기 시작한다.
#YELLOW#이 기술을 보다 잘 이해하려거든 제정신을 되찾아라.#LAST#

이 칼이 네 정신으로부터 뽑혀나온다. 보거라!
		%s
]], "tformat")
t([[Summon an impossible sword, the Final Moment, and use it to strike everyone adjacent to you for %d%% weapon damage.
Mindpower: improves damage, accuracy, armor penetration, critical chance.

		Current Final Moment Stats:
		%s]], [[있을 수 없는 검 "최후의 순간"을 불러내 쥐고, 시전자와 인접한 적 모두를 베어 %d%% 무기 피해를 가합니다.
정신력: 피해량/정확도/방어력 관통/치명타 확률 증가.

		최후의 순간의 현재 능력치:
		%s]], "tformat")
t("Cut Space", "공간 절단", "talent name")
t([[The sword goes out before you, %d paces.

					The sword cuts all in its path (%d%%).
					You come to the blade.

The sword is behind you.

					It waits.
					It waits.

The sword comes to you.

					The sword cuts all in its path once more.
					You are together.

You are not holding a sword.                                        

Strikes with the sword grow more accurate (%d).
#YELLOW#Regain your sanity to better understand this talent.#LAST#]], [[칼이 네 앞으로 %d 걸음 나아간다.

					칼이 지나간 곳을 벤다 (%d%%).
					네가 칼에게 닿는다.

칼이 네 뒤에 있다.

					칼이 기다린다.
					칼이 기다린다.

칼이 네게 온다.

					칼이 지나간 곳을 다시 벤다.
					네가 칼과 함께다.

네가 칼을 쥐고 있지 않다.                                        

칼이 조금 더 정확하게 벤다 (%d).
#YELLOW#이 기술을 보다 잘 이해하려거든 제정신을 되찾아라.#LAST#]], "tformat")
t([[Throw the Final Moment up to %d spaces, attacking all targets in a line for %d%% weapon damage and teleporting yourself to the end of the line.  2 turns later, repeat the attack against all targets between your original position and your current position.                              

Learning this talent increases the Accuracy of your Final Moment by %d]], [[최후의 순간을 최대 %d 칸 멀리까지 던져 경로 상의 적들에게 %d%% 무기 피해를 가하고, 경로의 끝 지점으로 순간이동합니다. 2 턴 뒤, 시전자가 원래 있던 위치와 현재 위치 사이의 적들에게 다시 한 번 공격합니다.                              

이 기술을 배우면 최후의 순간의 정확도가 %d 상승합니다.]], "tformat")
t("Cut Fate", "운명 절단", "talent name")
t([[You lose your life or your sanity.

					The world stands still.

You are holding a sword.

					The world remains still.

You have %0.2f breaths.

Strikes with the sword may grant you a tenth of a breath (%d%%).
#YELLOW#Regain your sanity to better understand this talent.#LAST#]], [[네가 생명력이나 제정신을 잃는다.

					세상이 고요하다.

네가 칼을 쥐고 있다.

					세상이 고요하다.

네가 %0.2f 번 숨을 내쉰다.

칼로 벨 때마다 네가 1할의 숨결을 내쉰다 (%d%%).
#YELLOW#이 기술을 보다 잘 이해하려거든 제정신을 되찾아라.#LAST#]], "tformat")
t([[If you would gain insanity beyond your maximum, or would take damage exceeding your current health, time stops, granting you %0.2f turns.  While time is stopped, you use the Final Moment for all your attacks.
Mindpower: improves turn gain

This effect has a cooldown.

All attacks with the Final Moment have %d%% to grant you 10%% of a turn (up to 3 times per turn).
]], [[시전자가 최대치 이상으로 광기를 얻거나, 현재 생명력을 넘는 피해를 받게 되면 %0.2f 턴 동안 시간이 정지합니다. 시간이 정지한 동안에는 시전자는 모든 공격에 최후의 순간을 사용합니다.
정신력: 정지하는 턴 수 증가

이 효과는 재사용 대기시간이 존재합니다.

최후의 순간으로 가하는 모든 공격이 %d%% 확률로 시전자에게 10%%의 턴을 제공합니다 (매 턴 최대 3 번까지).
]], "tformat")
t("Cut Danger", "위험 절단", "talent name")
t([[Danger approaches.

					Your thoughts protect you, your sword is your shield.

The danger strikes you, weakened by %d.

					Your sword strikes back (%d%%).

Strikes with the sword may strike again.
#YELLOW#Regain your sanity to better understand this talent.#LAST#]], [[위험이 다가온다.

					네 생각이 너를 지키며, 네 칼이 너의 방패다.

너를 덮치는 위험이 %d 만큼 약해진다.

					네 칼이 앙갚음한다 (%d%%).

칼의 궤적이 또 다른 궤적을 낳는다.
#YELLOW#이 기술을 보다 잘 이해하려거든 제정신을 되찾아라.#LAST#]], "tformat")
t([[Summon the Final Moment to block incoming attacks.  For 1 turn, all incoming damage is reduced by %d and you will counterattack using the Final Moment for %d%% damage, even at range.  The counterattack can only happen once per attacker.
Mindpower: increases damage blocked
Mental Critical: increases damage blocked

Learning this talent gives attacks with the Final Moment a 20%% chance to trigger Cut Time (talent level %0.1f)]], [[최후의 순간을 불러내어 공격을 막습니다. 1 턴 동안 시전자가 받는 모든 피해가 %d 만큼 감소하고, 거리에 상관없이 최후의 순간으로 반격하여 %d%% 피해를 가합니다. 반격은 공격자마다 한 번씩만 일어납니다.
정신력: 피해 감소량 증가
정신 치명타 확률: 피해 감소량 증가

이 기술을 배우면 최후의 순간으로 가하는 공격이 20%% 확률로 시간 절단 (기술 레벨 %0.1f) 을 추가로 일으킵니다.]], "tformat")

------------------------------------------------
section "tome-classmartyr/data/talents/polarity.lua"

t("Deeper Shadows", "깊어지는 그림자", "talent name")
t([[You learn to intensify chaotic forces to your advantage, giving you a 'minimum insanity' for determining random insane effects.
Positive insanity effects will have at least %d / 50 power and be %d%% more common.
Negative insanity effects will have at least %d / 50 power but be %d%% less common.

(Insanity effects normally have 50 power at 100 insanity)
]], [[혼돈의 힘을 증폭시키고 이용하는 법을 익혀, '광기 최저치'를 통해 무작위 광기 추가효과를 결정합니다.
긍정적인 광기 추가효과는 최소 %d / 50 위력을 가지며 %d%% 더 자주 발생하게 됩니다.
부정적인 광기 추가효과는 최소 %d / 50 위력을 가지지만 %d%% 덜 발생하게 됩니다.

(광기 추가효과는 본래 광기 100에서 50 위력입니다)
]], "tformat")
t("Manic Speed", "광란의 속도", "talent name")
t("You can't use this if you can't move", "이동할 수 없으면 이 기술을 사용할 수 없다.", "logPlayer")
t("You aren't insane enough to use this", "이 기술을 사용하기에는 너무 제정신이다.", "logPlayer")
t([[Step into the time between seconds and move at infinite speed.  This will last for a random number of steps between %d and %d, or for one turn, whichever comes sooner.  
Moving at this speed triggers Out of Phase effects, as if you had teleported.

#INSANE_GREEN#Minimum Insanity: 10#LAST#

#{italic}#Perfection is not 'going faster'.  Perfection is 'already being there'.#{normal}#]], [[찰나의 순간들 사이로 발걸음을 내딛고 무한대의 속도로 움직이게 됩니다. 이 효과는 %d - %d 걸음 움직이는 동안, 또는 1 턴 동안 유지됩니다.  
이 정도 속도로 움직이는 것은 순간이동이나 다름없어, 위상 탈선 계통의 효과들을 발동시킬 수 있습니다.

#INSANE_GREEN#광기 최저치: 10#LAST#

#{italic}#'빠르게 움직이는' 것은 부족하다. '이미 그곳에 있는' 것이 완벽한 것이다.#{normal}#]], "tformat")
t("Mad Inspiration", "광기의 영감", "talent name")
t([[When you suffer a negative insanity effect, the mad visions grant you Inspiration, increasing your Mindpower by %d for %d turns.  This stacks up to %d times.
]], [[시전자가 부정적인 광기 추가효과를 받게 되면 제정신이 아닌 광경을 통해 영감 중첩을 얻습니다. 이 효과로 %d 턴 동안 정신력이 %d 상승하며, 이는 최대 %d 번 까지 중첩됩니다.
]], "tformat", {2,1,3})
t("Dement", "발광", "talent name")
t("You must be Inspired to use this talent.", "이 기술을 사용하려면 영감이 있어야 한다.", "logPlayer")
t([[Consume your Inspiration to drag a target into the depths of insanity(#SLATE#Mindpower vs. Mental#LAST#), reducing their damage dealt by %d%% and increasing the cooldowns of any talents they use by %d%% for the next %d turns.

Mindpower: increases effects
]], [[영감 중첩을 소모하여 대상을 광기에 빠뜨립니다 (#SLATE#정신력 vs. 정신 내성#LAST#). %d 턴 동안 대상이 가하는 피해를 %d%% 감소시키고, 대상이 기술을 사용할 때마다 해당 기술의 재사용 대기시간을 %d%% 증가시킵니다.

정신력: 효과 상승
]], "tformat", {3,1,2})

------------------------------------------------
section "tome-classmartyr/data/talents/revelation.lua"

t("Apocalypse Eyes", "종말을 보는 눈", "talent name")
t("#YELLOW#You look upon %s and realize its true nature as %s!", "#YELLOW#%s 바라보고 그 본모습이 %s임을 간파했다!", "say", nil, {"를"})
t([[You have trained yourself to look at the ruined world that others pretend not to notice. 
Your attention to detail increases stealth detection and invisibility detection by %d. The things you have learned give you %d%% resistance to and %d%% increased damage against the Horrors you see.

#ROYAL_BLUE#Sometimes reveals hidden truths that you'd rather not see.#LAST#
]], [[다른 이들이 못 본 체 하는 황폐한 세상의 모습을 직시합니다. 
주의깊은 관찰 덕분에 은신 감지력과 투명 감지력이 %d 상승합니다. 또한 이제껏 보고 배웠던 것들을 통해, 모습을 볼 수 있는 공포체를 상대로 모든 피해 저항이 %d%%, 가하는 피해량이 %d%% 상승합니다.

#ROYAL_BLUE#가끔 보고 싶지 않았던 숨겨진 진실을 밝혀줍니다.#LAST#
]], "tformat")
t("Abyssal Shot", "심연 사격", "talent name")
t([[Fire a shot into the mindscape to shatter the worldly guise of the target, dealing %d%% damage and revealing its true nature as a horror!
The horror will resume its disguise after %d turns.]], [[대상의 정신세계로 사격하여 %d%% 피해를 가합니다. 이 공격은 대상의 꾸며낸 겉모습을 완전히 파괴하고, 본모습인 공포체의 모습을 드러냅니다!
본모습이 드러난 공포체는 %d 턴 뒤 다시 변장합니다.]], "tformat")
t("Writhing Speed", "뒤틀린 속도", "talent name")
t([[Immediately reload %d times.  For the next %d turns, your ranged attack speed increases by %d%% and your accuracy by %d.

#{italic}#Harmonize with the world of horror all around you, letting the eyestalks guide your shots and the tentacles be your hands.#{normal}#
]], [[즉시 탄환을 %d 발 재장전합니다. 다음 %d 턴 동안 시전자의 원거리 공격 속도가 %d%%, 정확도가 %d 상승합니다.

#{italic}#네가 사는 공포스런 세상과 조화를 이루어라. 눈자루들이 네 탄환을 좇고 촉수들이 네 손이 되게 하라.#{normal}#
]], "tformat")
t("Suborn", "부추김", "talent name")
t("%s must be confused to be controlled!", "%s 조종하려면 혼란 상태여야 한다!", "logSeen", nil, {"를"})
t("%s is already part of your party!", "%s 이미 당신의 편이다!", "logSeen", nil, {"는"})
t("%s is immune to mind control!", "%s 정신 조작에 면역이다!", "logSeen", nil, {"는"})
t("%s resists the mental assault!", "%s 정신 공격에 저항했다!", "logSeen", nil, {"는"})
t([[Take control of a Confused target, bringing it onto your side (#SLATE#checks instakill immunity#LAST#).
Rare and stronger targets will be invulnerable for the duration, and will break free of the effect after %d turns.
Weaker targets can be controlled for %d turns and will die from the strain afterward.

#{italic}#Don't you remember?  #GREEN#We#LAST#'ve already absorbed that one.#{normal}# ]], [[혼란 상태인 대상 하나를 조종하여, 시전자의 편에서 싸우게 합니다 (#SLATE#즉사 저항 판정을 거침#LAST#).
등급이 희귀 이상인 적들은 지속시간 동안 피해를 받지 않으며, %d 턴 뒤 조종에서 풀려나게 됩니다.
그보다 약한 대상들은 %d 턴 동안 조종 가능하며 지속시간이 끝나면 즉사합니다.

#{italic}#기억나지 않나? #GREEN#우리#LAST#는 이미 저것을 흡수했었다.#{normal}# ]], "tformat")

------------------------------------------------
section "tome-classmartyr/data/talents/scourge.lua"

t("Scorn", "멸시", "talent name")
t([[Strike an enemy in melee, and, if you hit, afflict the target with Scorn, which does %d mind damage per turn for %d turns (#SLATE#no save#LAST#).  Scorn is considered a disease (but ignores immunity).  This will also attack with your shield if you have one equipped.
Mindpower: increases damage.

#GREEN#Our Gift:#LAST# The target will be crippled (#SLATE#Mindpower vs. Physical#LAST#) for %d turns.
]], [[적 하나를 근접 공격하고, 명중 시 멸시 효과를 겁니다 (#SLATE#내성 무시#LAST#). 멸시 효과는 %d 턴 동안 매 턴마다 %d 정신 피해를 가하며 질병으로 간주됩니다 (하지만 질병 저항은 무시함). 또한 시전자가 방패를 들고 있다면 방패로도 공격합니다.
정신력: 피해량 증가.

#GREEN#우리의 선물:#LAST# 대상이 %d 턴 동안 무력화됩니다 (#SLATE#정신력 vs. 물리 내성#LAST#).
]], "tformat", {2,1,3})
t("Mental Collapse", "정신 붕괴", "talent name")
t([[The knowledge of their failure compounds over time, increasing the mind damage Scorn deals by %d%% each turn as long as you are within 3 spaces of them.

#GREEN#Our Gift:#LAST# Scorn also gives the victim a %d%% chance to fail to use talents.]], [[희생자의 머릿속에 실패했다는 생각이 점점 쌓이게 됩니다. 시전자가 멸시 효과에 걸린 대상 주변 3 칸 내에 있다면 멸시의 피해량이 매 턴마다 %d%% 씩 상승합니다.

#GREEN#우리의 선물:#LAST# 멸시 효과가 %d%% 확률로 기술 시전에 실패하게 만듭니다.]], "tformat")
t("Challenging Call", "도전의 부름", "talent name")
t([[Demand that your foes return to face you rather than flee!  All diseased enemies in a cone of radius %d are pulled towards you #SLATE#(checks knockback resistance)#LAST#.

#GREEN#Our Gift:#LAST# All targets pulled in are then pinned for 1 turn #SLATE#(no save)#LAST#]], [[적들에게 도망치지 말고 맞서 싸우라고 명령합니다! 반경 %d 칸의 원뿔 범위 내에 있는 질병 효과를 받고 있는 적들을 전부 시전자에게로 끌어당깁니다 #SLATE#(밀어내기 저항 판정)#LAST#.

#GREEN#우리의 선물:#LAST# 끌려온 적들이 1 턴 동안 속박됩니다 #SLATE#(내성 무시)#LAST#.]], "tformat")
t("Triumphant Vitality", "승리의 활력", "talent name")
t([[Whenever your Scorn effect deals damage, you heal for %d%% of the damage done.  

#GREEN#Our Gift:#LAST# The damage dealt by Scorn is increased by 10-50%% based on your current insanity.]], [[시전자가 건 멸시 효과가 피해를 가할 때마다 시전자는 그 피해량의 %d%% 만큼 생명력을 회복합니다.  

#GREEN#우리의 선물:#LAST# 멸시 효과의 피해량이 시전자의 현재 광기량에 비례해 10%% - 50%% 상승합니다.]], "tformat")

------------------------------------------------
section "tome-classmartyr/data/talents/standard-bearer.lua"

t("Tendril Eruption", "촉수 분출", "talent name")
t("You require an empty offhand to use your tentacle hand.", "촉수 팔을 사용하기 위해서는 보조무기 칸을 비워야 한다.", "logPlayer")
t("You require a weapon and an empty offhand!", "주무기와 맨손이 필요하다!", "logPlayer")
t([[You plant your tentacle in the ground where it splits up and extends to a target zone of radius %d.
		The zone will erupt with many black tendrils to hit all foes caught inside dealing %d%% tentacle damage.

		If at least one enemy is hit you gain %d insanity.

		#YELLOW_GREEN#When constricting:#WHITE#The tendrils pummel your constricted target for %d%% tentacle damage and if adjacent you make an additional mainhand weapon attack.  Talent cooldown reduced to 10.]], [[촉수를 바닥에 심습니다. 촉수는 무수히 분열하고 늘어나 반경 %d 칸 내의 적들에게 %d%% 촉수 피해를 가합니다.

		공격이 한 명에게라도 명중하면 광기를 %d 획득합니다.

		#YELLOW_GREEN#촉수 조이기 도중:#WHITE#덩굴손이 조이기의 대상을 연이어 후려쳐 %d%% 피해를 주고, 적이 시전자와 인접한 경우 주무기 공격을 추가로 가합니다. 이 기술의 재사용 대기시간이 10 턴 단축됩니다.]], "tformat")
t("Triumphant Flag", "승리의 깃발", "talent name")
t("glorious flag", "영광스러운 깃발", "_t")
t([[When you kill an enemy, summon a Flag where they died that magically strikes nearby enemies. You also summon a flag when you have done enough damage to a powerful enemy: %d%% of the life of a rare enemy, %d%% of the life of a boss, or %d%% of the life of an elite boss or stronger.  In this case, the flag appears adjacent to them.
Summoning a flag has a cooldown.
The flag's level is your level + %d, its stats increase with your Willpower, and its damage is increased by %d%%.
Flags last until destroyed or until you leave the level, but you can only have 3 placed at a time.
]], [[시전자가 적을 살해하면 적이 죽은 위치에 깃발을 소환합니다. 깃발은 마법으로 근처의 적들을 공격합니다. 또한 시전자가 강한 적에게 충분한 피해를 가했을 때에도 깃발을 소환합니다 (희귀 등급: 최대 생명력의 %d%% / 보스: 최대 생명력의 %d%% / 정예 보스 이상: 최대 생명력의 %d%%). 이렇게 소환된 깃발은 적과 인접한 칸에 나타납니다.
깃발 소환은 재사용 대기시간이 있습니다.
깃발의 레벨은 시전자의 레벨 + %d 이고 깃발의 능력치는 의지 능력치에 비례해 상승하며, 또한 깃발이 가하는 피해량이 %d%% 만큼 상승합니다.
깃발은 파괴되거나 시전자가 구역을 떠나지 않는 이상 유지되지만, 동시에 존재할 수 있는 건 최대 3 개 까지입니다.
]], "tformat")
t("Symbolic Defiance", "상징적인 반항", "talent name")
t([[With incredible boldness, you plant a flag nearby without needing to defeat an enemy!

Levels in this talent grant your flags the ability to slowly pull enemies closer to them and reduce the cooldown between automatic flag placements by %d turns.]], [[엄청난 배짱으로, 적을 쓰러뜨리지 않고 그냥 근처에 깃발을 세웁니다!

이 기술의 레벨이 올라가면 시전자의 깃발들이 적들을 천천히 끌어당길 수 있게 됩니다. 또한 승리의 깃발의 재사용 대기시간이 %d 턴 감소합니다.]], "tformat")
t("Flag Toss", "깃발 던지기", "talent name")
t([[When you place a flag yourself, it can go anywhere within range %d.

Levels in this talent grant your flags the ability to move around of their own volition: travelling in range %d with accuracy %d.
]], [[깃발을 직접 꽂을 수 있는 거리가 %d 칸으로 늘어납니다.

이 기술의 레벨이 올라가면 시전자의 깃발들이 자유 의지를 가지고 움직일 수 있게 됩니다. 반경 %d 칸 내에 오차 %d 칸으로 움직입니다.
]], "tformat")
t("Aura of Confidence", "신뢰의 오라", "talent name")
t([[Whenever you start a turn within range 3 of one of your flags, each of you gains %d%% all resistance for 3 turns.

Levels in this talent grant your flags an area attack doing %d%% of their normal damage.]], [[시전자가 깃발들 주변 3 칸에서 턴을 시작하게 되면, 3 턴 동안 깃발 하나 당 모든 속성 저항을 %d%% 씩 얻습니다.

이 기술의 레벨이 올라가면 깃발들이 본래의 %d%% 피해량으로 범위 공격을 할 수 있게 됩니다.]], "tformat")

------------------------------------------------
section "tome-classmartyr/data/talents/unsettling.lua"

t("Unnerve", "평온 상실", "talent name")
t("%s resists the revelation!", "%s 계시에 저항했다!", "logSeen", nil, {"는"})
t([[Inform an enemy about the true bleak vistas of reality, confusing (#SLATE#Mindpower vs. Mental#LAST#) them for %d turns (%d confusion power).  The range of this talent will increase with the firing range of a ranged weapon in your main set or offset (but is always at least 3).

#ORANGE#Sanity Bonus:#LAST# Take advantage of their moment of realization to throw a sucker punch or other sneak attack, dealing %d%% unarmed damage.
]], [[적 하나에게 진실된 현실의 암울함을 보여 주어, %d 턴 동안 혼란시킵니다 (#SLATE#정신력 vs. 정신 내성#LAST#, 혼란 위력 %d). 이 기술의 사거리는 시전자가 장비하고 있는 원거리 무기의 사거리에 따라 증가합니다 (최소 3 칸).

#ORANGE#제정신 보너스:#LAST# 대상이 진실을 깨닫는 순간을 노려서 기습적으로 주먹을 (또는 다른 기습 공격을) 날려 %d%% 맨손 피해를 가합니다.
]], "tformat")
t("Unhinge", "이성 상실", "talent name")
t([[Your Unnerve effect tears at the victim's mind, dealing %d mind damage per turn.
Mindpower: improves damage

#ORANGE#Sanity Bonus:#LAST# Unnerve also reduces the victim's physical, spell, and mind power by %d.
Mindpower: improves stat reduction]], [[시전자의 불안 효과가 희생양의 정신을 찢어 놓아, 매 턴마다 %d 정신 피해를 가하게 됩니다.
정신력: 피해량 상승

#ORANGE#제정신 보너스:#LAST# 불안 효과가 희생자의 물리력/주문력/정신력도 %d 감소시킵니다.
정신력: 감소량 상승]], "tformat")
t("Unveil", "베일 상실", "talent name")
t([[The truth weighs heavily on the mind.  Each turn, unnerved targets have a %d%% chance that their cooling down talents will increase in cooldown.

#ORANGE#Sanity Bonus:#LAST# Whenever an Unnerved character acts, you may gain a small amount of insanity (based on how Confused they are).
]], [[진실이 머릿속에서 떠나지 않게 됩니다. 불안 효과를 받는 대상들은 매 턴 %d%% 확률로 재사용 대기 중인 기술들의 대기시간이 증가합니다.

#ORANGE#제정신 보너스:#LAST# 불안한 대상들이 행동할 때마다 시전자는 광기를 조금 얻습니다 (대상들의 혼란 위력에 비례).
]], "tformat")
t("Uninhibited", "제약 상실", "talent name")
t([[Your Unnerve ability can penetrate confusion immunity, with %d%% reduced effectiveness. 

#ORANGE#Sanity Bonus:#LAST# Your Unnerve affects a %d radius ball rather than a single target.]], [[시전자의 평온 상실이 혼란 저항을 무시할 수 있게 됩니다. 그 대신, 해당 기술의 효과가 %d%% 감소합니다.

#ORANGE#제정신 보너스:#LAST# 시전자의 평온 상실이 대상 지점으로부터 반경 %d 칸 내에 효과를 주게 됩니다.]], "tformat")

------------------------------------------------
section "tome-classmartyr/data/talents/vagabond.lua"

t("Sling Practice", "투석구 사용 경험", "talent name")
t([[You can't really call it 'mastery', but you've used a sling before, along with a variety of other weapons.
This increases Physical Power by %d and weapon damage by %d%% when using a sling and increases your reload rate by %d.
It also allows you to equip weapons and armor using the higher of your strength and dexterity.

Whenever you hit with a ranged weapon, you will gain #INSANE_GREEN#5 insanity.#LAST#

#YELLOW#Every level in this talent allows you to learn a Chivalry talent for free.#LAST#]], [[사실 이런 걸로 '숙련됐다'고 할 수는 없겠지만, 당신은 투석구와 그 외 갖가지 무기들을 사용해본 적이 있습니다.
투석구를 사용할 때 물리력이 %d, 무기 피해가 %d%% 상승하며 탄환 장전량도 %d 상승합니다.
또한 무기와 방어구를 장비할 때 힘이나 민첩 중 더 높은 것을 사용하게 됩니다.

원거리 무기로 하는 공격이 명중할 때마다 #INSANE_GREEN#광기를 5#LAST# 얻습니다.

#YELLOW#이 기술에 점수를 투자할 때마다 기사도 계열의 기술을 점수 소모 없이 익힐 수 있습니다.#LAST#]], "tformat")
t("Stagger Shot", "묵직한 사격", "talent name")
t([[You ready a sling shot with all your strength.
This shot does %d%% weapon damage, gives you an extra #INSANE_GREEN#5 insanity#LAST#, and knocks back your target %d spaces (#SLATE#checks knockback resistance#LAST#), even when things might seem to be in the way.

Learning this talent allows martyr talents to instantly and automatically swap to your alternate weapon set when needed.

#{italic}#Keep your distance!  It's...for your own good.#{normal}#

#YELLOW#Every level in this talent allows you to learn a Chivalry talent for free.#LAST#]], [[온 힘을 담아 사격을 합니다.
이 사격은 %d%% 무기 피해를 가하고 시전자는 #INSANE_GREEN#5 광기#LAST#를 추가로 얻으며, 대상을 %d 칸 밀어냅니다 (#SLATE#밀어내기 저항 판정#LAST#). 이때 경로 상에 장애물이 있더라도 밀어냅니다.

이 기술을 익히면 특정한 무기가 필요한 기술을 사용할 때, 턴 소모 없이 자동으로 보조 장비로 전환할 수 있게 됩니다.

#{italic}#가까이 오지 마! 다 너...를 위해서라고.#{normal}#

#YELLOW#이 기술에 점수를 투자할 때마다 기사도 계열의 기술을 점수 소모 없이 익힐 수 있습니다.#LAST#]], "tformat")
t("Tainted Bullets", "오염된 탄환", "talent name")
t([[You make unusual modifications to your sling bullets, causing them to inflict a 10%% movement speed slow (#SLATE#no save#LAST#) that stacks up to 10 times and deals %0.2f mind damage per stack. This counts as a disease (but ignores immunity).  If the target breaks free from the slow, they'll be immune to it for the next five turns. 
Mindpower: increases damage.

All your shots, including bullets from Shoot and other talents, now travel around friendly targets without causing them harm (regardless of whether this talent is sustained).

#YELLOW#Every level in this talent allows you to learn a Chivalry talent for free.#LAST#]], [[투석구 탄환을 범상치 않은 방법으로 개조하여, 탄환이 10%% 이동 속도 감속 효과 (#SLATE#내성 무시#LAST#) 를 걸게 합니다. 이 효과는 최대 10 번 중첩되며 중첩 당 %0.2f 정신 피해를 가합니다. 또한 이 효과는 질병으로 간주됩니다 (하지만 질병 저항은 무시함). 감속 효과에서 벗어난 대상은 다음 5 턴 동안 해당 효과에 면역이 됩니다. 
정신력: 피해량 증가.

지속 효과로써, 시전자의 모든 사격은 (일반 사격 기술 말고도 다른 기술들도) 우호적인 대상을 피해 없이 관통하게 됩니다.

#YELLOW#이 기술에 점수를 투자할 때마다 기사도 계열의 기술을 점수 소모 없이 익힐 수 있습니다.#LAST#]], "tformat")
t("Hollow Shell", "빈 껍데기", "talent name")
t([[Your body's vital organs are indistinct or perhaps missing.
Direct critical hits againts you deal %d%% less extra damage.

#{italic}#Nothing's ever going to hurt me worse than #GREEN#we#LAST# already have.#{normal}#

#YELLOW#Every level in this talent allows you to learn a Chivalry talent for free.#LAST#]], [[신체의 중요한 장기들이 형태가 불분명합니다. 어쩌면 아예 사라졌을지도요.
시전자가 받는 치명타 피해량이 %d%% 감소합니다.

#{italic}#내가 얼마나 다치든 간에 #GREEN#우리#LAST#가 이미 당했던 거에 비하면 별 거 아니지.#{normal}#

#YELLOW#이 기술에 점수를 투자할 때마다 기사도 계열의 기술을 점수 소모 없이 익힐 수 있습니다.#LAST#]], "tformat")

------------------------------------------------
section "tome-classmartyr/data/talents/whispers.lua"

t("Slipping Psyche", "위태로운 정신", "talent name")
t([[Gain melee damage as you gain insanity, up to %d (currently %d).
Reduce incoming damage by a flat amount as you approach sanity, up to %d per hit (currently %d).
Both values will improve with your level.

You benefit from #ORANGE#Sanity Bonus#LAST# while you have up to 40 Insanity.
You benefit from #GREEN#Our Gift#LAST# while you have at least 60 Insanity.

#{italic}#As long as I don't start thinking like #GREEN#us#LAST#, I'll be safe.#{normal}#
]], [[시전자의 광기가 높을수록 근접 피해량을 얻습니다 (최대 %d, 현재 %d).
시전자가 제정신을 차릴수록 고정 피해 감소량을 얻습니다 (최대 %d, 현재 %d).
각 수치는 시전자의 레벨에 비례해 증가합니다.

시전자의 광기가 40 이하라면 #ORANGE#제정신 보너스#LAST# 효과를 받습니다.
시전자의 광기가 60 이상이라면 #GREEN#우리의 선물#LAST# 효과를 받습니다.

#{italic}#내가 #GREEN#우리#LAST#처럼 생각하지만 않으면, 난 안전할 거야.#{normal}#
]], "tformat")
t("Guiding Light", "인도하는 빛", "talent name")
t("#YELLOW#A guiding light appears!#LAST#", "#YELLOW#인도하는 빛이 나타난다!#LAST#", "logSeen")
t([[While in combat, zones of guiding light will appear nearby, lasting %d turns.
Entering a green light will cause you to regenerate for %d health per turn for 5 turns.
Entering a blue light will refresh you, reducing the duration of outstanding cooldowns by %d turns.
Entering a orange light will grant you terrible strength, giving you +%d%% to all damage for 3 turns.]], [[전투 상황일 때, 인도하는 빛 영역이 근처에 생성되어 %d 턴 동안 유지됩니다.
초록색 빛에 들어가면 시전자의 생명력 재생이 5 턴 동안 %d 상승합니다.
파란색 빛에 들어가면 시전자의 활력이 회복되어, 기술들의 재사용 대기시간이 %d 턴 단축됩니다.
주황색 빛에 들어가면 소름끼치는 힘을 선사받습니다. 시전자가 가하는 피해량이 3 턴 동안 %d%% 상승합니다.]], "tformat")
t("Warning Lights", "경고의 빛", "talent name")
t([[Entering any light will imbue you with a destructive aura, dealing %d - %d mind damage to enemies within range 2 each turn for %d turns.  The damage will increase with your current insanity.
Mindpower: increases damage.

#{italic}#The light whispers secrets to bring about the destruction of your enemies.#{normal}#]], [[인도하는 빛이 시전자에게 파괴적인 오라를 덧씌웁니다. 시전자가 아무 빛 영역에 들어가게 되면 반경 2 칸 내의 적들에게 %d 턴 동안 %d - %d 정신 피해를 매 턴 가합니다. 피해량은 시전자의 현재 광기량에 비례합니다.
정신력: 피해량 증가.

#{italic}#빛이 네 적들에게 파멸을 안겨주는 비법을 속삭인다.#{normal}#]], "tformat", {3,1,2})
t("Jolt Awake", "이건 꿈이야", "talent name")
t("%s(%d to the dream)#LAST#", "%s(%d 는 꿈이다)#LAST#", "tformat")
t("#YELLOW#%s awakens from a terrible dream!#LAST#", "#YELLOW#%s 끔찍한 꿈에서 깨어났다!#LAST#", "logSeen", nil, {"는"})
t("#GREEN#You die in the dream!", "#GREEN#당신은 꿈속에서 죽었다!", "say")
t("If you suffer damage that would kill you, you instead awake from a dream of dying, setting your insanity to zero and becoming immune to damage for the rest of the turn.", "시전자가 죽음에 이르는 피해를 받게 되면 시전자는 자신이 죽는 꿈에서 즉시 깨어나고, 광기량이 0이 되면서 해당 턴에 받는 나머지 피해를 전부 무시합니다.", "tformat")

------------------------------------------------
section "tome-classmartyr/init.lua"


-- untranslated text
--[==[
t("Class: Martyr", "Class: Martyr", "init.lua long_name")
t("A new demented class.", "새로운 광인 직업.", "init.lua description")
--]==]


------------------------------------------------
section "tome-classmartyr/superload/data/talents/techniques/archery.lua"

t("You do not have enough ammo left!", "남은 탄환이 없다!", "logPlayer")

------------------------------------------------
section "tome-classmartyr/superload/mod/class/Actor.lua"


-- untranslated text
--[==[
t("#ORANGE#DEBUG: overcharging: %d on %d!#LAST#", "#ORANGE#DEBUG: overcharging: %d on %d!#LAST#", "logSeen")
--]==]


