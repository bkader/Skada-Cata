local Skada = _G.Skada
if not Skada then return end
Skada:RegisterModule("Improvement", function(L)
	if Skada:IsDisabled("Improvement") then return end

	local mod = Skada:NewModule("Improvement")
	local mod_modes = mod:NewModule("Improvement modes")
	local mod_comparison = mod:NewModule("Improvement comparison")

	local pairs, select = pairs, select
	local date, tostring = date, tostring
	local playerid = UnitGUID("player")

	local modes = {
		"ActiveTime",
		"Damage",
		"DamageTaken",
		"Deaths",
		"Dispels",
		"Fails",
		"Healing",
		"Interrupts",
		"Overhealing"
	}

	local localized = {
		ActiveTime = L["Active Time"],
		Damage = L["Damage Done"],
		DamageTaken = L["Damage Taken"],
		Deaths = L["Deaths"],
		Dispels = L["Dispels"],
		Fails = L["Fails"],
		Healing = L["Healing"],
		Interrupts = L["Interrupts"],
		Overhealing = L["Overhealing"]
	}

	local revlocalized = {
		[L["Active Time"]] = "ActiveTime",
		[L["Damage Done"]] = "Damage",
		[L["Damage Taken"]] = "DamageTaken",
		[L["Deaths"]] = "Deaths",
		[L["Dispels"]] = "Dispels",
		[L["Fails"]] = "Fails",
		[L["Healing"]] = "Healing",
		[L["Interrupts"]] = "Interrupts",
		[L["Overhealing"]] = "Overhealing"
	}

	local updaters = {}

	updaters.ActiveTime = function(set, player)
		return Skada:GetActiveTime(set, player, true)
	end

	updaters.Damage = function(set, player)
		return player.damage or 0
	end

	updaters.DamageTaken = function(set, player)
		return player.damagetaken or 0
	end

	updaters.Deaths = function(set, player)
		return player.deaths or 0
	end

	updaters.Healing = function(set, player)
		return (player.heal or 0) + (player.absorb or 0)
	end

	updaters.Overhealing = function(set, player)
		return player.overheal or 0
	end

	updaters.Interrupts = function(set, player)
		return player.interrupt or 0
	end

	updaters.Dispels = function(set, player)
		return player.dispel or 0
	end

	updaters.Fails = function(set, player)
		return player.fail or 0
	end

	local function find_boss_data(bossname)
		if not bossname then
			return
		end
		mod.db = mod.db or {}
		for k, v in pairs(mod.db) do
			if k == bossname then
				return v
			end
		end

		mod.db[bossname] = {count = 0, encounters = {}}
		return find_boss_data(bossname)
	end

	local function find_encounter_data(boss, starttime)
		for i = 1, #boss.encounters do
			local encounter = boss.encounters[i]
			if encounter and encounter.starttime == starttime then
				return encounter
			end
		end

		boss.encounters[#boss.encounters + 1] = {starttime = starttime, data = {}}
		return find_encounter_data(boss, starttime)
	end

	function mod_comparison:Enter(win, id, label)
		win.targetid, win.modename = id, revlocalized[label] or label
		win.title = (win.targetname or UNKNOWN) .. " - " .. label
	end

	function mod_comparison:Update(win, set)
		win.title = (win.targetname or UNKNOWN) .. " - " .. (localized[win.modename] or win.modename)
		local boss = find_boss_data(win.targetname)

		if boss and boss.encounters then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for i = 1, #boss.encounters do
				local encounter = boss.encounters[i]
				nr = nr + 1
				local d = win:nr(nr)

				d.id = i
				d.label = date("%x %X", encounter.starttime)

				d.value = encounter.data[win.modename] or 0
				if win.modename == "ActiveTime" then
					d.valuetext = Skada:FormatTime(d.value)
				elseif win.modename == "Deaths" or win.modename == "Interrupts" or win.modename == "Fails" then
					d.valuetext = tostring(d.value)
				else
					d.valuetext = Skada:FormatValueCols(
						Skada:FormatNumber(d.value),
						Skada:FormatNumber((d.value) / max(1, encounter.data.ActiveTime or 0))
					)
				end

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function mod_modes:Enter(win, id, label)
		win.targetid, win.targetname = id, label
		win.title = L["%s's overall data"]:format(label)
	end

	function mod_modes:Update(win, set)
		win.title = L["%s's overall data"]:format(win.targetname or UNKNOWN)
		local boss = find_boss_data(win.targetname)

		if boss then
			if win.metadata then
				win.metadata.maxvalue = 1
			end

			local nr = 0
			for i = 1, #modes do
				local mode = modes[i]
				nr = nr + 1
				local d = win:nr(nr)

				d.id = i
				d.label = localized[mode] or mode

				local value, active = 0, 0
				for j = 1, #boss.encounters do
					value = value + (boss.encounters[j].data[mode] or 0)
					active = active + (boss.encounters[j].data.ActiveTime or 0)
				end

				d.value = value

				if mode == "ActiveTime" then
					d.valuetext = Skada:FormatTime(d.value)
				elseif mode == "Deaths" or mode == "Interrupts" or mode == "Fails" then
					d.valuetext = tostring(d.value)
				else
					d.valuetext = Skada:FormatNumber(d.value)
				end
			end
		end
	end

	function mod:Update(win, set)
		win.title = L["Improvement"]

		if self.db then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 0
			for name, data in pairs(self.db) do
				nr = nr + 1
				local d = win:nr(nr)

				d.id = name
				d.label = name
				d.class = "BOSS"
				d.value = data.count
				d.valuetext = tostring(data.count)

				if win.metadata and d.value > win.metadata.maxvalue then
					win.metadata.maxvalue = d.value
				end
			end
		end
	end

	function mod:OnInitialize()
		if not self.db then
			SkadaImprovementDB = SkadaImprovementDB or {}

			-- get back old data
			if Skada.char.improvement then
				if Skada.char.improvement.bosses then
					SkadaImprovementDB = CopyTable(Skada.char.improvement.bosses or {})
				else
					SkadaImprovementDB = CopyTable(Skada.char.improvement)
				end
				Skada.char.improvement = nil
			end

			self.db = SkadaImprovementDB
		end
	end

	function mod:BossDefeated(event, set)
		if event == "COMBAT_BOSS_DEFEATED" and set and set.type == "raid" and set.success then
			local boss = find_boss_data(set.mobname)
			if not boss then return end

			local encounter = find_encounter_data(boss, set.starttime)
			if not encounter then return end

			for i = 1, #set.players do
				local player = set.players[i]
				if player and player.id == playerid then
					for j = 1, #modes do
						local mode = modes[j]
						if mode and updaters[mode] then
							encounter.data[mode] = updaters[mode](set, player)
						elseif mode then
							encounter.data[mode] = player[mode:lower()]
						end
					end
					-- increment boss count and stop
					boss.count = boss.count + 1
					if boss.count ~= #boss.encounters then
						boss.count = #boss.encounters
					end
					break
				end
			end
		end
	end

	function mod:OnEnable()
		playerid = playerid or Skada.userGUID or UnitGUID("player")
		self:OnInitialize()

		mod_comparison.metadata = {notitleset = true}
		mod_modes.metadata = {click1 = mod_comparison, notitleset = true}
		self.metadata = {
			click1 = mod_modes,
			notitleset = true, -- ignore title set
			icon = "Interface\\Icons\\ability_warrior_intensifyrage"
		}

		Skada.RegisterMessage(self, "COMBAT_BOSS_DEFEATED", "BossDefeated")
		Skada:AddMode(self)
	end

	function mod:OnDisable()
		Skada.UnregisterAllMessages(self)
		Skada:RemoveMode(self)
	end

	local function ask_for_reset()
		StaticPopupDialogs["ResetImprovementDialog"] = {
			text = L["Do you want to reset your improvement data?"],
			button1 = ACCEPT,
			button2 = CANCEL,
			timeout = 30,
			whileDead = 0,
			hideOnEscape = 1,
			OnAccept = function()
				mod:Reset()
			end
		}
		StaticPopup_Show("ResetImprovementDialog")
	end

	function mod:Reset()
		Skada:Wipe()
		SkadaImprovementDB = wipe(SkadaImprovementDB or {})
		self.db = nil
		self:OnInitialize()

		local windows = Skada:GetWindows()
		for i = 1, #windows do
			local win = windows[i]
			local mode = (win and win.db) and win.db.mode or nil
			if mode == L["Improvement"] or mode == L["Improvement modes"] or mode == L["Improvement comparison"] then
				win:DisplayMode(mod)
			end
		end

		Skada:UpdateDisplay(true)
		Skada:Print(L["All data has been reset."])
		Skada:CleanGarbage()
	end

	local Default_ShowPopup = Skada.ShowPopup
	function Skada:ShowPopup(win, force)
		if win and win.db and win.db.mode == L["Improvement"] then
			ask_for_reset()
			return
		end

		return Default_ShowPopup(Skada, win, force)
	end
end)