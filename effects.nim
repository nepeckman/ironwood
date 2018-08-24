import condition, poketype
type

  EffectActivationKind* = enum
    eakTurnStart, eakTurnEnd eakBeforeAttack, eakAfterAttack, eakOnSwitchIn, eakOnSwitchOut, eakPassive

  EffectTargetKind* = enum
    etkField, etkSelf, etkPokemon

  EffectKind* = enum
    ekStatus, ekCondition, ekBoost, ekHP, ekTypeChange, ekForceSwitch

  Effect* = ref object of RootObj
    activation*: EffectActivationKind
    target*: EffectTargetKind
    case kind*: EffectKind
    of ekStatus: status: StatusConditionKind
    of ekCondition: condition: GeneralConditionKind
    of ekBoost: boostChange: tuple[atk: int, def: int, spa: int, spd: int, spe: int]
    of ekHP: hpChange: int
    of ekTypeChange: typeChange: PokeType
    of ekForceSwitch: isRandom: bool
