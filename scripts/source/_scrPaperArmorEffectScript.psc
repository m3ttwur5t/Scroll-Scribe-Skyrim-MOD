Scriptname _scrPaperArmorEffectScript extends ActiveMagicEffect  
import PO3_SKSEFunctions

Spell Property StatProviderSpell Auto

Actor ThisActor
Form[] ScrollItemList
int LastValidIndex
int ScrollCount
bool IsProcessing = false

Event OnEffectStart(Actor akTarget, Actor akCaster)
	ThisActor = akTarget
	ScrollItemList = AddItemsOfTypeToArray(ThisActor, 23, abNoEquipped = false, abNoFavorited = false, abNoQuestItem = true)
	if ScrollItemList.Length == 0
		Debug.Notification("No Scrolls to maintain Paper Armor")
		Self.Dispel()
		return
	endif
	
	LastValidIndex = ScrollItemList.Length - 1
	Randomize(ScrollItemList)
	ScrollCount = Count(ScrollItemList)
	
	RefreshSpell(CalcMagnitude(ScrollCount))
endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	ThisActor.DispelSpell(StatProviderSpell)
endEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	if IsProcessing
		return
	endif
	IsProcessing = true
	RegisterForSingleUpdate(2.0)
EndEvent

Event OnUpdate()
	Form destroyedItem = GetValidItem()
	if !destroyedItem
		Debug.Notification("No Scrolls to maintain Paper Armor")
		Self.Dispel()
		return
	endif
	RemoveScroll(destroyedItem)
	RefreshSpell(CalcMagnitude(ScrollCount))
	Randomize(ScrollItemList)
	IsProcessing = false
EndEvent

Function RemoveScroll(Form toRemove)
	ThisActor.RemoveItem(toRemove, aiCount = 1, abSilent = false, akOtherContainer = None)
	ScrollCount -= 1
EndFunction

Function RefreshSpell(float mag)
	ThisActor.RemoveSpell(StatProviderSpell)
	StatProviderSpell.SetNthEffectMagnitude(0, mag)
	StatProviderSpell.SetNthEffectMagnitude(1, mag / 10)
	ThisActor.AddSpell(StatProviderSpell, abVerbose = false)
EndFunction

float Function CalcMagnitude(int n)
	float asFloat = n as float
	float ret = 666.0 * (asFloat / (asFloat + 166.0))
	return ret
EndFunction

Form Function GetValidItem()
	while LastValidIndex >= 0
		Form current = ScrollItemList[LastValidIndex]
		if (ThisActor as ObjectReference).GetItemCount(current) > 0
			return current
		endif
		LastValidIndex -= 1
	endwhile
	return none
EndFunction

int Function Count(Form[] myArray)
	int ret = 0
	int i = 0
	while i < myArray.Length
		Form itm = myArray[i]
		int cnt = (ThisActor as ObjectReference).GetItemCount(myArray[i])
		ret += cnt
		i += 1
	endwhile
	return ret
EndFunction

int Function Randomize(Form[] myArray)
    int i = 0
	int j = 0
    Form tempForm

    while i < LastValidIndex
        j = Utility.RandomInt(0, LastValidIndex)

        tempForm = myArray[i]
        myArray[i] = myArray[j]
        myArray[j] = tempForm
		i += 1
    endwhile
EndFunction