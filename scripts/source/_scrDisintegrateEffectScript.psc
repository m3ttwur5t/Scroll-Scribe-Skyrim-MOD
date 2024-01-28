Scriptname _scrDisintegrateEffectScript extends ActiveMagicEffect  

FormList Property ImmunityList auto
EffectShader property MagicEffectShader auto
Activator property AshPileObject auto
MiscObject Property ArcaneDust auto

Actor thisActor
int dustAdded

Event OnEffectStart(Actor akTarget, Actor akCaster)
  thisActor = akTarget
endEvent

Event OnDying(Actor Killer)
	bool isImmune
	if ImmunityList == none
		isImmune = False
	else
		ActorBase thisActorBase = thisActor.GetBaseObject() as ActorBase
		Race thisActorRace = thisActorBase.GetRace()
		
		if ImmunityList.hasform(thisActorRace)
			isImmune = True
		elseif ImmunityList.hasform(thisActorBase)
			isImmune = True
		else
			isImmune = False
		endif
	endif

	if isImmune == False
		float healthPct = thisActor.GetActorValuePercentage("Health")
		float curHealth = thisActor.GetActorValue("Health")
		float maxHealth = Math.Ceiling(curHealth / healthPct)
		float diffHealth = Math.Ceiling( curHealth - maxHealth * 0.2)
		;Debug.Notification("Cur: " + curHealth + ", Max: " + maxHealth + ", Diff: " + diffHealth + ", Pct: " + healthPct)
		dustAdded = m3Helper.Min(maxHealth as int, -1 * diffHealth as int)
		thisActor.AddItem(ArcaneDust, dustAdded, true)
		
		thisActor.SetCriticalStage(thisActor.CritStage_DisintegrateStart)

		if	MagicEffectShader != none
			MagicEffectShader.play(thisActor)
		endif
		
		utility.wait(0.75)     
		thisActor.AttachAshPile(AshPileObject)

		utility.wait(1.65)
		if	MagicEffectShader != none
			MagicEffectShader.stop(thisActor)
		endif

		thisActor.SetAlpha (0.0,True)
		thisActor.SetCriticalStage(thisActor.CritStage_DisintegrateEnd)
	endif
EndEvent