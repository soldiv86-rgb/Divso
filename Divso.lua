getgenv().AnimeDiceConfig = {
	-- ★★ ONE CLICK: true = start farming immediately on load (no need to press start yourself) ★★
	AutoStart      = true,
	ShowUI         = false,    -- ★ false = only the center-screen overlay text (doesn't create a UI window)
	StartHidden    = true,     -- (used when ShowUI=true) AutoStart then hide UI
	AntiAFK        = true,     -- prevent being kicked for being idle for 20 minutes (proactive input every 60 sec)
	FpsBoost       = true,     -- ★ potato graphics + ★ remove trees/houses/signs + disable floating numbers/+$/effects/shadows (FPS increases when opening multiple clients · keeps ground + our units)
	HorstLog       = true,     -- send separate logs to Horst (current money/income per second/rebirth) — auto if Horst exists

	-- ─── Roll / Equip / Sell ───
	AutoRoll       = true,     -- roll continuously (skip cutscenes · disable game's auto-roll)
	HideCutscene   = true,     -- hide 1 in X animation screen
	AutoEquipBest  = true,     -- equip the best units into house slots
	AutoSell       = true,     -- sell units when inventory is full (skip placed/locked units)
	SellKeepBuffer = 6,        -- sell when remaining storage space is less than this
	SellKeepIncome = 1e12,        -- ★ don't sell units that make $/s from this value onward (0=off · 1e6=1M/s, 1e9=1B/s, 1e12=1T/s)

	-- ─── Upgrades / Dice / Rebirth ───
	AutoUpgrade    = true,     -- buy upgrade tree upgrades when enough money is available
	UpgradePriority= "Balanced", -- Balanced / Luck / Money / Storage / Damage / RollSpeed
	AutoDice       = true,     -- buy + equip the dice with the highest luck
	AutoRebirth    = true,     -- rebirth when enough money is available (+ save money for it)

	-- ─── Income ───
	AutoCollect    = true,     -- collect money from every house slot
	AutoLevelUnit  = true,     -- level up units in the house
	MaxUnitLevel   = 20,       -- don't level units beyond this (prevents spending too much and missing rebirth)
	AutoQuest      = true,     -- claim quests when completed

	-- ─── Tower / Rewards / Potions ───
	AutoTower      = true,     -- automatically enter towers (choose a mode the team can handle + climb floors)
	TowerMode      = "auto",   -- ★ "auto"=calculate the most worthwhile option · or specify: Dragon Tower / Cursed Tower / Pirate Tower / Infinity Tower
	AutoReward     = true,     -- claim daily / offline / group rewards
	AutoBoost      = true,     -- use the highest-tier boost per category

	-- ─── auto-trade: transfer units to the HOST account (requires 2+ accounts · gate: 1000 rolls + both accounts ≥14 days old) ───
	AutoTrade      = true,    -- ★ enable trading system (set TradeHost first) · default off
	TradeHost      = { "@Sasuke_030220" }, -- ★ recipient (main): UserId / "@username" / or multiple hosts as a list { "Name1", "Name2" } · 0=off
	TradeSendMode  = "none", -- "keep_slotted"=send every unit except house-placed units · "all"=send everything · "keep_income"=keep valuable units · "none"=don't send units (only Gems/Trait in TradeSendItems)
	TradeKeepIncome= 0,        -- (keep_income mode) don't send units that make $/s from this value onward (0=no filter · 1e6=1M/s)
	TradeGather    = false,    -- ★ keep disabled! teleporting into Horst's reserved server doesn't work = error 773 · have Horst keep host+member in the same server and trade when co-located
	TradeSendItems = { "Gems", "Trait Reroll" }, -- ★ stackable items to auto-send: Gems/Trait Reroll · add potions such as "Damage I" · {} = units only
	TradeMinItems  = 0,        -- ★ trade when there are ≥ this many items (Gems+Trait total) · 0=trade immediately · e.g. 50 = accumulate 50 before sending (prevents trading tiny amounts)

	-- ─── weather-hunt: search for servers with a weather event (UPD 4 · Luck/Cash/Roll Speed ×2.5) ───
	WeatherHunt    = false,    -- ★ enable weather system (passive: every client watches for events in its own server · if found + not full=beacon · other clients move into available slots · no random hopping = no 772 spam)
	WeatherTarget  = "any",    -- "any"=take any event · or "Luck Event"/"Cash Event"/"Roll Speed Event"
	WeatherMinRemaining = 60,  -- event must have ≥ this many seconds remaining (prevents finding it when almost over · 60=1 minute)
}
loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/a817acd7a3f5e93d1498028145dfd05d.lua"))()
