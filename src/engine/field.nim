import gameData/fieldConditions

type

  TeamSideKind* = enum tskHome, tskAway

  Field* = ref object
    format*: FieldFormatKind
    weather: FieldWeatherKind
    weatherSuppressed*: bool
    terrain*: FieldTerrainKind
    auras*: set[FieldAuraKind]
    gravityActive*: bool
    trickRoomActive*: bool
    homeSideEffects: set[FieldSideEffects]
    awaySideEffects: set[FieldSideEffects]

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
    awaySideEffects: {}
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
    awaySideEffects: field.awaySideEffects
  )

proc weather*(field: Field): FieldWeatherKind =
  if field.weatherSuppressed: fwkNone else: field.weather

proc sideEffects*(field: Field, side: TeamSideKind): set[FieldSideEffects] =
  if side == tskHome: field.homeSideEffects else: field.awaySideEffects
