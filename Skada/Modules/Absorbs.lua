local Skada = Skada

-- cache frequently used globals
local pairs, ipairs, select, format, wipe = pairs, ipairs, select, string.format, wipe
local max, min, floor = math.max, math.min, math.floor
local GetSpellInfo = Skada.GetSpellInfo or GetSpellInfo
local UnitGUID, UnitClass, unitClass = UnitGUID, UnitClass, Skada.unitClass
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

	local LGT = LibStub("LibGroupTalents-1.0")

	local GroupIterator = Skada.GroupIterator
	local UnitName, UnitExists, UnitBuff = UnitName, UnitExists, UnitBuff
	local UnitIsDeadOrGhost, UnitHealthInfo = UnitIsDeadOrGhost, Skada.UnitHealthInfo
	local GetTime, band = GetTime, bit.band
	local tsort, tContains = table.sort, tContains
	local T = Skada.Table

	local shields = nil -- holds the list of players shields and other stuff
	local shieldamounts = nil -- holds the amount shields absorbed so far
	local shieldspopped = nil -- holds the list of shields that popped on a player
	local absorb = {}

	-- spells in the following table will be ignored.
	local ignoredSpells = {}

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
	-- Note: this order is reversed
	local function SortShields(a, b)
		local a_spellid, b_spellid = a.spellid, b.spellid

		if a_spellid == b_spellid then
			return (a.ts > b.ts)
		end

		-- Twin Val'ky
		if a_spellid == 65686 then
			return false
		end
		if b_spellid == 65686 then
			return true
		end
		if a_spellid == 65684 then
			return false
		end
		if b_spellid == 65684 then
			return true
		end

		-- Mage Ward
		if a_spellid == 543 then
			return false
		end
		if b_spellid == 543 then
			return true
		end

		-- Shadow Ward
		if a_spellid == 6229 then
			return false
		end
		if b_spellid == 6229 then
			return true
		end

		-- Sacred Shield
		if a_spellid == 58597 then
			return false
		end
		if b_spellid == 58597 then
			return true
		end

		-- Fel Blossom
		if a_spellid == 28527 then
			return false
		end
		if b_spellid == 28527 then
			return true
		end

		-- Divine Aegis
		if a_spellid == 47753 then
			return false
		end
		if b_spellid == 47753 then
			return true
		end

		-- Ice Barrier
		if a_spellid == 11426 then
			return false
		end
		if b_spellid == 11426 then
			return true
		end

		-- Sacrifice
		if a_spellid == 7812 then
			return false
		end
		if b_spellid == 7812 then
			return true
		end

		-- Will of the Necropolis
		if a_spellid == 81164 then
			return false
		end
		if b_spellid == 81164 then
			return true
		end

		-- Ardent Defender
		if a_spellid == 31850 then
			return false
		end
		if b_spellid == 31850 then
			return true
		end

		-- Hardened Skin (Corroded Skeleton Key)
		if a_spellid == 71586 then
			return false
		end
		if b_spellid == 71586 then
			return true
		end

		return (a.ts > b.ts)
	end

	local function HandleShield(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		-- shield removed?
		if eventtype == "SPELL_AURA_REMOVED" then
			local spellid, _, _, _, amount = ...
			if amount ~= nil and shields[dstName] and shields[dstName][spellid] and shields[dstName][spellid][srcName] then
				shields[dstName][spellid][srcName].amount = 0
			end
			return
		end

		-- shield applied
		local spellid, _, spellschool, _, amount = ...
		if spellid and amount ~= nil and not tContains(ignoredSpells, spellid) and dstName then
			shields[dstName] = shields[dstName] or {}
			shields[dstName][spellid] = shields[dstName][spellid] or {}

			-- log spell casts.
			Skada:DispatchSets(log_spellcast, srcGUID, srcName, srcFlags, spellid, spellschool)

			shields[dstName][spellid][srcName] = {
				srcGUID = srcGUID,
				srcFlags = srcFlags,
				spellid = spellid,
				school = spellschool,
				amount = amount,
				ts = timestamp,
				full = true
			}
		end
	end

	local function process_absorb(timestamp, dstGUID, dstName, dstFlags, absorbed, spellschool, damage, broke)
		shields[dstName] = shields[dstName] or {}
		shieldspopped = wipe(shieldspopped)
		local count, total = 0, damage + absorbed

		for spellid, spells in pairs(shields[dstName]) do
			for srcName, shield in pairs(spells) do
				if shield.ts <= timestamp and shield.amount > 0 then
					-- Light Essence vs Fire Damage
					if spellid == 65686 and band(spellschool, 0x4) == spellschool then
						return -- don't record
					-- Dark Essence vs Shadow Damage
					elseif spellid == 65684 and band(spellschool, 0x20) == spellschool then
						return -- don't record
					-- Mage Ward vs Frost Damage
					elseif
						spellid == 543 and
						band(spellschool, 0x04) ~= spellschool and -- Fire Damage
						band(spellschool, 0x10) ~= spellschool and -- Frost Damage
						band(spellschool, 0x40) ~= spellschool -- Arcane Damage
					then
						-- nothing
					-- Shadow Ward vs Shadow Damage
					elseif spellid == 6229 and band(spellschool, 0x20) ~= spellschool then
						-- nothing
					-- Anti-Magic and Savage Defense vs Physical Damage
					-- elseif (spellid == 48707 or spellid == 62600) and band(spellschool, 0x01) == spellschool then
					-- 	-- nothing
					else
						shieldspopped[#shieldspopped + 1] = {
							srcGUID = shield.srcGUID,
							srcName = srcName,
							srcFlags = shield.srcFlags,
							spellid = shield.spellid,
							school = shield.school,
							points = shield.points,
							ts = shield.ts,
							amount = shield.amount,
							full = shield.full
						}
						count = count + 1
					end
				end
			end
		end

		-- the player has no shields, so nothing to do.
		if count <= 0 then return end

		-- if the player has a single shield and it broke, we update its max absorb
		if count == 1 and broke and shieldspopped[1].full and shieldspopped[1].full.amount then
			local s = shieldspopped[1]
			shieldamounts[s.srcName] = shieldamounts[s.srcName] or {}
			if (not shieldamounts[s.srcName][s.spellid] or shieldamounts[s.srcName][s.spellid] < absorbed) and absorbed < s.amount then
				shieldamounts[s.srcName][s.spellid] = absorbed
			end
		end

		-- we loop through available shields and make sure to update
		-- their maximum absorb values.
		for _, s in ipairs(shieldspopped) do
			if s.full and shieldamounts and shieldamounts[s.srcName] and shieldamounts[s.srcName][s.spellid] then
				s.amount = shieldamounts[s.srcName][s.spellid]
			end
		end

		tsort(shieldspopped, SortShields)

		local amount = absorbed
		local pshield = nil
		for i = #shieldspopped, 0, -1 do
			-- no shield left to check?
			if i == 0 then
				-- if we still have an absorbed amount running and there is
				-- a previous shield, we attributed dumbly to it.
				-- the "true" at the end is so we don't update the spell count or active time.
				if amount > 0 and pshield then
					absorb.playerid = pshield.srcGUID
					absorb.playername = pshield.srcName
					absorb.playerflags = pshield.srcFlags

					absorb.dstGUID = dstGUID
					absorb.dstName = dstName
					absorb.dstFlags = dstFlags

					absorb.spellid = pshield.spellid
					absorb.school = pshield.school
					absorb.amount = amount

					Skada:DispatchSets(log_absorb, absorb, true)
					log_absorb(Skada.total, absorb, true)
				end
				break
			end

			local s = shieldspopped[i]
			-- whoops! No shield?
			if not s then break end

			-- we store the previous shield to use later in case of
			-- any missing abosrb amount that wasn't properly added.
			pshield = s

			-- if the amount can be handled by the shield itself, we just
			-- attribute it and break, no need to check for more.
			if s.amount >= amount then
				shields[dstName][s.spellid][s.srcName].amount = s.amount - amount
				shields[dstName][s.spellid][s.srcName].full = nil

				absorb.playerid = s.srcGUID
				absorb.playername = s.srcName
				absorb.playerflags = s.srcFlags

				absorb.dstGUID = dstGUID
				absorb.dstName = dstName
				absorb.dstFlags = dstFlags

				absorb.spellid = s.spellid
				absorb.school = s.school
				absorb.amount = amount

				Skada:DispatchSets(log_absorb, absorb)
				log_absorb(Skada.total, absorb)
				break
			-- arriving at this point means that the shield broke,
			-- so we make sure to remove it first, use its max
			-- abosrb value then use the difference for the rest.
			else
				-- if the "points" key exists, we don't remove the shield because
				-- for us it means it's a passive shield that should always be kept.
				if s.points == nil then
					shields[dstName][s.spellid][s.srcName] = nil
				end

				absorb.playerid = s.srcGUID
				absorb.playername = s.srcName
				absorb.playerflags = s.srcFlags

				absorb.dstGUID = dstGUID
				absorb.dstName = dstName
				absorb.dstFlags = dstFlags

				absorb.spellid = s.spellid
				absorb.school = s.school
				absorb.amount = s.amount

				Skada:DispatchSets(log_absorb, absorb)
				log_absorb(Skada.total, absorb)
				amount = amount - s.amount
			end
		end
	end

	local function SpellDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellschool, amount, absorbed

		if eventtype == "SWING_DAMAGE" then
			amount, _, _, _, _, absorbed = ...
		else
			spellschool, amount, _, _, _, _, absorbed = select(3, ...)
		end

		if (absorbed or 0) > 0 and dstName and shields[dstName] then
			process_absorb(timestamp, dstGUID, dstName, dstFlags, absorbed, spellschool or 1, amount, amount > absorbed)
		end
	end

	local function SpellMissed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellschool, misstype, absorbed

		if eventtype == "SWING_MISSED" then
			misstype, _, absorbed = ...
		else
			spellschool, misstype, _, absorbed = select(3, ...)
		end

		if misstype == "ABSORB" and (absorbed or 0) > 0 and dstName and shields[dstName] then
			process_absorb(timestamp, dstGUID, dstName, dstFlags, absorbed, spellschool or 1, 0, false)
		end
	end

	local function EnvironmentDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local envtype, amount, _, _, _, _, absorbed = ...
		if (absorbed or 0) > 0 and dstName and shields[dstName] then
			local spellschool = 1

			if envtype == "Falling" or envtype == "FALLING" then
				spellschool = 1
			elseif envtype == "Drowning" or envtype == "DROWNING" then
				spellschool = 1
			elseif envtype == "Fatigue" or envtype == "FATIGUE" then
				spellschool = 1
			elseif envtype == "Fire" or envtype == "FIRE" then
				spellschool = 4
			elseif envtype == "Lava" or envtype == "LAVA" then
				spellschool = 4
			elseif envtype == "Slime" or envtype == "SLIME" then
				spellschool = 8
			end

			process_absorb(timestamp, dstGUID, dstName, dstFlags, absorbed, spellschool, amount, amount > absorbed)
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
		win.title = format(L["%s's absorbs on %s"], win.actorname or L.Unknown, label)
	end

	function spellmod:Update(win, set)
		win.title = format(L["%s's absorbs on %s"], win.actorname or L.Unknown, win.targetname or L.Unknown)
		if not set or not win.targetname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local total = actor and actor.absorb or 0
		if total > 0 and actor.absorbspells then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
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
						mod.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
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
		win.title = format(L["%s's absorb spells"], label)
	end

	function playermod:Update(win, set)
		win.title = format(L["%s's absorb spells"], win.actorname or L.Unknown)
		if not set or not win.actorname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		if enemy then return end -- unavailable for enemies yet

		local total = actor and actor.absorb or 0
		if total > 0 and actor.absorbspells then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
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
					mod.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
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

			local nr = 0
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
					mod.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
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
			for _, player in ipairs(set.players) do
				if not win.class or win.class == player.class then
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
							d.color = set.gold and Skada.classcolors.ARENA_GOLD or Skada.classcolors.ARENA_GREEN
						end

						d.value = amount
						d.valuetext = Skada:FormatValueCols(
							self.metadata.columns.Absorbs and Skada:FormatNumber(d.value),
							self.metadata.columns.HPS and  Skada:FormatNumber(aps),
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
				for _, enemy in ipairs(set.enemies) do
					if not win.class or win.class == enemy.class then
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
							d.color = set.gold and Skada.classcolors.ARENA_GREEN or Skada.classcolors.ARENA_GOLD

							d.value = amount
							d.valuetext = Skada:FormatValueCols(
								self.metadata.columns.Absorbs and Skada:FormatNumber(d.value),
								self.metadata.columns.HPS and  Skada:FormatNumber(aps),
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
			click4 = Skada.ToggleFilter,
			click4_label = L["Toggle Class Filter"],
			nototalclick = {playermod, targetmod},
			columns = {Absorbs = true, HPS = true, Percent = true},
			icon = [[Interface\Icons\spell_holy_powerwordshield]]
		}

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

		Skada:AddMode(self, L["Absorbs and Healing"])
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end

	function mod:GetSetSummary(set)
		if not set then return end
		local aps, amount = set:GetAPS()
		return Skada:FormatValueCols(
			self.metadata.columns.Absorbs and Skada:FormatNumber(amount),
			self.metadata.columns.HPS and Skada:FormatNumber(aps)
		), amount
	end

	function mod:AddSetAttributes(set)
		shields = shields or T.get("Absorbs_Shields")
		shieldamounts = shieldamounts or T.get("Absorbs_ShieldAmounts")
		shieldspopped = shieldspopped or T.get("Absorbs_ShieldsPopped")
	end

	function mod:SetComplete(set)
		T.clear(absorb)
		T.free("Absorbs_Shields", shields)
		T.free("Absorbs_ShieldAmounts", shieldamounts)
		T.free("Absorbs_ShieldsPopped", shieldspopped)
		-- clean absorbspells table:
		if (set.absorb or 0) == 0 then return end
		for _, p in ipairs(set.players) do
			if p.absorb and p.absorb == 0 then
				p.absorbspells = nil
			elseif p.absorbspells then
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
				tooltip:AddDoubleLine(L["Overhealing"], format("%s (%s)", Skada:FormatNumber(spell.overheal), Skada:FormatPercent(spell.overheal, spell.overheal + spell.amount)), 1, 1, 1)
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
		win.title = format(L["%s's absorbs and healing on %s"], win.actorname or L.Unknown, label)
	end

	function spellmod:Update(win, set)
		win.title = format(L["%s's absorbs and healing on %s"], win.actorname or L.Unknown, win.targetname or L.Unknown)
		if not set or not win.targetname then return end

		local actor, enemy = set:GetActor(win.actorname, win.actorid)
		local total = actor and actor:GetAbsorbHealOnTarget(win.targetname) or 0

		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0

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
							mod.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
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
							mod.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
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
		win.title = format(L["%s's absorb and healing spells"], label)
	end

	function playermod:Update(win, set)
		win.title = format(L["%s's absorb and healing spells"], win.actorname or L.Unknown)
		if not win.actorname then return end

		local actor = set and set:GetActor(win.actorname, win.actorid)
		local total = actor and actor:GetAbsorbHeal() or 0

		if total > 0 and (actor.healspells or actor.absorbspells) then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0

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
						mod.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
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
						mod.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
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

			local nr = 0
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
						mod.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
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
			for _, player in ipairs(set.players) do
				if not win.class or win.class == player.class then
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
							d.color = set.gold and Skada.classcolors.ARENA_GOLD or Skada.classcolors.ARENA_GREEN
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
				for _, enemy in ipairs(set.enemies) do
					if not win.class or win.class == enemy.class then
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
							d.color = set.gold and Skada.classcolors.ARENA_GREEN or Skada.classcolors.ARENA_GOLD

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
			click4 = Skada.ToggleFilter,
			click4_label = L["Toggle Class Filter"],
			post_tooltip = hps_tooltip,
			nototalclick = {playermod, targetmod},
			columns = {Healing = true, HPS = true, Percent = true},
			icon = [[Interface\Icons\spell_holy_healingfocus]]
		}

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
			tooltip:AddDoubleLine(L["Overhealing"], Skada:FormatPercent(set.overheal, amount), 1, 1, 1)
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
			for _, player in ipairs(set.players) do
				if not win.class or win.class == player.class then
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
							d.color = set.gold and Skada.classcolors.ARENA_GOLD or Skada.classcolors.ARENA_GREEN
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
				for _, enemy in ipairs(set.enemies) do
					if not win.class or win.class == enemy.class then
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
							d.color = set.gold and Skada.classcolors.ARENA_GREEN or Skada.classcolors.ARENA_GOLD

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
			click4 = Skada.ToggleFilter,
			click4_label = L["Toggle Class Filter"],
			columns = {HPS = true, Percent = true},
			icon = [[Interface\Icons\spell_nature_rejuvenation]]
		}

		local parentmod = Skada:GetModule(L["Absorbs and Healing"], true)
		if parentmod then
			self.metadata.click1 = parentmod.metadata.click1
			self.metadata.click2 = parentmod.metadata.click2
			self.metadata.nototalclick = parentmod.metadata.nototalclick
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
		for _, p in ipairs(set.players) do
			local spell = (p.absorbspells and p.absorbspells[id]) or (p.healspells and p.healspells[id])
			if spell then
				if not cacheTable[id] then
					cacheTable[id] = {school = spell.school, amount = spell.amount}
					cacheTable[id].isabsorb = (p.absorbspells and p.absorbspells[id])
				else
					cacheTable[id].amount = cacheTable[id].amount + spell.amount
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
			if (spell.overheal or 0) > 0 then
				local overheal = set.overheal or 1
				tooltip:AddDoubleLine(L["Overhealing"], format("%s (%s)", Skada:FormatNumber(spell.overheal), Skada:FormatPercent(spell.overheal, overheal)), 1, 1, 1)
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

		for _, p in ipairs(set.players) do
			local spell = (p.absorbspells and p.absorbspells[win.spellid]) or (p.healspells and p.healspells[win.spellid])
			if spell then
				cacheTable[p.name] = {
					id = p.id,
					class = p.class,
					role = p.role,
					spec = p.spec,
					amount = spell.amount
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
					mod.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
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

			local nr = 0
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
			columns = {Healing = true, Percent = true},
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
			for _, player in ipairs(self.players) do
				if player.healspells then
					for spellid, spell in pairs(player.healspells) do
						if not tbl[spellid] then
							tbl[spellid] = {school = spell.school, amount = spell.amount}
						else
							tbl[spellid].amount = tbl[spellid].amount + spell.amount
						end
					end
				end
				if player.absorbspells then
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