import condition, poketype
type

  EffectActivationKind* = enum
    eakTurnStart, eakTurnEnd eakBeforeAttack, eakAfterAttack, eakOnSwitchIn, eakOnSwitchOut, eakPassive

  EffectTargetKind* = enum
    etkField, etkSelf, etkPokemon, etkNone

  EffectKind* = enum
    ekStatus, ekCondition, ekBoost, ekHP, ekTypeChange, ekForceSwitch, ekNull

  Effect* = ref object of RootObj
    activation: EffectActivationKind
    target: EffectTargetKind
    case kind: EffectKind
    of ekStatus: status: StatusConditionKind
    of ekCondition: condition: GeneralConditionKind
    of ekBoost: boostChange: tuple[atk: int, def: int, spa: int, spd: int, spe: int]
    of ekHP: hpChange: int
    of ekTypeChange: typeChange: PokeType
    of ekForceSwitch: isRandom: bool
    of ekNull: discard

proc activation*(effect: Effect): EffectActivationKind =
  if isNil(effect): eakPassive else: effect.activation

proc target*(effect: Effect): EffectTargetKind =
  if isNil(effect): etkNone else: effect.target

proc kind*(effect: Effect): EffectKind =
  if isNil(effect): ekNull else: effect.kind

proc status*(effect: Effect): StatusConditionKind = effect.status
proc condition*(effect: Effect): GeneralConditionKind = effect.condition
proc boostChange*(effect: Effect): tuple[atk: int, def: int, spa: int, spd: int, spe: int] = effect.boostChange
proc hpChange*(effect: Effect): int = effect.hpChange
proc typeChange*(effect: Effect): PokeType = effect.typeChange
proc isRandom*(effect: Effect): bool = effect.isRandom
