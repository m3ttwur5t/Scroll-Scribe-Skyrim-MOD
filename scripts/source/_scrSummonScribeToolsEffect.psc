Scriptname _scrSummonScribeToolsEffect extends ActiveMagicEffect  
_scrWorkstationManagerScript Property WorkstationScript Auto

Furniture Property WorkbenchBase  Auto  
Container Property WorkbenchExtract  Auto  
Container Property WorkbenchFusion  Auto  
Container Property WorkbenchUpscaler  Auto  

Activator Property EffectSummon Auto
Activator Property EffectBanish Auto

Perk Property ExtractorPerk Auto
Perk Property FusionPerk Auto
Perk Property AmplifierPerk Auto

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
	if ThisActor.HasPerk(AmplifierPerk)
		SummonUpscaleBox()
	endif
EndFunction

Function SummonBasicBench()
	float SpawnOffsetX = SpawnDistance * math.sin(SpawnAngleZ)
	float SpawnOffsetY = SpawnDistance * math.cos(SpawnAngleZ)
	
	WorkstationScript.SummonedBenchBase = ThisActor.PlaceAtMe(WorkbenchBase,1,FALSE,true)
	WorkstationScript.SummonedBenchBase.SetPosition(ThisActor.X + SpawnOffsetX, ThisActor.Y + SpawnOffsetY, ThisActor.Z)
	WorkstationScript.SummonedBenchBase.SetAngle(0.0, 0.0, SpawnAngleZ)
	WorkstationScript.SummonedBenchBase.PlaceAtMe(EffectSummon,1,FALSE,false)
	WorkstationScript.SummonedBenchBase.SetActorOwner(ThisActor.GetActorBase())
	Utility.Wait(0.5)
	WorkstationScript.SummonedBenchBase.EnableNoWait(True)
EndFunction

Function SummonExtractor()
	float mySpawnOffsetX = WorkstationScript.SummonedBenchBase.X + 40 * math.cos(SpawnAngleZ) + 70 * math.sin(SpawnAngleZ)
	float mySpawnOffsetY = WorkstationScript.SummonedBenchBase.Y + 70 * math.cos(SpawnAngleZ) - 40 * math.sin(SpawnAngleZ)
	float mySpawnOffsetZ = WorkstationScript.SummonedBenchBase.Z + 35.0
	
	WorkstationScript.SummonedBenchExtract = WorkstationScript.SummonedBenchBase.PlaceAtMe(WorkbenchExtract,1,FALSE,true)
	WorkstationScript.SummonedBenchExtract.SetPosition(mySpawnOffsetX, mySpawnOffsetY, mySpawnOffsetZ)
	WorkstationScript.SummonedBenchExtract.SetScale(0.70)
	WorkstationScript.SummonedBenchExtract.SetAngle(0.0, 0.0, SpawnAngleZ + 30)
	WorkstationScript.SummonedBenchExtract.SetActorOwner(ThisActor.GetActorBase())
	WorkstationScript.SummonedBenchExtract.EnableNoWait(True)
EndFunction

Function SummonFusionBox()
	float mySpawnOffsetX = WorkstationScript.SummonedBenchBase.X - 40 * math.cos(SpawnAngleZ) + 85 * math.sin(SpawnAngleZ)
	float mySpawnOffsetY = WorkstationScript.SummonedBenchBase.Y + 85 * math.cos(SpawnAngleZ) + 40 * math.sin(SpawnAngleZ)
	float mySpawnOffsetZ = WorkstationScript.SummonedBenchBase.Z + 66.0
	
	WorkstationScript.SummonedBenchFusion = WorkstationScript.SummonedBenchBase.PlaceAtMe(WorkbenchFusion,1,FALSE,true)
	WorkstationScript.SummonedBenchFusion.SetPosition(mySpawnOffsetX, mySpawnOffsetY, mySpawnOffsetZ)
	WorkstationScript.SummonedBenchFusion.SetScale(0.3)
	WorkstationScript.SummonedBenchFusion.SetAngle(0.0, 0.0, SpawnAngleZ + 45)
	WorkstationScript.SummonedBenchFusion.SetActorOwner(ThisActor.GetActorBase())
	WorkstationScript.SummonedBenchFusion.EnableNoWait(True)
EndFunction

Function SummonUpscaleBox()
	float mySpawnOffsetX = WorkstationScript.SummonedBenchBase.X - 0 * math.cos(SpawnAngleZ) + 100 * math.sin(SpawnAngleZ)
	float mySpawnOffsetY = WorkstationScript.SummonedBenchBase.Y + 100 * math.cos(SpawnAngleZ) + 0 * math.sin(SpawnAngleZ)
	float mySpawnOffsetZ = WorkstationScript.SummonedBenchBase.Z + 66.0
	
	WorkstationScript.SummonedBenchUpscale = WorkstationScript.SummonedBenchBase.PlaceAtMe(WorkbenchUpscaler,1,FALSE,true)
	WorkstationScript.SummonedBenchUpscale.SetPosition(mySpawnOffsetX, mySpawnOffsetY, mySpawnOffsetZ)
	WorkstationScript.SummonedBenchUpscale.SetScale(0.08)
	WorkstationScript.SummonedBenchUpscale.SetAngle(0.0, 0.0, SpawnAngleZ + 0)
	WorkstationScript.SummonedBenchUpscale.SetActorOwner(ThisActor.GetActorBase())
	WorkstationScript.SummonedBenchUpscale.EnableNoWait(True)
EndFunction

Function BanishWorkbenches()
	
	WorkstationScript.SummonedBenchBase.PlaceAtMe(EffectBanish,1,FALSE,false)
	Utility.Wait(0.5)
	WorkstationScript.SummonedBenchBase.DisableNoWait(true)
	WorkstationScript.SummonedBenchBase.Delete()
	WorkstationScript.SummonedBenchBase = none
	
	if WorkstationScript.SummonedBenchExtract
		WorkstationScript.SummonedBenchExtract.RemoveAllItems(ThisActor)
		WorkstationScript.SummonedBenchExtract.DisableNoWait(true)
		WorkstationScript.SummonedBenchExtract.Delete()
		WorkstationScript.SummonedBenchExtract = none
	endif
	
	if WorkstationScript.SummonedBenchFusion
		WorkstationScript.SummonedBenchFusion.RemoveAllItems(ThisActor)
		WorkstationScript.SummonedBenchFusion.DisableNoWait(true)
		WorkstationScript.SummonedBenchFusion.Delete()
		WorkstationScript.SummonedBenchFusion = none
	endif
	
	if WorkstationScript.SummonedBenchUpscale
		WorkstationScript.SummonedBenchUpscale.RemoveAllItems(ThisActor)
		WorkstationScript.SummonedBenchUpscale.DisableNoWait(true)
		WorkstationScript.SummonedBenchUpscale.Delete()
		WorkstationScript.SummonedBenchUpscale = none
	endif
EndFunction