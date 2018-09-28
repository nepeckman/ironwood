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

func activation*(effect: Effect): EffectActivationKind =
  if isNil(effect): eakPassive else: effect.activation

func target*(effect: Effect): EffectTargetKind =
  if isNil(effect): etkNone else: effect.target

func kind*(effect: Effect): EffectKind =
  if isNil(effect): ekNull else: effect.kind

func status*(effect: Effect): StatusConditionKind = effect.status
func condition*(effect: Effect): GeneralConditionKind = effect.condition
func boostChange*(effect: Effect): tuple[atk: int, def: int, spa: int, spd: int, spe: int] = effect.boostChange
func hpChange*(effect: Effect): int = effect.hpChange
func typeChange*(effect: Effect): PokeType = effect.typeChange
func isRandom*(effect: Effect): bool = effect.isRandom
func weather*(effect: Effect): FieldWeatherKind = effect.weather
func terrain*(effect: Effect): FieldTerrainKind = effect.terrain

func toEffectTarget*(str: string): EffectTargetKind =
  case str
  of "Field": etkField
  of "Self": etkSelf
  else: etkPokemon

func toEffectActivation*(str: string): EffectActivationKind =
  case str
  of "TurnStart": eakTurnStart
  of "TurnEnd": eakTurnEnd
  of "BeforeAttack": eakBeforeAttack
  of "AfterAttack": eakAfterAttack
  of "OnSwitchIn": eakOnSwitchIn
  of "OnSwitchOut": eakOnSwitchOut
  else: eakPassive

func newBoostEffect*(target: EffectTargetKind, 
                     boostChange: tuple[atk: int, def: int, spa: int, spd: int, spe: int],
                     activation = eakAfterAttack): Effect =
  Effect(target: target, activation: activation, kind: ekBoost, boostChange: boostChange)

func newWeatherEffect*(weather: FieldWeatherKind, activation = eakAfterAttack): Effect =
  Effect(target: etkField, activation: activation, kind: ekWeather, weather: weather)

func newTerrainEffect*(terrain: FieldTerrainKind, activation = eakAfterAttack): Effect =
  Effect(target: etkField, activation: activation, kind: ekTerrain, terrain: terrain)
