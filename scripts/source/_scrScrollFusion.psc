Scriptname _scrScrollFusion extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	;if ScribeData.EquippedLeft && ScribeData.EquippedRight
	;	Scroll fusedScroll = ScrollScribe.FuseAndCreate(ScribeData.EquippedLeft, ScribeData.EquippedRight)
	;	akTarget.RemoveItem(ScribeData.EquippedLeft, 1)
	;	akTarget.RemoveItem(ScribeData.EquippedRight, 1)
	;	akTarget.AddItem(fusedScroll, 1)
	;
	;	Debug.Notification("Fusion successful! Created " + fusedScroll.GetName())
	;endif
	_scrFusionBag.Activate(Game.GetPlayer())
EndEvent
_scrData Property ScribeData Auto  

ObjectReference Property _scrFusionBag  Auto  
