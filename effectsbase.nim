type

  EffectActivationKind* = enum
    eakTurnStart, eakTurnEnd eakBeforeAttack, eakAfterAttack, eakOnSwitchIn, eakOnSwitchOut

  EffectTargetKind* = enum
    etkField, etkSelf, etkPokemon

  EffectKind* = enum
    ekStatus, ekCondition, ekBoost, ekHP, ekTypeChange, ekForceSwitch

  Effect* = ref object of RootObj
    activation*: EffectActivationKind
    target*: EffectTargetKind
