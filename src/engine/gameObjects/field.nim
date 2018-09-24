import tables
import ../gameData/fieldConditions
import pokemon

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

proc makeField*(): Field =
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

proc copy*(field: Field): Field =
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

proc weather*(field: Field): FieldWeatherKind =
  if field.weatherSuppressed: fwkNone else: field.weather

proc sideEffects*(field: Field, side: TeamSideKind): set[FieldSideEffect] =
  if side == tskHome: field.homeSideEffects else: field.awaySideEffects

proc `weather=`*(field: Field, weather: FieldWeatherKind) =
  field.weather = weather

proc setWeatherSuppression*(field: Field, suppressed: bool) =
  field.weatherSuppressed = suppressed

proc changeWeather*(field: Field, pokemon: Pokemon, weather: FieldWeatherKind) =
  if weather.normalWeather and
     not field.weather.strongWeather and
     field.weather != weather:
    field.weather = weather
    field.weatherCounter = 5
  elif weather.strongWeather:
    field.weather = weather
    field.weatherCounter = -1

proc decrementCounters*(field: Field) =
  if field.weatherCounter > 0:
    field.weatherCounter = field.weatherCounter - 1
  if field.weatherCounter == 0:
    field.weather = fwkNone
