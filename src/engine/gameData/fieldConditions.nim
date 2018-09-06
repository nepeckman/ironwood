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

