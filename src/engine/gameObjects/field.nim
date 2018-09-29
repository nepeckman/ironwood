import tables
import ../gameData/fieldConditions

type

  Field* = ref object
    format*: FieldFormatKind
    weather: FieldWeatherKind
    weatherSuppressed: bool
    terrain*: FieldTerrainKind
    auras*: set[FieldAuraKind]
    gravityActive*: bool
    trickRoomActive*: bool
    homeSideEffects: set[FieldSideEffect]
    awaySideEffects: set[FieldSideEffect]
    sideEffectCounters: Table[FieldSideEffect, int]
    weatherCounter: int
    terrainCounter: int

func makeField*(): Field =
  Field(
    format: ffkSingles,
    weather: fwkNone,
    weatherSuppressed: false,
    terrain: ftkNone,
    auras: {},
    gravityActive: false,
    trickRoomActive: false,
    homeSideEffects: {},
    awaySideEffects: {},
    sideEffectCounters: initTable[FieldSideEffect, int](),
    weatherCounter: 0,
    terrainCounter: 0
  )

func copy*(field: Field): Field =
  Field(
    format: field.format,
    weather: field.weather,
    weatherSuppressed: field.weatherSuppressed,
    terrain: field.terrain,
    auras: field.auras,
    gravityActive: field.gravityActive,
    trickRoomActive: field.trickRoomActive,
    homeSideEffects: field.homeSideEffects,
    awaySideEffects: field.awaySideEffects,
    sideEffectCounters: field.sideEffectCounters,
    weatherCounter: field.weatherCounter,
    terrainCounter: field.terrainCounter
  )

func weather*(field: Field): FieldWeatherKind =
  if field.weatherSuppressed: fwkNone else: field.weather

func terrain*(field: Field): FieldTerrainKind = field.terrain

func rawWeather*(field: Field): FieldWeatherKind = field.weather

func sideEffects*(field: Field, side: TeamSideKind): set[FieldSideEffect] =
  if side == tskHome: field.homeSideEffects else: field.awaySideEffects

func weatherSuppressed*(field: Field): bool = field.weatherSuppressed 

proc `weatherSuppressed=`*(field: Field, suppressed: bool) =
  field.weatherSuppressed = suppressed

proc changeTerrain*(field: Field, terrain: FieldTerrainKind, turns = 5) =
  if terrain != field.terrain:
    field.terrain = terrain
    field.terrainCounter = turns

proc changeWeather*(field: Field, weather: FieldWeatherKind, turns = 5) =
  if weather != field.weather:
    field.weather = weather
    field.weatherCounter = turns

proc decrementCounters*(field: Field) =
  if field.weatherCounter > 0:
    field.weatherCounter = field.weatherCounter - 1
  if field.weatherCounter == 0:
    field.weather = fwkNone

  if field.terrainCounter > 0:
    field.terrainCounter = field.terrainCounter - 1
  if field.terrainCounter == 0:
    field.terrain = ftkNone

export fieldConditions
