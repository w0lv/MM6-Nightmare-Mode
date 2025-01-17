diffIncrease=30
diffMod=diffIncrease/100

PowerCureOverflow=SETTINGS["PowerCureOverflow"]
function events.HealingSpellPower(t)
  if t.Spell == 54 then
    active = 0
	t.Result=0
    for i = 0, 3 do
      if Party[i].Dead == 0 and Party[i].Eradicated == 0 and Party[i].Stoned == 0 and Party[i].Unconscious == 0 then
        active = active + 1
		t.Result=t.Result+Party[i].HP
      end
    end
	settedhp=t.Result/active
	overflow=0
	
	--get list with hp ordered
	hpList = {} 
	 for i = 0, 3 do
      if Party[i].Dead == 0 and Party[i].Eradicated == 0 and Party[i].Stoned == 0 and Party[i].Unconscious == 0 then
        table.insert(hpList, {index = i, hp = Party[i].HP})
      end
    end
	
	-- Sort the hpList based on HP values in ascending order
    table.sort(hpList, function(a, b) return a.hp < b.hp end)
	
		for v = 1, #hpList do
		i=hpList[v].index
		  if Party[i].Dead == 0 and Party[i].Eradicated == 0 and Party[i].Stoned == 0 and Party[i].Unconscious == 0 then
			if settedhp > Party[i]:GetFullHP() then
				overflow=(settedhp-Party[i]:GetFullHP())
				active=math.max(1,active-1)
				settedhp=settedhp+overflow/active
				--debug.Message(dump(overflow))
				--debug.Message(dump(active))
				--debug.Message(dump(settedhp))
			end
		  end
		end

	if active>0 then
	t.Result=settedhp*4
	end
	--bonus from skill items etc
	
	personality=t.Caster:GetPersonality()
	intellect=t.Caster:GetIntellect()
	bonus=math.max(personality,intellect)
	luck=t.Caster:GetLuck()
	roll=math.random(1,1000)
	crownbonus=1
	ringbonus=1
	artifactbonus=1
	it=t.Caster:GetActiveItem(4)
	if it then
		if it.Charges>1000 then
			crownbonus=(it.Charges%1000)/100+1
		end
	end
	
	for it in t.Caster:EnumActiveItems() do
		if it.Bonus2 == 33 then		
			ringbonus=1.5
		end
		if it.Number==413 then
			artifactbonus=1.5
		end
	end
	
	if SETTINGS["TRUENIGHTMARE"]~=true then
		if roll<=luck+50 then
		t.Result = t.Result+9*t.Skill*(1+bonus/500)*(1.5+bonus/500)*crownbonus*ringbonus*artifactbonus
		Game.ShowStatusText("Critical Heal")
		else
		t.Result = t.Result+9*t.Skill*(1+bonus/500)*crownbonus*ringbonus*artifactbonus
		end
	else
		if roll<=luck+50 then
		t.Result = t.Result+9*t.Skill*(1+bonus/500)*(1.5+bonus/500)*crownbonus*ringbonus*artifactbonus*(1-diffMod)
		Game.ShowStatusText("Critical Heal")
		else
		t.Result = t.Result+9*t.Skill*(1+bonus/500)*crownbonus*ringbonus*artifactbonus*(1-diffMod)
		end
	end
end




if t.Spell == 77 and PowerCureOverflow then
--t.Result = t.Result / 4
a2=0
b2=0
c2=0
d2=0
	a = Party[0]:GetFullHP()-Party[0].HP-t.Result
	if a < 0 then
	a2 = a * -1
	a = 0
	end
 		b = Party[1]:GetFullHP()-Party[1].HP-t.Result
	if b < 0 then
	b2 = b * -1
	b = 0
	end
		c = Party[2]:GetFullHP()-Party[2].HP-t.Result
	if c < 0 then
	c2 = c * -1
	c = 0
	end
		d = Party[3]:GetFullHP()-Party[3].HP-t.Result
	if d < 0 then
	d2 = d * -1
	d = 0
	end

	if a2 < 0 then
	a2 = 0
	end
	if b2 < 0 then
	b2 = 0
	end
	if c2 < 0 then
	c2 = 0
	end
	if d2 < 0 then
	d2 = 0
	end

MissHP = a + b + c + d
surplus = (a2 + b2 + c2 + d2)/6


Party[0].HP = math.min(Party[0]:GetFullHP(), Party[0].HP + surplus * a / MissHP, 32767)
Party[1].HP = math.min(Party[1]:GetFullHP(), Party[1].HP + surplus * b / MissHP, 32767)
Party[2].HP = math.min(Party[2]:GetFullHP(), Party[2].HP + surplus * c / MissHP, 32767)
Party[3].HP = math.min(Party[3]:GetFullHP(), Party[3].HP + surplus * d / MissHP, 32767)
if Party[0].HP > Party[0]:GetFullHP() then
Party[0].HP = Party[0]:GetFullHP()
end
if Party[1].HP > Party[1]:GetFullHP() then
Party[1].HP = Party[1]:GetFullHP()
end
if Party[2].HP > Party[2]:GetFullHP() then
Party[2].HP = Party[2]:GetFullHP()
end
if Party[3].HP > Party[3]:GetFullHP() then
Party[3].HP = Party[3]:GetFullHP()
end
--t.Result = t.Result * 4
end
end

--changes for TRUE NIGHTMARE MODE
if SETTINGS["TRUENIGHTMARE"]==true then
	function events.HealingSpellPower(t)
		if t.Spell ~= 54 then
			t.Result=t.Result*(1-diffMod)
		end
	end

	function events.CalcDamageToMonster(t)
		t.Result=t.Result*(1-diffMod)
		--nerf to vampiric
		data=WhoHitMonster()
		leech=0
		if data and data.Player and data.Object==nil and t.DamageKind==0 then
			for it in data.Player:EnumActiveItems() do
				if it.Bonus2 == 16 or it.Bonus2 == 41 then
					if t.Result<t.Monster.HP then
						leech=1
					end
				end
			end
		end
		if leech==1 then
			data.Player.HP=data.Player.HP-t.Result*0.05
		end
		leech=0
	end

	function events.CalcDamageToPlayer(t)
		t.Result=t.Result*(1+diffMod)
	end
	
	function events.BeforeNewGameAutosave() 
		vars.TRUENIGHTMARE=true
	end
end


function events.LoadMap()
	--check for TNM
	if vars.TRUENIGHTMARE==true and SETTINGS["TRUENIGHTMARE"]~=true then
		Sleep(1)
		Message("this is a True Nightmare save. ACTIVATE it in mm6.ini")
		Game.ExitMapAction=7
	end
	if vars.TRUENIGHTMARE==nil and SETTINGS["TRUENIGHTMARE"]==true then
		Sleep(1)
		Message("this is NOT a True Nightmare save. DEACTIVATE it in mm6.ini")
		Game.ExitMapAction=7
	end
	--check for settings
	if vars.TRUENIGHTMARE and vars.TRUENIGHTMARE then
		if SETTINGS["RandomizeMapClusters"]~=false then
			Sleep(1)
			Message("Set RandomizedMapClusters to false in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["AdaptiveMonsterMode"]~="disabled" then
			Sleep(1)
			Message("Set AdaptiveMonsterMode to disabled in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["EasierMonsters"]~=false then
			Sleep(1)
			Message("Set EasierMonsters to false in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["MoreLinkedSkills"]~=false then
			Sleep(1)
			Message("Set MoreLinkedSkills to false in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["MonsterExperienceMultiplier"]~=1.00 then
			Sleep(1)
			Message("Set MonsterExperienceMultiplier to 1.00 in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["GlobalMapResetDays"]~="default" then
			Sleep(1)
			Message("Set GlobalMapResetDays to default in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["HomingProjectiles"]~=true then
			Sleep(1)
			Message("Set HomingProjectiles to true in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["EqualizedMode"]~=false then
			Sleep(1)
			Message("Set EqualizedMode to false in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["ItemRework"]~=true then
			Sleep(1)
			Message("Set ItemRework to true in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["StatsRework"]~=true then
			Sleep(1)
			Message("Set StatsRework to true in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end
		if SETTINGS["PowerCureOverflow"]~=false then
			Sleep(1)
			Message("Set PowerCureOverflow to false in mm6.ini to play True Nightmare")
			Game.ExitMapAction=7
		end	
	end
end
