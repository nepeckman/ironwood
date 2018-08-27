type

  FieldWeatherKind* = enum
    fwkSun, fwkRain, fwkSand, fwkHail, fwkNone, fwkHarshSun, fwkHeavyRain, fwkStrongWinds

  FieldTerrainKind* = enum
    ftkPsychic, ftkElectric, ftkFairy, ftkGrass, ftkNone

  FieldAuraKind* = enum
    fakDark, fakFairy

  FieldSideEffects* = enum #Effects targeting just one side
    fseLightScreen, fseReflect, fseAuroraVeil, fseStealthRocks,
    fseSpikes1, fseSpikes2, fseSpikes3, fseToxicSpikes1, fseToxicSpikes2,
    fseTailwind
    #TODO: add pledge effects

  FieldFormatKind* = enum
    ffkSingles, ffkDoubles, ffkTriples, ffkRotation

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

proc weather*(field: Field): FieldWeatherKind =
  if field.weatherSuppressed: fwkNone else: field.weather

proc sideEffects*(field: Field, side: TeamSideKind): set[FieldSideEffects] =
  if side == tskHome: field.homeSideEffects else: field.awaySideEffects
