SERAPHIN=SETTINGS["ClericAsSeraphin"]
Mastery=SETTINGS["Mastery"]
if Mastery==true then
if SERAPHIN==false then

function events.HealingSpellPower(t)
	if (t.Caster.Class==const.Class.HighPriest or t.Caster.Class==const.Class.Priest or t.Caster.Class==const.Class.Cleric) then
	mastery=t.Caster.Skills[const.Skills.Thievery]
	if mastery>=64 then 
	mastery=mastery-64
	rank=2
	end
	if mastery>=64 then
	mastery=mastery-64
	rank=3
	end
XSP = t.Caster.SP* mastery * 0.001
if t.Spell == 77 then
XSP = XSP / 4
end
t.Caster.SP = t.Caster.SP - math.floor(XSP)
t.Result =t.Result+XSP^0.7*mastery+mastery
end
end

function events.CalcSpellDamage(t)
	local data = WhoHitMonster()
	if data.Player and (data.Player.Class==const.Class.HighPriest or data.Player.Class==const.Class.Priest or data.Player.Class==const.Class.Cleric) then	
	mastery=data.Player.Skills[const.Skills.Thievery]
	if mastery>=64 then 
	mastery=mastery-64
	rank=2
	end
	if mastery>=64 then
	mastery=mastery-64
	rank=3
	end
YSP = data.Player.SP * mastery * 0.001
data.Player.SP = data.Player.SP - math.floor(YSP)
t.Result =t.Result+YSP^0.7*mastery^0.7+mastery
end
end

function events.CalcDamageToPlayer(t)
	if (t.Player.Class==const.Class.HighPriest or t.Player.Class==const.Class.Priest or t.Player.Class==const.Class.Cleric) and t.Player.Unconscious==0 and t.Player.Dead==0 and t.Player.Eradicated==0  then
	mastery=t.Player.Skills[const.Skills.Thievery]
	if mastery>=64 then 
	mastery=mastery-64
	rank=2
	end
	if mastery>=64 then
	mastery=mastery-64
	rank=3
	end
WSP = t.Result-t.Result*0.97^mastery
t.Player.SP = t.Player.SP - math.floor(WSP^(0.85-mastery/100))
t.Result=t.Result*0.97^mastery

end
end


function events.GameInitialized2()
Game.ClassKinds.StartingSkills[1][const.Skills.Thievery] = 1
	Game.SkillNames[const.Skills.Thievery]="Mastery"
	Game.SkillNames[const.Skills.Diplomacy]="Diplomacy"
	Game.SkillDescriptions[const.Skills.Thievery]="Mastery is a skill that allows players to increase their class bonus, making their character more powerful and effective in combat. The mastery skill is unique to each class, and players must invest points into it to improve their character's mastery level.\nRight-click on 'class name' on top of the 'stats' tab to access a wealth of information about your class's unique mastery abilities. "


end
end
end
