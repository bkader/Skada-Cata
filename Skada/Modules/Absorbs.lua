local Skada = Skada

-- cache frequently used globals
local pairs, format, pformat = pairs, string.format, Skada.pformat
local _

-- ============== --
-- Absorbs module --
-- ============== --

Skada:RegisterModule("Absorbs", function(L, P, _, _, new, del)
	local mod = Skada:NewModule("Absorbs")
	local playermod = mod:NewModule("Absorb spell list")
	local targetmod = mod:NewModule("Absorbed target list")
	local spellmod = targetmod:NewModule("Absorb spell list")
	local spellschools = Skada.spellschools
	local ignoredSpells = Skada.dummyTable -- Edit Skada\Core\Tables.lua
	local passiveSpells = Skada.dummyTable -- Edit Skada\Core\Tables.lua

	local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER or 0x00000100
	local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_AFFILIATION_OUTSIDER or 0x00000008
	local COMBATLOG_OBJECT_REACTION_MASK = COMBATLOG_OBJECT_REACTION_MASK or 0x000000F0

	local GetTime, band, tsort, max = GetTime, bit.band, table.sort, math.max
	local UnitGUID, UnitName = UnitGUID, UnitName
	local UnitBuff, UnitIsDeadOrGhost = UnitBuff, UnitIsDeadOrGhost
	local GroupIterator = Skada.GroupIterator
	local T = Skada.Table

	local absorbspells = {
		[48707] = 5, -- Anti-Magic Shell
		[51052] = 10, -- Anti-Magic Zone
		[108008] = 86400, -- Will of the Necropolis
		[77535] = 10, -- Blood Shield
		[62606] = 10, -- Savage Defense Proc
		[11426] = 60, -- Ice Barrier
		[1463] = 60, --  Mana shield
		[543] = 30, -- Mage Ward
		[86273] = 6, -- Illuminated Healing
		[88063] = 6, -- Guarded by the Light
		[96263] = 15, -- Sacred Shield
		[31850] = 10, -- Ardent Defender
		[105801] = 10, -- Delayed Judgment
		[31230] = 10, -- Cheat Death
		[17] = 30, -- Power Word: Shield
		[47509] = 15, -- Divine Aegis (rank 1)
		[47511] = 15, -- Divine Aegis (rank 2)
		[47515] = 15, -- Divine Aegis (rank 3)
		[47753] = 15, -- Divine Aegis (rank 1)
		[54704] = 15, -- Divine Aegis (rank 1)
		[47788] = 10, -- Guardian Spirit
		[62618] = 25, -- Power Word: Barrier
		[81781] = 25, -- Power Word: Barrier
		[7812] = 30, -- Sacrifice
		[6229] = 30, -- Shadow Ward
		[25228] = 86400, -- Soul Link
		[29674] = 86400, -- Lesser Ward of Shielding
		[29719] = 86400, -- Greater Ward of Shielding
		[29701] = 86400, -- Greater Shielding
		[28538] = 120, -- Major Holy Protection Potion
		[28537] = 120, -- Major Shadow Protection Potion
		[28536] = 120, --  Major Arcane Protection Potion
		[28513] = 120, -- Major Nature Protection Potion
		[28512] = 120, -- Major Frost Protection Potion
		[28511] = 120, -- Major Fire Protection Potion
		[7233] = 120, -- Fire Protection Potion
		[7239] = 120, -- Frost Protection Potion
		[7242] = 120, -- Shadow Protection Potion
		[7245] = 120, -- Holy Protection Potion
		[6052] = 120, -- Nature Protection Potion
		[53915] = 120, -- Mighty Shadow Protection Potion
		[53914] = 120, -- Mighty Nature Protection Potion
		[53913] = 120, -- Mighty Frost Protection Potion
		[53911] = 120, -- Mighty Fire Protection Potion
		[53910] = 120, -- Mighty Arcane Protection Potion
		[17548] = 120, -- Greater Shadow Protection Potion
		[17546] = 120, -- Greater Nature Protection Potion
		[17545] = 120, -- Greater Holy Protection Potion
		[17544] = 120, -- Greater Frost Protection Potion
		[17543] = 120, -- Greater Fire Protection Potion
		[17549] = 120, -- Greater Arcane Protection Potion
		[28527] = 15, -- Fel Blossom
		[29432] = 3600, -- Frozen Rune
		[36481] = 4, -- Arcane Barrier (TK Kael'Thas) Shield
		[57350] = 6, -- Darkmoon Card: Illusion
		[70845] = 10, -- Stoicism
		[17252] = 30, -- Mark of the Dragon Lord (LBRS epic ring)
		[25750] = 15, -- Defiler's Talisman/Talisman of Arathor
		[25747] = 15, -- Defiler's Talisman/Talisman of Arathor
		[25746] = 15, -- Defiler's Talisman/Talisman of Arathor
		[23991] = 15, -- Defiler's Talisman/Talisman of Arathor
		[30997] = 300, -- Pendant of Frozen Flame Usage
		[31002] = 300, -- Pendant of the Null Rune
		[30999] = 300, -- Pendant of Withering
		[30994] = 300, -- Pendant of Thawing
		[31000] = 300, -- Pendant of Shadow's End
		[23506]= 20, -- Arena Grand Master
		[12561] = 60, -- Goblin Construction Helmet
		[31771] = 20, -- Runed Fungalcap
		[21956] = 10, -- Mark of Resolution
		[29506] = 20, -- The Burrower's Shell
		[4057] = 60, -- Flame Deflector
		[4077] = 60, -- Ice Deflector
		[39228] = 20, -- Argussian Compass (may not be an actual absorb)
		[27779] = 30, -- Divine Protection (Priest dungeon set 1/2)
		[11657] = 20, -- Jang'thraze (Zul Farrak)
		[10368] = 15, -- Uther's Light Effect
		[37515] = 15, -- Blade Turning
		[42137] = 86400, -- Greater Rune of Warding
		[26467] = 30, -- Scarab Brooch
		[27539] = 6, -- Thick Obsidian Breatplate
		[28810] = 30, -- Faith Set Proc Armor of Faith
		[54808] = 12, -- Noise Machine Proc Sonic Shield
		[55019] = 12, -- Sonic Shield
		[64413] = 8, -- Val'anyr, Hammer of Ancient Kings proc Protection of Ancient Kings
		[105909] = 6, -- Shield of Fury
		[105801] = 6, -- Delayed Judgement
		[40322] = 30, -- Teron's Vengeful Spirit Ghost - Spirit Shield
		[65874] = 15, -- Twin Val'kyr's: Shield of Darkness
		[67257] = 15, -- Twin Val'kyr's: Shield of Darkness (300000)
		[67256] = 15, -- Twin Val'kyr's: Shield of Darkness (700000)
		[67258] = 15, -- Twin Val'kyr's: Shield of Darkness (1200000)
		[65858] = 15, -- Twin Val'kyr's Shield of Lights (175000)
		[67260] = 15, -- Twin Val'kyr's: Shield of Lights (300000)
		[67259] = 15, -- Twin Val'kyr's: Shield of Lights (700000)
		[67261] = 15, -- Twin Val'kyr's: Shield of Lights (1200000)
		[65686] = 86400, -- Twin Val'kyr: Light Essence
		[65684] = 86400, -- Twin Val'kyr: Dark Essence
	}

	local shields = nil -- holds the list of players shields and other stuff
	local absorb = {}

	local function format_valuetext(d, columns, total, aps, metadata, subview)
		d.valuetext = Skada:FormatValueCols(
			columns.Absorbs and Skada:FormatNumber(d.value),
			columns[subview and "sAPS" or "APS"] and aps and Skada:FormatNumber(aps),
			columns[subview and "sPercent" or "Percent"] and Skada:FormatPercent(d.value, total)
		)

		if metadata and d.value > metadata.maxvalue then
			metadata.maxvalue = d.value
		end
	end

	local function log_spellcast(set, playerid, playername, playerflags, spellid, spellschool)
		if not set or (set == Skada.total and not P.totalidc) then return end

		local player = Skada:FindPlayer(set, playerid, playername, playerflags)
		if player and player.absorbspells and player.absorbspells[spellid] then
			player.absorbspells[spellid].casts = (player.absorbspells[spellid].casts or 1) + 1

			-- fix possible missing spell school.
			if not player.absorbspells[spellid].school and spellschool then
				player.absorbspells[spellid].school = spellschool
			end
		end
	end

	local function log_absorb(set, nocount)
		if not absorb.spellid or not absorb.amount or absorb.amount == 0 then return end

		local player = Skada:GetPlayer(set, absorb.playerid, absorb.playername)
		if not player then return end

		if player.role ~= "DAMAGER" and not nocount then
			Skada:AddActiveTime(set, player, not passiveSpells[absorb.spellid], nil, absorb.dstName)
		end

		-- add absorbs amount
		player.absorb = (player.absorb or 0) + absorb.amount
		set.absorb = (set.absorb or 0) + absorb.amount

		-- saving this to total set may become a memory hog deluxe.
		if set == Skada.total and not P.totalidc then return end

		-- record the spell
		local spell = player.absorbspells and player.absorbspells[absorb.spellid]
		if not spell then
			player.absorbspells = player.absorbspells or {}
			spell = {school = absorb.school, amount = absorb.amount, count = 1}
			player.absorbspells[absorb.spellid] = spell
		else
			if not spell.school and absorb.school then
				spell.school = absorb.school
			end
			spell.amount = (spell.amount or 0) + absorb.amount
			if not nocount then
				spell.count = (spell.count or 0) + 1
			end
		end

		-- start cast counter.
		spell.casts = spell.casts or 1

		if not spell.min or absorb.amount < spell.min then
			spell.min = absorb.amount
		end
		if not spell.max or absorb.amount > spell.max then
			spell.max = absorb.amount
		end

		-- record the target
		if absorb.dstName then
			spell.targets = spell.targets or {}
			spell.targets[absorb.dstName] = (spell.targets[absorb.dstName] or 0) + absorb.amount
		end
	end

	-- https://github.com/TrinityCore/TrinityCore/blob/5d82995951c2be99b99b7b78fa12505952e86af7/src/server/game/Spells/Auras/SpellAuraEffects.h#L316
	local function shields_order_pred(a, b)
		local a_spellid, b_spellid = a.spellid, b.spellid

		if a_spellid == b_spellid then
			return (a.ts < b.ts)
		end

		-- Twin Val'ky
		if a_spellid == 65686 then
			return true
		end
		if b_spellid == 65686 then
			return false
		end
		if a_spellid == 65684 then
			return true
		end
		if b_spellid == 65684 then
			return false
		end

		-- Mage Ward
		if a_spellid == 543 then
			return true
		end
		if b_spellid == 543 then
			return false
		end

		-- Shadow Ward
		if a_spellid == 6229 then
			return true
		end
		if b_spellid == 6229 then
			return false
		end

		-- Sacred Shield | TODO: needs review (96263)
		if a_spellid == 58597 then
			return true
		end
		if b_spellid == 58597 then
			return false
		end

		-- Fel Blossom
		if a_spellid == 28527 then
			return true
		end
		if b_spellid == 28527 then
			return false
		end

		-- Divine Aegis
		if a_spellid == 47753 then
			return true
		end
		if b_spellid == 47753 then
			return false
		end

		-- Ice Barrier
		if a_spellid == 11426 then
			return true
		end
		if b_spellid == 11426 then
			return false
		end

		-- Sacrifice
		if a_spellid == 7812 then
			return true
		end
		if b_spellid == 7812 then
			return false
		end

		-- Delayed Judgement | TODO: needs review
		if a_spellid == 105801 then
			return true
		end
		if b_spellid == 105801 then
			return false
		end

		return (a.ts < b.ts)
	end

	local function ValidateShield(srcFlags, dstFlags)
		local valid = nil

		if srcFlags and dstFlags then
			-- make sure both parts are valid.
			valid = band(srcFlags, dstFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0

			-- make sure both are in the group
			valid = valid and (band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0)
			valid = valid and (band(dstFlags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0)

			-- make sure both are friendly to each other
			valid = valid and (band(srcFlags, dstFlags, COMBATLOG_OBJECT_REACTION_MASK) ~= 0)
		end

		return valid
	end

	local function RemoveShield(dstName, srcGUID, spellid)
		shields[dstName] = shields[dstName] or new()
		for i = 1, #shields[dstName] do
			local shield = shields[dstName][i]
			if shield and shield.srcGUID == srcGUID and shield.spellid == spellid then
				del(tremove(shields[dstName], i))
				tsort(shields[dstName], shields_order_pred)
				break
			end
		end
	end

	local function handle_shield(timestamp, eventtype, srcGUID, srcName, srcFlags, _, dstName, _, spellid, _, spellschool)
		if not spellid or not absorbspells[spellid] or not dstName or ignoredSpells[spellid] then return end

		shields = shields or T.get("Skada_Shields") -- create table if missing

		-- shield removed
		if eventtype == "SPELL_AURA_REMOVED" then
			if shields[dstName] then
				for i = 1, #shields[dstName] do
					local shield = shields[dstName][i]
					if shield and shield.srcGUID == srcGUID and shield.spellid == spellid then
						Skada:ScheduleTimer(RemoveShield, 0.1, dstName, srcGUID, spellid)
						break
					end
				end
			end
			return
		end

		-- create player's shields table
		shields[dstName] = shields[dstName] or new()

		-- Soul Link
		if spellid == 25228 then
			srcGUID, srcName = Skada:FixMyPets(srcGUID, srcName, srcFlags)
		end

		-- shield refreshed
		if eventtype == "SPELL_AURA_REFRESH" then
			local index = nil
			for i = 1, #shields[dstName] do
				local shield = shields[dstName][i]
				if shield and shield.srcGUID == srcGUID and shield.spellid == spellid then
					shield.ts = timestamp
					index = i

					-- fix school
					if not shield.school and spellschool then
						shield.school = spellschool
					end

					break
				end
			end

			-- not found? add it
			if not index then
				local shield = new()
				shield.spellid = spellid
				shield.school = spellschool
				shield.srcGUID = srcGUID
				shield.srcName = srcName
				shield.srcFlags = srcFlags
				shield.ts = timestamp

				tinsert(shields[dstName], shield)
			else
				shields[dstName][index].ts = timestamp
			end

			tsort(shields[dstName], shields_order_pred)
		else
			local shield = new()
			shield.spellid = spellid
			shield.school = spellschool
			shield.srcGUID = srcGUID
			shield.srcName = srcName
			shield.srcFlags = srcFlags
			shield.ts = timestamp

			tinsert(shields[dstName], shield)
			tsort(shields[dstName], shields_order_pred)
		end
	end

	local function process_shield(dstName, spellschool)
		shields[dstName] = shields[dstName] or new()

		for i = 1, #shields[dstName] do
			local s = shields[dstName][i]
			if s and s.spellid == 543 then -- Mage Ward (Mage)
				if band(spellschool, 0x10) == spellschool or band(spellschool, 0x04) == spellschool or band(spellschool, 0x40) == spellschool then
					return s
				end
			elseif s and s.spellid == 6229 then -- Shadow Ward (Warlock)
				if band(spellschool, 0x20) == spellschool then
					return s
				end
			elseif s then
				return s
			end
		end
	end

	local function process_absorb(dstGUID, dstName, dstFlags, absorbed, spellschool, damage)
		shields[dstName] = shields[dstName] or new()

		local shield = process_shield(dstName, spellschool, absorbed + damage)
		if shield then
			absorb.playerid = shield.srcGUID
			absorb.playername = shield.srcName
			absorb.playerflags = shield.srcFlags

			absorb.dstGUID = dstGUID
			absorb.dstName = dstName
			absorb.dstFlags = dstFlags

			absorb.spellid = shield.spellid
			absorb.school = shield.school
			absorb.amount = absorbed

			Skada:DispatchSets(log_absorb)
		end
	end

	local function spell_damage(timestamp, eventtype, _, _, _, dstGUID, dstName, dstFlags, ...)
		local spellschool, amount, absorbed

		if eventtype == "SWING_DAMAGE" then
			amount, _, _, _, _, absorbed = ...
		elseif eventtype == "ENVIRONMENTAL_DAMAGE" then
			_, amount, _, spellschool, _, _, absorbed = ...
		else
			_, _, spellschool, amount, _, _, _, _, absorbed = ...
		end

		if absorbed and absorbed > 0 and dstName and shields and shields[dstName] then
			process_absorb(dstGUID, dstName, dstFlags, absorbed, spellschool or 0x01, amount)
		end
	end

	local function spell_missed(timestamp, eventtype, _, _, _, dstGUID, dstName, dstFlags, ...)
		local spellschool, misstype, absorbed

		if eventtype == "SWING_MISSED" then
			misstype, _, absorbed = ...
		else
			_, _, spellschool, misstype, _, absorbed = ...
		end

		if misstype == "ABSORB" and absorbed and absorbed > 0 and dstName and shields and shields[dstName] then
			process_absorb(dstGUID, dstName, dstFlags, absorbed, spellschool or 0x01, 0)
		end
	end

	local function absorb_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		local actor = set and set:GetActor(label, id)
		if not actor then return end

		local totaltime = set:GetTime()
		local activetime = actor:GetTime(true)
		local aps, damage = actor:GetAPS()

		tooltip:AddDoubleLine(L["Activity"], Skada:FormatPercent(activetime, totaltime), nil, nil, nil, 1, 1, 1)
		tooltip:AddDoubleLine(L["Segment Time"], Skada:FormatTime(totaltime), 1, 1, 1)
		tooltip:AddDoubleLine(L["Active Time"], Skada:FormatTime(activetime), 1, 1, 1)
		tooltip:AddDoubleLine(L["Absorbs"], Skada:FormatNumber(damage), 1, 1, 1)

		local suffix = Skada:FormatTime(P.timemesure == 1 and activetime or totaltime)
		tooltip:AddDoubleLine(Skada:FormatNumber(damage) .. "/" .. suffix, Skada:FormatNumber(aps), 1, 1, 1)
	end

	local function playermod_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local spell = actor and actor.absorbspells and actor.absorbspells[id]
		if not spell then return end

		tooltip:AddLine(actor.name .. " - " .. label)
		if spell.school and spellschools[spell.school] then
			tooltip:AddLine(spellschools(spell.school))
		end

		if spell.casts and spell.casts > 0 then
			tooltip:AddDoubleLine(L["Casts"], spell.casts, 1, 1, 1)
		end

		local average = nil
		if spell.count and spell.count > 0 then
			tooltip:AddDoubleLine(L["Hits"], spell.count, 1, 1, 1)
			average = spell.amount / spell.count
		end

		local separator = nil

		if spell.min then
			tooltip:AddLine(" ")
			separator = true
			tooltip:AddDoubleLine(L["Minimum"], Skada:FormatNumber(spell.min), 1, 1, 1)
		end

		if spell.max then
			if not separator then
				tooltip:AddLine(" ")
				separator = true
			end
			tooltip:AddDoubleLine(L["Maximum"], Skada:FormatNumber(spell.max), 1, 1, 1)
		end

		if average then
			if not separator then
				tooltip:AddLine(" ")
				separator = true
			end

			tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(average), 1, 1, 1)
		end
	end

	function spellmod:Enter(win, id, label)
		win.targetid, win.targetname = id, label
		win.title = L["actor absorb spells"](win.actorname or L["Unknown"], label)
	end

	function spellmod:Update(win, set)
		win.title = L["actor absorb spells"](win.actorname or L["Unknown"], win.targetname or L["Unknown"])
		if not set or not win.targetname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local total = actor and actor.absorb or 0

		if total == 0 or not actor.absorbspells then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = mod.metadata.columns
		local actortime = cols.sAPS and actor:GetTime()

		for spellid, spell in pairs(actor.absorbspells) do
			if spell.targets and spell.targets[win.targetname] then
				nr = nr + 1

				local d = win:spell(nr, spellid, spell)
				d.value = spell.targets[win.targetname]
				format_valuetext(d, cols, total, actortime and (d.value / actortime), win.metadata, true)
			end
		end
	end

	function playermod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = L["actor absorb spells"](label)
	end

	function playermod:Update(win, set)
		win.title = L["actor absorb spells"](win.actorname or L["Unknown"])
		if not set or not win.actorname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local total = actor and actor.absorb or 0

		if total == 0 or not actor.absorbspells then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = mod.metadata.columns
		local actortime = cols.sAPS and actor:GetTime()

		for spellid, spell in pairs(actor.absorbspells) do
			nr = nr + 1

			local d = win:spell(nr, spellid, spell)
			d.value = spell.amount
			format_valuetext(d, cols, total, actortime and (d.value / actortime), win.metadata, true)
		end
	end

	function targetmod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = pformat(L["%s's absorbed targets"], label)
	end

	function targetmod:Update(win, set)
		win.title = pformat(L["%s's absorbed targets"], win.actorname)
		if not set or not win.actorname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local total = actor and actor.absorb or 0
		local targets = (total > 0) and actor:GetAbsorbTargets()

		if not targets then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = mod.metadata.columns
		local actortime = cols.sAPS and actor:GetTime()

		for targetname, target in pairs(targets) do
			nr = nr + 1

			local d = win:actor(nr, target, nil, targetname)
			d.value = target.amount
			format_valuetext(d, cols, total, actortime and (d.value / actortime), win.metadata, true)
		end
	end

	function mod:Update(win, set)
		win.title = win.class and format("%s (%s)", L["Absorbs"], L[win.class]) or L["Absorbs"]

		local total = set and set:GetAbsorb(win.class)
		if not total or total == 0 then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = self.metadata.columns
		local is_arena = (Skada.forPVP and set.type == "arena")

		local actors = set.players -- players
		for i = 1, #actors do
			local actor = actors[i]
			if actor and (not win.class or win.class == actor.class) then
				local aps, amount = actor:GetAPS(nil, not cols.APS)
				if amount > 0 then
					nr = nr + 1

					local d = win:actor(nr, actor)
					d.color = is_arena and Skada.classcolors(set.gold and "ARENA_GOLD" or "ARENA_GREEN") or nil
					d.value = amount
					format_valuetext(d, cols, total, aps, win.metadata)
				end
			end
		end

		actors = is_arena and set.enemies or nil -- arena enemies
		if not actors then return end

		for i = 1, #actors do
			local actor = actors[i]
			if actor and not actor.fake and (not win.class or win.class == actor.class) then
				local aps, amount = actor:GetAPS(nil, not cols.APS)
				if amount > 0 then
					nr = nr + 1

					local d = win:actor(nr, actor, true)
					d.color = Skada.classcolors(set.gold and "ARENA_GREEN" or "ARENA_GOLD")
					d.value = amount
					format_valuetext(d, cols, total, aps, win.metadata)
				end
			end
		end
	end

	function mod:GetSetSummary(set, win)
		local aps, amount = set:GetAPS(win and win.class)
		local valuetext = Skada:FormatValueCols(
			self.metadata.columns.Absorbs and Skada:FormatNumber(amount),
			self.metadata.columns.APS and Skada:FormatNumber(aps)
		)
		return valuetext, amount
	end

	do
		local function check_unit_shields(unit, owner, timestamp, curtime)
			if not UnitIsDeadOrGhost(unit) then
				local dstName, dstGUID = UnitName(unit), UnitGUID(unit)
				for i = 1, 40 do
					local _, _, _, _, _, _, expires, unitCaster, _, _, spellid = UnitBuff(unit, i)
					if not spellid then
						break -- nothing found
					elseif absorbspells[spellid] and unitCaster then
						handle_shield(timestamp + max(0, expires - curtime), nil, UnitGUID(unitCaster), UnitName(unitCaster), nil, dstGUID, dstName, nil, spellid)
					end
				end
			end
		end

		function mod:CombatEnter(_, set, timestamp)
			if set and not set.stopped and not self.checked then
				GroupIterator(check_unit_shields, timestamp, set.last_time or GetTime())
				self.checked = true
			end
		end

		function mod:CombatLeave()
			T.clear(absorb)
			T.free("Skada_Shields", shields, nil, del)
			self.checked = nil
		end
	end

	function mod:OnEnable()
		playermod.metadata = {tooltip = playermod_tooltip}
		targetmod.metadata = {showspots = true, click1 = spellmod}
		self.metadata = {
			showspots = true,
			post_tooltip = absorb_tooltip,
			click1 = playermod,
			click2 = targetmod,
			click4 = Skada.FilterClass,
			click4_label = L["Toggle Class Filter"],
			columns = {Absorbs = true, APS = true, Percent = true, sAPS = false, sPercent = true},
			icon = [[Interface\Icons\spell_holy_devineaegis]]
		}

		-- no total click.
		playermod.nototal = true
		targetmod.nototal = true

		local flags_src = {src_is_interesting = true}

		Skada:RegisterForCL(
			handle_shield,
			"SPELL_AURA_APPLIED",
			"SPELL_AURA_REFRESH",
			"SPELL_AURA_REMOVED",
			flags_src
		)

		local flags_dst = {dst_is_interesting_nopets = true}

		Skada:RegisterForCL(
			spell_damage,
			"DAMAGE_SHIELD",
			"SPELL_DAMAGE",
			"SPELL_PERIODIC_DAMAGE",
			"SPELL_BUILDING_DAMAGE",
			"RANGE_DAMAGE",
			"SWING_DAMAGE",
			"ENVIRONMENTAL_DAMAGE",
			flags_dst
		)

		Skada:RegisterForCL(
			spell_missed,
			"SPELL_MISSED",
			"SPELL_PERIODIC_MISSED",
			"SPELL_BUILDING_MISSED",
			"RANGE_MISSED",
			"SWING_MISSED",
			flags_dst
		)

		Skada.RegisterMessage(self, "COMBAT_PLAYER_ENTER", "CombatEnter")
		Skada.RegisterMessage(self, "COMBAT_PLAYER_LEAVE", "CombatLeave")
		Skada:AddMode(self, L["Absorbs and Healing"])

		-- table of ignored spells:
		if Skada.ignoredSpells then
			if Skada.ignoredSpells.absorbs then
				ignoredSpells = Skada.ignoredSpells.absorbs
			end
			if Skada.ignoredSpells.activeTime then
				passiveSpells = Skada.ignoredSpells.activeTime
			end
		end
	end

	function mod:OnDisable()
		Skada.UnregisterAllMessages(self)
		Skada:RemoveMode(self)
	end

	function mod:SetComplete(set)
		-- clean absorbspells table:
		if not set.absorb or set.absorb == 0 then return end
		for i = 1, #set.players do
			local p = set.players[i]
			if p and (p.absorb == 0 or (not p.absorb and p.absorbspells)) then
				p.absorb, p.absorbspells = nil, del(p.absorbspells, true)
			end
		end
	end
end)

-- ========================== --
-- Absorbs and healing module --
-- ========================== --

Skada:RegisterModule("Absorbs and Healing", function(L, P)
	local mod = Skada:NewModule("Absorbs and Healing")
	local playermod = mod:NewModule("Absorbs and healing spells")
	local targetmod = mod:NewModule("Absorbed and healed targets")
	local spellmod = targetmod:NewModule("Absorbs and healing spells")
	local spellschools = Skada.spellschools

	local function format_valuetext(d, columns, total, hps, metadata, subview)
		d.valuetext = Skada:FormatValueCols(
			columns.Healing and Skada:FormatNumber(d.value),
			columns[subview and "sHPS" or "HPS"] and hps and Skada:FormatNumber(hps),
			columns[subview and "sPercent" or "Percent"] and Skada:FormatPercent(d.value, total)
		)

		if metadata and d.value > metadata.maxvalue then
			metadata.maxvalue = d.value
		end
	end

	local function hps_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set then return end

		local actor = set:GetActor(label, id)
		if not actor then return end

		local totaltime = set:GetTime()
		local activetime = actor:GetTime(true)
		local hps, amount = actor:GetAHPS()

		tooltip:AddDoubleLine(L["Activity"], Skada:FormatPercent(activetime, totaltime), nil, nil, nil, 1, 1, 1)
		tooltip:AddDoubleLine(L["Segment Time"], Skada:FormatTime(set:GetTime()), 1, 1, 1)
		tooltip:AddDoubleLine(L["Active Time"], Skada:FormatTime(activetime), 1, 1, 1)
		tooltip:AddDoubleLine(L["Absorbs and Healing"], Skada:FormatNumber(amount), 1, 1, 1)

		local suffix = Skada:FormatTime(P.timemesure == 1 and activetime or totaltime)
		tooltip:AddDoubleLine(Skada:FormatNumber(amount) .. "/" .. suffix, Skada:FormatNumber(hps), 1, 1, 1)
	end

	local function playermod_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set or not win.actorname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if not actor then return end

		local spell = actor.absorbspells and actor.absorbspells[id] -- absorb?
		spell = spell or actor.healspells and actor.healspells[id] -- heal?
		if not spell then return end

		tooltip:AddLine(actor.name .. " - " .. label)
		if spell.school and spellschools[spell.school] then
			tooltip:AddLine(spellschools(spell.school))
		end

		if enemy then
			tooltip:AddDoubleLine(L["Amount"], spell.amount, 1, 1, 1)
			return
		end

		if spell.casts then
			tooltip:AddDoubleLine(L["Casts"], spell.casts, 1, 1, 1)
		end

		local average = nil
		if spell.count and spell.count > 0 then
			tooltip:AddDoubleLine(L["Hits"], spell.count, 1, 1, 1)
			average = spell.amount / spell.count

			if spell.c_num and spell.c_num > 0 then
				tooltip:AddDoubleLine(L["Critical"], Skada:FormatPercent(spell.c_num, spell.count), 0.67, 1, 0.67)
			end
		end

		if spell.o_amt and spell.o_amt > 0 then
			tooltip:AddDoubleLine(L["Total Healing"], Skada:FormatNumber(spell.o_amt + spell.amount), 1, 1, 1)
			tooltip:AddDoubleLine(L["Overheal"], format("%s (%s)", Skada:FormatNumber(spell.o_amt), Skada:FormatPercent(spell.o_amt, spell.o_amt + spell.amount)), 1, 0.67, 0.67)
		end

		local separator = nil

		if spell.min then
			tooltip:AddLine(" ")
			separator = true

			local spellmin = spell.min
			if spell.c_min and spell.c_min < spellmin then
				spellmin = spell.c_min
			end
			tooltip:AddDoubleLine(L["Minimum"], Skada:FormatNumber(spellmin), 1, 1, 1)
		end

		if spell.max then
			if not separator then
				tooltip:AddLine(" ")
				separator = true
			end

			local spellmax = spell.max
			if spell.c_max and spell.c_max > spellmax then
				spellmax = spell.c_max
			end
			tooltip:AddDoubleLine(L["Maximum"], Skada:FormatNumber(spellmax), 1, 1, 1)
		end

		if average then
			if not separator then
				tooltip:AddLine(" ")
				separator = true
			end

			tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(average), 1, 1, 1)
		end
	end

	function spellmod:Enter(win, id, label)
		win.targetid, win.targetname = id, label
		win.title = L["actor absorb and heal spells"](win.actorname or L["Unknown"], label)
	end

	function spellmod:Update(win, set)
		win.title = L["actor absorb and heal spells"](win.actorname or L["Unknown"], win.targetname or L["Unknown"])
		if not set or not win.targetname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		local total = actor and actor:GetAbsorbHealOnTarget(win.targetname)

		if not total or total == 0 or not (actor.healspells or actor.absorbspells) then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = mod.metadata.columns
		local actortime = cols.sHPS and actor:GetTime()

		local spells = actor.healspells -- heal spells
		if spells then
			for spellid, spell in pairs(spells) do
				if spell.targets and spell.targets[win.targetname] then
					nr = nr + 1

					local d = win:spell(nr, spellid, spell, nil, true)
					d.value = enemy and spell.targets[win.targetname] or spell.targets[win.targetname].amount or 0
					format_valuetext(d, mod.metadata.columns, total, actortime and (d.value / actortime), win.metadata, true)
				end
			end
		end

		spells = actor.absorbspells -- absorb spells
		if not spells then return end

		for spellid, spell in pairs(spells) do
			if spell.targets and spell.targets[win.targetname] then
				nr = nr + 1

				local d = win:spell(nr, spellid, spell)
				d.value = spell.targets[win.targetname] or 0
				format_valuetext(d, mod.metadata.columns, total, actortime and (d.value / actortime), win.metadata, true)
			end
		end
	end

	function playermod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = L["actor absorb and heal spells"](label)
	end

	function playermod:Update(win, set)
		win.title = L["actor absorb and heal spells"](win.actorname or L["Unknown"])
		if not win.actorname then return end

		local actor = set and set:GetActor(win.actorname, win.actorid)
		local total = actor and actor:GetAbsorbHeal()

		if not total or total == 0 or not (actor.healspells or actor.absorbspells) then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = mod.metadata.columns
		local actortime = cols.sHPS and actor:GetTime()

		local spells = actor.healspells -- heal spells
		if spells then
			for spellid, spell in pairs(spells) do
				nr = nr + 1

				local d = win:spell(nr, spellid, spell, nil, true)
				d.value = spell.amount
				format_valuetext(d, cols, total, actortime and (d.value / actortime), win.metadata, true)
			end
		end

		spells = actor.absorbspells -- absorb spells
		if not spells then return end

		for spellid, spell in pairs(spells) do
			nr = nr + 1

			local d = win:spell(nr, spellid, spell)
			d.value = spell.amount
			format_valuetext(d, cols, total, actortime and (d.value / actortime), win.metadata, true)
		end
	end

	function targetmod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = pformat(L["%s's absorbed and healed targets"], label)
	end

	function targetmod:Update(win, set)
		win.title = pformat(L["%s's absorbed and healed targets"], win.actorname)

		local actor = set and set:GetActor(win.actorname, win.actorid)
		local total = actor and actor:GetAbsorbHeal() or 0
		local targets = (total > 0) and actor:GetAbsorbHealTargets()

		if not targets then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = mod.metadata.columns
		local actortime = cols.sAPS and actor:GetTime()

		for targetname, target in pairs(targets) do
			if target.amount > 0 then
				nr = nr + 1

				local d = win:actor(nr, target, nil, targetname)
				d.value = target.amount
				format_valuetext(d, cols, total, actortime and (d.value / actortime), win.metadata, true)
			end
		end
	end

	function mod:Update(win, set)
		win.title = win.class and format("%s (%s)", L["Absorbs and Healing"], L[win.class]) or L["Absorbs and Healing"]

		local total = set and set:GetAbsorbHeal(win.class)
		if not total or total == 0 then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = self.metadata.columns
		local is_arena = (Skada.forPVP and set.type == "arena")

		local actors = set.players -- players
		for i = 1, #actors do
			local actor = actors[i]
			if actor and (not win.class or win.class == actor.class) then
				local hps, amount = actor:GetAHPS(nil, not cols.HPS)
				if amount > 0 then
					nr = nr + 1

					local d = win:actor(nr, actor)
					d.color = is_arena and Skada.classcolors(set.gold and "ARENA_GOLD" or "ARENA_GREEN") or nil
					d.value = amount
					format_valuetext(d, cols, total, hps, win.metadata)
				end
			end
		end

		actors = is_arena and set.enemies or nil -- arena enemies
		if not actors then return end

		for i = 1, #actors do
			local actor = actors[i]
			if actor and not actor.fake and (not win.class or win.class == actor.class) then
				local hps, amount = actor:GetAHPS(nil, not cols.HPS)
				if amount > 0 then
					nr = nr + 1

					local d = win:actor(nr, actor, true)
					d.color = Skada.classcolors(set.gold and "ARENA_GREEN" or "ARENA_GOLD")
					d.value = amount
					format_valuetext(d, cols, total, hps, win.metadata)
				end
			end
		end
	end

	function mod:GetSetSummary(set, win)
		if not set then return end
		local hps, amount = set:GetAHPS(win and win.class)
		return Skada:FormatValueCols(
			self.metadata.columns.Healing and Skada:FormatNumber(amount),
			self.metadata.columns.HPS and Skada:FormatNumber(hps)
		), amount
	end

	function mod:AddToTooltip(set, tooltip)
		if not set then return end
		local hps, amount = set:GetAHPS()
		if amount > 0 then
			tooltip:AddDoubleLine(L["Healing"], Skada:FormatNumber(amount), 1, 1, 1)
			tooltip:AddDoubleLine(L["HPS"], Skada:FormatNumber(hps), 1, 1, 1)
		end
		if set.overheal and set.overheal > 0 then
			amount = amount + set.overheal
			tooltip:AddDoubleLine(L["Overheal"], Skada:FormatPercent(set.overheal, amount), 1, 1, 1)
		end
	end

	local function feed_personal_hps()
		local set = Skada:GetSet("current")
		local player = set and set:GetPlayer(Skada.userGUID, Skada.userName)
		if player then
			return Skada:FormatNumber(player:GetAHPS()) .. " " .. L["HPS"]
		end
	end

	local function feed_raid_hps()
		local set = Skada:GetSet("current")
		return Skada:FormatNumber(set and set:GetAHPS() or 0) .. " " .. L["RHPS"]
	end

	function mod:OnEnable()
		playermod.metadata = {tooltip = playermod_tooltip}
		targetmod.metadata = {showspots = true, click1 = spellmod}
		self.metadata = {
			showspots = true,
			click1 = playermod,
			click2 = targetmod,
			click4 = Skada.FilterClass,
			click4_label = L["Toggle Class Filter"],
			post_tooltip = hps_tooltip,
			columns = {Healing = true, HPS = true, Percent = true, sHPS = false, sPercent = true},
			icon = [[Interface\Icons\spell_holy_healingfocus]]
		}

		-- no total click.
		playermod.nototal = true
		targetmod.nototal = true

		Skada:AddFeed(L["Healing: Personal HPS"], feed_personal_hps)
		Skada:AddFeed(L["Healing: Raid HPS"], feed_raid_hps)

		Skada:AddMode(self, L["Absorbs and Healing"])
	end

	function mod:OnDisable()
		Skada:RemoveFeed(L["Healing: Personal HPS"])
		Skada:RemoveFeed(L["Healing: Raid HPS"])
		Skada:RemoveMode(self)
	end
end, "Absorbs", "Healing")

-- ============================== --
-- Healing done per second module --
-- ============================== --

Skada:RegisterModule("HPS", function(L, P)
	local mod = Skada:NewModule("HPS")

	local function format_valuetext(d, columns, total, metadata)
		d.valuetext = Skada:FormatValueCols(
			columns.HPS and Skada:FormatNumber(d.value),
			columns.Percent and Skada:FormatPercent(d.value, total)
		)

		if metadata and d.value > metadata.maxvalue then
			metadata.maxvalue = d.value
		end
	end

	local function hps_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set then return end

		local actor = set:GetActor(label, id)
		if not actor then return end

		local totaltime = set:GetTime()
		local activetime = actor:GetTime(true)
		local hps, amount = actor:GetAHPS()

		tooltip:AddLine(actor.name .. " - " .. L["HPS"])
		tooltip:AddDoubleLine(L["Segment Time"], Skada:FormatTime(set:GetTime()), 1, 1, 1)
		tooltip:AddDoubleLine(L["Active Time"], Skada:FormatTime(activetime), 1, 1, 1)
		tooltip:AddDoubleLine(L["Absorbs and Healing"], Skada:FormatNumber(amount), 1, 1, 1)

		local suffix = Skada:FormatTime(P.timemesure == 1 and activetime or totaltime)
		tooltip:AddDoubleLine(Skada:FormatNumber(amount) .. "/" .. suffix, Skada:FormatNumber(hps), 1, 1, 1)
	end

	function mod:Update(win, set)
		win.title = win.class and format("%s (%s)", L["HPS"], L[win.class]) or L["HPS"]

		local total = set and set:GetAHPS(win.class)
		if not total or total == 0 then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = self.metadata.columns
		local is_arena = (Skada.forPVP and set.type == "arena")

		local actors = set.players -- players
		for i = 1, #actors do
			local actor = actors[i]
			if actor and (not win.class or win.class == actor.class) then
				local amount = actor:GetAHPS(nil, not cols.HPS)
				if amount > 0 then
					nr = nr + 1

					local d = win:actor(nr, actor)
					d.color = is_arena and Skada.classcolors(set.gold and "ARENA_GOLD" or "ARENA_GREEN") or nil
					d.value = amount
					format_valuetext(d, cols, total, win.metadata)
				end
			end
		end

		actors = is_arena and set.enemies or nil -- arena enemies
		if not actors then return end

		for i = 1, #actors do
			local actor = actors[i]
			if actor and not actor.fake and (not win.class or win.class == actor.class) then
				local amount = actor:GetHPS(nil, not cols.HPS)
				if amount > 0 then
					nr = nr + 1

					local d = win:actor(nr, actor, true)
					d.color = Skada.classcolors(set.gold and "ARENA_GREEN" or "ARENA_GOLD")
					d.value = amount
					format_valuetext(d, cols, total, win.metadata)
				end
			end
		end
	end

	function mod:GetSetSummary(set, win)
		local value =  set:GetAHPS(win and win.class)
		return Skada:FormatNumber(value), value
	end

	function mod:OnEnable()
		self.metadata = {
			showspots = true,
			tooltip = hps_tooltip,
			click4 = Skada.FilterClass,
			click4_label = L["Toggle Class Filter"],
			columns = {HPS = true, Percent = true},
			icon = [[Interface\Icons\spell_nature_rejuvenation]]
		}

		local parentmod = Skada:GetModule("Absorbs and Healing", true)
		if parentmod then
			self.metadata.click1 = parentmod.metadata.click1
			self.metadata.click2 = parentmod.metadata.click2
		end

		Skada:AddMode(self, L["Absorbs and Healing"])
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end
end, "Absorbs", "Healing", "Absorbs and Healing")

-- ===================== --
-- Healing done by spell --
-- ===================== --

Skada:RegisterModule("Healing Done By Spell", function(L, _, _, C, new, _, clear)
	local mod = Skada:NewModule("Healing Done By Spell")
	local spellmod = mod:NewModule("Healing spell sources")
	local spellschools = Skada.spellschools
	local GetSpellInfo = Skada.GetSpellInfo or GetSpellInfo
	local get_absorb_heal_spells = nil

	local function format_valuetext(d, columns, total, hps, metadata, subview)
		d.valuetext = Skada:FormatValueCols(
			columns.Healing and Skada:FormatNumber(d.value),
			columns[subview and "sHPS" or "HPS"] and Skada:FormatNumber(hps),
			columns[subview and "sPercent" or "Percent"] and Skada:FormatPercent(d.value, total)
		)

		if metadata and d.value > metadata.maxvalue then
			metadata.maxvalue = d.value
		end
	end

	local function player_tooltip(win, id, label, tooltip)
		local set = win.spellname and win:GetSelectedSet()
		local player = set and set:GetActor(label, id)
		if not player then return end

		local spell = player.healspells and player.healspells[win.spellid]
		spell = spell or player.absorbspells and player.absorbspells[win.spellid]
		if not spell then return end

		tooltip:AddLine(label .. " - " .. win.spellname)

		if spell.casts then
			tooltip:AddDoubleLine(L["Casts"], spell.casts, 1, 1, 1)
		end

		if spell.count then
			tooltip:AddDoubleLine(L["Count"], spell.count, 1, 1, 1)

			if spell.c_num then
				tooltip:AddDoubleLine(L["Critical"], Skada:FormatPercent(spell.c_num, spell.count), 1, 1, 1)
				tooltip:AddLine(" ")
			end

			if spell.min and spell.max then
				tooltip:AddDoubleLine(L["Minimum"], Skada:FormatNumber(spell.min), 1, 1, 1)
				tooltip:AddDoubleLine(L["Maximum"], Skada:FormatNumber(spell.max), 1, 1, 1)
				tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(spell.amount / spell.count), 1, 1, 1)
			end
		end

		if spell.o_amt then
			tooltip:AddDoubleLine(L["Overheal"], format("%s (%s)", Skada:FormatNumber(spell.o_amt), Skada:FormatPercent(spell.o_amt, spell.amount + spell.o_amt)), nil, nil, nil, 1, 0.67, 0.67)
		end
	end

	local function spell_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		local total = set and set:GetAbsorbHeal() or 0
		if total == 0 then return end

		clear(C)
		for i = 1, #set.players do
			local p = set.players[i]
			local spell = p and ((p.absorbspells and p.absorbspells[id]) or (p.healspells and p.healspells[id])) or nil
			if spell then
				if not C[id] then
					C[id] = new()
					C[id].school = spell.school
					C[id].amount = spell.amount
					C[id].o_amt = spell.o_amt
					C[id].isabsorb = (p.absorbspells and p.absorbspells[id])
				else
					C[id].amount = C[id].amount + spell.amount
					if spell.o_amt then
						C[id].o_amt = (C[id].o_amt or 0) + spell.o_amt
					end
				end
			end
		end

		local spell = C[id]
		if not spell then return end

		tooltip:AddLine((GetSpellInfo(id)))
		if spell.school and spellschools[spell.school] then
			tooltip:AddLine(spellschools(spell.school))
		end

		if spell.casts and spell.casts > 0 then
			tooltip:AddDoubleLine(L["Casts"], spell.casts, 1, 1, 1)
		end

		if spell.count and spell.count > 0 then
			tooltip:AddDoubleLine(L["Hits"], spell.count, 1, 1, 1)
		end
		tooltip:AddDoubleLine(spell.isabsorb and L["Absorbs"] or L["Healing"], format("%s (%s)", Skada:FormatNumber(spell.amount), Skada:FormatPercent(spell.amount, total)), 1, 1, 1)
		if set.overheal and spell.o_amt and spell.o_amt > 0 then
			tooltip:AddDoubleLine(L["Overheal"], format("%s (%s)", Skada:FormatNumber(spell.o_amt), Skada:FormatPercent(spell.o_amt, set.overheal)), 1, 1, 1)
		end
	end

	function spellmod:Enter(win, id, label)
		win.spellid, win.spellname = id, label
		win.title = pformat(L["%s's sources"], label)
	end

	function spellmod:Update(win, set)
		win.title = pformat(L["%s's sources"], win.spellname)
		if not (win.spellid and set) then return end

		-- let's go...
		local total = 0
		local players = clear(C)

		local _players = set.players
		for i = 1, #_players do
			local p = _players[i]
			local spell = p and ((p.absorbspells and p.absorbspells[win.spellid]) or (p.healspells and p.healspells[win.spellid])) or nil
			if spell then
				players[p.name] = new()
				players[p.name].id = p.id
				players[p.name].class = p.class
				players[p.name].role = p.role
				players[p.name].spec = p.spec
				players[p.name].amount = spell.amount
				players[p.name].time = mod.metadata.columns.sHPS and p:GetTime()
				-- calculate the total.
				total = total + spell.amount
			end
		end

		if total == 0 then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = mod.metadata.columns

		for playername, player in pairs(players) do
			nr = nr + 1

			local d = win:actor(nr, player, nil, playername)
			d.value = player.amount
			format_valuetext(d, cols, total, player.time and (d.value / player.time), win.metadata, true)
		end
	end

	function mod:Update(win, set)
		win.title = L["Healing Done By Spell"]
		local total = set and set:GetAbsorbHeal()
		local spells = (total and total > 0) and get_absorb_heal_spells(set)

		if not spells then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local cols = self.metadata.columns
		local settime = cols.HPS and set:GetTime()

		for spellid, spell in pairs(spells) do
			nr = nr + 1

			local d = win:spell(nr, spellid, spell, nil, true)
			d.value = spell.amount
			format_valuetext(d, cols, total, settime and (d.value / settime), win.metadata)
		end
	end

	function mod:OnEnable()
		spellmod.metadata = {showspots = true, tooltip = player_tooltip}
		self.metadata = {
			click1 = spellmod,
			post_tooltip = spell_tooltip,
			columns = {Healing = true, HPS = false, Percent = true, sHPS = false, sPercent = true},
			icon = [[Interface\Icons\spell_nature_healingwavelesser]]
		}
		Skada:AddMode(self, L["Absorbs and Healing"])
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end

	---------------------------------------------------------------------------

	local function fill_spells_table(t, spellid, info)
		local spell = t[spellid]
		if not spell then
			spell = new()
			-- common
			spell.school = info.school
			spell.amount = info.amount

			-- for heals
			spell.o_amt = info.o_amt

			t[spellid] = spell
		else
			spell.amount = spell.amount + info.amount
			if info.o_amt then -- for heals
				spell.o_amt = (spell.o_amt or 0) + info.o_amt
			end
		end
	end

	get_absorb_heal_spells = function(self, tbl)
		if not self.players or not (self.absorb or self.heal) then return end

		tbl = clear(tbl or C)
		for i = 1, #self.players do
			local player = self.players[i]
			if player and player.healspells then
				for spellid, spell in pairs(player.healspells) do
					fill_spells_table(tbl, spellid, spell)
				end
			end
			if player and player.absorbspells then
				for spellid, spell in pairs(player.absorbspells) do
					fill_spells_table(tbl, spellid, spell)
				end
			end
		end
		return tbl
	end
end, "Absorbs", "Healing")
