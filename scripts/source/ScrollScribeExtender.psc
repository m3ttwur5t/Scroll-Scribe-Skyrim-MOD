scriptName ScrollScribeExtender

Scroll function FuseAndCreate(Scroll lhs, Scroll rhs) global native
bool function CanFuse(Scroll lhs, Scroll rhs, bool canDoubleFuse) global native
Scroll function GetScrollForBook(Book spellBook) global native
Spell function GetSpellFromScroll(Scroll theScroll) global native
function OverrideSpell(Spell target, Spell source) global native
Spell function GetZeroCostCopy(Spell source) global native
int function GetApproxFullGoldValue(Form aform) global native
Spell function GetUpgradedSpell(Spell source) global native
Scroll function GetScrollFromSpell(Spell source) global native
