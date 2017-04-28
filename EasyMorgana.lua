if myHero.charName ~= "Morgana" then return end

class "Morganna"
require("DamageLib")
local path = SCRIPT_PATH.."Orbwalker.lua"

if FileExist(path) then
  _G.Enable_Ext_Lib = true
  loadfile(path)()
else
  print("Orbwalker Not Found. You need to install IC's Orbwalker before using this script or rename the Lua into Orbwalker.lua")
  return
end 

function OnLoad() Morganna() end


function Morganna:__init()
    Q = {range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width,icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/DarkBindingMissile.png"}
    W = {range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width,icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/TormentedSoil.png"}
    E = {range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width,icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/BlackShield.png"}
	R = {range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width,icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/SoulShackles.png"}

    self:Menu()
    Callback.Add("Tick", function() self:Tick() end)
end


function Morganna:Menu()
    self.Menu = MenuElement({type = MENU, name = "Morganna", id = "Morganna",leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/Morgana.png"})

    self.Menu:MenuElement({type = MENU, id ="Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "Q", name ="Use Q", value = true,leftIcon = Q.icon})
    self.Menu.Combo:MenuElement({id = "W", name ="Use W", value = true,leftIcon = W.icon})
    self.Menu.Combo:MenuElement({id = "E", name ="Use E", value = true,leftIcon = E.icon})
	self.Menu.Combo:MenuElement({id = "R", name ="Use R", value = true,leftIcon = R.icon})
end

function Morganna:Tick()
    if not myHero.dead  then
        local target = _G.SDK.TargetSelector:GetTarget(1.2*E.range)
        if target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then   
            self:Combo(target)
        end        
    end
end
function CountAlliesInRange(point, range)
	if type(point) ~= "userdata" then error("{CountAlliesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
	local range = range == nil and math.huge or range 
	if type(range) ~= "number" then error("{CountAlliesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
	local n = 0
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isAlly and not unit.isMe and Utility:IsValidTarget(unit, range, false, point) then
			n = n + 1
		end
	end
	return n
end

local function CountEnemiesInRange(point, range)
	if type(point) ~= "userdata" then error("{CountEnemiesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
	local range = range == nil and math.huge or range 
	if type(range) ~= "number" then error("{CountEnemiesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
	local n = 0
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if Utility:IsValidTarget(unit, range, true, point) then
			n = n + 1
		end
	end
	return n
end
function Morganna:Combo(target)
local ally = _G.SDK.ObjectManager:GetAllyHeroes(R.range)
local enemy = _G.SDK.ObjectManager:GetEnemyHeroes(R.range)
        if myHero.pos:DistanceTo(target.pos) < Q.range and target:GetCollision(W.width,W.speed,W.delay) < 1 and Utility:IsReady(_Q) and self.Menu.Combo.Q:Value() then
            local Epos = target:GetPrediction(Q.speed, Q.delay)
            if Epos and myHero.pos:DistanceTo(Epos) < Q.range then
             Control.CastSpell(HK_Q, Epos)
            end
		end
			if myHero.pos:DistanceTo(target.pos) < W.range and Utility:IsReady(_W) and target:GetCollision(W.width,W.speed,W.delay) < 1 and self.Menu.Combo.W:Value() then
				local Epos = target:GetPrediction(W.speed, W.delay)
				if not Utility:IsReady(_Q) or Utility:IsImmobileTarget(target) then
					if Epos and myHero.pos:DistanceTo(Epos) < W.range then
							Control.CastSpell(HK_W, Epos)
					end
				end
			end
		if myHero.pos:DistanceTo(target.pos) < R.range and Utility:IsReady(_R) and self.Menu.Combo.R:Value() then
			if (CountEnemiesInRange(target,R.range) < CountAlliesInRange(target,R.range)) then
				Control.CastSpell(HK_R)
			elseif getdmg("R", target, myHero) >= target.health then  
				Control.CastSpell(HK_R)
			end
		end
		
end

class "Utility"

function Utility:__init()
end

function Utility:GetPercentHP(unit)
	return 100 * unit.health / unit.maxHealth
end
function Utility:GetPercentMP(unit)
	return 100 * unit.mana / unit.maxMana
end

function Utility:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end
function Utility:IsImmobileTarget(target) --Noddy CC Detector
    for i = 0, target.buffCount do
        local buff = target:GetBuff(i)
        if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
            return true
        end
    end
    return false    
end
function Utility:GetAllyHeroes()
	self.AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly and not Hero.isMe then
			table.insert(self.AllyHeroes, Hero)
		end
	end
	return self.AllyHeroes
end

function Utility:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Utility:HasBuff(unit, buffname)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			return true
		end
	end
	return false
end

function Utility:GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.name:lower() == buffname:lower() and Buff.count > 0 then
			return Buff
		end
	end
	return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

function Utility:IsImmune(unit)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if (Buff.name == "kindredrnodeathbuff" or Buff.name == "undyingrage") and self:GetPercentHP(unit) <= 10 then
			return true
		end
		if Buff.name == "vladimirsanguinepool" or Buff.name == "judicatorintervention" then 
            return true
        end
	end
	return false
end

function Utility:IsValidTarget(unit, range, checkTeam, from)
    local range = range == nil and math.huge or range
    if type(range) ~= "number" then error("{IsValidTarget}: bad argument #2 (number expected, got "..type(range)..")") end
    if type(checkTeam) ~= "nil" and type(checkTeam) ~= "boolean" then error("{IsValidTarget}: bad argument #3 (boolean or nil expected, got "..type(checkTeam)..")") end
    if type(from) ~= "nil" and type(from) ~= "userdata" then error("{IsValidTarget}: bad argument #4 (vector or nil expected, got "..type(from)..")") end
    if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or Utility:IsImmune(unit) or (checkTeam and unit.isAlly) then 
    return false 
  end 
  return unit.pos:DistanceTo(from and from or myHero) < range 
end

function Utility:IsReady(slot)
	if Game.CanUseSpell(slot) == 0 then
		return true
	end
	return false
end


Utility()
