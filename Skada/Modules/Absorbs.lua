local _, Skada = ...
local Private = Skada.Private

-- cache frequently used globals
local pairs, format, uformat = pairs, string.format, Private.uformat
local new, del = Private.newTable, Private.delTable
local tooltip_school = Skada.tooltip_school
local hits_perc = "%s (\124cffffffff%s\124r)"

-- ============== --
-- Absorbs module --
-- ============== --

Skada:RegisterModule("Absorbs", function(L, P, G)
	local mode = Skada:NewModule("Absorbs")
	local mode_spell = mode:NewModule("Absorb spell list")
	local mode_target = mode:NewModule("Absorbed target list")
	local mode_target_spell = mode_target:NewModule("Absorb spell list")
	tooltip_school = tooltip_school or Skada.tooltip_school
	local ignored_spells = Skada.ignored_spells.absorb -- Edit Skada\Core\Tables.lua
	local passive_spells = Skada.ignored_spells.time -- Edit Skada\Core\Tables.lua

	local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER or 0x00000100
	local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_AFFILIATION_OUTSIDER or 0x00000008
	local COMBATLOG_OBJECT_REACTION_MASK = COMBATLOG_OBJECT_REACTION_MASK or 0x000000F0

	local GetTime, band, tsort, max = GetTime, bit.band, table.sort, math.max
	local wipe, clear = wipe, Private.clearTable
	local mode_cols = nil

	local absorbspells = {
		[17] = 0x02, -- Power Word: Shield
		[543] = 0x40, -- Mage Ward
		[1463] = 0x40, -- Mana shield
		[4057] = 0x04, -- Flame Deflector (Fire Resistance)
		[4077] = 0x10, -- Ice Deflector (Frost Resistance)
		[6229] = 0x20, -- Shadow Ward
		[7233] = 0x08, -- Fire Protection Potion
		[7239] = 0x10, -- Frost Protection Potion
		[7242] = 0x20, -- Shadow Protection Potion
		[7245] = 0x02, -- Holy Protection Potion
		[7259] = 0x01, -- Nature Protection Potion
		[7812] = 0x20, -- Sacrifice
		[10368] = 0x02, -- Uther's Light Effect
		[11426] = 0x10, -- Ice Barrier
		[11657] = 0x01, -- Jang'thraze
		[12561] = 0x04, -- Goblin Construction Helmet (Fire Protection)
		[17252] = 0x01, -- Mark of the Dragon Lord (LBRS epic ring)
		[17543] = 0x04, -- Greater Fire Protection Potion
		[17544] = 0x10, -- Greater Frost Protection Potion
		[17545] = 0x02, -- Greater Holy Protection Potion
		[17546] = 0x08, -- Greater Nature Protection Potion
		[17548] = 0x20, -- Greater Shadow Protection Potion
		[17549] = 0x04, -- Greater Arcane Protection Potion
		[21956] = 0x02, -- Mark of Resolution (Physical Protection)
		[23506] = 0x02, -- Arena Grand Master (Aura of Protection)
		[23991] = 0x02, -- Defiler's Talisman/Talisman of Arathor
		[25228] = 0x20, -- Soul Link
		[25746] = 0x02, -- Defiler's Talisman/Talisman of Arathor
		[25747] = 0x02, -- Defiler's Talisman/Talisman of Arathor
		[25750] = 0x02, -- Defiler's Talisman/Talisman of Arathor
		[26467] = 0x01, -- Scarab Brooch (Persistent Shield)
		[27539] = 0x01, -- Thick Obsidian Breatplate (Obsidian Armor)
		[27779] = 0x02, -- Divine Protection (Priest dungeon set 1/2)
		[28511] = 0x08, -- Major Fire Protection Potion
		[28512] = 0x10, -- Major Frost Protection Potion
		[28513] = 0x08, -- Major Nature Protection Potion
		[28527] = 0x02, -- Fel Blossom
		[28536] = 0x04, --  Major Arcane Protection Potion
		[28537] = 0x20, -- Major Shadow Protection Potion
		[28538] = 0x02, -- Major Holy Protection Potion
		[28810] = 0x02, -- Faith Set Proc (Armor of Faith)
		[29432] = 0x04, -- Frozen Rune (Fire Protection)
		[29506] = 0x02, -- The Burrower's Shell
		[29674] = 0x40, -- Lesser Ward of Shielding
		[29701] = 0x40, -- Greater Shielding
		[29719] = 0x40, -- Greater Ward of Shielding
		[30994] = 0x10, -- Pendant of Thawing (Frost Absorption)
		[30997] = 0x04, -- Pendant of Frozen Flame (Fire Absorption)
		[30999] = 0x08, -- Pendant of Withering (Nature Absorption)
		[31000] = 0x20, -- Pendant of Shadow's End (Shadow Absorption)
		[31002] = 0x40, -- Pendant of the Null Rune (Arcane Absorption)
		[31230] = 0x01, -- Cheat Death
		[31771] = 0x02, -- Runed Fungalcap (Shell of Deterrence)
		[31850] = 0x01, -- Ardent Defender
		[36481] = 0x40, -- Arcane Barrier (TK Kael'Thas) Shield
		[37515] = 0x02, -- Blade Turning
		[39228] = 0x02, -- Argussian Compass
		[40322] = 0x10, -- Teron's Vengeful Spirit Ghost - Spirit Shield
		[42137] = 0x01, -- Greater Rune of Warding
		[47509] = 0x02, -- Divine Aegis (rank 1)
		[47511] = 0x02, -- Divine Aegis (rank 2)
		[47515] = 0x02, -- Divine Aegis (rank 3)
		[47753] = 0x02, -- Divine Aegis (rank 1)
		[47788] = 0x02, -- Guardian Spirit
		[48707] = 0x20, -- Anti-Magic Shell
		[51052] = 0x20, -- Anti-Magic Zone
		[53910] = 0x04, -- Mighty Arcane Protection Potion
		[53911] = 0x08, -- Mighty Fire Protection Potion
		[53913] = 0x10, -- Mighty Frost Protection Potion
		[53914] = 0x08, -- Mighty Nature Protection Potion
		[53915] = 0x20, -- Mighty Shadow Protection Potion
		[54704] = 0x02, -- Divine Aegis (rank 1)
		[54808] = 0x01, -- Noise Machine (onic Shield)
		[55019] = 0x01, -- Sonic Shield
		[57350] = 0x01, -- Darkmoon Card: Illusion
		[62606] = 0x08, -- Savage Defense
		[62618] = 0x02, -- Power Word: Barrier
		[64413] = 0x08, -- Protection of Ancient Kings (Val'anyr, Hammer of Ancient Kings)
		[65684] = 0x01, -- Twin Val'kyr: Dark Essence
		[65686] = 0x01, -- Twin Val'kyr: Light Essence
		[65858] = 0x04, -- Twin Val'kyr's Shield of Lights (175000)
		[65874] = 0x20, -- Twin Val'kyr's: Shield of Darkness
		[67256] = 0x20, -- Twin Val'kyr's: Shield of Darkness (700000)
		[67257] = 0x20, -- Twin Val'kyr's: Shield of Darkness (300000)
		[67258] = 0x20, -- Twin Val'kyr's: Shield of Darkness (1200000)
		[67259] = 0x04, -- Twin Val'kyr's: Shield of Lights (700000)
		[67260] = 0x04, -- Twin Val'kyr's: Shield of Lights (300000)
		[67261] = 0x04, -- Twin Val'kyr's: Shield of Lights (1200000)
		[70845] = 0x01, -- Stoicism
		[77535] = 0x20, -- Blood Shield
		[81781] = 0x02, -- Power Word: Barrier
		[86273] = 0x02, -- Illuminated Healing
		[88063] = 0x02, -- Guarded by the Light
		[96263] = 0x02, -- Sacred Shield
		[105801] = 0x02, -- Delayed Judgment
		[105909] = 0x02, -- Shield of Fury
		[108008] = 0x01 -- Will of the Necropolis
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

	local function log_spellcast(set, actorid, actorname, actorflags, spellid)
		if not set or (set == Skada.total and not P.totalidc) then return end

		local actor = Skada:FindActor(set, actorid, actorname, actorflags)
		if actor and actor.absorbspells and actor.absorbspells[spellid] then
			actor.absorbspells[spellid].casts = (actor.absorbspells[spellid].casts or 1) + 1
		end
	end

	local function log_absorb(set, nocount)
		if not absorb.amount or absorb.amount == 0 then return end

		local actor = Skada:GetActor(set, absorb.actorid, absorb.actorname, absorb.actorflags)
		if not actor then
			return
		elseif actor.role ~= "DAMAGER" and not passive_spells[absorb.spell] and not nocount then
			Skada:AddActiveTime(set, actor, absorb.dstName)
		end

		-- add absorbs amount
		actor.absorb = (actor.absorb or 0) + absorb.amount
		set.absorb = (set.absorb or 0) + absorb.amount

		-- saving this to total set may become a memory hog deluxe.
		if set == Skada.total and not P.totalidc then return end

		-- record the spell
		local spell = actor.absorbspells and actor.absorbspells[absorb.spellid]
		if not spell then
			actor.absorbspells = actor.absorbspells or {}
			actor.absorbspells[absorb.spellid] = {amount = 0}
			spell = actor.absorbspells[absorb.spellid]
		end

		spell.amount = spell.amount + absorb.amount

		-- start cast counter.
		spell.casts = spell.casts or 1

		if not nocount then
			spell.count = (spell.count or 0) + 1

			if absorb.critical then
				spell.c_num = (spell.c_num or 0) + 1
				spell.c_amt = (spell.c_amt or 0) + absorb.amount
				if not spell.c_max or absorb.amount > spell.c_max then
					spell.c_max = absorb.amount
				end
				if not spell.c_min or absorb.amount < spell.c_min then
					spell.c_min = absorb.amount
				end
			else
				spell.n_num = (spell.n_num or 0) + 1
				spell.n_amt = (spell.n_amt or 0) + absorb.amount
				if not spell.n_max or absorb.amount > spell.n_max then
					spell.n_max = absorb.amount
				end
				if not spell.n_min or absorb.amount < spell.n_min then
					spell.n_min = absorb.amount
				end
			end
		end

		-- record the target
		if not absorb.dstName then return end
		spell.targets = spell.targets or {}
		spell.targets[absorb.dstName] = (spell.targets[absorb.dstName] or 0) + absorb.amount
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

	-- local function ValidateShield(srcFlags, dstFlags)
	-- 	local valid = nil

	-- 	if srcFlags and dstFlags then
	-- 		-- make sure both parts are valid.
	-- 		valid = band(srcFlags, dstFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0

	-- 		-- make sure both are in the group
	-- 		valid = valid and (band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0)
	-- 		valid = valid and (band(dstFlags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0)

	-- 		-- make sure both are friendly to each other
	-- 		valid = valid and (band(srcFlags, dstFlags, COMBATLOG_OBJECT_REACTION_MASK) ~= 0)
	-- 	end

	-- 	return valid
	-- end

	local function remove_shield(dstName, srcGUID, spellid)
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

	local function handle_shield(t)
		if not t.spellid or not absorbspells[t.spellid] or not t.dstName or ignored_spells[t.spellid] then return end

		shields = shields or {} -- create table if missing
		local dstName = Skada:FixPetsName(t.dstGUID, t.dstName, t.dstFlags)
		local srcGUID, srcName, srcFlags = t.srcGUID, t.srcName, t.srcFlags

		-- shield removed?
		if t.event == "SPELL_AURA_REMOVED" then
			if shields[dstName] then
				for i = 1, #shields[dstName] do
					local shield = shields[dstName][i]
					if shield and shield.srcGUID == srcGUID and shield.spellid == t.spellid then
						Skada:ScheduleTimer(remove_shield, 0.1, dstName, srcGUID, t.spellid)
						break
					end
				end
			end
			return
		end

		-- create player's shields table
		shields[dstName] = shields[dstName] or new()

		-- Soul Link
		if t.spellid == 25228 then
			srcGUID, srcName, srcFlags = Skada:FixMyPets(srcGUID, srcName, srcFlags)
		end

		-- shield refreshed
		if t.event == "SPELL_AURA_REFRESH" then
			local index = nil
			for i = 1, #shields[dstName] do
				local shield = shields[dstName][i]
				if shield and shield.srcGUID == srcGUID and shield.spellid == t.spellid then
					shield.ts = t.timestamp
					index = i
					break
				end
			end

			-- not found? add it
			if not index then
				local shield = new()
				shield.spellid = t.spellid
				shield.string = t.spellstring
				shield.srcGUID = srcGUID
				shield.srcName = srcName
				shield.srcFlags = srcFlags
				shield.ts = t.timestamp
				shields[dstName][#shields[dstName] + 1] = shield
			else
				shields[dstName][index].ts = t.timestamp
			end

			tsort(shields[dstName], shields_order_pred)
		else
			local shield = new()
			shield.spellid = t.spellid
			shield.string = t.spellstring
			shield.srcGUID = srcGUID
			shield.srcName = srcName
			shield.srcFlags = srcFlags
			shield.ts = t.timestamp

			shields[dstName][#shields[dstName] + 1] = shield
			tsort(shields[dstName], shields_order_pred)

			-- record spell cast (ignore pre-shields)
			if not t.__temp then
				Skada:DispatchSets(log_spellcast, srcGUID, srcName, srcFlags, t.spellstring)
			end
		end

		if t.__temp then t = del(t) end
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
			absorb.actorid = shield.srcGUID
			absorb.actorname = shield.srcName
			absorb.actorflags = shield.srcFlags

			absorb.dstGUID = dstGUID
			absorb.dstName = dstName
			absorb.dstFlags = dstFlags

			absorb.spell = shield.spellid
			absorb.spellid = shield.string
			absorb.string = shield.string
			absorb.amount = absorbed

			Skada:DispatchSets(log_absorb)
		end
	end

	local function spell_damage(t)
		local dstName = t.dstName and Skada:FixPetsName(t.dstGUID, t.dstName, t.dstFlags)
		if dstName and shields and shields[dstName] and t.absorbed and t.absorbed > 0 then
			process_absorb(t.dstGUID, dstName, t.dstFlags, t.absorbed, t.spellschool or 0x01, t.amount)
		end
	end

	local function absorb_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		local actor = set and set:GetActor(id, label)
		if not actor then return end

		local totaltime = set:GetTime()
		local activetime = actor:GetTime(set, true)
		local aps, damage = actor:GetAPS(set)

		tooltip:AddDoubleLine(L["Activity"], Skada:FormatPercent(activetime, totaltime), nil, nil, nil, 1, 1, 1)
		tooltip:AddDoubleLine(L["Segment Time"], Skada:FormatTime(totaltime), 1, 1, 1)
		tooltip:AddDoubleLine(L["Active Time"], Skada:FormatTime(activetime), 1, 1, 1)
		tooltip:AddDoubleLine(L["Absorbs"], Skada:FormatNumber(damage), 1, 1, 1)

		local suffix = Skada:FormatTime(P.timemesure == 1 and activetime or totaltime)
		tooltip:AddDoubleLine(Skada:FormatNumber(damage) .. "/" .. suffix, Skada:FormatNumber(aps), 1, 1, 1)
	end

	local function mode_spell_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set then return end

		local actor = set:GetActor(win.actorid, win.actorname)
		local spell = actor and actor.absorbspells and actor.absorbspells[id]
		if not spell then return end

		tooltip:AddLine(actor.name .. " - " .. label)
		tooltip_school(tooltip, id)

		if spell.casts and spell.casts > 0 then
			tooltip:AddDoubleLine(L["Casts"], spell.casts, 1, 1, 1)
		end

		if not spell.count or spell.count == 0 then return end

		-- hits and average
		tooltip:AddDoubleLine(L["Hits"], spell.count, 1, 1, 1)
		tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(spell.amount / spell.count), 1, 1, 1)

		-- normal hits
		if spell.n_num then
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine(L["Normal Hits"], format(hits_perc, Skada:FormatNumber(spell.n_num), Skada:FormatPercent(spell.n_num, spell.count)))
			if spell.n_min then
				tooltip:AddDoubleLine(L["Minimum"], Skada:FormatNumber(spell.n_min), 1, 1, 1)
			end
			if spell.n_max then
				tooltip:AddDoubleLine(L["Maximum"], Skada:FormatNumber(spell.n_max), 1, 1, 1)
			end
			tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(spell.n_amt / spell.n_num), 1, 1, 1)
		end
	end

	function mode_target_spell:Enter(win, id, label)
		win.targetid, win.targetname = id, label
		win.title = L["actor absorb spells"](win.actorname or L["Unknown"], label)
	end

	function mode_target_spell:Update(win, set)
		win.title = L["actor absorb spells"](win.actorname or L["Unknown"], win.targetname or L["Unknown"])
		if not set or not win.targetname then return end

		local actor = set:GetActor(win.actorid, win.actorname)
		if not actor or actor.enemy then return end -- unavailable for enemies yet

		local total = actor.absorb
		local spells = (total and total > 0) and actor.absorbspells
		if not spells then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local actortime = mode_cols.sAPS and actor:GetTime(set)

		for spellid, spell in pairs(spells) do
			local amount = spell.targets and spell.targets[win.targetname]
			if spell.targets and amount then
				nr = nr + 1

				local d = win:spell(nr, spellid, spell)
				d.value = amount
				format_valuetext(d, mode_cols, total, actortime and (d.value / actortime), win.metadata, true)
			end
		end
	end

	function mode_spell:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = L["actor absorb spells"](label)
	end

	function mode_spell:Update(win, set)
		win.title = L["actor absorb spells"](win.actorname or L["Unknown"])
		if not set or not win.actorname then return end

		local actor = set:GetActor(win.actorid, win.actorname)
		if not actor or actor.enemy then return end -- unavailable for enemies yet

		local total = actor.absorb
		local spells = (total and total > 0) and actor.absorbspells
		if not spells then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local actortime = mode_cols.sAPS and actor:GetTime(set)

		for spellid, spell in pairs(spells) do
			nr = nr + 1

			local d = win:spell(nr, spellid, spell)
			d.value = spell.amount
			format_valuetext(d, mode_cols, total, actortime and (d.value / actortime), win.metadata, true)
		end
	end

	function mode_target:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = uformat(L["%s's absorbed targets"], label)
	end

	function mode_target:Update(win, set)
		win.title = uformat(L["%s's absorbed targets"], win.actorname)
		if not set or not win.actorname then return end

		local actor = set:GetActor(win.actorid, win.actorname)
		if not actor or actor.enemy then return end -- unavailable for enemies yet

		local total = actor and actor.absorb or 0
		local targets = (total > 0) and actor:GetAbsorbTargets(set)

		if not targets then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local actortime = mode_cols.sAPS and actor:GetTime(set)

		for targetname, target in pairs(targets) do
			nr = nr + 1

			local d = win:actor(nr, target, target.enemy, targetname)
			d.value = target.amount
			format_valuetext(d, mode_cols, total, actortime and (d.value / actortime), win.metadata, true)
		end
	end

	function mode:Update(win, set)
		win.title = win.class and format("%s (%s)", L["Absorbs"], L[win.class]) or L["Absorbs"]

		local total = set and set:GetAbsorb(win.class)
		if not total or total == 0 then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local actors = set.actors

		for actorname, actor in pairs(actors) do
			if win:show_actor(actor, set, true) and actor.absorb then
				local aps, amount = actor:GetAPS(set, nil, not mode_cols.APS)
				if amount > 0 then
					nr = nr + 1

					local d = win:actor(nr, actor, actor.enemy)
					d.value = amount
					format_valuetext(d, mode_cols, total, aps, win.metadata)
					win:color(d, set, actor.enemy)
				end
			end
		end
	end

	function mode:GetSetSummary(set, win)
		local aps, amount = set:GetAPS(win and win.class)
		local valuetext = Skada:FormatValueCols(
			self.metadata.columns.Absorbs and Skada:FormatNumber(amount),
			self.metadata.columns.APS and Skada:FormatNumber(aps)
		)
		return amount, valuetext
	end

	do
		local UnitGUID, UnitName = UnitGUID, UnitName
		local UnitBuff, UnitIsDeadOrGhost = UnitBuff, UnitIsDeadOrGhost
		local GroupIterator = Skada.GroupIterator

		local function check_unit_shields(unit, owner, timestamp, curtime)
			if UnitIsDeadOrGhost(unit) then return end

			local dstGUID, dstName = UnitGUID(unit), UnitName(unit)
			for i = 1, 40 do
				local _, _, _, _, _, _, expires, unitCaster, _, _, spellid = UnitBuff(unit, i)
				if not spellid then
					break -- nothing found
				elseif absorbspells[spellid] and unitCaster and not ignored_spells[spellid] then
					local t = new()
					t.timestamp = timestamp + max(0, expires - curtime)
					t.srcGUID = UnitGUID(unitCaster)
					t.srcName = UnitName(unitCaster)
					t.srcFlags = 0
					t.dstGUID = dstGUID
					t.dstName = dstName
					t.dstFlags = 0
					t.spellid = spellid
					t.spellstring = format("%s.%s", spellid, absorbspells[spellid])
					t.__temp = true
					handle_shield(t)
				end
			end
		end

		function mode:CombatEnter(_, set, args)
			if not G.inCombat and set and not set.stopped and not self.checked then
				GroupIterator(check_unit_shields, args.timestamp, set.last_time or GetTime())
				self.checked = true
			end
		end

		function mode:CombatLeave()
			self.checked = nil
			wipe(absorb)
			clear(shields)
		end
	end

	function mode:OnEnable()
		mode_spell.metadata = {tooltip = mode_spell_tooltip}
		mode_target.metadata = {showspots = true, click1 = mode_target_spell}
		self.metadata = {
			showspots = true,
			post_tooltip = absorb_tooltip,
			click1 = mode_spell,
			click2 = mode_target,
			click4 = Skada.FilterClass,
			click4_label = L["Toggle Class Filter"],
			columns = {Absorbs = true, APS = true, Percent = true, sAPS = false, sPercent = true},
			icon = [[Interface\Icons\spell_holy_devineaegis]]
		}

		mode_cols = self.metadata.columns

		-- no total click.
		mode_spell.nototal = true
		mode_target.nototal = true

		local flags_src = {src_is_interesting = true}

		Skada:RegisterForCL(
			handle_shield,
			flags_src,
			"SPELL_AURA_APPLIED",
			"SPELL_AURA_REFRESH",
			"SPELL_AURA_REMOVED"
		)

		local flags_dst = {dst_is_interesting = true}

		Skada:RegisterForCL(
			spell_damage,
			flags_dst,
			-- damage events
			"DAMAGE_SHIELD",
			"DAMAGE_SPLIT",
			"RANGE_DAMAGE",
			"SPELL_BUILDING_DAMAGE",
			"SPELL_DAMAGE",
			"SPELL_PERIODIC_DAMAGE",
			"SWING_DAMAGE",
			"ENVIRONMENTAL_DAMAGE",
			-- missed events
			"DAMAGE_SHIELD_MISSED",
			"RANGE_MISSED",
			"SPELL_BUILDING_MISSED",
			"SPELL_MISSED",
			"SPELL_PERIODIC_MISSED",
			"SWING_MISSED"
		)

		Skada.RegisterMessage(self, "COMBAT_PLAYER_ENTER", "CombatEnter")
		Skada.RegisterMessage(self, "COMBAT_PLAYER_LEAVE", "CombatLeave")
		Skada:AddMode(self, "Absorbs and Healing")
	end

	function mode:OnDisable()
		Skada.UnregisterAllMessages(self)
		Skada:RemoveMode(self)
	end

	function mode:SetComplete(set)
		-- clean absorbspells table:
		if not set.absorb or set.absorb == 0 then return end
		for _, actor in pairs(set.actors) do
			local amount = actor.absorb
			if (not amount and actor.absorbspells) or amount == 0 then
				actor.absorb = nil
				actor.absorbspells = del(actor.absorbspells, true)
			end
		end
	end
end)

-- ========================== --
-- Absorbs and healing module --
-- ========================== --

Skada:RegisterModule("Absorbs and Healing", function(L, P)
	local mode = Skada:NewModule("Absorbs and Healing")
	local mode_spell = mode:NewModule("Absorbs and healing spells")
	local mode_target = mode:NewModule("Absorbed and healed targets")
	local mode_target_spell = mode_target:NewModule("Absorbs and healing spells")
	local mode_cols = nil

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

		local actor = set:GetActor(id, label)
		if not actor then return end

		local totaltime = set:GetTime()
		local activetime = actor:GetTime(set, true)
		local hps, amount = actor:GetAHPS(set)

		tooltip:AddDoubleLine(L["Activity"], Skada:FormatPercent(activetime, totaltime), nil, nil, nil, 1, 1, 1)
		tooltip:AddDoubleLine(L["Segment Time"], Skada:FormatTime(set:GetTime()), 1, 1, 1)
		tooltip:AddDoubleLine(L["Active Time"], Skada:FormatTime(activetime), 1, 1, 1)
		tooltip:AddDoubleLine(L["Absorbs and Healing"], Skada:FormatNumber(amount), 1, 1, 1)

		local suffix = Skada:FormatTime(P.timemesure == 1 and activetime or totaltime)
		tooltip:AddDoubleLine(Skada:FormatNumber(amount) .. "/" .. suffix, Skada:FormatNumber(hps), 1, 1, 1)
	end

	local function mode_spell_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set then return end

		local actor = set:GetActor(win.actorid, win.actorname)
		if not actor then return end

		local spell = actor.healspells and actor.healspells[id] or actor.absorbspells and actor.absorbspells[id]
		if not spell then return end

		tooltip:AddLine(actor.name .. " - " .. label)
		tooltip_school(tooltip, id)

		if spell.casts and spell.casts > 0 then
			tooltip:AddDoubleLine(L["Casts"], spell.casts, 1, 1, 1)
		end

		if not spell.count or spell.count == 0 then return end

		-- hits and average
		tooltip:AddDoubleLine(L["Hits"], spell.count, 1, 1, 1)
		tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(spell.amount / spell.count), 1, 1, 1)
		if spell.o_amt and spell.o_amt > 0 then
			tooltip:AddDoubleLine(L["Overheal"], format(hits_perc, Skada:FormatNumber(spell.o_amt), Skada:FormatPercent(spell.o_amt, spell.amount + spell.o_amt)), 1, 0.67, 0.67)
		end

		-- normal hits
		if spell.n_num then
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine(L["Normal Hits"], format(hits_perc, Skada:FormatNumber(spell.n_num), Skada:FormatPercent(spell.n_num, spell.count)))
			if spell.n_min then
				tooltip:AddDoubleLine(L["Minimum"], Skada:FormatNumber(spell.n_min), 1, 1, 1)
			end
			if spell.n_max then
				tooltip:AddDoubleLine(L["Maximum"], Skada:FormatNumber(spell.n_max), 1, 1, 1)
			end
			tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(spell.n_amt / spell.n_num), 1, 1, 1)
		end

		-- critical hits
		if spell.c_num then
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine(L["Critical Hits"], format(hits_perc, Skada:FormatNumber(spell.c_num), Skada:FormatPercent(spell.c_num, spell.count)))
			if spell.c_min then
				tooltip:AddDoubleLine(L["Minimum"], Skada:FormatNumber(spell.c_min), 1, 1, 1)
			end
			if spell.c_max then
				tooltip:AddDoubleLine(L["Maximum"], Skada:FormatNumber(spell.c_max), 1, 1, 1)
			end
			tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(spell.c_amt / spell.c_num), 1, 1, 1)
		end
	end

	function mode_target_spell:Enter(win, id, label)
		win.targetid, win.targetname = id, label
		win.title = L["actor absorb and heal spells"](win.actorname or L["Unknown"], label)
	end

	function mode_target_spell:Update(win, set)
		win.title = L["actor absorb and heal spells"](win.actorname or L["Unknown"], win.targetname or L["Unknown"])
		if not set or not win.targetname then return end

		local actor = set:GetActor(win.actorid, win.actorname)
		local total = actor and actor:GetAbsorbHealOnTarget(win.targetname)

		if not total or total == 0 or not (actor.healspells or actor.absorbspells) then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local actortime = mode_cols.sHPS and actor:GetTime(set)

		local spells = actor.healspells -- heal spells
		if spells then
			for spellid, spell in pairs(spells) do
				local amount = spell.targets and spell.targets[win.targetname]
				amount = amount and (actor.enemy and amount or amount.amount)
				if amount then
					nr = nr + 1

					local d = win:spell(nr, spellid, spell, nil, true)
					d.value = amount
					format_valuetext(d, mode_cols, total, actortime and (d.value / actortime), win.metadata, true)
				end
			end
		end

		spells = actor.absorbspells -- absorb spells
		if not spells then return end

		for spellid, spell in pairs(spells) do
			local amount = spell.targets and spell.targets[win.targetname]
			if amount then
				nr = nr + 1

				local d = win:spell(nr, spellid, spell)
				d.value = amount
				format_valuetext(d, mode_cols, total, actortime and (d.value / actortime), win.metadata, true)
			end
		end
	end

	function mode_spell:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = L["actor absorb and heal spells"](label)
	end

	function mode_spell:Update(win, set)
		win.title = L["actor absorb and heal spells"](win.actorname or L["Unknown"])
		if not win.actorname then return end

		local actor = set and set:GetActor(win.actorid, win.actorname)
		local total = actor and actor:GetAbsorbHeal()

		if not total or total == 0 or not (actor.healspells or actor.absorbspells) then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local actortime = mode_cols.sHPS and actor:GetTime(set)

		local spells = actor.healspells -- heal spells
		if spells then
			for spellid, spell in pairs(spells) do
				nr = nr + 1

				local d = win:spell(nr, spellid, spell, nil, true)
				d.value = spell.amount
				format_valuetext(d, mode_cols, total, actortime and (d.value / actortime), win.metadata, true)
			end
		end

		spells = actor.absorbspells -- absorb spells
		if not spells then return end

		for spellid, spell in pairs(spells) do
			nr = nr + 1

			local d = win:spell(nr, spellid, spell)
			d.value = spell.amount
			format_valuetext(d, mode_cols, total, actortime and (d.value / actortime), win.metadata, true)
		end
	end

	function mode_target:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = uformat(L["%s's absorbed and healed targets"], label)
	end

	function mode_target:Update(win, set)
		win.title = uformat(L["%s's absorbed and healed targets"], win.actorname)

		local actor = set and set:GetActor(win.actorid, win.actorname)
		local total = actor and actor:GetAbsorbHeal()
		local targets = (total and total > 0) and actor:GetAbsorbHealTargets(set)

		if not targets then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local actortime = mode_cols.sAPS and actor:GetTime(set)

		for targetname, target in pairs(targets) do
			if target.amount > 0 then
				nr = nr + 1

				local d = win:actor(nr, target, target.enemy, targetname)
				d.value = target.amount
				format_valuetext(d, mode_cols, total, actortime and (d.value / actortime), win.metadata, true)
			end
		end
	end

	function mode:Update(win, set)
		win.title = win.class and format("%s (%s)", L["Absorbs and Healing"], L[win.class]) or L["Absorbs and Healing"]

		local total = set and set:GetAbsorbHeal(win.class)
		if not total or total == 0 then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local actors = set.actors

		for actorname, actor in pairs(actors) do
			if win:show_actor(actor, set, true) and (actor.absorb or actor.heal) then
				local hps, amount = actor:GetAHPS(set, nil, not mode_cols.HPS)
				if amount > 0 then
					nr = nr + 1

					local d = win:actor(nr, actor, actor.enemy)
					d.value = amount
					format_valuetext(d, mode_cols, total, hps, win.metadata)
					win:color(d, set, actor.enemy)
				end
			end
		end
	end

	function mode:GetSetSummary(set, win)
		if not set then return end
		local hps, amount = set:GetAHPS(win and win.class)
		local valuetext = Skada:FormatValueCols(
			self.metadata.columns.Healing and Skada:FormatNumber(amount),
			self.metadata.columns.HPS and Skada:FormatNumber(hps)
		)
		return amount, valuetext
	end

	function mode:AddToTooltip(set, tooltip)
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
		local actor = set and set:GetActor(Skada.userGUID, Skada.userName)
		if actor then
			return format("%s %s", Skada:FormatNumber((actor:GetAHPS(set))), L["HPS"])
		end
	end

	local function feed_raid_hps()
		local set = Skada:GetSet("current")
		return Skada:FormatNumber(set and set:GetAHPS() or 0) .. " " .. L["RHPS"]
	end

	function mode:OnEnable()
		mode_spell.metadata = {tooltip = mode_spell_tooltip}
		mode_target.metadata = {showspots = true, click1 = mode_target_spell}
		mode_cols = self.metadata.columns

		-- no total click.
		mode_spell.nototal = true
		mode_target.nototal = true

		Skada:AddFeed(L["Healing: Personal HPS"], feed_personal_hps)
		Skada:AddFeed(L["Healing: Raid HPS"], feed_raid_hps)

		Skada:AddMode(self, "Absorbs and Healing")
	end

	function mode:OnDisable()
		Skada:RemoveFeed(L["Healing: Personal HPS"])
		Skada:RemoveFeed(L["Healing: Raid HPS"])
		Skada:RemoveMode(self)
	end

	function mode:OnInitialize()
		self.metadata = {
			showspots = true,
			click1 = mode_spell,
			click2 = mode_target,
			click4 = Skada.FilterClass,
			click4_label = L["Toggle Class Filter"],
			post_tooltip = hps_tooltip,
			columns = {Healing = true, HPS = true, Percent = true, sHPS = false, sPercent = true},
			icon = [[Interface\Icons\spell_holy_healingfocus]]
		}
	end
end, "Absorbs", "Healing")

-- ============================== --
-- Healing done per second module --
-- ============================== --

Skada:RegisterModule("HPS", function(L, P)
	local mode = Skada:NewModule("HPS")
	local mode_cols = nil

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

		local actor = set:GetActor(id, label)
		if not actor then return end

		local totaltime = set:GetTime()
		local activetime = actor:GetTime(set, true)
		local hps, amount = actor:GetAHPS(set)

		tooltip:AddLine(actor.name .. " - " .. L["HPS"])
		tooltip:AddDoubleLine(L["Segment Time"], Skada:FormatTime(set:GetTime()), 1, 1, 1)
		tooltip:AddDoubleLine(L["Active Time"], Skada:FormatTime(activetime), 1, 1, 1)
		tooltip:AddDoubleLine(L["Absorbs and Healing"], Skada:FormatNumber(amount), 1, 1, 1)

		local suffix = Skada:FormatTime(P.timemesure == 1 and activetime or totaltime)
		tooltip:AddDoubleLine(Skada:FormatNumber(amount) .. "/" .. suffix, Skada:FormatNumber(hps), 1, 1, 1)
	end

	function mode:Update(win, set)
		win.title = win.class and format("%s (%s)", L["HPS"], L[win.class]) or L["HPS"]

		local total = set and set:GetAHPS(win.class)
		if not total or total == 0 then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local actors = set.actors

		for actorname, actor in pairs(actors) do
			if win:show_actor(actor, set, true) and (actor.absorb or actor.heal) then
				local amount = actor:GetAHPS(set, nil, not mode_cols.HPS)
				if amount > 0 then
					nr = nr + 1

					local d = win:actor(nr, actor, actor.enemy)
					d.value = amount
					format_valuetext(d, mode_cols, total, win.metadata)
					win:color(d, set, actor.enemy)
				end
			end
		end
	end

	function mode:GetSetSummary(set, win)
		local value =  set:GetAHPS(win and win.class)
		return value, Skada:FormatNumber(value)
	end

	function mode:OnEnable()
		self.metadata = {
			showspots = true,
			tooltip = hps_tooltip,
			click4 = Skada.FilterClass,
			click4_label = L["Toggle Class Filter"],
			columns = {HPS = true, Percent = true},
			icon = [[Interface\Icons\spell_nature_rejuvenation]]
		}

		mode_cols = self.metadata.columns

		local parent = Skada:GetModule("Absorbs and Healing", true)
		if parent and parent.metadata then
			self.metadata.click1 = parent.metadata.click1
			self.metadata.click2 = parent.metadata.click2
		end

		Skada:AddMode(self, "Absorbs and Healing")
	end

	function mode:OnDisable()
		Skada:RemoveMode(self)
	end
end, "Absorbs", "Healing", "Absorbs and Healing")

-- ===================== --
-- Healing done by spell --
-- ===================== --

Skada:RegisterModule("Healing Done By Spell", function(L, _, _, C)
	local mode = Skada:NewModule("Healing Done By Spell")
	local mode_source = mode:NewModule("Healing spell sources")
	local clear = Private.clearTable
	local get_absorb_heal_spells = nil
	local mode_cols = nil

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

	local function mode_source_tooltip(win, id, label, tooltip)
		local set = win.spellname and win:GetSelectedSet()
		local actor = set and set:GetActor(id, label)
		if not actor then return end

		local spell = actor.healspells and actor.healspells[win.spellid]
		spell = spell or actor.absorbspells and actor.absorbspells[win.spellid]
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

	function mode_source:Enter(win, id, label)
		win.spellid, win.spellname = id, label
		win.title = uformat(L["%s's sources"], label)
	end

	function mode_source:Update(win, set)
		win.title = uformat(L["%s's sources"], win.spellname)
		if not (win.spellid and set) then return end

		-- let's go...
		local total = 0
		local overheal = 0
		local sources = clear(C)

		local actors = set.actors
		for actorname, actor in pairs(actors) do
			if actor and not actor.enemy and (actor.absorbspells or actor.healspells) then
				local spell = actor.absorbspells and actor.absorbspells[win.spellid]
				spell = spell or actor.healspells and actor.healspells[win.spellid]
				if spell and spell.amount then
					sources[actorname] = new()
					sources[actorname].id = actor.id
					sources[actorname].class = actor.class
					sources[actorname].role = actor.role
					sources[actorname].spec = actor.spec
					sources[actorname].enemy = actor.enemy
					sources[actorname].amount = spell.amount
					sources[actorname].time = mode.metadata.columns.sHPS and actor:GetTime(set)
					-- calculate the total.
					total = total + spell.amount
					if spell.o_amt then
						overheal = overheal + spell.o_amt
					end
				end
			end
		end

		if total == 0 and overheal == 0 then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		for sourcename, source in pairs(sources) do
			nr = nr + 1

			local d = win:actor(nr, source, source.enemy, sourcename)
			d.value = source.amount
			format_valuetext(d, mode_cols, total, source.time and (d.value / source.time), win.metadata, true)
		end
	end

	function mode:Update(win, set)
		win.title = L["Healing Done By Spell"]
		local total = set and set:GetAbsorbHeal()
		local spells = (total and total > 0) and get_absorb_heal_spells(set)

		if not spells then
			return
		elseif win.metadata then
			win.metadata.maxvalue = 0
		end

		local nr = 0
		local settime = mode_cols.HPS and set:GetTime()

		for spellid, spell in pairs(spells) do
			nr = nr + 1

			local d = win:spell(nr, spellid, spell, nil, true)
			d.value = spell.amount
			format_valuetext(d, mode_cols, total, settime and (d.value / settime), win.metadata)
		end
	end

	function mode:OnEnable()
		mode_source.metadata = {showspots = true, tooltip = mode_source_tooltip}
		self.metadata = {
			click1 = mode_source,
			columns = {Healing = true, HPS = false, Percent = true, sHPS = false, sPercent = true},
			icon = [[Interface\Icons\spell_nature_healingwavelesser]]
		}
		mode_cols = self.metadata.columns
		Skada:AddMode(self, "Absorbs and Healing")
	end

	function mode:OnDisable()
		Skada:RemoveMode(self)
	end

	---------------------------------------------------------------------------

	local function fill_spells_table(t, spellid, info)
		if not info or not (info.amount or info.o_amt) then return end

		local spell = t[spellid]
		if not spell then
			spell = new()
			-- common
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
		if not self.actors or not (self.absorb or self.heal) then return end

		tbl = clear(tbl or C)
		for _, actor in pairs(self.actors) do
			if actor.healspells then
				for spellid, spell in pairs(actor.healspells) do
					fill_spells_table(tbl, spellid, spell)
				end
			end
			if actor.absorbspells then
				for spellid, spell in pairs(actor.absorbspells) do
					fill_spells_table(tbl, spellid, spell)
				end
			end
		end
		return tbl
	end
end, "Absorbs", "Healing")
