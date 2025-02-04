local Rebalance
Rebalance = 1
Rebalanze = 1
if SETTINGS["ImbaSubClasses"]==false then
Rebalance = 0.95
Rebalanze = 0
end

ASSASSIN=SETTINGS["ArcherAsAssassin"]
if ASSASSIN==true then


-- damage scaling with speed (meant to be like classic Agility stat)
function events.CalcDamageToMonster(t)
	local data = WhoHitMonster()
	if data.Player and (data.Player.Class==const.Class.WarriorMage or data.Player.Class==const.Class.BattleMage or data.Player.Class==const.Class.Archer) and t.DamageKind==0 and data.Object==nil then
			speed=data.Player:GetSpeed()
			bonusDamage=speed/500
			t.Result=t.Result*(1+bonusDamage*Rebalanze)*Rebalance
		end
	
end
--Energy Spender, when energy is 30 or more and adds a combo point up to 5
function events.CalcDamageToMonster(t)		
	local data = WhoHitMonster()
	if data.Player and (data.Player.Class==const.Class.WarriorMage or data.Player.Class==const.Class.BattleMage or data.Player.Class==const.Class.Archer) and data.Player.SP>=30 and t.DamageKind==0 and data.Object==nil then
	--get mastery
	mastery=data.Player.Skills[const.Skills.Thievery]
	if mastery>=64 then 
	mastery=mastery-64
	rank=2
	end
	if mastery>=64 then
	mastery=mastery-64
	rank=3
	end
		t.Result=t.Result*(1.2+0.1*mastery)
		data.Player.SP=data.Player.SP-30
		    if comboPoint==nil then
		    comboPoint=0
				else if comboPoint<5 then
				comboPoint=comboPoint+1
				end
			end
	end
end
--have a 30% chance to replenish 15 energy when attacking
function events.CalcDamageToMonster(t)		
	data = WhoHitMonster()
	if data.Player and (data.Player.Class==const.Class.WarriorMage or data.Player.Class==const.Class.BattleMage or data.Player.Class==const.Class.Archer) and t.DamageKind==0 and data.Object==nil then	
		if math.random(1,100)<=30 then
			data.Player.SP=data.Player.SP+15
		end
	end
end


--consume combo points
function events.CalcSpellDamage(t)
--get mastery

	local data = WhoHitMonster()
	if data.Player and (data.Player.Class==const.Class.WarriorMage or data.Player.Class==const.Class.BattleMage or data.Player.Class==const.Class.Archer) then	
	
	mastery=data.Player.Skills[const.Skills.Thievery]
	if mastery>=64 then 
	mastery=mastery-64
	rank=2
	end
	if mastery>=64 then
	mastery=mastery-64
	rank=3
	end
	
    if comboPoint==nil then
		comboPoint=0
	end
	if comboPoint==0 then
        t.Result=t.Result*0.5
	end
	if comboPoint<5 then
        t.Result=t.Result*(1+0.2*comboPoint)*(1+mastery*0.05) 
		comboPoint=0		
	end
	if comboPoint==5 then
            t.Result=t.Result*2.5*(1+mastery*0.05) 
			comboPoint=0
	end
		comboPoint=0
    end

	
end

--function events.CalcDamageToPlayer(t)
--	evt.FaceExpression{Player = "Current", Frame = 33}
--	t.Result=0
--end
--SP increase items will add only 1/5 of SP
function events.CalcStatBonusByItems(t)
	if (t.Player.Class==const.Class.WarriorMage or t.Player.Class==const.Class.BattleMage or t.Player.Class==const.Class.Archer) and t.Stat == const.Stats.SP then
		for it in t.Player:EnumActiveItems() do
			if it.Bonus==9 then
				t.Result = t.Result/5
			end
		end
	end
end


--Dodge
function events.CalcDamageToPlayer(t)
	if (t.Player.Class==const.Class.WarriorMage or t.Player.Class==const.Class.BattleMage or t.Player.Class==const.Class.Archer and t.DamageKind==0) then
--GET MASTERY SKILL
	mastery=t.Player.Skills[const.Skills.Thievery]
	if mastery>=64 then 
	mastery=mastery-64
	rank=2
	end
	if mastery>=64 then
	mastery=mastery-64
	rank=3
	end
	
		roll=math.random(1, 100)
		--dodge change=5 base +1% per skill point
		if roll<=mastery+5 then
			t.Result=0
			Game.ShowStatusText("Dodged")
			evt.FaceExpression{Player = t.PlayerIndex, Frame = 33}
		end
	end
end


--Set base of 100 energy and starting skills




function events.GameInitialized2()
    Game.Classes.HPFactor[const.Class.Archer] = 2
	Game.Classes.SPFactor[const.Class.Archer] = 0
    Game.Classes.HPFactor[const.Class.BattleMage] = 3
	Game.Classes.SPFactor[const.Class.BattleMage] = 0
    Game.Classes.HPFactor[const.Class.WarriorMage] = 4
	Game.Classes.SPFactor[const.Class.WarriorMage] = 0
	Game.ClassKinds.StartingSkills[4][const.Skills.Dark] = 0
	Game.ClassKinds.StartingSkills[4][const.Skills.Axe] = 0
	Game.ClassKinds.StartingSkills[4][const.Skills.Spear] = 0
	Game.ClassKinds.StartingSkills[4][const.Skills.Chain] = 0
	Game.ClassKinds.StartingSkills[4][const.Skills.Bodybuilding] = 2
	Game.ClassKinds.StartingSkills[4][const.Skills.Thievery] = 1
	Game.ClassKinds.StartingSkills[4][const.Skills.Meditation] = 0
	Game.ClassKinds.SPBase[4] = 100
Game.ClassNames[const.Class.Archer]="Rogue"
Game.ClassNames[const.Class.BattleMage]="Shadow"
Game.ClassNames[const.Class.WarriorMage]="Assassin"
Game.ClassDescriptions[const.Class.Archer] = "A rogue is a daring and cunning warrior, skilled in the art of deception and quick thinking. Their agility and speed allow them to strike with deadly precision, always staying one step ahead of their opponents.\n\nStats:\nHP: 2 per level\nEnergy (SP): 100 base, no SP per level\n5% dodge\n\nAbilities:\nCan use Elemental Spells\nEach 5 points in Speed will increase damage by 1%\nMelee attacks have a 30% chance to restore 15 energy.\nYou will automatically restore 40 energy every 10 seconds\nMastery will add 1% dodge and 5% combo point skills\n\nAttack:\nConsumes 30 energy to deal 20%+10% per mastery point increased damage (can crit)\nAdds a combo point, up to 5\n\nSpell Cast:\nConsumes all combo points\nDeals 20% increased damage per combo point consumed\nIf 5 combo points are consumed, damage will increase by 250%\nSpell cast with no combo points will do half the damage\n\nMastery\nEach point of mastery will increase damage of energy spender by 10%, and combo point ability by 5% " 
Game.ClassDescriptions[const.Class.BattleMage] ="Shadow, the ultimate evolution of the rogue. Masters of deadly precision, they strike with unmatched agility and cunning. Their blades cut through enemies with ease, and their power lies in their ability to manipulate darkness. They are the masters of fear, striking terror into the hearts of their foes. The Shadow is a force to be reckoned with, feared by all who stand in their way.\nStats:\nHP: 3 per level\nEnergy (SP): 100 base, no SP per level\n5% dodge\nAbilities:\nCan use Elemental Spells\nEach 5 points in Speed will increase damage by 1%\nMelee attacks have a 30% chance to restore 15 energy.\nYou will automatically restore 40 energy every 10 seconds\nMastery will add 1% dodge and 5% combo point skills\n\nAttack:\nConsumes 30 energy to deal 20%+10% per mastery point increased damage (can crit)\nAdds a combo point, up to 5\n\nSpell Cast:\nConsumes all combo points\nDeals 20% increased damage per combo point consumed\nIf 5 combo points are consumed, damage will increase by 250%\nSpell cast with no combo points will do half the damage\n\nMastery\nEach point of mastery will increase damage of energy spender by 10%, and combo point ability by 5% " 
Game.ClassDescriptions[const.Class.WarriorMage] ="Assassin, the ultimate evolution of the shadow. They strike with ruthless precision and deadly blades, able to eliminate their targets with a single, fatal blow. Their movements are graceful and silent, and their mastery of assassination is unmatched. \n\nStats:\nHP: 4 per level\nEnergy (SP): 100 base, no SP per level\n5% dodge\n\nAbilities:\nCan use Elemental Spells\nEach 5 points in Speed will increase damage by 1%\nMelee attacks have a 30% chance to restore 15 energy.\nYou will automatically restore 40 energy every 10 seconds\nMastery will add 1% dodge and 5% combo point skills\n\nAttack:\nConsumes 30 energy to deal 20%+10% per mastery point increased damage (can crit)\nAdds a combo point, up to 5\n\nSpell Cast:\nConsumes all combo points\nDeals 20% increased damage per combo point consumed\nIf 5 combo points are consumed, damage will increase by 250%\nSpell cast with no combo points will do half the damage\n\nMastery\nEach point of mastery will increase damage of energy spender by 10%, and combo point ability by 5% "
end	

--timers
local function restoreManaArcher() 
	for _, pl in Party do 
		if pl.Class == const.Class.Archer then 
			pl.SP = math.min(pl.SP + 1, pl:GetFullSP()) 
		end 
	end 
end
--Timer(restoreManaArcher, const.Second*30) 

local function restoreManaBattleMage() 
	for _, pl in Party do 
		if pl.Class == const.Class.BattleMage then 
			pl.SP = math.min(pl.SP + 1, pl:GetFullSP()) 
		end 
	end 
end
--Timer(restoreManaBattleMage, const.Second*20) 

local function restoreManaWarriorMage() 
	for _, pl in Party do 
		if pl.Class == const.Class.WarriorMage then 
			pl.SP = math.min(pl.SP + 1, pl:GetFullSP()) 
		end 
	end 
end
--Timer(restoreManaWarriorMage, const.Second*15) 

function events.LoadMap(wasInGame)
local function restoreManaArcher() 
	for _, pl in Party do 
		if pl.Class == const.Class.Archer then 
			pl.SP = math.min(pl.SP + 2, pl:GetFullSP()) 
		end 
	end 
end
Timer(restoreManaArcher, const.Minute/2) 

local function restoreManaBattleMage() 
	for _, pl in Party do 
		if pl.Class == const.Class.BattleMage then 
			pl.SP = math.min(pl.SP + 3, pl:GetFullSP()) 
		end 
	end 
end
Timer(restoreManaBattleMage, const.Minute/2) 

local function restoreManaWarriorMage() 
	for _, pl in Party do 
		if pl.Class == const.Class.WarriorMage then 
			pl.SP = math.min(pl.SP + 4, pl:GetFullSP()) 
		end 
	end 
end
Timer(restoreManaWarriorMage, const.Minute/2) 
end

end

