local Skada = Skada

local pairs, tostring, format = pairs, tostring, string.format
local GetSpellInfo = Skada.GetSpellInfo or GetSpellInfo
local GetSpellLink = Skada.GetSpellLink or GetSpellLink
local playerPrototype = Skada.playerPrototype
local _

local CCSpells = {
	[118] = 0x40, -- Polymorph
	[12809] = 0x01, -- Concussion Blow
	[20066] = 0x02, -- Repentance
	[2637] = 0x08, -- Hibernate
	[28271] = 0x40, -- Polymorph: Turtle
	[28272] = 0x40, -- Polymorph: Pig
	[3355] = 0x10, -- Freezing Trap Effect
	[33786] = 0x08, -- Cyclone
	[339] = 0x08, -- Entangling Roots
	[45524] = 0x10, -- Chains of Ice
	[51722] = 0x01, -- Dismantle
	[6358] = 0x20, -- Seduction (Succubus)
	[676] = 0x01, -- Disarm
	[6770] = 0x01, -- Sap
	[710] = 0x20, -- Banish
	[9484] = 0x02, -- Shackle Undead
}

-- extended CC list for only CC Done and CC Taken modules
local ExtraCCSpells = {
	-- Death Knight
	[47476] = 0x20, -- Strangulate
	[49203] = 0x10, -- Hungering Cold
	[47481] = 0x01, -- Gnaw
	[49560] = 0x01, -- Death Grip
	-- Druid
	[339] = 0x08, -- Entangling Roots
	[19975] = 0x08, -- Entangling Roots (Nature's Grasp)
	[66070] = 0x08, -- Entangling Roots (Force of Nature)
	[16979] = 0x01, -- Feral Charge - Bear
	[45334] = 0x01, -- Feral Charge Effect
	[22570] = 0x01, -- Maim
	-- Hunter
	[5116] = true, -- Concussive Shot
	[19503] = 0x01, -- Scatter Shot
	[19386] = 0x08, -- Wyvern Sting
	[4167] = 0x01, -- Web (Spider)
	[24394] = 0x01, -- Intimidation
	[19577] = 0x08, -- Intimidation (stun)
	[50541] = 0x01, -- Clench (Scorpid)
	[26090] = 0x08, -- Pummel (Gorilla)
	[1513] = 0x08, -- Scare Beast
	[64803] = 0x01, -- Entrapment
	-- Mage
	[61305] = 0x40, -- Polymorph Cat
	[61721] = 0x40, -- Polymorph Rabbit
	[61780] = 0x40, -- Polymorph Turkey
	[31661] = 0x04, -- Dragon's Breath
	[44572] = 0x10, -- Deep Freeze
	[122] = 0x10, -- Frost Nova
	[33395] = 0x10, -- Freeze (Frost Water Elemental)
	[55021] = 0x40, -- Silenced - Improved Counterspell
	-- Paladin
	[853] = 0x02, -- Hammer of Justice
	[10326] = 0x02, -- Turn Evil
	[2812] = 0x02, -- Holy Wrath
	[31935] = 0x02, -- Avengers Shield
	-- Priest
	[8122] = 0x20, -- Psychic Scream
	[605] = 0x20, -- Dominate Mind (Mind Control)
	[15487] = 0x20, -- Silence
	[64044] = 0x20, -- Psychic Horror
	-- Rogue
	[408] = 0x01, -- Kidney Shot
	[2094] = 0x01, -- Blind
	[1833] = 0x01, -- Cheap Shot
	[1776] = 0x01, -- Gouge
	[1330] = 0x01, -- Garrote - Silence
	-- Shaman
	[51514] = 0x08, -- Hex
	[8056] = 0x10, -- Frost Shock
	[64695] = 0x08, -- Earthgrab (Earthbind Totem with Storm, Earth and Fire talent)
	[3600] = 0x08, -- Earthbind (Earthbind Totem)
	[39796] = 0x01, -- Stoneclaw Stun (Stoneclaw Totem)
	[8034] = 0x10, -- Frostbrand Weapon
	-- Warlock
	[5484] = 0x20, -- Howl of Terror
	[30283] = 0x20, -- Shadowfury
	[22703] = 0x04, -- Infernal Awakening
	[6789] = 0x20, -- Death Coil
	[24259] = 0x20, -- Spell Lock
	-- Warrior
	[5246] = 0x01, -- Initmidating Shout
	[46968] = 0x01, -- Shockwave
	[6552] = 0x01, -- Pummel
	[58357] = 0x01, -- Heroic Throw silence
	[7922] = 0x01, -- Charge
	[12323] = 0x01, -- Piercing Howl
	-- Racials
	[20549] = 0x01, -- War Stomp (Tauren)
	[28730] = 0x40, -- Arcane Torrent (Bloodelf)
	[47779] = 0x40, -- Arcane Torrent (Bloodelf)
	[50613] = 0x40, -- Arcane Torrent (Bloodelf)
	-- Engineering
	[67890] = 0x04 -- Cobalt Frag Bomb
}

local function GetSpellSchool(spellid)
	if CCSpells[spellid] and CCSpells[spellid] ~= true then
		return CCSpells[spellid]
	end
	if ExtraCCSpells[spellid] and ExtraCCSpells[spellid] ~= true then
		return ExtraCCSpells[spellid]
	end
end

-- ======= --
-- CC Done --
-- ======= --
Skada:RegisterModule("CC Done", function(L, P, _, C, new, _, clear)
	if Skada:IsDisabled("CC Done") then return end

	local mod = Skada:NewModule("CC Done")
	local playermod = mod:NewModule("Crowd Control Spells")
	local targetmod = mod:NewModule("Crowd Control Targets")

	local function log_ccdone(set, cc)
		local player = Skada:GetPlayer(set, cc.playerid, cc.playername, cc.playerflags)
		if player then
			-- increment the count.
			player.ccdone = (player.ccdone or 0) + 1
			set.ccdone = (set.ccdone or 0) + 1

			-- saving this to total set may become a memory hog deluxe.
			if set == Skada.total and not P.totalidc then return end

			-- record the spell.
			local spell = player.ccdonespells and player.ccdonespells[cc.spellid]
			if not spell then
				player.ccdonespells = player.ccdonespells or {}
				player.ccdonespells[cc.spellid] = {count = 0}
				spell = player.ccdonespells[cc.spellid]
			end
			spell.count = spell.count + 1

			-- record the target.
			if cc.dstName then
				spell.targets = spell.targets or {}
				spell.targets[cc.dstName] = (spell.targets[cc.dstName] or 0) + 1
			end
		end
	end

	local data = {}

	local function AuraApplied(ts, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellid = ...

		if CCSpells[spellid] or ExtraCCSpells[spellid] then
			data.playerid, data.playername = Skada:FixMyPets(srcGUID, srcName, srcFlags)
			data.playerflags = srcFlags

			data.dstGUID = dstGUID
			data.dstName = dstName
			data.dstFlags = dstFlags

			data.spellid = spellid

			Skada:DispatchSets(log_ccdone, data)
		end
	end

	function playermod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = format(L["%s's control spells"], label)
	end

	function playermod:Update(win, set)
		win.title = format(L["%s's control spells"], win.actorname or L["Unknown"])

		local player = set and set:GetPlayer(win.actorid, win.actorname)
		local total = player and player.ccdone or 0

		if total > 0 and player.ccdonespells then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for spellid, spell in pairs(player.ccdonespells) do
				nr = nr + 1
				local d = win:nr(nr)

				d.id = spellid
				d.spellid = spellid
				d.label, _, d.icon = GetSpellInfo(spellid)
				d.spellschool = GetSpellSchool(spellid)

				d.value = spell.count
				d.valuetext = Skada:FormatValueCols(
					mod.metadata.columns.Count and d.value,
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
		win.title = format(L["%s's control targets"], label)
	end

	function targetmod:Update(win, set)
		win.title = format(L["%s's control targets"], win.actorname or L["Unknown"])

		local player = set and set:GetPlayer(win.actorid, win.actorname)
		local total = player and player.ccdone or 0
		local targets = (total > 0) and player:GetCCDoneTargets()

		if targets then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for targetname, target in pairs(targets) do
				nr = nr + 1
				local d = win:nr(nr)

				d.id = target.id or targetname
				d.label = targetname
				d.class = target.class
				d.role = target.role
				d.spec = target.spec

				d.value = target.count
				d.valuetext = Skada:FormatValueCols(
					mod.metadata.columns.Count and d.value,
					mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
				)

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function mod:Update(win, set)
		win.title = win.class and format("%s (%s)", L["CC Done"], L[win.class]) or L["CC Done"]

		local total = set.ccdone or 0
		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for i = 1, #set.players do
				local player = set.players[i]
				if player and player.ccdone and (not win.class or win.class == player.class) then
					nr = nr + 1
					local d = win:nr(nr)

					d.id = player.id or player.name
					d.label = player.name
					d.text = player.id and Skada:FormatName(player.name, player.id)
					d.class = player.class
					d.role = player.role
					d.spec = player.spec

					d.value = player.ccdone
					d.valuetext = Skada:FormatValueCols(
						self.metadata.columns.Count and d.value,
						self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
					)

					if win.metadata and d.value > win.metadata.maxvalue then
						win.metadata.maxvalue = d.value
					end
				end
			end
		end
	end

	function mod:OnEnable()
		self.metadata = {
			showspots = true,
			ordersort = true,
			click1 = playermod,
			click2 = targetmod,
			click4 = Skada.FilterClass,
			click4_label = L["Toggle Class Filter"],
			columns = {Count = true, Percent = false, sPercent = false},
			icon = [[Interface\Icons\spell_frost_chainsofice]]
		}

		-- no total click.
		playermod.nototal = true
		targetmod.nototal = true

		Skada:RegisterForCL(
			AuraApplied,
			"SPELL_AURA_APPLIED",
			"SPELL_AURA_REFRESH",
			{src_is_interesting = true}
		)

		Skada:AddMode(self, L["Crowd Control"])
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end

	function mod:AddToTooltip(set, tooltip)
		if set.ccdone and set.ccdone > 0 then
			tooltip:AddDoubleLine(L["CC Done"], set.ccdone, 1, 1, 1)
		end
	end

	function mod:GetSetSummary(set)
		local ccdone = set.ccdone or 0
		return tostring(ccdone), ccdone
	end

	function playerPrototype:GetCCDoneTargets(tbl)
		if self.ccdonespells then
			tbl = clear(tbl or C)
			for _, spell in pairs(self.ccdonespells) do
				if spell.targets then
					for name, count in pairs(spell.targets) do
						if not tbl[name] then
							tbl[name] = new()
							tbl[name].count = count
						else
							tbl[name].count = tbl[name].count + count
						end
						if not tbl[name].class then
							local actor = self.super:GetActor(name)
							if actor then
								tbl[name].class = actor.class
								tbl[name].role = actor.role
								tbl[name].spec = actor.spec
							end
						end
					end
				end
			end
			return tbl
		end
	end
end)

-- ======== --
-- CC Taken --
-- ======== --
Skada:RegisterModule("CC Taken", function(L, P, _, C, new, _, clear)
	if Skada:IsDisabled("CC Taken") then return end

	local mod = Skada:NewModule("CC Taken")
	local playermod = mod:NewModule("Crowd Control Spells")
	local sourcemod = mod:NewModule("Crowd Control Sources")

	local RaidCCSpells = {}

	local function log_cctaken(set, cc)
		local player = Skada:GetPlayer(set, cc.playerid, cc.playername, cc.playerflags)
		if player then
			-- increment the count.
			player.cctaken = (player.cctaken or 0) + 1
			set.cctaken = (set.cctaken or 0) + 1

			-- saving this to total set may become a memory hog deluxe.
			if set == Skada.total and not P.totalidc then return end

			-- record the spell.
			local spell = player.cctakenspells and player.cctakenspells[cc.spellid]
			if not spell then
				player.cctakenspells = player.cctakenspells or {}
				player.cctakenspells[cc.spellid] = {count = 0}
				spell = player.cctakenspells[cc.spellid]
			end
			spell.count = spell.count + 1

			-- record the source.
			if cc.srcName then
				spell.sources = spell.sources or {}
				spell.sources[cc.srcName] = (spell.sources[cc.srcName] or 0) + 1
			end
		end
	end

	local data = {}

	local function AuraApplied(ts, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellid = ...

		if CCSpells[spellid] or ExtraCCSpells[spellid] or RaidCCSpells[spellid] then
			data.srcGUID = srcGUID
			data.srcName = srcName
			data.srcFlags = srcFlags

			data.playerid = dstGUID
			data.playername = dstName
			data.playerflags = dstFlags

			data.spellid = spellid

			Skada:DispatchSets(log_cctaken, data)
		end
	end

	function playermod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = format(L["%s's control spells"], label)
	end

	function playermod:Update(win, set)
		win.title = format(L["%s's control spells"], win.actorname or L["Unknown"])

		local player = set and set:GetPlayer(win.actorid, win.actorname)
		local total = player and player.cctaken or 0

		if total > 0 and player.cctakenspells then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for spellid, spell in pairs(player.cctakenspells) do
				nr = nr + 1
				local d = win:nr(nr)

				d.id = spellid
				d.spellid = spellid
				d.label, _, d.icon = GetSpellInfo(spellid)
				d.spellschool = GetSpellSchool(spellid) or RaidCCSpells[spellid]

				d.value = spell.count
				d.valuetext = Skada:FormatValueCols(
					mod.metadata.columns.Count and d.value,
					mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
				)

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function sourcemod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = format(L["%s's control sources"], label)
	end

	function sourcemod:Update(win, set)
		win.title = format(L["%s's control sources"], win.actorname or L["Unknown"])

		local player = set and set:GetPlayer(win.actorid, win.actorname)
		local total = player and player.cctaken or 0
		local sources = (total > 0) and player:GetCCTakenSources()

		if sources then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for sourcename, source in pairs(sources) do
				nr = nr + 1
				local d = win:nr(nr)

				d.id = source.id or sourcename
				d.label = sourcename
				d.class = source.class
				d.role = source.role
				d.spec = source.spec

				d.value = source.count
				d.valuetext = Skada:FormatValueCols(
					mod.metadata.columns.Count and d.value,
					mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
				)

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function mod:Update(win, set)
		win.title = win.class and format("%s (%s)", L["CC Taken"], L[win.class]) or L["CC Taken"]

		local total = set.cctaken or 0
		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for i = 1, #set.players do
				local player = set.players[i]
				if player and player.cctaken and (not win.class or win.class == player.class) then
					nr = nr + 1
					local d = win:nr(nr)

					d.id = player.id or player.name
					d.label = player.name
					d.text = player.id and Skada:FormatName(player.name, player.id)
					d.class = player.class
					d.role = player.role
					d.spec = player.spec

					d.value = player.cctaken
					d.valuetext = Skada:FormatValueCols(
						self.metadata.columns.Count and d.value,
						self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
					)

					if win.metadata and d.value > win.metadata.maxvalue then
						win.metadata.maxvalue = d.value
					end
				end
			end
		end
	end

	function mod:OnEnable()
		self.metadata = {
			showspots = true,
			ordersort = true,
			click1 = playermod,
			click2 = sourcemod,
			click4 = Skada.FilterClass,
			click4_label = L["Toggle Class Filter"],
			columns = {Count = true, Percent = false, sPercent = false},
			icon = [[Interface\Icons\spell_magic_polymorphrabbit]]
		}

		-- no total click.
		playermod.nototal = true
		sourcemod.nototal = true

		Skada:RegisterForCL(
			AuraApplied,
			"SPELL_AURA_APPLIED",
			"SPELL_AURA_REFRESH",
			{dst_is_interesting = true}
		)

		Skada:AddMode(self, L["Crowd Control"])
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end

	function mod:AddToTooltip(set, tooltip)
		if set.cctaken and set.cctaken > 0 then
			tooltip:AddDoubleLine(L["CC Taken"], set.cctaken, 1, 1, 1)
		end
	end

	function mod:GetSetSummary(set)
		local cctaken = set.cctaken or 0
		return tostring(cctaken), cctaken
	end

	function playerPrototype:GetCCTakenSources(tbl)
		if self.cctakenspells then
			tbl = clear(tbl or C)
			for _, spell in pairs(self.cctakenspells) do
				if spell.sources then
					for name, count in pairs(spell.sources) do
						if not tbl[name] then
							tbl[name] = new()
							tbl[name].count = count
						else
							tbl[name].count = tbl[name].count + count
						end
						if not tbl[name].class then
							local actor = self.super:GetActor(name)
							if actor then
								tbl[name].class = actor.class
								tbl[name].role = actor.role
								tbl[name].spec = actor.spec
							end
						end
					end
				end
			end
			return tbl
		end
	end
end)

-- =========== --
-- CC Breakers --
-- =========== --
Skada:RegisterModule("CC Breaks", function(L, P, _, C, new, _, clear)
	if Skada:IsDisabled("CC Breaks") then return end

	local mod = Skada:NewModule("CC Breaks")
	local playermod = mod:NewModule("Crowd Control Spells")
	local targetmod = mod:NewModule("Crowd Control Targets")

	local UnitName, UnitInRaid, IsInRaid = UnitName, UnitInRaid, Skada.IsInRaid
	local GetPartyAssignment, UnitIterator = GetPartyAssignment, Skada.UnitIterator

	local function log_ccbreak(set, cc)
		local player = Skada:GetPlayer(set, cc.playerid, cc.playername)
		if player then
			-- increment the count.
			player.ccbreak = (player.ccbreak or 0) + 1
			set.ccbreak = (set.ccbreak or 0) + 1

			-- saving this to total set may become a memory hog deluxe.
			if set == Skada.total and not P.totalidc then return end

			-- record the spell.
			local spell = player.ccbreakspells and player.ccbreakspells[cc.spellid]
			if not spell then
				player.ccbreakspells = player.ccbreakspells or {}
				player.ccbreakspells[cc.spellid] = {count = 0}
				spell = player.ccbreakspells[cc.spellid]
			end
			spell.count = spell.count + 1

			-- record the target.
			if cc.dstName then
				spell.targets = spell.targets or {}
				spell.targets[cc.dstName] = (spell.targets[cc.dstName] or 0) + 1
			end
		end
	end

	local data = {}

	local function AuraBroken(ts, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellid, spellname, _, extraspellid, extraspellname, _, auratype = ...
		if not CCSpells[spellid] then return end

		local petid, petname = srcGUID, srcName
		local srcGUID_modified, srcName_modified = Skada:FixMyPets(srcGUID, srcName, srcFlags)

		data.playerid = srcGUID_modified or srcGUID
		data.playername = srcName_modified or srcName
		data.playerflags = srcFlags

		data.dstGUID = dstGUID
		data.dstName = dstName
		data.dstFlags = dstFlags

		data.spellid = spellid
		data.extraspellid = extraspellid

		Skada:DispatchSets(log_ccbreak, data)

		-- Optional announce
		srcName = srcName_modified or srcName
		if P.modules.ccannounce and IsInRaid() and UnitInRaid(srcName) then
			if Skada.insType == "pvp" then return end

			-- Ignore main tanks and main assist?
			if P.modules.ccignoremaintanks then
				-- Loop through our raid and return if src is a main tank.
				for unit in UnitIterator(true) do -- exclude pets
					if UnitName(unit) == srcName and (GetPartyAssignment("MAINTANK", unit) or GetPartyAssignment("MAINASSIST", unit)) then
						return
					end
				end
			end

			-- Prettify pets.
			if petid ~= srcGUID_modified then
				srcName = petname .. " (" .. srcName .. ")"
			end

			-- Go ahead and announce it.
			if extraspellid or extraspellname then
				Skada:SendChat(format(L["%s on %s removed by %s's %s"], spellname, dstName, srcName, GetSpellLink(extraspellid or extraspellname)), "RAID", "preset")
			else
				Skada:SendChat(format(L["%s on %s removed by %s"], spellname, dstName, srcName), "RAID", "preset")
			end
		end
	end

	function playermod:Enter(win, id, label)
		win.actorid, win.actorname = id, label
		win.title = format(L["%s's control spells"], label)
	end

	function playermod:Update(win, set)
		win.title = format(L["%s's control spells"], win.actorname or L["Unknown"])

		local player = set and set:GetPlayer(win.actorid, win.actorname)
		local total = player and player.ccbreak or 0

		if total > 0 and player.ccbreakspells then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for spellid, spell in pairs(player.ccbreakspells) do
				nr = nr + 1
				local d = win:nr(nr)

				d.id = spellid
				d.spellid = spellid
				d.label, _, d.icon = GetSpellInfo(spellid)
				d.spellschool = GetSpellSchool(spellid)

				d.value = spell.count
				d.valuetext = Skada:FormatValueCols(
					mod.metadata.columns.Count and d.value,
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
		win.title = format(L["%s's control targets"], label)
	end

	function targetmod:Update(win, set)
		win.title = format(L["%s's control targets"], win.actorname or L["Unknown"])

		local player = set and set:GetPlayer(win.actorid, win.actorname)
		local total = player and player.ccbreak or 0
		local targets = (total > 0) and player:GetCCBreakTargets()

		if targets then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for targetname, target in pairs(targets) do
				nr = nr + 1
				local d = win:nr(nr)

				d.id = target.id or targetname
				d.label = targetname
				d.class = target.class
				d.role = target.role
				d.spec = target.spec

				d.value = target.count
				d.valuetext = Skada:FormatValueCols(
					mod.metadata.columns.Count and d.value,
					mod.metadata.columns.sPercent and Skada:FormatPercent(d.value, total)
				)

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function mod:Update(win, set)
		win.title = win.class and format("%s (%s)", L["CC Breaks"], L[win.class]) or L["CC Breaks"]

		local total = set.ccbreak or 0
		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for i = 1, #set.players do
				local player = set.players[i]
				if player and player.ccbreak and (not win.class or win.class == player.class) then
					nr = nr + 1
					local d = win:nr(nr)

					d.id = player.id or player.name
					d.label = player.name
					d.text = player.id and Skada:FormatName(player.name, player.id)
					d.class = player.class
					d.role = player.role
					d.spec = player.spec

					d.value = player.ccbreak
					d.valuetext = Skada:FormatValueCols(
						self.metadata.columns.Count and d.value,
						self.metadata.columns.Percent and Skada:FormatPercent(d.value, total)
					)

					if win.metadata and d.value > win.metadata.maxvalue then
						win.metadata.maxvalue = d.value
					end
				end
			end
		end
	end

	function mod:OnEnable()
		self.metadata = {
			showspots = true,
			ordersort = true,
			click1 = playermod,
			click2 = targetmod,
			click4 = Skada.FilterClass,
			click4_label = L["Toggle Class Filter"],
			columns = {Count = true, Percent = false, sPercent = false},
			icon = [[Interface\Icons\spell_holy_sealofvalor]]
		}

		-- no total click.
		playermod.nototal = true
		targetmod.nototal = true

		Skada:RegisterForCL(
			AuraBroken,
			"SPELL_AURA_BROKEN",
			"SPELL_AURA_BROKEN_SPELL",
			{src_is_interesting = true}
		)

		Skada:AddMode(self, L["Crowd Control"])
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end

	function mod:AddToTooltip(set, tooltip)
		if set.ccbreak and set.ccbreak > 0 then
			tooltip:AddDoubleLine(L["CC Breaks"], set.ccbreak, 1, 1, 1)
		end
	end

	function mod:GetSetSummary(set)
		local ccbreak = set.ccbreak or 0
		return tostring(ccbreak), ccbreak
	end

	function playerPrototype:GetCCBreakTargets(tbl)
		if self.ccbreakspells then
			tbl = clear(tbl or C)
			for _, spell in pairs(self.ccbreakspells) do
				if spell.targets then
					for name, count in pairs(spell.targets) do
						if not tbl[name] then
							tbl[name] = new()
							tbl[name].count = count
						else
							tbl[name].count = tbl[name].count + count
						end
						if not tbl[name].class then
							local actor = self.super:GetActor(name)
							if actor then
								tbl[name].class = actor.class
								tbl[name].role = actor.role
								tbl[name].spec = actor.spec
							end
						end
					end
				end
			end
			return tbl
		end
	end

	function mod:OnInitialize()
		Skada.options.args.modules.args.ccoptions = {
			type = "group",
			name = self.localeName,
			desc = format(L["Options for %s."], self.localeName),
			args = {
				header = {
					type = "description",
					name = self.localeName,
					fontSize = "large",
					image = [[Interface\Icons\spell_holy_sealofvalor]],
					imageWidth = 18,
					imageHeight = 18,
					imageCoords = {0.05, 0.95, 0.05, 0.95},
					width = "full",
					order = 0
				},
				sep = {
					type = "description",
					name = " ",
					width = "full",
					order = 1
				},
				ccannounce = {
					type = "toggle",
					name = format(L["Announce %s"], self.localeName),
					order = 10,
					width = "double"
				},
				ccignoremaintanks = {
					type = "toggle",
					name = L["Ignore Main Tanks"],
					order = 20,
					width = "double"
				}
			}
		}
	end
end)