type

  FieldWeatherKind* = enum
    fwkSun, fwkRain, fwkSand, fwkHail, fwkNone, fwkHarshSun, fwkHeavyRain, fwkStrongWinds

  FieldTerrainKind* = enum
    ftkPsychic, ftkElectric, ftkFairy, ftkGrass, ftkNone

  FieldAuraKind* = enum
    fakDark, fakFairy

  FieldSideEffect* = enum #Effects targeting just one side
    fseLightScreen, fseReflect, fseAuroraVeil, fseStealthRocks,
    fseSpikes, fseToxicSpikes, fseTailwind
    #TODO: add pledge effects

  FieldFormatKind* = enum
    ffkSingles, ffkDoubles, ffkTriples, ffkRotation

proc toWeather*(weather: string): FieldWeatherKind =
  case weather
  of "Sun": fwkSun
  else: fwkNone
