local Skada = Skada

-- cache frequently used globals
local pairs, select, wipe = pairs, select, wipe
local format, max, floor = string.format, math.max, math.floor
local UnitGUID, GetSpellInfo = UnitGUID, Skada.GetSpellInfo or GetSpellInfo
local _

-- ============== --
-- Absorbs module --
-- ============== --

Skada:AddLoadableModule("Absorbs", function(L)
	if Skada:IsDisabled("Absorbs") then return end

	local mod = Skada:NewModule(L["Absorbs"])
	local playermod = mod:NewModule(L["Absorb spell list"])
	local targetmod = mod:NewModule(L["Absorbed target list"])
	local spellmod = targetmod:NewModule(L["Absorb spell list"])
	local ignoredSpells = Skada.dummyTable -- Edit Skada\Core\Tables.lua

	local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER or 0x00000100
	local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_AFFILIATION_OUTSIDER or 0x00000008
	local COMBATLOG_OBJECT_REACTION_MASK = COMBATLOG_OBJECT_REACTION_MASK or 0x000000F0

	local GroupIterator = Skada.GroupIterator
	local UnitName, UnitExists, UnitBuff = UnitName, UnitExists, UnitBuff
	local UnitIsDeadOrGhost = UnitIsDeadOrGhost
	local GetTime, band, tsort = GetTime, bit.band, table.sort
	local T = Skada.Table
	local new, del = Skada.newTable, Skada.delTable

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
		[31000] = 300, -- Pendant of Shadow's End Usage
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

	local function log_spellcast(set, playerid, playername, playerflags, spellid, spellschool)
		local player = Skada:GetPlayer(set, playerid, playername, playerflags)
		if player and player.absorbspells and player.absorbspells[spellid] then
			player.absorbspells[spellid].casts = (player.absorbspells[spellid].casts or 1) + 1

			-- fix possible missing spell school.
			if not player.absorbspells[spellid].school and spellschool then
				player.absorbspells[spellid].school = spellschool
			end
		end
	end

	local function log_absorb(set, absorb, nocount)
		if not absorb.spellid then return end

		local player = Skada:GetPlayer(set, absorb.playerid, absorb.playername)
		if player then
			Skada:AddActiveTime(player, (player.role ~= "DAMAGER" and not nocount))

			-- add absorbs amount
			set.absorb = (set.absorb or 0) + absorb.amount
			player.absorb = (player.absorb or 0) + absorb.amount

			-- saving this to total set may become a memory hog deluxe.
			if set == Skada.total then return end

			-- record the spell
			local spell = player.absorbspells and player.absorbspells[absorb.spellid]
			if not spell then
				player.absorbspells = player.absorbspells or {}
				spell = {school = absorb.school, count = 1, amount = absorb.amount}
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
				local actor = Skada:GetActor(set, absorb.dstGUID, absorb.dstName, absorb.dstFlags)
				if actor then
					spell.targets = spell.targets or {}
					spell.targets[absorb.dstName] = (spell.targets[absorb.dstName] or 0) + absorb.amount
				end
			end
		end
	end

	-- https://github.com/TrinityCore/TrinityCore/blob/5d82995951c2be99b99b7b78fa12505952e86af7/src/server/game/Spells/Auras/SpellAuraEffects.h#L316
	local function ShieldsOrderPred(a, b)
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
				tsort(shields[dstName], ShieldsOrderPred)
				break
			end
		end
	end

	local function HandleShield(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellid = ...
		if not spellid or not absorbspells[spellid] or not dstName or ignoredSpells[spellid] then return end

		shields = shields or T.get("Skada_Shields") -- create global shields table

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

		-- complete data
		local spellschool
		spellid, _, spellschool = ...

		-- create player's shields table
		shields[dstName] = shields[dstName] or new()

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

			tsort(shields[dstName], ShieldsOrderPred)
		else
			local shield = new()
			shield.spellid = spellid
			shield.school = spellschool
			shield.srcGUID = srcGUID
			shield.srcName = srcName
			shield.srcFlags = srcFlags
			shield.ts = timestamp

			tinsert(shields[dstName], shield)
			tsort(shields[dstName], ShieldsOrderPred)
		end
	end

	do
		local function CheckUnitShields(unit, owner, timestamp, curtime)
			if not UnitIsDeadOrGhost(unit) then
				local dstName, dstGUID = UnitName(unit), UnitGUID(unit)
				for i = 1, 40 do
					local _, _, _, _, _, _, expires, unitCaster, _, _, spellid = UnitBuff(unit, i)
					if spellid then
						if absorbspells[spellid] and unitCaster then
							HandleShield(timestamp + expires - curtime, nil, UnitGUID(unitCaster), UnitName(unitCaster), nil, dstGUID, dstName, nil, spellid)
						end
					else
						break -- nothing found
					end
				end
			end
		end

		function mod:CheckPreShields(event, set, timestamp)
			if event == "COMBAT_PLAYER_ENTER" and set and not set.stopped and not self.checked then
				GroupIterator(CheckUnitShields, timestamp, GetTime())
				self.checked = true
			end
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

			Skada:DispatchSets(log_absorb, true, absorb)
		end
	end

	local function SpellDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellschool, amount, absorbed

		if eventtype == "SWING_DAMAGE" then
			amount, _, _, _, _, absorbed = ...
		else
			_, _, spellschool, amount, _, _, _, _, absorbed = ...
		end

		if (absorbed or 0) > 0 and dstName and shields and shields[dstName] then
			process_absorb(dstGUID, dstName, dstFlags, absorbed, spellschool or 1, amount)
		end
	end

	local function SpellMissed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellschool, misstype, absorbed

		if eventtype == "SWING_MISSED" then
			misstype, _, absorbed = ...
		else
			_, _, spellschool, misstype, _, absorbed = ...
		end

		if misstype == "ABSORB" and (absorbed or 0) > 0 and dstName and shields and shields[dstName] then
			process_absorb(dstGUID, dstName, dstFlags, absorbed, spellschool or 1, 0)
		end
	end

	local function EnvironmentDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local envtype, amount, _, _, _, _, absorbed = ...
		if (absorbed or 0) > 0 and dstName and shields and shields[dstName] then
			local spellschool = 0x01

			if envtype == "Fire" or envtype == "FIRE" then
				spellschool = 0x04
			elseif envtype == "Lava" or envtype == "LAVA" then
				spellschool = 0x04
			elseif envtype == "Slime" or envtype == "SLIME" then
				spellschool = 0x08
			end

			process_absorb(dstGUID, dstName, dstFlags, absorbed, spellschool, amount)
		end
	end

	local function playermod_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local spell = actor and actor.absorbspells and actor.absorbspells[id]
		if spell then
			tooltip:AddLine(actor.name .. " - " .. label)
			if spell.school and Skada.spellschools[spell.school] then
				tooltip:AddLine(
					Skada.spellschools[spell.school].name,
					Skada.spellschools[spell.school].r,
					Skada.spellschools[spell.school].g,
					Skada.spellschools[spell.school].b
				)
			end

			if (spell.casts or 0) > 0 then
				tooltip:AddDoubleLine(L["Casts"], spell.casts, 1, 1, 1)
			end

			if (spell.count or 0) > 0 then
				tooltip:AddDoubleLine(L["Hits"], spell.count, 1, 1, 1)
				tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(spell.amount / spell.count), 1, 1, 1)
			end

			if spell.min and spell.max then
				tooltip:AddLine(" ")
				tooltip:AddDoubleLine(L["Minimum Hit"], Skada:FormatNumber(spell.min), 1, 1, 1)
				tooltip:AddDoubleLine(L["Maximum Hit"], Skada:FormatNumber(spell.max), 1, 1, 1)
				tooltip:AddDoubleLine(L["Average Hit"], Skada:FormatNumber((spell.min + spell.max) / 2), 1, 1, 1)
			end
		end
	end

	function spellmod:Enter(win, id, label)
		win.targetid, win.targetname = id, label
		win.title = L["actor absorb spells"](win.actorname or L.Unknown, label)
	end

	function spellmod:Update(win, set)
		win.title = L["actor absorb spells"](win.actorname or L.Unknown, win.targetname or L.Unknown)
		if not set or not win.targetname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local total = actor and actor.absorb or 0
		if total > 0 and actor.absorbspells then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local actortime, nr = mod.metadata.columns.sAPS and actor:GetTime(), 0
			for spellid, spell in pairs(actor.absorbspells) do
				if spell.targets and spell.targets[win.targetname] then
					nr = nr + 1

					local d = win.dataset[nr] or {}
					win.dataset[nr] = d

					d.id = spellid
					d.spellid = spellid
					d.spellschool = spell.school
					d.label, _, d.icon = GetSpellInfo(spellid)

					d.value = spell.targets[win.targetname]
					d.valuetext = Skada:FormatValueCols(
						mod.metadata.columns.Absorbs and Skada:FormatNumber(d.value),
						actortime and Skada:FormatNumber(d.value / actortime),
						mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
					)

					if win.metadata and d.value > win.metadata.maxvalue then
						win.metadata.maxvalue = d.value
					end
				end
			end
		end
	end

	function playermod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = L["actor absorb spells"](label)
	end

	function playermod:Update(win, set)
		win.title = L["actor absorb spells"](win.actorname or L.Unknown)
		if not set or not win.actorname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local total = actor and actor.absorb or 0
		if total > 0 and actor.absorbspells then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local actortime, nr = mod.metadata.columns.sAPS and actor:GetTime(), 0
			for spellid, spell in pairs(actor.absorbspells) do
				nr = nr + 1

				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.id = spellid
				d.spellid = spellid
				d.spellschool = spell.school
				d.label, _, d.icon = GetSpellInfo(spellid)

				d.value = spell.amount
				d.valuetext = Skada:FormatValueCols(
					mod.metadata.columns.Absorbs and Skada:FormatNumber(d.value),
					actortime and Skada:FormatNumber(d.value / actortime),
					mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
				)

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function targetmod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = format(L["%s's absorbed targets"], label)
	end

	function targetmod:Update(win, set)
		win.title = format(L["%s's absorbed targets"], win.actorname or L.Unknown)
		if not set or not win.actorname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local total = actor and actor.absorb or 0
		local targets = (total > 0) and actor:GetAbsorbTargets()

		if targets then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local actortime, nr = mod.metadata.columns.sAPS and actor:GetTime(), 0
			for targetname, target in pairs(targets) do
				nr = nr + 1

				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.id = target.id or targetname
				d.label = targetname
				d.text = target.id and Skada:FormatName(targetname, target.id)
				d.class = target.class
				d.role = target.role
				d.spec = target.spec

				d.value = target.amount
				d.valuetext = Skada:FormatValueCols(
					mod.metadata.columns.Absorbs and Skada:FormatNumber(d.value),
					actortime and Skada:FormatNumber(d.value / actortime),
					mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
				)

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function mod:Update(win, set)
		win.title = win.class and format("%s (%s)", L["Absorbs"], L[win.class]) or L["Absorbs"]

		local total = set and set:GetAbsorb() or 0
		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0

			-- players
			for i = 1, #set.players do
				local player = set.players[i]
				if player and (not win.class or win.class == player.class) then
					local aps, amount = player:GetAPS()
					if amount > 0 then
						nr = nr + 1

						local d = win.dataset[nr] or {}
						win.dataset[nr] = d

						d.id = player.id or player.name
						d.label = player.name
						d.text = player.id and Skada:FormatName(player.name, player.id)
						d.class = player.class
						d.role = player.role
						d.spec = player.spec

						if Skada.forPVP and set.type == "arena" then
							d.color = Skada:ClassColor(set.gold and "ARENA_GOLD" or "ARENA_GREEN")
						end

						d.value = amount
						d.valuetext = Skada:FormatValueCols(
							self.metadata.columns.Absorbs and Skada:FormatNumber(d.value),
							self.metadata.columns.APS and  Skada:FormatNumber(aps),
							self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
						)

						if win.metadata and d.value > win.metadata.maxvalue then
							win.metadata.maxvalue = d.value
						end
					end
				end
			end

			-- arena enemies
			if Skada.forPVP and set.type == "arena" and set.enemies then
				for i = 1, #set.enemies do
					local enemy = set.enemies[i]
					if enemy and not enemy.fake and (not win.class or win.class == enemy.class) then
						local aps, amount = enemy:GetAPS()
						if amount > 0 then
							nr = nr + 1

							local d = win.dataset[nr] or {}
							win.dataset[nr] = d

							d.id = enemy.id or enemy.name
							d.label = enemy.name
							d.text = nil
							d.class = enemy.class
							d.role = enemy.role
							d.spec = enemy.spec
							d.color = Skada:ClassColor(set.gold and "ARENA_GREEN" or "ARENA_GOLD")

							d.value = amount
							d.valuetext = Skada:FormatValueCols(
								self.metadata.columns.Absorbs and Skada:FormatNumber(d.value),
								self.metadata.columns.APS and  Skada:FormatNumber(aps),
								self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
							)

							if win.metadata and d.value > win.metadata.maxvalue then
								win.metadata.maxvalue = d.value
							end
						end
					end
				end
			end
		end
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
			columns = {Absorbs = true, APS = true, Percent = true, sAPS = false, sPercent = true},
			icon = [[Interface\Icons\spell_holy_powerwordshield]]
		}

		-- no total click.
		playermod.nototal = true
		targetmod.nototal = true

		local flags_src = {src_is_interesting_nopets = true}

		Skada:RegisterForCL(
			HandleShield,
			"SPELL_AURA_APPLIED",
			"SPELL_AURA_REFRESH",
			"SPELL_AURA_REMOVED",
			flags_src
		)

		local flags_dst = {dst_is_interesting_nopets = true}

		Skada:RegisterForCL(
			SpellDamage,
			"DAMAGE_SHIELD",
			"SPELL_DAMAGE",
			"SPELL_PERIODIC_DAMAGE",
			"SPELL_BUILDING_DAMAGE",
			"RANGE_DAMAGE",
			"SWING_DAMAGE",
			flags_dst
		)

		Skada:RegisterForCL(
			EnvironmentDamage,
			"ENVIRONMENTAL_DAMAGE",
			flags_dst
		)

		Skada:RegisterForCL(
			SpellMissed,
			"SPELL_MISSED",
			"SPELL_PERIODIC_MISSED",
			"SPELL_BUILDING_MISSED",
			"RANGE_MISSED",
			"SWING_MISSED",
			flags_dst
		)

		Skada.RegisterMessage(self, "COMBAT_PLAYER_ENTER", "CheckPreShields")
		Skada:AddMode(self, L["Absorbs and Healing"])

		-- table of ignored spells:
		if Skada.ignoredSpells and Skada.ignoredSpells.absorbs then
			ignoredSpells = Skada.ignoredSpells.absorbs
		end
	end

	function mod:OnDisable()
		Skada.UnregisterAllMessages(self)
		Skada:RemoveMode(self)
	end

	function mod:GetSetSummary(set)
		if not set then return end
		local aps, amount = set:GetAPS()
		return Skada:FormatValueCols(
			self.metadata.columns.Absorbs and Skada:FormatNumber(amount),
			self.metadata.columns.APS and Skada:FormatNumber(aps)
		), amount
	end

	function mod:SetComplete(set)
		T.clear(absorb)
		T.free("Skada_Shields", shields, nil, del)
		self.checked = nil
		-- clean absorbspells table:
		if (set.absorb or 0) == 0 then return end
		for i = 1, #set.players do
			local p = set.players[i]
			if p and p.absorb == 0 then
				p.absorbspells = nil
			elseif p and p.absorbspells then
				for spellid, spell in pairs(p.absorbspells) do
					if spell.amount == 0 then
						p.absorbspells[spellid] = nil
					end
				end
				if next(p.absorbspells) == nil then
					p.absorbspells = nil
				end
			end
		end
	end
end)

-- ========================== --
-- Absorbs and healing module --
-- ========================== --

Skada:AddLoadableModule("Absorbs and Healing", function(L)
	if Skada:IsDisabled("Healing", "Absorbs", "Absorbs and Healing") then return end

	local mod = Skada:NewModule(L["Absorbs and Healing"])
	local playermod = mod:NewModule(L["Absorbs and healing spells"])
	local targetmod = mod:NewModule(L["Absorbed and healed targets"])
	local spellmod = targetmod:NewModule(L["Absorbs and healing spells"])

	local function hps_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set then return end

		local actor, enemy = set:GetActor(label, id)
		if actor then
			local totaltime = set:GetTime()
			local activetime = actor:GetTime(true)
			local hps, amount = actor:GetAHPS()

			tooltip:AddDoubleLine(L["Activity"], Skada:FormatPercent(activetime, totaltime), nil, nil, nil, 1, 1, 1)
			tooltip:AddDoubleLine(L["Segment Time"], Skada:FormatTime(set:GetTime()), 1, 1, 1)
			tooltip:AddDoubleLine(L["Active Time"], Skada:FormatTime(activetime), 1, 1, 1)
			tooltip:AddDoubleLine(L["Absorbs and Healing"], Skada:FormatNumber(amount), 1, 1, 1)

			local suffix = Skada:FormatTime(Skada.db.profile.timemesure == 1 and activetime or totaltime)
			tooltip:AddDoubleLine(Skada:FormatNumber(amount) .. "/" .. suffix, Skada:FormatNumber(hps), 1, 1, 1)
		end
	end

	local function playermod_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set or not win.actorname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if not actor then return end

		local spell = actor.absorbspells and actor.absorbspells[id] -- absorb?
		spell = spell or actor.healspells and actor.healspells[id] -- heal?

		if spell then
			tooltip:AddLine(actor.name .. " - " .. label)
			if spell.school and Skada.spellschools[spell.school] then
				tooltip:AddLine(
					Skada.spellschools[spell.school].name,
					Skada.spellschools[spell.school].r,
					Skada.spellschools[spell.school].g,
					Skada.spellschools[spell.school].b
				)
			end

			if enemy then
				tooltip:AddDoubleLine(L["Amount"], spell.amount, 1, 1, 1)
				return
			end

			if (spell.casts or 0) > 0 then
				tooltip:AddDoubleLine(L["Casts"], spell.casts, 1, 1, 1)
			end

			if (spell.count or 0) > 0 then
				tooltip:AddDoubleLine(L["Hits"], spell.count, 1, 1, 1)
				tooltip:AddDoubleLine(L["Average"], Skada:FormatNumber(spell.amount / spell.count), 1, 1, 1)

				if (spell.critical or 0) > 0 then
					tooltip:AddDoubleLine(L["Critical"], Skada:FormatPercent(spell.critical, spell.count), 1, 1, 1)
				end
			end

			if (spell.overheal or 0) > 0 then
				tooltip:AddLine(" ")
				tooltip:AddDoubleLine(L["Total Healing"], Skada:FormatNumber(spell.overheal + spell.amount), 1, 1, 1)
				tooltip:AddDoubleLine(L["Overheal"], format("%s (%s)", Skada:FormatNumber(spell.overheal), Skada:FormatPercent(spell.overheal, spell.overheal + spell.amount)), 1, 1, 1)
			end

			if spell.min and spell.max then
				local spellmin = spell.min
				if spell.criticalmin and spell.criticalmin < spellmin then
					spellmin = spell.criticalmin
				end
				local spellmax = spell.max
				if spell.criticalmax and spell.criticalmax > spellmax then
					spellmax = spell.criticalmax
				end
				tooltip:AddLine(" ")
				tooltip:AddDoubleLine(L["Minimum Hit"], Skada:FormatNumber(spellmin), 1, 1, 1)
				tooltip:AddDoubleLine(L["Maximum Hit"], Skada:FormatNumber(spellmax), 1, 1, 1)
				tooltip:AddDoubleLine(L["Average Hit"], Skada:FormatNumber((spellmin + spellmax) / 2), 1, 1, 1)
			end
		end
	end

	function spellmod:Enter(win, id, label)
		win.targetid, win.targetname = id, label
		win.title = L["actor absorb and heal spells"](win.actorname or L.Unknown, label)
	end

	function spellmod:Update(win, set)
		win.title = L["actor absorb and heal spells"](win.actorname or L.Unknown, win.targetname or L.Unknown)
		if not set or not win.targetname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		local total = actor and actor:GetAbsorbHealOnTarget(win.targetname) or 0

		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local actortime, nr = mod.metadata.columns.sHPS and actor:GetTime(), 0

			if actor.healspells then
				for spellid, spell in pairs(actor.healspells) do
					if spell.targets and spell.targets[win.targetname] then
						nr = nr + 1

						local d = win.dataset[nr] or {}
						win.dataset[nr] = d

						d.id = spellid
						d.spellid = spellid
						d.spellschool = spell.school
						d.label, _, d.icon = GetSpellInfo(spellid)

						if spell.ishot then
							d.text = d.label .. L["HoT"]
						end

						if enemy then
							d.value = spell.targets[win.targetname]
						else
							d.value = spell.targets[win.targetname].amount or 0
						end

						d.valuetext = Skada:FormatValueCols(
							mod.metadata.columns.Healing and Skada:FormatNumber(d.value),
							actortime and Skada:FormatNumber(d.value / actortime),
							mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
						)

						if win.metadata and d.value > win.metadata.maxvalue then
							win.metadata.maxvalue = d.value
						end
					end
				end
			end

			if actor.absorbspells then
				for spellid, spell in pairs(actor.absorbspells) do
					if spell.targets and spell.targets[win.targetname] then
						nr = nr + 1

						local d = win.dataset[nr] or {}
						win.dataset[nr] = d

						d.id = spellid
						d.spellid = spellid
						d.spellschool = spell.school
						d.label, _, d.icon = GetSpellInfo(spellid)

						d.value = spell.targets[win.targetname] or 0
						d.valuetext = Skada:FormatValueCols(
							mod.metadata.columns.Healing and Skada:FormatNumber(d.value),
							actortime and Skada:FormatNumber(d.value / actortime),
							mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
						)

						if win.metadata and d.value > win.metadata.maxvalue then
							win.metadata.maxvalue = d.value
						end
					end
				end
			end
		end
	end

	function playermod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = L["actor absorb and heal spells"](label)
	end

	function playermod:Update(win, set)
		win.title = L["actor absorb and heal spells"](win.actorname or L.Unknown)
		if not win.actorname then return end

		local actor = set and set:GetActor(win.actorname, win.actorid)
		local total = actor and actor:GetAbsorbHeal() or 0

		if total > 0 and (actor.healspells or actor.absorbspells) then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local actortime, nr = mod.metadata.columns.sHPS and actor:GetTime(), 0

			if actor.healspells then
				for spellid, spell in pairs(actor.healspells) do
					nr = nr + 1

					local d = win.dataset[nr] or {}
					win.dataset[nr] = d

					d.id = spellid
					d.spellid = spellid
					d.spellschool = spell.school
					d.label, _, d.icon = GetSpellInfo(spellid)

					if spell.ishot then
						d.text = d.label .. L["HoT"]
					end

					d.value = spell.amount
					d.valuetext = Skada:FormatValueCols(
						mod.metadata.columns.Healing and Skada:FormatNumber(d.value),
						actortime and Skada:FormatNumber(d.value / actortime),
						mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
					)

					if win.metadata and d.value > win.metadata.maxvalue then
						win.metadata.maxvalue = d.value
					end
				end
			end

			if actor.absorbspells then
				for spellid, spell in pairs(actor.absorbspells) do
					nr = nr + 1

					local d = win.dataset[nr] or {}
					win.dataset[nr] = d

					d.id = spellid
					d.spellid = spellid
					d.spellschool = spell.school
					d.label, _, d.icon = GetSpellInfo(spellid)

					d.value = spell.amount
					d.valuetext = Skada:FormatValueCols(
						mod.metadata.columns.Healing and Skada:FormatNumber(d.value),
						actortime and Skada:FormatNumber(d.value / actortime),
						mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
					)

					if win.metadata and d.value > win.metadata.maxvalue then
						win.metadata.maxvalue = d.value
					end
				end
			end
		end
	end

	function targetmod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = format(L["%s's absorbed and healed targets"], label)
	end

	function targetmod:Update(win, set)
		win.title = format(L["%s's absorbed and healed targets"], win.actorname or L.Unknown)

		local actor = set and set:GetActor(win.actorname, win.actorid)
		local total = actor and actor:GetAbsorbHeal() or 0
		local targets = (total > 0) and actor:GetAbsorbHealTargets()

		if targets then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local actortime, nr = mod.metadata.columns.sHPS and actor:GetTime(), 0
			for targetname, target in pairs(targets) do
				if target.amount > 0 then
					nr = nr + 1

					local d = win.dataset[nr] or {}
					win.dataset[nr] = d

					d.id = target.id or targetname
					d.label = targetname
					d.class = target.class
					d.role = target.role
					d.spec = target.spec

					d.value = target.amount
					d.valuetext = Skada:FormatValueCols(
						mod.metadata.columns.Healing and Skada:FormatNumber(d.value),
						actortime and Skada:FormatNumber(d.value / actortime),
						mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
					)

					if win.metadata and d.value > win.metadata.maxvalue then
						win.metadata.maxvalue = d.value
					end
				end
			end
		end
	end

	function mod:Update(win, set)
		win.title = win.class and format("%s (%s)", L["Absorbs and Healing"], L[win.class]) or L["Absorbs and Healing"]

		local total = set and set:GetAbsorbHeal() or 0
		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0

			-- players
			for i = 1, #set.players do
				local player = set.players[i]
				if player and (not win.class or win.class == player.class) then
					local hps, amount = player:GetAHPS()

					if amount > 0 then
						nr = nr + 1

						local d = win.dataset[nr] or {}
						win.dataset[nr] = d

						d.id = player.id or player.name
						d.label = player.name
						d.text = player.id and Skada:FormatName(player.name, player.id)
						d.class = player.class
						d.role = player.role
						d.spec = player.spec

						if Skada.forPVP and set.type == "arena" then
							d.color = Skada:ClassColor(set.gold and "ARENA_GOLD" or "ARENA_GREEN")
						end

						d.value = amount
						d.valuetext = Skada:FormatValueCols(
							self.metadata.columns.Healing and Skada:FormatNumber(d.value),
							self.metadata.columns.HPS and Skada:FormatNumber(hps),
							self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
						)

						if win.metadata and d.value > win.metadata.maxvalue then
							win.metadata.maxvalue = d.value
						end
					end
				end
			end

			-- arena enemies
			if Skada.forPVP and set.type == "arena" and set.enemies and set.GetEnemyHeal then
				for i = 1, #set.enemies do
					local enemy = set.enemies[i]
					if enemy and not enemy.fake and (not win.class or win.class == enemy.class) then
						local hps, amount = enemy:GetAHPS()

						if amount > 0 then
							nr = nr + 1

							local d = win.dataset[nr] or {}
							win.dataset[nr] = d

							d.id = enemy.id or enemy.name
							d.label = enemy.name
							d.text = nil
							d.class = enemy.class
							d.role = enemy.role
							d.spec = enemy.spec
							d.color = Skada:ClassColor(set.gold and "ARENA_GREEN" or "ARENA_GOLD")

							d.value = amount
							d.valuetext = Skada:FormatValueCols(
								self.metadata.columns.Healing and Skada:FormatNumber(d.value),
								self.metadata.columns.HPS and Skada:FormatNumber(hps),
								self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
							)

							if win.metadata and d.value > win.metadata.maxvalue then
								win.metadata.maxvalue = d.value
							end
						end
					end
				end
			end
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

	function mod:AddToTooltip(set, tooltip)
		if not set then return end
		local hps, amount = set:GetAHPS()
		if amount > 0 then
			tooltip:AddDoubleLine(L["Healing"], Skada:FormatNumber(amount), 1, 1, 1)
			tooltip:AddDoubleLine(L["HPS"], Skada:FormatNumber(hps), 1, 1, 1)
		end
		if (set.overheal or 0) > 0 then
			amount = amount + set.overheal
			tooltip:AddDoubleLine(L["Overheal"], Skada:FormatPercent(set.overheal, amount), 1, 1, 1)
		end
	end

	function mod:GetSetSummary(set)
		if not set then return end
		local hps, amount = set:GetAHPS()
		return Skada:FormatValueCols(
			self.metadata.columns.Healing and Skada:FormatNumber(amount),
			self.metadata.columns.HPS and Skada:FormatNumber(hps)
		), amount
	end
end)

-- ============================== --
-- Healing done per second module --
-- ============================== --

Skada:AddLoadableModule("HPS", function(L)
	if Skada:IsDisabled("Absorbs", "Healing", "Absorbs and Healing", "HPS") then return end

	local mod = Skada:NewModule(L["HPS"])

	local function hps_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		if not set then return end

		local actor, enemy = set:GetActor(label, id)
		if actor then
			local totaltime = set:GetTime()
			local activetime = actor:GetTime(true)
			local hps, amount = actor:GetAHPS()

			tooltip:AddLine(actor.name .. " - " .. L["HPS"])
			tooltip:AddDoubleLine(L["Segment Time"], Skada:FormatTime(set:GetTime()), 1, 1, 1)
			tooltip:AddDoubleLine(L["Active Time"], Skada:FormatTime(activetime), 1, 1, 1)
			tooltip:AddDoubleLine(L["Absorbs and Healing"], Skada:FormatNumber(amount), 1, 1, 1)

			local suffix = Skada:FormatTime(Skada.db.profile.timemesure == 1 and activetime or totaltime)
			tooltip:AddDoubleLine(Skada:FormatNumber(amount) .. "/" .. suffix, Skada:FormatNumber(hps), 1, 1, 1)
		end
	end

	function mod:Update(win, set)
		win.title = win.class and format("%s (%s)", L["HPS"], L[win.class]) or L["HPS"]

		local total = set and set:GetAHPS() or 0
		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0

			-- players
			for i = 1, #set.players do
				local player = set.players[i]
				if player and (not win.class or win.class == player.class) then
					local amount = player:GetAHPS()
					if amount > 0 then
						nr = nr + 1

						local d = win.dataset[nr] or {}
						win.dataset[nr] = d

						d.id = player.id or player.name
						d.label = player.name
						d.text = player.id and Skada:FormatName(player.name, player.id)
						d.class = player.class
						d.role = player.role
						d.spec = player.spec

						if Skada.forPVP and set.type == "arena" then
							d.color = Skada:ClassColor(set.gold and "ARENA_GOLD" or "ARENA_GREEN")
						end

						d.value = amount
						d.valuetext = Skada:FormatValueCols(
							self.metadata.columns.HPS and Skada:FormatNumber(d.value),
							self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
						)

						if win.metadata and d.value > win.metadata.maxvalue then
							win.metadata.maxvalue = d.value
						end
					end
				end
			end

			-- arena enemies
			if Skada.forPVP and set.type == "arena" and set.enemies and set.GetEnemyHeal then
				for i = 1, #set.enemies do
					local enemy = set.enemies[i]
					if enemy and not enemy.fake and (not win.class or win.class == enemy.class) then
						local amount = enemy:GetHPS()
						if amount > 0 then
							nr = nr + 1

							local d = win.dataset[nr] or {}
							win.dataset[nr] = d

							d.id = enemy.id or enemy.name
							d.label = enemy.name
							d.text = nil
							d.class = enemy.class
							d.role = enemy.role
							d.spec = enemy.spec
							d.color = Skada:ClassColor(set.gold and "ARENA_GREEN" or "ARENA_GOLD")

							d.value = amount
							d.valuetext = Skada:FormatValueCols(
								self.metadata.columns.HPS and Skada:FormatNumber(d.value),
								self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
							)

							if win.metadata and d.value > win.metadata.maxvalue then
								win.metadata.maxvalue = d.value
							end
						end
					end
				end
			end
		end
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

		local parentmod = Skada:GetModule(L["Absorbs and Healing"], true)
		if parentmod then
			self.metadata.click1 = parentmod.metadata.click1
			self.metadata.click2 = parentmod.metadata.click2
		end

		Skada:AddMode(self, L["Absorbs and Healing"])
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end

	function mod:GetSetSummary(set)
		return Skada:FormatNumber(set and set:GetAHPS() or 0)
	end
end)

-- ===================== --
-- Healing done by spell --
-- ===================== --

Skada:AddLoadableModule("Healing Done By Spell", function(L)
	if Skada:IsDisabled("Healing", "Absorbs", "Healing Done By Spell") then return end

	local mod = Skada:NewModule(L["Healing Done By Spell"])
	local spellmod = mod:NewModule(L["Healing spell sources"])
	local cacheTable = Skada.cacheTable

	local function spell_tooltip(win, id, label, tooltip)
		local set = win:GetSelectedSet()
		local total = set and set:GetAbsorbHeal() or 0
		if total == 0 then return end

		wipe(cacheTable)
		for i = 1, #set.players do
			local p = set.players[i]
			local spell = p and ((p.absorbspells and p.absorbspells[id]) or (p.healspells and p.healspells[id])) or nil
			if spell then
				if not cacheTable[id] then
					cacheTable[id] = {school = spell.school, amount = spell.amount, overheal = spell.overheal}
					cacheTable[id].isabsorb = (p.absorbspells and p.absorbspells[id])
				else
					cacheTable[id].amount = cacheTable[id].amount + spell.amount
					if spell.overheal then
						cacheTable[id].overheal = (cacheTable[id].overheal or 0) + spell.overheal
					end
				end
			end
		end

		local spell = cacheTable[id]
		if spell then
			tooltip:AddLine(GetSpellInfo(id))
			if spell.school and Skada.spellschools[spell.school] then
				tooltip:AddLine(
					Skada.spellschools[spell.school].name,
					Skada.spellschools[spell.school].r,
					Skada.spellschools[spell.school].g,
					Skada.spellschools[spell.school].b
				)
			end

			if (spell.casts or 0) > 0 then
				tooltip:AddDoubleLine(L["Casts"], spell.casts, 1, 1, 1)
			end

			if (spell.count or 0) > 0 then
				tooltip:AddDoubleLine(L["Hits"], spell.count, 1, 1, 1)
			end
			tooltip:AddDoubleLine(spell.isabsorb and L["Absorbs"] or L["Healing"], format("%s (%s)", Skada:FormatNumber(spell.amount), Skada:FormatPercent(spell.amount, total)), 1, 1, 1)
			if set.overheal and (spell.overheal or 0) > 0 then
				tooltip:AddDoubleLine(L["Overheal"], format("%s (%s)", Skada:FormatNumber(spell.overheal), Skada:FormatPercent(spell.overheal, set.overheal)), 1, 1, 1)
			end
		end
	end

	function spellmod:Enter(win, id, label)
		win.spellid, win.spellname = id, label
		win.title = format(L["%s's sources"], label)
	end

	function spellmod:Update(win, set)
		win.title = format(L["%s's sources"], win.spellname or L.Unknown)
		if not (win.spellid and set) then return end

		-- let's go...
		wipe(cacheTable)
		local total = 0

		for i = 1, #set.players do
			local p = set.players[i]
			local spell = p and ((p.absorbspells and p.absorbspells[win.spellid]) or (p.healspells and p.healspells[win.spellid])) or nil
			if spell then
				cacheTable[p.name] = {
					id = p.id,
					class = p.class,
					role = p.role,
					spec = p.spec,
					amount = spell.amount,
					time = mod.metadata.columns.sHPS and p:GetTime()
				}
				-- calculate the total.
				total = total + spell.amount
			end
		end

		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for playername, player in pairs(cacheTable) do
				nr = nr + 1

				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.id = player.id or playername
				d.label = playername
				d.text = player.id and Skada:FormatName(playername, player.id)
				d.class = player.class
				d.role = player.role
				d.spec = player.spec

				d.value = player.amount
				d.valuetext = Skada:FormatValueCols(
					mod.metadata.columns.Healing and Skada:FormatNumber(d.value),
					player.time and Skada:FormatNumber(d.value / player.time),
					mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
				)

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function mod:Update(win, set)
		win.title = L["Healing Done By Spell"]
		local total = set and set:GetAbsorbHeal() or 0
		local spells = (total > 0) and set:GetAbsorbHealSpells()

		if spells then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local settime, nr = self.metadata.columns.HPS and set:GetTime(), 0
			for spellid, spell in pairs(spells) do
				nr = nr + 1

				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.id = spellid
				d.spellid = spellid
				d.spellschool = spell.school
				d.label, _, d.icon = GetSpellInfo(spellid)

				if spell.ishot then
					d.text = d.label .. L["HoT"]
				end

				d.value = spell.amount
				d.valuetext = Skada:FormatValueCols(
					self.metadata.columns.Healing and Skada:FormatNumber(d.value),
					settime and Skada:FormatNumber(d.value / settime),
					self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
				)

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function mod:OnEnable()
		spellmod.metadata = {showspots = true}
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

	local setPrototype = Skada.setPrototype

	function setPrototype:GetAbsorbHealSpells(tbl)
		if (self.absorb or self.heal) and self.players then
			tbl = wipe(tbl or cacheTable)
			for i = 1, #self.players do
				local player = self.players[i]
				if player and player.healspells then
					for spellid, spell in pairs(player.healspells) do
						if not tbl[spellid] then
							tbl[spellid] = {school = spell.school, amount = spell.amount, overheal = spell.overheal}
						else
							tbl[spellid].amount = tbl[spellid].amount + spell.amount
							if spell.overheal then
								tbl[spellid].overheal = (tbl[spellid].overheal or 0) + spell.overheal
							end
						end
					end
				end
				if player and player.absorbspells then
					for spellid, spell in pairs(player.absorbspells) do
						if not tbl[spellid] then
							tbl[spellid] = {school = spell.school, amount = spell.amount}
						else
							tbl[spellid].amount = tbl[spellid].amount + spell.amount
						end
					end
				end
			end
		end

		return tbl
	end
end)