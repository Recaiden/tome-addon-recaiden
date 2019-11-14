local print = print
if not config.settings.cheat then print = function() end end

local useImplicitCrit = DamageType.useImplicitCrit
local initState = DamageType.initState

local baseProjector = engine.DamageType.defaultProjector

defaultProjectorShrug = function(src, x, y, type, dam, state)
   if not game.level.map:isBound(x, y) then return 0 end

   ----------------------------------------------------------------------------
   -- New hook which appears at the very beginning of the projector, before targeting and crits
   local hd = {"DamageProjector:prebase", src=src, x=x, y=y, type=type, dam=dam, state=state}
   if src:triggerHook(hd) then
      dam = hd.dam
      if hd.stopped then
         return hd.stopped
      end
   end
   ----------------------------------------------------------------------------
   
   -- Manage crits.
   state = initState(state)
   useImplicitCrit(src, state)
   local crit_type = state.crit_type
   local crit_power = state.crit_power
   
   local add_dam = 0
   if src:attr("all_damage_convert") and src:attr("all_damage_convert_percent") and src.all_damage_convert ~= type then
      local ndam = dam * src.all_damage_convert_percent / 100
      dam = dam - ndam
      local nt = src.all_damage_convert
      src.all_damage_convert = nil
      add_dam = DamageType:get(nt).projector(src, x, y, nt, ndam, state)
      src.all_damage_convert = nt
      if dam <= 0 then return add_dam end
   end

   if src:attr("elemental_mastery") then
      local ndam = dam * src.elemental_mastery
      local old = src.elemental_mastery
      src.elemental_mastery = nil
      dam = 0
      dam = dam + DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, ndam, state)
      dam = dam + DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, ndam, state)
      dam = dam + DamageType:get(DamageType.LIGHTNING).projector(src, x, y, DamageType.LIGHTNING, ndam, state)
      dam = dam + DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, ndam, state)
      src.elemental_mastery = old
      return dam
   end

   if src:attr("twilight_mastery") then
      local ndam = dam * src.twilight_mastery
      local old = src.twilight_mastery
      src.twilight_mastery = nil
      dam = 0
      dam = dam + DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, ndam, state)
      dam = dam + DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, ndam, state)
      src.twilight_mastery = old
      return dam
   end
   local source_talent = src.__projecting_for and src.__projecting_for.project_type and (src.__projecting_for.project_type.talent_id or src.__projecting_for.project_type.talent) and src.getTalentFromId and src:getTalentFromId(src.__projecting_for.project_type.talent or src.__projecting_for.project_type.talent_id)
   local terrain = game.level.map(x, y, Map.TERRAIN)
   if terrain then terrain:check("damage_project", src, x, y, type, dam, source_talent) end

   local target = game.level.map(x, y, Map.ACTOR)
   if target then
      local rsrc = src.resolveSource and src:resolveSource() or src
      local rtarget = target.resolveSource and target:resolveSource() or target

      print("[PROJECTOR] starting dam", type, dam)
      --------------------------------------------------------------------------
      -- repurposing 'ignore_direct_crits' attribute to reduce rather than cancel crit power
      if crit_power > 1 then
         local ignore_direct_crits = target:attr 'ignore_direct_crits'
         local adj_crit_power = crit_power
         
         -- Add crit bonus power for being unseen (direct damage only, diminished with range)
         local unseen_crit = src.__is_actor and target.__is_actor and not src.__project_source and src.unseen_critical_power
         if unseen_crit and not target:canSee(src) and src:canSee(target) then
            local d, reduc = core.fov.distance(src.x, src.y, x, y), 0
            if d > 3 then
               reduc = math.scale(d, 3, 10, 0, 1)
               unseen_crit = math.max(0, unseen_crit*(1 - reduc))
            end
            if unseen_crit > 0 then
               if target.unseen_crit_defense and target.unseen_crit_defense > 0 then
                  unseen_crit = math.max(0, unseen_crit*(1 - target.unseen_crit_defense))
               end
               adj_crit_power = adj_crit_power + unseen_crit
               print("[PROJECTOR] unseen_critical_power, range, unseen_crit_defense", unseen_crit, d, target.unseen_crit_defense, "=>", adj_crit_power)
            end
         end
         if ignore_direct_crits then
            adj_crit_power = math.max(1, adj_crit_power - ignore_direct_crits/100)
            print("[PROJECTOR] ignore_direct_crits", ignore_direct_crits, "=>", adj_crit_power)
            if adj_crit_power <= 1 then game.logSeen(target, "%s shrugs off the critical damage!", target.name:capitalize()) end
         end
         dam = dam * adj_crit_power/crit_power
         print("[PROJECTOR] after crit power adjustments dam", dam, crit_power, "=>", adj_crit_power)
      end
      --------------------------------------------------------------------------
      
      local hd = {"DamageProjector:base", src=src, x=x, y=y, type=type, dam=dam, state=state}
      if src:triggerHook(hd) then dam = hd.dam if hd.stopped then return hd.stopped end end

         -- Difficulty settings
         if game.difficulty == game.DIFFICULTY_EASY and rtarget.player then
            dam = dam * 0.7
         end
         print("[PROJECTOR] after difficulty dam", dam)

         if src.__global_accuracy_damage_bonus then
            dam = dam * src.__global_accuracy_damage_bonus
            print("[PROJECTOR] after staff accuracy damage bonus", dam)
         end

         -- Daze
         if src:attr("dazed") then
            dam = dam * 0.5
         end

         if src:attr("stunned") then
            dam = dam * 0.5
            print("[PROJECTOR] stunned dam", dam)
         end
         if src:attr("invisible_damage_penalty") then
            dam = dam * util.bound(1 - (src.invisible_damage_penalty / (src.invisible_damage_penalty_divisor or 1)), 0, 1)
            print("[PROJECTOR] invisible dam", dam)
         end
         if src:attr("numbed") then
            dam = dam - dam * src:attr("numbed") / 100
            print("[PROJECTOR] numbed dam", dam)
         end
         if src:attr("generic_damage_penalty") then
            dam = dam - dam * math.min(100, src:attr("generic_damage_penalty")) / 100
            print("[PROJECTOR] generic dam", dam)
         end

         -- Preemptive shielding
         if target.isTalentActive and target:isTalentActive(target.T_PREMONITION) then
            local t = target:getTalentFromId(target.T_PREMONITION)
            t.on_damage(target, t, type)
         end

         local lastdam = dam
         -- Item-granted damage ward talent
         if target:hasEffect(target.EFF_WARD) then
            local e = target.tempeffect_def[target.EFF_WARD]
            dam = e.absorb(type, dam, target.tmp[target.EFF_WARD], target, src)
            if dam ~= lastdam then
               game:delayedLogDamage(src, target, 0, ("%s(%d warded)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", lastdam-dam), false)
            end
         end

         -- Increases damage
         local mind_linked = false
         local inc = 0
         if src.inc_damage then
            if src.combatGetDamageIncrease then inc = src:combatGetDamageIncrease(type)
            else inc = (src.inc_damage.all or 0) + (src.inc_damage[type] or 0) end
            if src.getVim and src:attr("demonblood_dam") then inc = inc + ((src.demonblood_dam or 0) * (src:getVim() or 0)) end
            if inc ~= 0 then print("[PROJECTOR] after DamageType increase dam", dam + (dam * inc / 100)) end
         end

         -- Increases damage for the entity type (Demon, Undead, etc)
         if target.type and src and src.inc_damage_actor_type then
            local increase = 0
            for k, v in pairs(src.inc_damage_actor_type) do
               if target:checkClassification(tostring(k)) then increase = math.max(increase, v) end
            end
            if increase and increase~= 0 then
               print("[PROJECTOR] before inc_damage_actor_type", dam + (dam * inc / 100))
               inc = inc + increase
               print("[PROJECTOR] after inc_damage_actor_type", dam + (dam * inc / 100))
            end
         end

         -- Increases damage to sleeping targets
         if target:attr("sleep") and src.attr and src:attr("night_terror") then
            inc = inc + src:attr("night_terror")
            print("[PROJECTOR] after night_terror", dam + (dam * inc / 100))
         end
         -- Increases damage to targets with Insomnia
         if src.attr and src:attr("lucid_dreamer") and target:hasEffect(target.EFF_INSOMNIA) then
            inc = inc + src:attr("lucid_dreamer")
            print("[PROJECTOR] after lucid_dreamer", dam + (dam * inc / 100))
         end
         -- Mind Link
         if type == DamageType.MIND and target:hasEffect(target.EFF_MIND_LINK_TARGET) then
            local eff = target:hasEffect(target.EFF_MIND_LINK_TARGET)
            if eff.src == src or eff.src == src.summoner then
               mind_linked = true
               inc = inc + eff.power
               print("[PROJECTOR] after mind_link", dam + (dam * inc / 100))
            end
         end

         -- Rigor mortis
         if src.necrotic_minion and target:attr("inc_necrotic_minions") then
            inc = inc + target:attr("inc_necrotic_minions")
            print("[PROJECTOR] after necrotic increase dam", dam + (dam * inc) / 100)
         end

         -- dark vision increases damage done in creeping dark
         if src and src ~= target and game.level.map:checkAllEntities(x, y, "creepingDark") then
            local dark = game.level.map:checkAllEntities(x, y, "creepingDark")
            if dark.summoner == src and dark.damageIncrease > 0 and not dark.projecting then
               local source = src.__project_source or src
               inc = inc + dark.damageIncrease
               game:delayedLogMessage(source, target, "dark_strike"..(source.uid or ""), "#Source# strikes #Target# in the darkness (%+d%%%%%%%% damage).", dark.damageIncrease) -- resolve %% 3 levels deep
            end
         end

         if dam > 0 and src and src.__is_actor and src:knowTalent(src.T_BACKSTAB) then
            local power = src:callTalent("T_BACKSTAB", "getDamageBoost")
            local nb = 0
            for eff_id, p in pairs(target.tmp) do
               local e = target.tempeffect_def[eff_id]
               if (e.subtype.stun or e.subtype.blind or e.subtype.pin or e.subtype.disarm or e.subtype.cripple or e.subtype.confusion or e.subtype.silence)then nb = nb + 1 end
            end
            if nb > 0 then
               local boost = math.min(power*nb, power*3)
               inc = inc + boost
               print("[PROJECTOR] after backstab", dam + (dam * inc / 100))
            end
         end

         dam = dam + (dam * inc / 100)

         -- Blast the iceblock
         if src.attr and src:attr("encased_in_ice") then
            local eff = src:hasEffect(src.EFF_FROZEN)
            eff.hp = eff.hp - dam
            local srcname = src.x and src.y and game.level.map.seens(src.x, src.y) and src.name:capitalize() or "Something"
            if eff.hp < 0 and not eff.begone then
               game.logSeen(src, "%s forces the iceblock to shatter.", src.name:capitalize())
               game:onTickEnd(function() src:removeEffect(src.EFF_FROZEN) end)
               eff.begone = game.turn
            else
               game:delayedLogDamage(src, eff.ice, dam, ("%s%d %s#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", math.ceil(dam), DamageType:get(type).name))
               if eff.begone and eff.begone < game.turn and eff.hp < 0 then
                  game.logSeen(src, "%s forces the iceblock to shatter.", src.name:capitalize())
                  src:removeEffect(src.EFF_FROZEN)
               end
            end
            return 0 + add_dam
         end


         local hd = {"DamageProjector:beforeResists", src=src, x=x, y=y, type=type, dam=dam, state=state}
         if src:triggerHook(hd) then dam = hd.dam if hd.stopped then return hd.stopped end end
            if target.iterCallbacks then
               for cb in target:iterCallbacks("callbackOnTakeDamageBeforeResists") do
                  local ret = cb(src, x, y, type, dam, state)
                  if ret then
                     if ret.dam then dam = ret.dam end
                     if ret.stopped then return ret.stopped end
                  end
               end
            end

            --target.T_STONE_FORTRESS could be checked/applied here (ReduceDamage function in Dwarven Fortress talent)

            -- affinity healing, we store it to apply it after damage is resolved
            local affinity_heal = 0
            if target.damage_affinity then
               affinity_heal = math.max(0, dam * target:combatGetAffinity(type) / 100)
            end

            -- reduce by resistance to entity type (Demon, Undead, etc)
            -- Summoned, Unnatural, Unliving still go into this table, we just parse them differently in checkClassification
            if target.resists_actor_type and src and src.type then
               local res = 0

               for k, v in pairs(target.resists_actor_type) do
                  if src:checkClassification(tostring(k)) then res = math.max(res, v) end
               end

               res = math.min(res, target.resists_cap_actor_type or 90)

               if res ~= 0 then
                  print("[PROJECTOR] before entity", src.type, "resists dam", dam)
                  if res >= 100 then dam = 0
                  elseif res <= -100 then dam = dam * 2
                  else dam = dam * ((100 - res) / 100)
                  end
                  print("[PROJECTOR] after entity", src.type, "resists dam", dam)
               end
            end

            -- Reduce damage with resistance
            if target.resists then
               local pen = 0
               if src.combatGetResistPen then 
                  pen = src:combatGetResistPen(type)
                  if type == DamageType.ARCANE and src.knowTalent and src:knowTalent(src.T_AURA_OF_SILENCE) then pen = pen + src:combatGetResistPen(DamageType.NATURE) end
               elseif src.resists_pen then pen = (src.resists_pen.all or 0) + (src.resists_pen[type] or 0)
               end
               local dominated = target:hasEffect(target.EFF_DOMINATED)
               if dominated and dominated.src == src then pen = pen + (dominated.resistPenetration or 0) end
               if target:attr("sleep") and src.attr and src:attr("night_terror") then pen = pen + src:attr("night_terror") end
               local res = target:combatGetResist(type)
               pen = util.bound(pen, 0, 100)
               if res > 0 then	res = res * (100 - pen) / 100 end
               print("[PROJECTOR] res", res, (100 - res) / 100, " on dam", dam)
               if res >= 100 then dam = 0
               elseif res <= -100 then dam = dam * 2
               else dam = dam * ((100 - res) / 100)
               end
            end
            print("[PROJECTOR] after resists dam", dam)

            -- Reduce damage with resistance against self
            if src == target and target.resists_self then
               local res = (target.resists_self[type] or 0) + (target.resists_self.all or 0)
               print("[PROJECTOR] res", res, (100 - res) / 100, " on dam", dam)
               if res >= 100 then dam = 0
               elseif res <= -100 then dam = dam * 2
               else dam = dam * ((100 - res) / 100)
               end
               print("[PROJECTOR] after self-resists dam", dam)
            end

            local initial_dam = dam
            lastdam = dam
            -- Static reduce damage for psionic kinetic shield
            if target.isTalentActive and target:isTalentActive(target.T_KINETIC_SHIELD) then
               local t = target:getTalentFromId(target.T_KINETIC_SHIELD)
               dam = t.ks_on_damage(target, t, type, dam)
            end
            -- Static reduce damage for psionic thermal shield
            if target.isTalentActive and target:isTalentActive(target.T_THERMAL_SHIELD) then
               local t = target:getTalentFromId(target.T_THERMAL_SHIELD)
               dam = t.ts_on_damage(target, t, type, dam)
            end
            -- Static reduce damage for psionic charged shield
            if target.isTalentActive and target:isTalentActive(target.T_CHARGED_SHIELD) then
               local t = target:getTalentFromId(target.T_CHARGED_SHIELD)
               dam = t.cs_on_damage(target, t, type, dam)
            end
            if dam ~= lastdam then
               game:delayedLogDamage(src, target, 0, ("%s(%d to psi shield)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", lastdam-dam), false)
            end

            -- Block talent from shields
            if dam > 0 and target:attr("block") then
               local e = target.tempeffect_def[target.EFF_BLOCKING]
               lastdam = dam
               dam = e.do_block(type, dam, target.tmp[target.EFF_BLOCKING], target, src)
               if lastdam - dam > 0 then game:delayedLogDamage(src, target, 0, ("%s(%d blocked)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", lastdam-dam), false) end
            end
            if dam > 0 and target.isTalentActive and target:isTalentActive(target.T_FORGE_SHIELD) then
               local t = target:getTalentFromId(target.T_FORGE_SHIELD)
               lastdam = dam
               dam = t.doForgeShield(type, dam, t, target, src)
               if lastdam - dam > 0 then game:delayedLogDamage(src, target, 0, ("%s(%d blocked)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", lastdam-dam), false) end
            end

            --Vim based defence
            if target:attr("demonblood_def") and target.getVim then
               local demon_block = math.min(dam*0.5,target.demonblood_def*(target:getVim() or 0))
               dam= dam - demon_block
               target:incVim((-demon_block)/20)
            end

            -- Static reduce damage
            if dam > 0 and target.isTalentActive and target:isTalentActive(target.T_ANTIMAGIC_SHIELD) then
               local t = target:getTalentFromId(target.T_ANTIMAGIC_SHIELD)
               lastdam = dam
               dam = t.on_damage(target, t, type, dam, src)
               if lastdam - dam  > 0 then game:delayedLogDamage(src, target, 0, ("%s(%d antimagic)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", lastdam - dam), false) end
            end

            -- Flat damage reduction ("armour")
            if dam > 0 and target.flat_damage_armor then
               local dec = math.min(dam, target:combatGetFlatResist(type))
               if dec > 0 then game:delayedLogDamage(src, target, 0, ("%s(%d resist armour)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", dec), false) end
               dam = math.max(0, dam - dec)
               print("[PROJECTOR] after flat damage armor", dam)
            end

            -- roll with it damage reduction
            if type == DamageType.PHYSICAL and target:knowTalent(target.T_ROLL_WITH_IT) and not target:attr("never_move") then
               dam = dam * target:callTalent(target.T_ROLL_WITH_IT, "getMult")
               print("[PROJECTOR] after Roll With It dam", dam)
            end

            if target:attr("resist_unseen") and not target:canSee(src) then
               dam = dam * (1 - math.min(target.resist_unseen,100)/100)
            end

            -- Sanctuary: reduces damage if it comes from outside of Gloom
            if target.isTalentActive and target:isTalentActive(target.T_GLOOM) and target:knowTalent(target.T_SANCTUARY) then
               if state and state.sanctuaryDamageChange then
                  -- projectile was targeted outside of gloom
                  dam = dam * (100 + state.sanctuaryDamageChange) / 100
                  print("[PROJECTOR] Sanctuary (projectile) dam", dam)
               elseif src and src.x and src.y then
                  -- assume instantaneous projection and check range to source
                  local t = target:getTalentFromId(target.T_GLOOM)
                  if core.fov.distance(target.x, target.y, src.x, src.y) > target:getTalentRange(t) then
                     t = target:getTalentFromId(target.T_SANCTUARY)
                     dam = dam * (100 + t.getDamageChange(target, t)) / 100
                     print("[PROJECTOR] Sanctuary (source) dam", dam)
                  end
               end
            end

            -- Psychic Projection
            if src.attr and src:attr("is_psychic_projection") and not game.zone.is_dream_scape then
               if (target.subtype and target.subtype == "ghost") or mind_linked then
                  dam = dam
               else
                  dam = 0
               end
            end

            --Dark Empathy (Reduce damage against summoner)
            if src.necrotic_minion_be_nice and src.summoner == target then
               dam = dam * (1 - src.necrotic_minion_be_nice)
            end

            --Dark Empathy (Reduce damage against other minions)
            if src.necrotic_minion_be_nice and target.summoner and src.summoner == target.summoner then
               dam = dam * (1 - src.necrotic_minion_be_nice)
            end

            -- Curse of Misfortune: Unfortunate End (chance to increase damage enough to kill)
            if src and src.hasEffect and src:hasEffect(src.EFF_CURSE_OF_MISFORTUNE) then
               local eff = src:hasEffect(src.EFF_CURSE_OF_MISFORTUNE)
               local def = src.tempeffect_def[src.EFF_CURSE_OF_MISFORTUNE]
               dam = def.doUnfortunateEnd(src, eff, target, dam)
            end

            if src:attr("crushing_blow") and (dam * (1.25 + (src.combat_critical_power or 0)/200)) > target.life then
               dam = dam * (1.25 + (src.combat_critical_power or 0)/200)
               game.logPlayer(src, "You end your target with a crushing blow!")
            end

            -- Flat damage cap
            if target.flat_damage_cap then
               local cap = nil
               if target.flat_damage_cap.all then cap = target.flat_damage_cap.all end
               if target.flat_damage_cap[type] then cap = target.flat_damage_cap[type] end
               if cap and cap > 0 then
                  local ignored = math.max(0, dam - cap * target.max_life / 100)
                  if ignored > 0 then game:delayedLogDamage(src, target, 0, ("#LIGHT_GREY#(%d resilience)#LAST#"):format(ignored), false) end
                  dam = dam - ignored
                  print("[PROJECTOR] after flat damage cap", dam)
               end
            end

            print("[PROJECTOR] final dam after static checks", dam)

            local hd = {"DamageProjector:final", src=src, x=x, y=y, type=type, dam=dam, state=state}
            if src:triggerHook(hd) then dam = hd.dam if hd.stopped then return hd.stopped end end
               if target.iterCallbacks then
                  for cb in target:iterCallbacks("callbackOnTakeDamage") do
                     local ret = cb(src, x, y, type, dam, state)
                     if ret then
                        if ret.dam then dam = ret.dam end
                        if ret.stopped then return ret.stopped end
                     end
                  end
               end

               if target.resists and target.resists.absolute then -- absolute resistance (from Terrasca)
                  dam = dam * ((100 - math.min(target.resists_cap.absolute or 70, target.resists.absolute)) / 100)
                  print("[PROJECTOR] after absolute resistance dam", dam)
               end

               print("[PROJECTOR] final dam after hooks and callbacks", dam)

               local dead
               dead, dam = target:takeHit(dam, src, {damtype=type, source_talent=source_talent, initial_dam=initial_dam})

               -- Log damage for later
               if not DamageType:get(type).hideMessage then
                  local visible, srcSeen, tgtSeen = game:logVisible(src, target)
                  if visible then -- don't log damage that the player doesn't know about
                     if crit_power > 1 then
                        game:delayedLogDamage(src, target, dam, ("#{bold}#%s%d %s#{normal}##LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", dam, DamageType:get(type).name), true)
                     else
                        game:delayedLogDamage(src, target, dam, ("%s%d %s#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", dam, DamageType:get(type).name), false)
                     end
                  end
               end

               if dam > 0 and src.attr and src:attr("martyrdom") and not state.no_reflect then
                  game:delayedLogMessage(src, target, "martyrdom", "#CRIMSON##Source# damages %s through Martyrdom!", string.his_her_self(src))
                  state.no_reflect = true
                  DamageType.defaultProjector(target, src.x, src.y, type, dam * src.martyrdom / 100, state)
                  state.no_reflect = nil
               end
               if target.attr and target:attr("reflect_damage") and not state.no_reflect and src.x and src.y then
                  game:delayedLogMessage(target, src, "reflect_damage"..(src.uid or ""), "#CRIMSON##Source# reflects damage back to #Target#!")
                  state.no_reflect = true
                  DamageType.defaultProjector(target, src.x, src.y, type, dam * target.reflect_damage / 100, state)
                  state.no_reflect = nil
               end
               -- Braided damage
               if dam > 0 and target:hasEffect(target.EFF_BRAIDED) then
                  game:onTickEnd(function()target:callEffect(target.EFF_BRAIDED, "doBraid", dam)end)
               end

               if target.knowTalent and target:knowTalent(target.T_RESOLVE) and target:reactionToward(src) <= 0 then local t = target:getTalentFromId(target.T_RESOLVE) t.on_absorb(target, t, type, dam) end

               if target ~= src and target.attr and target:attr("damage_resonance") and not target:hasEffect(target.EFF_RESONANCE) then
                  target:setEffect(target.EFF_RESONANCE, 5, {damtype=type, dam=target:attr("damage_resonance")})
               end

               if not target.dead and dam > 0 and type == DamageType.MIND and src and src.knowTalent and src:knowTalent(src.T_MADNESS) then
                  local t = src:getTalentFromId(src.T_MADNESS)
                  t.doMadness(target, t, src)
               end

               -- Curse of Nightmares: Nightmare
               if not target.dead and dam > 0 and src and target.hasEffect and target:hasEffect(src.EFF_CURSE_OF_NIGHTMARES) then
                  local eff = target:hasEffect(target.EFF_CURSE_OF_NIGHTMARES)
                  eff.isHit = true -- handle at the end of the turn
               end

               if not target.dead and dam > 0 and target:attr("elemental_harmony") and not target:hasEffect(target.EFF_ELEMENTAL_HARMONY) and target ~= src then
                  if type == DamageType.FIRE or type == DamageType.COLD or type == DamageType.LIGHTNING or type == DamageType.ACID or type == DamageType.NATURE then
                     target:setEffect(target.EFF_ELEMENTAL_HARMONY, target:callTalent(target.T_ELEMENTAL_HARMONY, "duration"), {power=target:attr("elemental_harmony"), type=type, no_ct_effect=true})
                  end
               end

               -- damage affinity healing
               if not target.dead and affinity_heal > 0 then
                  target:heal(affinity_heal, src)
                  game:delayedLogMessage(target, nil, "Affinity"..type, "#Source##LIGHT_GREEN# HEALS#LAST# from "..(DamageType:get(type).text_color or "#aaaaaa#")..DamageType:get(type).name.."#LAST# damage!")
               end

               if dam > 0 and src.damage_log and src.damage_log.weapon then
                  src.damage_log[type] = (src.damage_log[type] or 0) + dam
                  if src.turn_procs and src.turn_procs.weapon_type then
                     src.damage_log.weapon[src.turn_procs.weapon_type.kind] = (src.damage_log.weapon[src.turn_procs.weapon_type.kind] or 0) + dam
                     src.damage_log.weapon[src.turn_procs.weapon_type.mode] = (src.damage_log.weapon[src.turn_procs.weapon_type.mode] or 0) + dam
                  end
               end

               if dam > 0 and target.damage_intake_log and target.damage_intake_log.weapon then
                  target.damage_intake_log[type] = (target.damage_intake_log[type] or 0) + dam
                  if src.turn_procs and src.turn_procs.weapon_type then
                     target.damage_intake_log.weapon[src.turn_procs.weapon_type.kind] = (target.damage_intake_log.weapon[src.turn_procs.weapon_type.kind] or 0) + dam
                     target.damage_intake_log.weapon[src.turn_procs.weapon_type.mode] = (target.damage_intake_log.weapon[src.turn_procs.weapon_type.mode] or 0) + dam
                  end
               end

               if dam > 0 and source_talent then
                  local t = source_talent

                  local spellshock = src:attr("spellshock_on_damage")
                  if spellshock and t.is_spell and target:checkHit(src:combatSpellpower(1, spellshock), target:combatSpellResist(), 0, 95, 15) and not target:hasEffect(target.EFF_SPELLSHOCKED) then
                     target:crossTierEffect(target.EFF_SPELLSHOCKED, src:combatSpellpower(1, spellshock))
                  end

                  if src.__projecting_for then
                     -- Disable friendly fire for procs since players can't control when they happen or where they hit
                     local old_ff = src.nullify_all_friendlyfire
                     src.nullify_all_friendlyfire = true
                     if src.talent_on_spell and next(src.talent_on_spell) and t.is_spell and not src.turn_procs.spell_talent then
                        for id, d in pairs(src.talent_on_spell) do
                           if rng.percent(d.chance) and t.id ~= d.talent then
                              src.turn_procs.spell_talent = true
                              local old = src.__projecting_for
                              src:forceUseTalent(d.talent, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=d.level, ignore_ressources=true})
                              src.__projecting_for = old
                           end
                        end
                     end

                     if src.talent_on_wild_gift and next(src.talent_on_wild_gift) and t.is_nature and not src.turn_procs.wild_gift_talent then
                        for id, d in pairs(src.talent_on_wild_gift) do
                           if rng.percent(d.chance) and t.id ~= d.talent then
                              src.turn_procs.wild_gift_talent = true
                              local old = src.__projecting_for
                              src:forceUseTalent(d.talent, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=d.level, ignore_ressources=true})
                              src.__projecting_for = old
                           end
                        end
                     end

                     if src.talent_on_mind and next(src.talent_on_mind) and t.is_mind and not src.turn_procs.mind_talent then
                        for id, d in pairs(src.talent_on_mind) do
                           if rng.percent(d.chance) and t.id ~= d.talent then
                              src.turn_procs.mind_talent = true
                              local old = src.__projecting_for
                              src:forceUseTalent(d.talent, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=d.level, ignore_ressources=true})
                              src.__projecting_for = old
                           end
                        end
                     end
                     src.nullify_all_friendlyfire = old_ff

                     if not target.dead and (t.is_spell or t.is_mind) and not src.turn_procs.meteoric_crash and src.knowTalent and src:knowTalent(src.T_METEORIC_CRASH) then
                        src.turn_procs.meteoric_crash = true
                        src:triggerTalent(src.T_METEORIC_CRASH, nil, target)
                     end

                     if not target.dead and t.is_spell and target.knowTalent then
                        if target:knowTalent(target.T_SPELL_FEEDBACK) then
                           target:triggerTalent(target.T_SPELL_FEEDBACK, nil, src, t)
                        end
                        if target:knowTalent(target.T_NATURE_S_DEFIANCE) then
                           target:triggerTalent(target.T_NATURE_S_DEFIANCE, nil, src, t)
                        end
                     end
                     if t.is_spell and src.knowTalent and src:knowTalent(src.T_BORN_INTO_MAGIC) then
                        src:triggerTalent(target.T_BORN_INTO_MAGIC, nil, type)
                     end

                     if not target.dead and src.isTalentActive and src:isTalentActive(src.T_UNSTOPPABLE_NATURE) and t.is_nature and not src.turn_procs.unstoppable_nature then
                        src:callTalent(src.T_UNSTOPPABLE_NATURE, "freespit", target)
                        src.turn_procs.unstoppable_nature = true
                     end
                  end
               end

               if src.turn_procs and not src.turn_procs.dazing_damage and src.hasEffect and src:hasEffect(src.EFF_DAZING_DAMAGE) then
                  if target:canBe("stun") then
                     local power = math.max(src:combatSpellpower(), src:combatMindpower(), src:combatPhysicalpower())
                     target:setEffect(target.EFF_DAZED, 2, {})
                  end
                  src:removeEffect(src.EFF_DAZING_DAMAGE)
                  src.turn_procs.dazing_damage = true
               end

               if src.turn_procs and not src.turn_procs.blighted_soil and src:attr("blighted_soil") and rng.percent(src:attr("blighted_soil")) then
                  local tid = rng.table{src.EFF_ROTTING_DISEASE, src.EFF_DECREPITUDE_DISEASE, src.EFF_DECREPITUDE_DISEASE}
                  if not target:hasEffect(tid) then
                     local l = game.zone:level_adjust_level(game.level, game.zone, "object")
                     local p = math.ceil(4 + l / 2)
                     target:setEffect(tid, 8, {str=p, con=p, dex=p, dam=5 + l / 2, src=src})
                     src.turn_procs.blighted_soil = true
                  end
               end

               --curse of madness effect spread on crit
               if state.crit_power > 1 and src.hasEffect and src:hasEffect(src.EFF_CURSE_OF_MADNESS) then
                  local eff = src:hasEffect(src.EFF_CURSE_OF_MADNESS)
                  local def = src.tempeffect_def[src.EFF_CURSE_OF_MADNESS]
                  def.doConspirator(src, eff, target)
               end


               return dam + add_dam
   end
   return 0 + add_dam
end

setDefaultProjector(defaultProjectorShrug)

for i, p in pairs(engine.DamageType.dam_def) do
   if p.projector == baseProjector then
      p.projector = engine.DamageType.defaultProjector
   end
end

