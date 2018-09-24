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
  of "Rain": fwkRain
  of "Sand": fwkSand
  of "Hail": fwkHail
  of "HeavyRain": fwkHeavyRain
  of "HarshSun": fwkHarshSun
  of "StrongWinds": fwkStrongWinds
  else: fwkNone

proc toTerrain*(terrain: string): FieldTerrainKind =
  case terrain
  of "Psychic": ftkPsychic
  of "Electric": ftkElectric
  of "Fairy": ftkFairy
  of "Grass": ftkGrass
  else: ftkNone

proc normalWeather*(weather: FieldWeatherKind): bool =
  weather in {fwkSun, fwkRain, fwkSand, fwkHail}

proc strongWeather*(weather: FieldWeatherKind): bool =
  weather in {fwkHarshSun, fwkHeavyRain, fwkStrongWinds}
