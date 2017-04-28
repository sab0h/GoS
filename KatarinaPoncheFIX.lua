--[[------------------------------------------------------------------------------------------------------------

 ____  __.       __               .__             __________                    .__            
|    |/ _|____ _/  |______ _______|__| ____ _____ \______   \____   ____   ____ |  |__   ____  
|      < \__  \\   __\__  \\_  __ \  |/    \\__  \ |     ___/  _ \ /    \_/ ___\|  |  \_/ __ \ 
|    |  \ / __ \|  |  / __ \|  | \/  |   |  \/ __ \|    |  (  <_> )   |  \  \___|   Y  \  ___/ 
|____|__ (____  /__| (____  /__|  |__|___|  (____  /____|   \____/|___|  /\___  >___|  /\___  >
        \/    \/          \/              \/     \/                    \/     \/     \/     \/

--------------------------------------------------------------------------------------------------------------]]
--ver. 1.3

if myHero.charName ~= "Katarina" then return end

require("DamageLib")

class "KatarinaPonche"

local Spin = false
local daggerPos = {}

--Int

function OnLoad()
    KatarinaPonche()
end

local Spells = {
		Q = {range = 625},
		W = {},
		E = {range = 725},
		R = {range = 550},
		P = {range = 340}
	}

function KatarinaPonche:__init()
	self:Menu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	PrintChat("KatarinaPonche : Loaded")
end

function KatarinaPonche:Menu()
	Menu = MenuElement({type = MENU, id = "KatarinaPonche", name = "KatarinaPonche"})

	Menu:MenuElement({type = MENU, id = "Combo", name = "[Combo Manager]"})
	Menu.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	Menu.Combo:MenuElement({id = "W", name = "Use W", value = true})
	Menu.Combo:MenuElement({id = "E", name = "Use E", value = true})
	Menu.Combo:MenuElement({id = "R", name = "Use R", value = true})

	Menu:MenuElement({type = MENU, id = "RManager", name = "[R Manager]"})
	Menu.RManager:MenuElement({id = "Info", name = "Score For Each Champions :", type = SPACE})
	local count = 0
	for K, Enemy in pairs(self:GetEnemyHeroes()) do
		Menu.RManager:MenuElement({id = Enemy.charName, name = Enemy.charName, value = 1, min = 1, max = 3})
		count = count + 1
	end
	Menu.RManager:MenuElement({id = "MinR", name = "Min Score to Cast R", value = 1 , min = 1, max = count * 3})

	Menu:MenuElement({type = MENU, id = "Harass", name = "[Harass Manager]"})
	Menu.Harass:MenuElement({id = "Q", name = "Use Q", value = true})
	Menu.Harass:MenuElement({id = "W", name = "Use W", value = true})
	Menu.Harass:MenuElement({id = "E", name = "Use E", value = false})
	Menu.Harass:MenuElement({id = "Disabled", name = "Disable All", value = false})

	Menu:MenuElement({type = MENU, id = "Ks", name = "[KS Manager]"})
	Menu.Ks:MenuElement({id = "Q", name = "Use Q", value = true})
	Menu.Ks:MenuElement({id = "W", name = "Use W", value = true})
	Menu.Ks:MenuElement({id = "E", name = "Use E", value = true})
	Menu.Ks:MenuElement({id = "R", name = "Use R", value = false})
	if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
		Menu.Ks:MenuElement({id = "UseIgn", name = "Use Ignite", value = false})
	end
	Menu.Ks:MenuElement({id = "Recall", name = "Disable During Recall", value = true})
	Menu.Ks:MenuElement({id = "Disabled", name = "Disable All", value = false})

	Menu:MenuElement({type = MENU, name = "[Draw Manager]", id = "Draw"})
	Menu.Draw:MenuElement({type = MENU, name = "Draw Q Spell", id = "Q"})
	Menu.Draw.Q:MenuElement({name = "Enabled", id = "Enabled", value = true})
	Menu.Draw.Q:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
	Menu.Draw:MenuElement({type = MENU, name = "Draw E Spell", id = "E"})
	Menu.Draw.E:MenuElement({name = "Enabled", id = "Enabled", value = true})
	Menu.Draw.E:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
	Menu.Draw:MenuElement({type = MENU, name = "Draw R Spell", id = "R"})
	Menu.Draw.R:MenuElement({name = "Enabled", id = "Enabled", value = true})
	Menu.Draw.R:MenuElement({name = "Color:", id = "Color", color = Draw.Color(255, 255, 255, 255)})
	Menu.Draw:MenuElement({name = "Disable All Drawings", id = "Disabled", value = false})
	Menu.Draw:MenuElement({name = "Disable On CD", id = "CD", value = false})

	Menu:MenuElement({type = MENU, id = "Misc", name = "[Misc Settings]"})
	Menu.Misc:MenuElement({id = "R", name = "R Max range", value = 450, min = 0, max = 550})
end

function KatarinaPonche:Tick()
	if myHero.dead or self:CheckR() or spin == true then return end
	self:DaggerAdd()
	self:DaggerRemove()
	self:CheckR()
	self:KillSteal()
	local target=_G.SDK.TargetSelector:GetTarget(800)
	if target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then   
            self:Combo(target)
    end
	if target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then 
		self:Harass()
	end
end

function KatarinaPonche:DaggerAdd()
	for u = 1, Game.ParticleCount() do
		local particle = Game.Particle(u)
		if particle and particle.name == "Katarina_Base_W_Indicator_Ally.troy" then
			local found = false
			for i=1,#daggerPos do
				if daggerPos[i] == particle.pos then
					found = true
				end
			end
			if found == false then
				table.insert(daggerPos, particle.pos)
			end
		end
	end
end

function KatarinaPonche:DaggerRemove()
	for i=1,#daggerPos do
		local found = false
		for u = 1, Game.ParticleCount() do
			local particle = Game.Particle(u)
			if particle and particle.name == "Katarina_Base_W_Indicator_Ally.troy" then
				if daggerPos[i] == particle.pos then
					found = true
				end
			end
		end
		if found == false then
			table.remove(daggerPos, i)
		end
	end
end

function KatarinaPonche:CheckR()
	local found = false
		if Spin == true then
			for K, Enemy in pairs(self:GetEnemyHeroes()) do
				if self:IsValidTarget(Enemy, Spells.R.range, false, myHero.pos) then
					found = true
				end
			end
		end
	if found == false and Spin then
		self:EnableEOW()
		Spin = false
	end
end

function KatarinaPonche:KillSteal()
	if  Menu.Ks.Disabled:Value() or (self:IsRecalling() and Menu.Ks.Recall:Value()) or Spin then return end
	for K, Enemy in pairs(self:GetEnemyHeroes()) do
		if Menu.Ks.Q:Value() and self:IsReady(_Q) and self:IsValidTarget(Enemy, Spells.Q.range, false, myHero.pos) then
			if getdmg("Q", Enemy, myHero) > Enemy.health then
				self:CastQ(Enemy)
			end
		end
		if Menu.Ks.Q:Value() and Menu.Ks.E:Value() and self:IsReady(_Q) and self:IsReady(_E) and self:IsValidTarget(Enemy, Spells.Q.range + Spells.E.range, false, myHero.pos) then
			if getdmg("Q", Enemy, myHero) > Enemy.health then
				self:EKS(Enemy)
			end
		end
		if Menu.Ks.E:Value() and self:IsReady(_E) and self:IsValidTarget(Enemy, Spells.E.range, false, myHero.pos) then
			if getdmg("E", Enemy, myHero) > Enemy.health then
				self:CastE(Enemy)
			end
		end
		if Menu.Ks.R:Value() and self:IsReady(_R) and self:IsValidTarget(Enemy, Spells.R.range, false, myHero.pos) then
			if getdmg("R", Enemy, myHero) > Enemy.health then
				self:CastR()
			end
		end
		if myHero:GetSpellData(5).name == "SummonerDot" and Menu.Ks.UseIgn:Value() and self:IsReady(SUMMONER_2) then
			if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
				Control.CastSpell(HK_SUMMONER_2, Enemy)
			end
		end
		if myHero:GetSpellData(4).name == "SummonerDot" and Menu.Ks.UseIgn:Value() and self:IsReady(SUMMONER_1) then
			if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
				Control.CastSpell(HK_SUMMONER_1, Enemy)
			end
		end
	end
end

function KatarinaPonche:EKS(target)
	for K, Enemy in pairs(self:GetEnemyHeroes()) do
		if self:IsValidTarget(Enemy, Spells.E.range, false, myHero.pos) and Enemy.pos:DistanceTo(target.pos) < Spells.Q.range then
			self:CastE(Enemy) return
		end
	end
	for K, Ally in pairs(self:GetAllyHeroes()) do
		if self:IsValidTarget(Ally, Spells.E.range, false, myHero.pos) and Ally.pos:DistanceTo(target.pos) < Spells.Q.range then
			self:CastE(Ally) return
		end
	end
	for K, Minion in pairs(self:GetMinions(Spells.E.range)) do
		if self:IsValidTarget(Minion, Spells.E.range, false, myHero.pos) and Minion.pos:DistanceTo(target.pos) < Spells.Q.range then
			self:CastE(Minion) return
		end
	end
end

function  KatarinaPonche:DisableEOW()
	_G.SDK.Orbwalker:SetAttack(false)
	_G.SDK.Orbwalker:SetMovement(false)
end

function  KatarinaPonche:EnableEOW()
	_G.SDK.Orbwalker:SetMovement(true)
	_G.SDK.Orbwalker:SetAttack(true)
end

function KatarinaPonche:CastQ(target)
	Control.CastSpell(HK_Q, target)
end

function KatarinaPonche:CastW()
	Control.CastSpell(HK_W)
end

function KatarinaPonche:CastE(target)
	Control.CastSpell(HK_E, target)
end

function KatarinaPonche:CastR()
	Spin = true
	self:DisableEOW()
	Control.CastSpell(HK_R)
	DelayAction(function() Spin = false self:EnableEOW() end, 2.5)
end

function KatarinaPonche:Combo()
	if Menu.Combo.E:Value() and self:IsReady(_E) then
		for i=1,#daggerPos do
			for i, Enemy in pairs(self:GetEnemyHeroes()) do
				if self:IsValidTarget(Enemy, Spells.E.range + Spells.P.range, false, myHero.pos) and self:IsValidTarget(Enemy, Spells.P.range, false, daggerPos[i]) then
					self:CastE(daggerPos[i])
				end
			end
		end
	end
	if Menu.Combo.E:Value() and self:IsReady(_E) then
		local target = self:GetTarget(Spells.E.range)
		if target ~= nil and self:IsValidTarget(target, Spells.E.range, false, myHero.pos)then
			self:CastE(target)
		end
	end
	if Menu.Combo.W:Value() and self:IsReady(_W) then
		local target = self:GetTarget(Spells.P.range)
		if target ~= nil and self:IsValidTarget(target, Spells.P.range, false, myHero.pos) then
			self:CastW()
		end
	end
	if Menu.Combo.Q:Value() and self:IsReady(_Q) then
		local target = self:GetTarget(Spells.Q.range)
		if target ~= nil and self:IsValidTarget(target, Spells.Q.range, false, myHero.pos) then
			self:CastQ(target)
		end
	end
	if Menu.Combo.R:Value() and self:IsReady(_R) and (not self:IsReady(_Q) or not Menu.Combo.Q:Value()) and (not self:IsReady(_W) or not Menu.Combo.W:Value())
		and (not self:IsReady(_E) or not Menu.Combo.E:Value()) then
		local target = self:GetTarget(Menu.Misc.R:Value())
		if target ~= nil and self:IsEnough() then
			self:CastR()
		end
	end
end

function KatarinaPonche:Harass()
	if Menu.Harass.Disabled:Value() then return end
	if Menu.Harass.E:Value() and self:IsReady(_E) and not Spin then
		for i=1,#daggerPos do
			for i, Enemy in pairs(self:GetEnemyHeroes()) do
				if self:IsValidTarget(Enemy, Spells.E.range + Spells.P.range, false, myHero.pos) and self:IsValidTarget(Enemy, Spells.P.range, false, daggerPos[i]) then
					self:CastE(daggerPos[i])
				end
			end
		end
	end
	if Menu.Harass.E:Value() and self:IsReady(_E) then
		local target = self:GetTarget(Spells.E.range)
		if target ~= nil and self:IsValidTarget(target, Spells.E.range, false, myHero.pos)then
			self:CastE(target)
		end
	end
	if Menu.Harass.W:Value() and self:IsReady(_W) then
		local target = self:GetTarget(Spells.P.range)
		if target ~= nil and self:IsValidTarget(target, Spells.P.range, false, myHero.pos) then
			self:CastW()
		end
	end
	if Menu.Harass.Q:Value() and self:IsReady(_Q) then
		local target = self:GetTarget(Spells.Q.range)
		if target ~= nil and self:IsValidTarget(target, Spells.Q.range, false, myHero.pos) then
			self:CastQ(target)
		end
	end
end

function KatarinaPonche:IsEnough(pos)
	local count = 0
	for K, Enemy in pairs(self:GetEnemyHeroes()) do
		if self:IsValidTarget(Enemy, Menu.Misc.R:Value(), false, myHero.pos) then
			count = count + Menu.RManager[Enemy.charName]:Value()
		end
	end
	if count >= Menu.RManager.MinR:Value() then return true
	else return false end
end

function KatarinaPonche:GetTarget(range)
  local target = nil
  local lessCast = 0
  local GetEnemyHeroes = self:GetEnemyHeroes()
  for i = 1, #GetEnemyHeroes do
  	local Enemy = GetEnemyHeroes[i]
    if self:IsValidTarget(Enemy, range, false, myHero.pos) then
      local Armor = (100 + Enemy.magicResist) / 100
      local Killable = Armor * Enemy.health
      if Killable <= lessCast or lessCast == 0 then
        target = Enemy
        lessCast = Killable
      end
    end
  end
  return target
end

function KatarinaPonche:IsRecalling()
	for K, Buff in pairs(self:GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function KatarinaPonche:IsBuffed(target, BuffName)
	for K, Buff in pairs(GetBuffs(target)) do
		if Buff.name == BuffName then
			return true
		end
	end
	return false
end

function KatarinaPonche:GetAllyHeroes()
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function KatarinaPonche:GetEnemyHeroes()
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

function KatarinaPonche:GetMinions(range)
	EnemyMinions = {}
	for i = 1, Game.MinionCount() do
		local Minion = Game.Minion(i)
		if self:IsValidTarget(Minion, range, false, myHero) then
			table.insert(EnemyMinions, Minion)
		end
	end
end

function KatarinaPonche:GetPercentMP(unit)
	return 100 * unit.mana / unit.maxMana
end

function KatarinaPonche:GetPercentHP(unit)
	return 100 * unit.health / unit.maxHealth
end

function KatarinaPonche:GetBuffs(unit)
	T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(T, Buff)
		end
	end
	return T
end

function KatarinaPonche:IsImmune(unit)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if (Buff.name == "kindredrnodeathbuff" or Buff.name == "undyingrage") and GetPercentHP(unit) <= 10 then
			return true
		end
		if Buff.name == "vladimirsanguinepool" or Buff.name == "judicatorintervention" or Buff.name == "zhonyasringshield" then 
            return true
        end
	end
	return false
end

function KatarinaPonche:IsValidTarget(unit, range, checkTeam, from)
    local range = range == nil and math.huge or range
    if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or self:IsImmune(unit) or (checkTeam and unit.isAlly) then 
        return false 
    end 
    return unit.pos:DistanceTo(from) < range 
end

function KatarinaPonche:IsReady(slot)
	if  myHero:GetSpellData(slot).currentCd == 0 and myHero:GetSpellData(slot).level > 0 then
		return true
	end
	return false
end

function KatarinaPonche:Draw()
	if Menu.Draw.Disabled:Value() then return end
	if Menu.Draw.Q.Enabled:Value() and (not Menu.Draw.CD:Value() or IsReady(_Q)) then
		Draw.Circle(myHero.pos, Spells.Q.range, 1, Menu.Draw.Q.Color:Value())
	end
	if Menu.Draw.E.Enabled:Value() and (not Menu.Draw.CD:Value() or IsReady(_E)) then
		Draw.Circle(myHero.pos, Spells.E.range, 1, Menu.Draw.E.Color:Value())
	end
	if Menu.Draw.R.Enabled:Value() and (not Menu.Draw.CD:Value() or IsReady(_R)) then
		Draw.Circle(myHero.pos, Menu.Misc.R:Value(), 1, Menu.Draw.R.Color:Value())
	end
end