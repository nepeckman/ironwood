type

  FieldWeatherKind* = enum
    fwkSun, fwkRain, fwkSand, fwkHail, fwkNone, fwkHarshSun, fwkHeavyRain, fwkStrongWinds

  FieldTerrainKind* = enum
    ftkPsychic, ftkElectric, ftkFairy, ftkGrass, ftkNone

  FieldSideEffects* = enum #Effects targeting just one side
    fseLightScreen, fseReflect, fseAuroraVeil, fseStealthRocks,
    fseSpikes1, fseSpikes2, fseSpikes3, fseToxicSpikes1, fseToxicSpikes2

  FieldFormatKind = enum
    ffkSingles, ffkDoubles, ffkTriples, ffkRotation

  Field* = ref object
    weather*: FieldWeatherKind
    weatherSuppressed*: bool
    terrain*: FieldTerrainKind
    gravityActive*: bool
    trickRoomActive*: bool
    homeSide*: set[FieldSideEffects]
    awaySide*: set[FieldSideEffects]

proc makeField*(): Field =
  Field(
    weather: fwkNone,
    weatherSuppressed: false,
    terrain: ftkNone,
    gravityActive: false,
    trickRoomActive: false,
    homeSide: {},
    awaySide: {}
  )
