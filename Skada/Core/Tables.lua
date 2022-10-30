-- Tables.lua
-- Contains all tables used by different files and modules.
local _, ns = ...
local L = ns.Locale
local setmetatable = setmetatable

-------------------------------------------------------------------------------
-- ingoredSpells
-- a table of spells that are ignored per module.
-- entries should be like so: [spellid] = true

local ignored_spells = {
	-- [[ absorbs modules ]] --
	-- absorb = {},

	-- [[ buffs module ]] --
	buff = {
		[57819] = true, -- Tabard of the Argent Crusade
		[57820] = true, -- Tabard of the Ebon Blade
		[57821] = true, -- Tabard of the Kirin Tor
		[57822] = true, -- Tabard of the Wyrmrest Accord
		[57940] = true, -- Essence of Wintergrasp
		[72968] = true, -- Precious's Ribbon

		-- uncertain about the follwing spells:
		-- [73816] = true, -- Hellscream's Warsong (ICC-Horde 5%)
		-- [73818] = true, -- Hellscream's Warsong (ICC-Horde 10%)
		-- [73819] = true, -- Hellscream's Warsong (ICC-Horde 15%)
		-- [73820] = true, -- Hellscream's Warsong (ICC-Horde 20%)
		-- [73821] = true, -- Hellscream's Warsong (ICC-Horde 25%)
		-- [73822] = true, -- Hellscream's Warsong (ICC-Horde 30%)
		-- [73762] = true, -- Hellscream's Warsong (ICC-Alliance 5%)
		-- [73824] = true, -- Hellscream's Warsong (ICC-Alliance 10%)
		-- [73825] = true, -- Hellscream's Warsong (ICC-Alliance 15%)
		-- [73826] = true, -- Hellscream's Warsong (ICC-Alliance 20%)
		-- [73827] = true, -- Hellscream's Warsong (ICC-Alliance 25%)
		-- [73828] = true, -- Hellscream's Warsong (ICC-Alliance 30%)
	},

	-- [[ debuffs module ]] --
	debuff = {
		[57723] = true, -- Exhaustion (Heroism)
		[57724] = true, -- Sated (Bloodlust)
	},

	-- [[ damage / enemy damage taken modules ]] --
	-- damage = {},

	-- [[ damage taken / enemy damage done modules ]] --
	-- damagetaken = {},

	-- [[ dispels module ]] --
	-- dispel = {},

	-- [[ fails module ]] --
	-- fail = {},

	-- [[ friendly fire module ]] --
	-- friendfire = {},

	-- [[ healing / enemy healing done modules ]] --
	-- heal = {},

	-- [[ interrupts module ]] --
	-- interrupt = {},

	-- [[ resources module ]] --
	-- power = {},

	-- [[ first hit ignored spells ]] --
	firsthit = {
		[1130] = true, -- Hunter's Mark
		[56190] = true, -- Shadow Jade Focusing Lens
		[56191] = true, -- Shadow Jade Focusing Lens
		[60122] = true, -- Baby Spice
	},

	-- [[ no active time spells ]] --
	time = {
		[2947] = true, -- Fire Shield
		[7294] = true, -- Retribution Aura
		[26364] = true, -- Lightning Shield
		[34913] = true, -- Molten Armor
	}
}

-------------------------------------------------------------------------------
-- misc tables

-- resurrect spells
ns.ress_spells = {
	[3026] = 0x01, -- Use Soulstone
	[20484] = 0x08, -- Rebirth
	[20608] = 0x08, -- Reincarnation
}

-- list of crowd control spells
ns.cc_spells = {
	[118] = 0x40, -- Polymorph
	[339] = 0x08, -- Entangling Roots
	[676] = 0x01, -- Disarm
	[710] = 0x20, -- Banish
	[2637] = 0x08, -- Hibernate
	[3355] = 0x10, -- Freezing Trap Effect
	[6358] = 0x20, -- Seduction (Succubus)
	[6770] = 0x01, -- Sap
	[9484] = 0x02, -- Shackle Undead
	[12809] = 0x01, -- Concussion Blow
	[20066] = 0x02, -- Repentance
	[28271] = 0x40, -- Polymorph: Turtle
	[28272] = 0x40, -- Polymorph: Pig
	[33786] = 0x08, -- Cyclone
	[45524] = 0x10, -- Chains of Ice
	[51722] = 0x01, -- Dismantle
}

-- extended list of crowd control spells
ns.extra_cc_spells = setmetatable({
	-- Death Knight
	[47476] = 0x20, -- Strangulate
	[47481] = 0x01, -- Gnaw
	[49203] = 0x10, -- Hungering Cold
	[49560] = 0x01, -- Death Grip
	-- Druid
	[339] = 0x08, -- Entangling Roots
	[16979] = 0x01, -- Feral Charge - Bear
	[19975] = 0x08, -- Entangling Roots (Nature's Grasp)
	[22570] = 0x01, -- Maim
	[45334] = 0x01, -- Feral Charge Effect
	[66070] = 0x08, -- Entangling Roots (Force of Nature)
	-- Hunter
	[1513] = 0x08, -- Scare Beast
	[4167] = 0x01, -- Web (Spider)
	[5116] = 0x01, -- Concussive Shot
	[19386] = 0x08, -- Wyvern Sting
	[19503] = 0x01, -- Scatter Shot
	[19577] = 0x08, -- Intimidation (stun)
	[24394] = 0x01, -- Intimidation
	[26090] = 0x08, -- Pummel (Gorilla)
	[50541] = 0x01, -- Clench (Scorpid)
	[64803] = 0x01, -- Entrapment
	-- Mage
	[122] = 0x10, -- Frost Nova
	[31661] = 0x04, -- Dragon's Breath
	[33395] = 0x10, -- Freeze (Frost Water Elemental)
	[44572] = 0x10, -- Deep Freeze
	[55021] = 0x40, -- Silenced - Improved Counterspell
	[61305] = 0x40, -- Polymorph Cat
	[61721] = 0x40, -- Polymorph Rabbit
	[61780] = 0x40, -- Polymorph Turkey
	-- Paladin
	[853] = 0x02, -- Hammer of Justice
	[2812] = 0x02, -- Holy Wrath
	[10326] = 0x02, -- Turn Evil
	[31935] = 0x02, -- Avengers Shield
	-- Priest
	[605] = 0x20, -- Dominate Mind (Mind Control)
	[8122] = 0x20, -- Psychic Scream
	[15487] = 0x20, -- Silence
	[64044] = 0x20, -- Psychic Horror
	-- Rogue
	[408] = 0x01, -- Kidney Shot
	[1330] = 0x01, -- Garrote - Silence
	[1776] = 0x01, -- Gouge
	[1833] = 0x01, -- Cheap Shot
	[2094] = 0x01, -- Blind
	-- Shaman
	[3600] = 0x08, -- Earthbind (Earthbind Totem)
	[8034] = 0x10, -- Frostbrand Weapon
	[8056] = 0x10, -- Frost Shock
	[39796] = 0x01, -- Stoneclaw Stun (Stoneclaw Totem)
	[51514] = 0x08, -- Hex
	[64695] = 0x08, -- Earthgrab (Earthbind Totem with Storm, Earth and Fire talent)
	-- Warlock
	[5484] = 0x20, -- Howl of Terror
	[6789] = 0x20, -- Death Coil
	[22703] = 0x04, -- Infernal Awakening
	[24259] = 0x20, -- Spell Lock
	[30283] = 0x20, -- Shadowfury
	-- Warrior
	[5246] = 0x01, -- Initmidating Shout
	[6552] = 0x01, -- Pummel
	[7922] = 0x01, -- Charge
	[12323] = 0x01, -- Piercing Howl
	[46968] = 0x01, -- Shockwave
	[58357] = 0x01, -- Heroic Throw silence
	-- Racials
	[20549] = 0x01, -- War Stomp (Tauren)
	[28730] = 0x40, -- Arcane Torrent (Bloodelf)
	[47779] = 0x40, -- Arcane Torrent (Bloodelf)
	[50613] = 0x40, -- Arcane Torrent (Bloodelf)
	-- Engineering
	[67890] = 0x04, -- Cobalt Frag Bomb
}, {__index = ns.cc_spells})

-------------------------------------------------------------------------------
-- DO NOT EDIT THE CODE BELOW (unless you know what you're doing)
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- creature_to_fight
-- a table of creatures IDs used to fix segments names.

ns.creature_to_fight = {
	-- [[ Icecrown Citadel ]] --
	[36960] = L["Icecrown Gunship Battle"], -- Kor'kron Sergeant
	[36968] = L["Icecrown Gunship Battle"], -- Kor'kron Axethrower
	[36982] = L["Icecrown Gunship Battle"], -- Kor'kron Rocketeer
	[37117] = L["Icecrown Gunship Battle"], -- Kor'kron Battle-Mage
	[37215] = L["Icecrown Gunship Battle"], -- Orgrim's Hammer
	[36961] = L["Icecrown Gunship Battle"], -- Skybreaker Sergeant
	[36969] = L["Icecrown Gunship Battle"], -- Skybreaker Rifleman
	[36978] = L["Icecrown Gunship Battle"], -- Skybreaker Mortar Soldier
	[37116] = L["Icecrown Gunship Battle"], -- Skybreaker Sorcerer
	[37540] = L["Icecrown Gunship Battle"], -- The Skybreaker
	[37970] = L["Blood Prince Council"], -- Prince Valanar
	[37972] = L["Blood Prince Council"], -- Prince Keleseth
	[37973] = L["Blood Prince Council"], -- Prince Taldaram
	[36789] = L["Valithria Dreamwalker"], -- Valithria Dreamwalker
	[36791] = L["Valithria Dreamwalker"], -- Blazing Skeleton
	[37868] = L["Valithria Dreamwalker"], -- Risen Archmage
	[37886] = L["Valithria Dreamwalker"], -- Gluttonous Abomination
	[37934] = L["Valithria Dreamwalker"], -- Blistering Zombie
	[37985] = L["Valithria Dreamwalker"], -- Dream Cloud

	-- [[ Naxxramas ]] --
	[16062] = L["The Four Horsemen"], -- Highlord Mograine
	[16063] = L["The Four Horsemen"], -- Sir Zeliek
	[16064] = L["The Four Horsemen"], -- Thane Korth'azz
	[16065] = L["The Four Horsemen"], -- Lady Blaumeux
	[15930] = L["Thaddius"], -- Feugen
	[15929] = L["Thaddius"], -- Stalagg
	[15928] = L["Thaddius"], -- Thaddius

	-- [[ Trial of the Crusader ]] --
	[34796] = L["The Northrend Beasts"], -- Gormok
	[35144] = L["The Northrend Beasts"], -- Acidmaw
	[34799] = L["The Northrend Beasts"], -- Dreadscale
	[34797] = L["The Northrend Beasts"], -- Icehowl

	-- Champions of the Alliance
	[34461] = L["Faction Champions"], -- Tyrius Duskblade <Death Knight>
	[34460] = L["Faction Champions"], -- Kavina Grovesong <Druid>
	[34469] = L["Faction Champions"], -- Melador Valestrider <Druid>
	[34467] = L["Faction Champions"], -- Alyssia Moonstalker <Hunter>
	[34468] = L["Faction Champions"], -- Noozle Whizzlestick <Mage>
	[34465] = L["Faction Champions"], -- Velanaa <Paladin>
	[34471] = L["Faction Champions"], -- Baelnor Lightbearer <Paladin>
	[34466] = L["Faction Champions"], -- Anthar Forgemender <Priest>
	[34473] = L["Faction Champions"], -- Brienna Nightfell <Priest>
	[34472] = L["Faction Champions"], -- Irieth Shadowstep <Rogue>
	[34463] = L["Faction Champions"], -- Shaabad <Shaman>
	[34470] = L["Faction Champions"], -- Saamul <Shaman>
	[34474] = L["Faction Champions"], -- Serissa Grimdabbler <Warlock>
	[34475] = L["Faction Champions"], -- Shocuul <Warrior>
	[35465] = L["Faction Champions"], -- Zhaagrym <Harkzog's Minion / Serissa Grimdabbler's Minion>

	-- Champions of the Horde
	[34441] = L["Faction Champions"], -- Vivienne Blackwhisper <Priest>
	[34444] = L["Faction Champions"], -- Thrakgar <Shaman>
	[34445] = L["Faction Champions"], -- Liandra Suncaller <Paladin>
	[34447] = L["Faction Champions"], -- Caiphus the Stern <Priest>
	[34448] = L["Faction Champions"], -- Ruj'kah <Hunter>
	[34449] = L["Faction Champions"], -- Ginselle Blightslinger <Mage>
	[34450] = L["Faction Champions"], -- Harkzog <Warlock>
	[34451] = L["Faction Champions"], -- Birana Stormhoof <Druid>
	[34453] = L["Faction Champions"], -- Narrhok Steelbreaker <Warrior>
	[34454] = L["Faction Champions"], -- Maz'dinah <Rogue>
	[34455] = L["Faction Champions"], -- Broln Stouthorn <Shaman>
	[34456] = L["Faction Champions"], -- Malithas Brightblade <Paladin>
	[34458] = L["Faction Champions"], -- Gorgrim Shadowcleave <Death Knight>
	[34459] = L["Faction Champions"], -- Erin Misthoof <Druid>
	[35610] = L["Faction Champions"], -- Cat <Ruj'kah's Pet / Alyssia Moonstalker's Pet>

	[34496] = L["Twin Val'kyr"], -- Eydis Darkbane
	[34497] = L["Twin Val'kyr"], -- Fjola Lightbane

	-- [[ Ulduar ]] --
	[32857] = L["The Iron Council"], -- Stormcaller Brundir
	[32867] = L["The Iron Council"], -- Steelbreaker
	[32927] = L["The Iron Council"], -- Runemaster Molgeim
	[32930] = L["Kologarn"], -- Kologarn
	[32933] = L["Kologarn"], -- Left Arm
	[32934] = L["Kologarn"], -- Right Arm
	[33515] = L["Auriaya"], -- Auriaya
	[34014] = L["Auriaya"], -- Sanctum Sentry
	[34035] = L["Auriaya"], -- Feral Defender
	[32882] = L["Thorim"], -- Jormungar Behemoth
	[33288] = L["Yogg-Saron"], -- Yogg-Saron
	[33890] = L["Yogg-Saron"], -- Brain of Yogg-Saron
	[33136] = L["Yogg-Saron"], -- Guardian of Yogg-Saron
	[33350] = L["Mimiron"], -- Mimiron
	[33432] = L["Mimiron"], -- Leviathan Mk II
	[33651] = L["Mimiron"], -- VX-001
	[33670] = L["Mimiron"], -- Aerial Command Unit
}

-------------------------------------------------------------------------------
-- creature_to_boss
-- a table of adds used to deternmine the main boss in encounters.

ns.creature_to_boss = {
	-- [[ Icecrown Citadel ]] --
	[36960] = 37215, -- Kor'kron Sergeant > Orgrim's Hammer
	[36968] = 37215, -- Kor'kron Axethrower > Orgrim's Hammer
	[36982] = 37215, -- Kor'kron Rocketeer > Orgrim's Hammer
	[37117] = 37215, -- Kor'kron Battle-Mage > Orgrim's Hammer
	[36961] = 37540, -- Skybreaker Sergeant > The Skybreaker
	[36969] = 37540, -- Skybreaker Rifleman > The Skybreaker
	[36978] = 37540, -- Skybreaker Mortar Soldier > The Skybreaker
	[37116] = 37540, -- Skybreaker Sorcerer > The Skybreaker
	[36791] = 36789, -- Blazing Skeleton
	[37868] = 36789, -- Risen Archmage
	[37886] = 36789, -- Gluttonous Abomination
	[37934] = 36789, -- Blistering Zombie
	[37985] = 36789, -- Dream Cloud

	-- [[ Naxxramas ]] --
	[15930] = 15928, -- Feugen > Thaddius
	[15929] = 15928, -- Stalagg > Thaddius

	-- [[ Trial of the Crusader ]] --
	[34796] = 34797, -- Gormok > Icehowl
	[35144] = 34797, -- Acidmaw > Icehowl
	[34799] = 34797, -- Dreadscale > Icehowl

	-- [[ Ulduar ]] --
	[32933] = 32930, -- Left Arm > Kologarn
	[32934] = 32930, -- Right Arm > Kologarn
	[34014] = 33515, -- Sanctum Sentry > Auriaya
	[34035] = 33515, -- Feral Defender > Auriaya
	[32882] = 32865, -- Jormungar Behemoth > Thorim
	[33890] = 33288, -- Brain of Yogg-Saron > Yogg-Saron
	[33136] = 33288, -- Guardian of Yogg-Saron > Yogg-Saron
	[33432] = 33350, -- Leviathan Mk II > Mimiron
	[33651] = 33350, -- VX-001 > Mimiron
	[33670] = 33350, -- Aerial Command Unit > Mimiron
}

-- use LibBossIDs-1.0 as backup plan
local LBI = LibStub("LibBossIDs-1.0", true)
if LBI then setmetatable(ns.creature_to_boss, {__index = LBI.BossIDs}) end

-------------------------------------------------------------------------------

ns.dummyTable = {} -- a dummy table used as fallback
ns.cacheTable = {} -- primary cache table
ns.cacheTable2 = {} -- secondary cache table

-- ignored spells table
ns.ignored_spells = setmetatable(ignored_spells, {__index = function(t, key)
	return ns.dummyTable
end})

-- miss type to table key
ns.missTypes = {
	ABSORB = "abs_n",
	BLOCK = "blo_n",
	DEFLECT = "def_n",
	DODGE = "dod_n",
	EVADE = "eva_n",
	IMMUNE = "imm_n",
	MISS = "mis_n",
	PARRY = "par_n",
	REFLECT = "ref_n",
	RESIST = "res_n",
}
