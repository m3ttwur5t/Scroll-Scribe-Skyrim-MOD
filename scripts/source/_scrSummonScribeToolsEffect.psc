Scriptname _scrSummonScribeToolsEffect extends ActiveMagicEffect  
_scrWorkstationManagerScript Property WorkstationScript Auto

Furniture Property WorkbenchBase  Auto  
Container Property WorkbenchExtract  Auto  
Container Property WorkbenchFusion  Auto  

Activator Property EffectSummon Auto
Activator Property EffectBanish Auto

Perk Property ExtractorPerk Auto
Perk Property FusionPerk Auto

Actor ThisActor

float Property SpawnDistance = 80.0 Auto
float SpawnAngleZ

Event OnEffectStart(Actor akTarget, Actor akCaster)
	ThisActor = akTarget
	
	if ThisActor.IsInCombat()
		Debug.Notification("Cannot be used during combat.")
		return
	endif
	
	if WorkstationScript.IsBusy
		Debug.Notification("Workstation is still busy...")
		return
	endif
	
	if !WorkstationScript.SummonedBenchBase
		SummonWorkbenches()
	else
		BanishWorkbenches()
	endif
endEvent

Function SummonWorkbenches()
	SpawnAngleZ = ThisActor.GetAngleZ()
	SummonBasicBench()
	if ThisActor.HasPerk(ExtractorPerk)
		SummonExtractor()
	endif
	if ThisActor.HasPerk(FusionPerk)
		SummonFusionBox()
	endif
EndFunction

Function SummonBasicBench()
	float SpawnOffsetX = SpawnDistance * math.sin(SpawnAngleZ)
	float SpawnOffsetY = SpawnDistance * math.cos(SpawnAngleZ)
	
	WorkstationScript.SummonedBenchBase = ThisActor.PlaceAtMe(WorkbenchBase,1,FALSE,true)
	WorkstationScript.SummonedBenchBase.SetPosition(ThisActor.X + SpawnOffsetX, ThisActor.Y + SpawnOffsetY, ThisActor.Z)
	WorkstationScript.SummonedBenchBase.SetAngle(0.0, 0.0, SpawnAngleZ)
	WorkstationScript.SummonedBenchBase.PlaceAtMe(EffectSummon,1,FALSE,false)
	Utility.Wait(0.5)
	WorkstationScript.SummonedBenchBase.EnableNoWait(True)
EndFunction

Function SummonExtractor()
	float mySpawnOffsetX = WorkstationScript.SummonedBenchBase.X + 36 * math.cos(SpawnAngleZ) + 80 * math.sin(SpawnAngleZ)
	float mySpawnOffsetY = WorkstationScript.SummonedBenchBase.Y + 80 * math.cos(SpawnAngleZ) - 36 * math.sin(SpawnAngleZ)
	float mySpawnOffsetZ = WorkstationScript.SummonedBenchBase.Z + 30.0
	
	WorkstationScript.SummonedBenchExtract = WorkstationScript.SummonedBenchBase.PlaceAtMe(WorkbenchExtract,1,FALSE,true)
	WorkstationScript.SummonedBenchExtract.SetPosition(mySpawnOffsetX, mySpawnOffsetY, mySpawnOffsetZ)
	WorkstationScript.SummonedBenchFusion.SetScale(0.75)
	WorkstationScript.SummonedBenchExtract.SetAngle(0.0, 0.0, SpawnAngleZ + 30)
	WorkstationScript.SummonedBenchExtract.EnableNoWait(True)
EndFunction

Function SummonFusionBox()
	float mySpawnOffsetX = WorkstationScript.SummonedBenchBase.X - 36 * math.cos(SpawnAngleZ) + 80 * math.sin(SpawnAngleZ)
	float mySpawnOffsetY = WorkstationScript.SummonedBenchBase.Y + 80 * math.cos(SpawnAngleZ) + 36 * math.sin(SpawnAngleZ)
	float mySpawnOffsetZ = WorkstationScript.SummonedBenchBase.Z + 66.0
	
	WorkstationScript.SummonedBenchFusion = WorkstationScript.SummonedBenchBase.PlaceAtMe(WorkbenchFusion,1,FALSE,true)
	WorkstationScript.SummonedBenchFusion.SetPosition(mySpawnOffsetX, mySpawnOffsetY, mySpawnOffsetZ)
	WorkstationScript.SummonedBenchFusion.SetScale(0.3)
	WorkstationScript.SummonedBenchFusion.SetAngle(0.0, 0.0, SpawnAngleZ + 45)
	WorkstationScript.SummonedBenchFusion.EnableNoWait(True)
EndFunction

Function BanishWorkbenches()
	WorkstationScript.SummonedBenchBase.PlaceAtMe(EffectBanish,1,FALSE,false)
	Utility.Wait(1.0)
	WorkstationScript.SummonedBenchBase.DisableNoWait(true)
	WorkstationScript.SummonedBenchBase.Delete()
	WorkstationScript.SummonedBenchBase = none
	
	WorkstationScript.SummonedBenchExtract.DisableNoWait(true)
	WorkstationScript.SummonedBenchExtract.Delete()
	WorkstationScript.SummonedBenchExtract = none
	
	WorkstationScript.SummonedBenchFusion.DisableNoWait(true)
	WorkstationScript.SummonedBenchFusion.Delete()
	WorkstationScript.SummonedBenchFusion = none
EndFunction