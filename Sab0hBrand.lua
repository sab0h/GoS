if myHero.charName ~= "Brand" then return end
require "DamageLib"

local path = SCRIPT_PATH.."Orbwalker.lua"

if FileExist(path) then
  _G.Enable_Ext_Lib = true
  loadfile(path)()
else
  print("Orbwalker Not Found. You need to install IC's Orbwalker before using this script or rename the Lua into Orbwalker.lua")
  return
end 
-- Fähigkeiten
local Q = {delay = 0 ,range = 1050,speed = 1400,width = 75,icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/BrandQ.png"}
local W = {delay = 0.625 , range = 900,width = 187,icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/BrandW.png"}
local E = {delay = 0.1,range = 615,speed = 0,icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/BrandE.png"}
local R = {delay = 0.1,range = 750,icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/BrandR.png"}
-- Menu- 
local BrandMenu = MenuElement({type = MENU, id = "BrandMenu", name = "Brand", leftIcon = "http://orig12.deviantart.net/2798/f/2013/329/3/c/league_of_legends___brand_icon_256x_by_gamingtutsdk-d6vlkrh.png"})
--ComboMenu
BrandMenu:MenuElement({type = MENU, id = "Combo", name = "Brand | by Sab0h", leftIcon = "http://news.cdn.leagueoflegends.com/public/images/articles/2015/march_2015/upn/orbitallaser.jpg"})
BrandMenu.Combo:MenuElement({type = PARAM, id = "Q", name = "Use Q", value = true, leftIcon = Q.icon})
BrandMenu.Combo:MenuElement({type = PARAM, id = "W", name = "Use W", value = true, leftIcon = W.icon})
BrandMenu.Combo:MenuElement({type = PARAM, id = "E", name = "Use E", value = true, leftIcon = E.icon})
BrandMenu.Combo:MenuElement({type = PARAM, id = "R", name = "Use R", value = true, leftIcon = R.icon})

BrandMenu:MenuElement({type = MENU, id = "Extra", name = "Extra(WIP don't work!)", leftIcon = "http://news.cdn.leagueoflegends.com/public/images/articles/2015/march_2015/upn/orbitallaser.jpg"})
BrandMenu.Extra:MenuElement({type = PARAM, id = "FlashCombo", name = "FlashCombo Key", key=string.byte("X")})

BrandMenu:MenuElement({type = MENU, id = "Harass", name = "Harass", leftIcon = "http://news.cdn.leagueoflegends.com/public/images/articles/2015/march_2015/upn/orbitallaser.jpg"})
BrandMenu.Harass:MenuElement({type = PARAM, id = "Q", name = "Use Q", value = true, leftIcon = Q.icon})
BrandMenu.Harass:MenuElement({type = PARAM, id = "W", name = "Use W", value = true, leftIcon = W.icon})
BrandMenu.Harass:MenuElement({type = PARAM, id = "E", name = "Use E", value = true, leftIcon = E.icon})
BrandMenu.Harass:MenuElement({type = PARAM, id = "R", name = "Use R", value = true, leftIcon = R.icon})
--KillSecure
BrandMenu:MenuElement({type = MENU, id = "KillSecure", name = " KillSecure Menu", leftIcon = "http://www.freeiconspng.com/uploads/troll-face-png-2.png"})
BrandMenu.KillSecure:MenuElement({type = PARAM, id = "Q", name = "Use Q", value = true, leftIcon = Q.icon})
BrandMenu.KillSecure:MenuElement({type = PARAM, id = "E", name = "Use E", value = true, leftIcon = E.icon})


local target=nil
function IsImmune(unit)
	if type(unit) ~= "userdata" then error("{IsImmune}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	for i, buff in pairs(GetBuffs(unit)) do
		if (buff.name == "KindredRNoDeathBuff" or buff.name == "UndyingRage") and GetPercentHP(unit) <= 10 then
			return true
		end
		if buff.name == "VladimirSanguinePool" or buff.name == "JudicatorIntervention" then 
			return true
		end
	end
	return false
end
local function GetSummonerSpellSlot(name)
	if myHero:GetSpellData(4).name==name then
		return SUMMONER_1
	elseif myHero:GetSpellData(5).name==name then
		return SUMMONER_2
	end
end
function IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if type(range) ~= "number" then error("{IsValidTarget}: bad argument #2 (number expected, got "..type(range)..")") end
	if type(checkTeam) ~= "nil" and type(checkTeam) ~= "boolean" then error("{IsValidTarget}: bad argument #3 (boolean or nil expected, got "..type(checkTeam)..")") end
	if type(from) ~= "nil" and type(from) ~= "userdata" then error("{IsValidTarget}: bad argument #4 (vector or nil expected, got "..type(from)..")") end
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or IsImmune(unit) or (checkTeam and unit.isAlly) then 
		return false 
	end 
	return unit.pos:DistanceTo(from.pos and from.pos or myHero.pos) < range 
end

local function CountEnemiesInRange(point, range)
	if type(point) ~= "userdata" then error("{CountEnemiesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
	local range = range == nil and math.huge or range 
	if type(range) ~= "number" then error("{CountEnemiesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
	local n = 0
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if IsValidTarget(unit, range, true, point) then
			n = n + 1
		end
	end
	return n
end
function OnTick()
if myHero.dead then return end
	target=_G.SDK.TargetSelector:GetTarget(800)
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and target then
		if target.distance<800 then
			if BrandMenu.Combo.W:Value() and Game.CanUseSpell(_W)==READY and IsValidTarget(target,W.range, true, myHero)then
				local pos=target:GetPrediction(W.speed,W.delay)
				Control.CastSpell(HK_W,pos)
			elseif BrandMenu.Combo.Q:Value() and target:GetCollision(Q.width, Q.speed,Q.delay) == 0 and Game.CanUseSpell(_Q)==READY or Game.CanUseSpell(_Q)==READYNOCAST and target.distance<=Q.range and IsValidTarget(target, Q.range, true, myHero)then
				local pos=target:GetPrediction(Q.speed,Q.delay)
				Control.CastSpell(HK_Q,pos)
			elseif BrandMenu.Combo.E:Value() and Game.CanUseSpell(_E)==READY and target.distance<=E.range and IsValidTarget(target, E.range, true, myHero) then
				Control.CastSpell(HK_E,target)
			elseif BrandMenu.Combo.R:Value() and Game.CanUseSpell(_R)==READY and not target.dead and target.distance<=R.range and getdmg("R", target, myHero) >= target.health or (CountEnemiesInRange(target, 500) > 1 )  then
			Control.CastSpell(HK_R,target)		
			end
		end
	end
	--
	if BrandMenu.KillSecure.Q:Value() or BrandMenu.KillSecure.W:Value() or BrandMenu.KillSecure.E:Value() or BrandMenu.KillSecure.R:Value() then
		for i=1,Game.HeroCount() do
			local hero=Game.Hero(i)
			if hero.distance<=700 and hero.isEnemy and not hero.dead and not hero.isImmortal then
				if BrandMenu.KillSecure.Q:Value() and Game.CanUseSpell(_Q)==READY and target:GetCollision(Q.width,Q.speed,Q.delay)== 0 then
					if hero.distance<=Q.range and getdmg("Q",hero)>hero.health then
					local pos=target:GetPrediction(Q.speed,Q.delay)
						Control.CastSpell(HK_Q,pos)
					end
				elseif BrandMenu.KillSecure.E:Value() and Game.CanUseSpell(_E)==READY then
					if hero.distance<=E.range and getdmg("E",hero)>hero.health then
						Control.CastSpell(HK_E,hero)
					end
				end
			end
		end
	end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and target then
			if target.distance<800 then
				if BrandMenu.Harass.W:Value() and Game.CanUseSpell(_W)==READY and IsValidTarget(target,W.range, true, myHero)then
					local pos=target:GetPrediction(W.speed,W.delay)
					Control.CastSpell(HK_W,pos)
				elseif BrandMenu.Harass.Q:Value() and target:GetCollision(Q.width, Q.speed,Q.delay) == 0 and Game.CanUseSpell(_Q)==READY or Game.CanUseSpell(_Q)==READYNOCAST and target.distance<=Q.range and IsValidTarget(target, Q.range, true, myHero)then
					local pos=target:GetPrediction(Q.speed,Q.delay)
					Control.CastSpell(HK_Q,pos)
				elseif BrandMenu.Harass.E:Value() and Game.CanUseSpell(_E)==READY and target.distance<=E.range and IsValidTarget(target, E.range, true, myHero) then
					Control.CastSpell(HK_E,target)	
				end
			end
		end
		local flash=GetSummonerSpellSlot("SummonerFlash")
		if BrandMenu.Extra.FlashCombo:Value() and target then 
			if flash then
				local flashk
				if flash==4 then flashk=HK_SUMMONER_1 else flashk=HK_SUMMONER_2 end
					if target.distance<800 then
						if BrandMenu.Combo.W:Value() and Game.CanUseSpell(_W)==READY and IsValidTarget(target,W.range, true, myHero)then
							local pos=target:GetPrediction(W.speed,W.delay)
							Control.CastSpell(HK_W,pos)
						elseif BrandMenu.Combo.Q:Value() and target:GetCollision(Q.width, Q.speed,Q.delay) == 0 and Game.CanUseSpell(_Q)==READY or Game.CanUseSpell(_Q)==READYNOCAST and target.distance<=Q.range and IsValidTarget(target, Q.range, true, myHero)then
							local pos=target:GetPrediction(Q.speed,Q.delay)
							Control.CastSpell(HK_Q,pos)
						elseif BrandMenu.Combo.E:Value() and Game.CanUseSpell(_E)==READY and target.distance<=E.range and IsValidTarget(target, E.range, true, myHero) then
							Control.CastSpell(HK_E,target)
						elseif BrandMenu.Combo.R:Value() and Game.CanUseSpell(_R)==READY and not target.dead and target.distance<=R.range and getdmg("R", target, myHero) >= target.health or (CountEnemiesInRange(target, 500) > 1 )  then
						Control.CastSpell(HK_R,target)		
						end
					end
			end	
		end
end


print("Sab0h | Brand Loaded!")
