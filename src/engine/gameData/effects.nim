import condition, poketype, fieldConditions
type

  EffectActivationKind* = enum
    eakTurnStart, eakTurnEnd eakBeforeAttack, eakAfterAttack, eakOnSwitchIn, eakOnSwitchOut, eakPassive

  EffectTargetKind* = enum
    etkField, etkSelf, etkPokemon, etkNone

  EffectKind* = enum
    ekStatus, ekCondition, ekBoost, ekHP, ekTypeChange, ekForceSwitch, 
    ekWeather, ekTerrain, ekNull

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
    of ekWeather: weather: FieldWeatherKind
    of ekTerrain: terrain: FieldTerrainKind
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
proc weather*(effect: Effect): FieldWeatherKind = effect.weather

proc toEffectTarget*(str: string): EffectTargetKind =
  case str
  of "Field": etkField
  of "Self": etkSelf
  else: etkPokemon

proc toEffectActivation*(str: string): EffectActivationKind =
  case str
  of "TurnStart": eakTurnStart
  of "TurnEnd": eakTurnEnd
  of "BeforeAttack": eakBeforeAttack
  of "AfterAttack": eakAfterAttack
  of "OnSwitchIn": eakOnSwitchIn
  of "OnSwitchOut": eakOnSwitchOut
  else: eakPassive

proc newBoostEffect*(target: EffectTargetKind, 
                     boostChange: tuple[atk: int, def: int, spa: int, spd: int, spe: int],
                     activation = eakAfterAttack): Effect =
  Effect(target: target, activation: activation, kind: ekBoost, boostChange: boostChange)

proc newWeatherEffect*(weather: FieldWeatherKind, activation = eakAfterAttack): Effect =
  Effect(target: etkField, activation: activation, kind: ekWeather, weather: weather)
