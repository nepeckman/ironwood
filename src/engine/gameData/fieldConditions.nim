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

  TeamSideKind* = enum tskHome, tskAway

func normalWeather*(weather: FieldWeatherKind): bool =
  weather in {fwkSun, fwkRain, fwkSand, fwkHail}

func strongWeather*(weather: FieldWeatherKind): bool =
  weather in {fwkHarshSun, fwkHeavyRain, fwkStrongWinds}

func sunny*(weather: FieldWeatherKind): bool =
  weather in {fwkHarshSun, fwkSun}

func rainy*(weather: FieldWeatherKind): bool =
  weather in {fwkHeavyRain, fwkRain}
