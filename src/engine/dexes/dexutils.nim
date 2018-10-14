import
  strutils,
  ../gameData/gameData

when defined(release):
  const fileSuffix* = ".min.json"
else:
  const fileSuffix* = ".json"

func toPokeMoveCategory*(category: string): PokeMoveCategory =
  case category.toLowerAscii
  of "physical": pmcPhysical
  of "special": pmcSpecial
  else: pmcStatus

func toPokeMoveTarget*(target: string): PokeMoveTarget =
  case target.toLowerAscii
  of "Self": pmtUser
  of "Ally": pmtAlly
  of "AllOthers": pmtAllOthers
  of "AllOpponents": pmtAllOpponents
  else: pmtSelectedTarget

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
  of "DuringAttack": eakDuringAttack
  of "AfterAttack": eakAfterAttack
  of "OnSwitchIn": eakOnSwitchIn
  of "OnSwitchOut": eakOnSwitchOut
  else: eakPassive

func toWeather*(weather: string): FieldWeatherKind =
  case weather
  of "Sun": fwkSun
  of "Rain": fwkRain
  of "Sand": fwkSand
  of "Hail": fwkHail
  of "HeavyRain": fwkHeavyRain
  of "HarshSun": fwkHarshSun
  of "StrongWinds": fwkStrongWinds
  else: fwkNone

func toTerrain*(terrain: string): FieldTerrainKind =
  case terrain
  of "Psychic": ftkPsychic
  of "Electric": ftkElectric
  of "Fairy": ftkFairy
  of "Grass": ftkGrass
  else: ftkNone

func toPokemonNature*(nature: string): PokeNature =
  parseEnum[PokeNature]("pn" & nature, pnBashful)

func toPokeType*(typeString: string): PokeType =
  case toLowerAscii(typestring)
  of "water": ptWater
  of "fire": ptFire
  of "electric": ptElectric
  of "dark": ptDark
  of "psychic": ptPsychic
  of "grass": ptGrass
  of "ice": ptIce
  of "dragon": ptDragon
  of "fairy": ptFairy
  of "normal": ptNormal
  of "fighting": ptFighting
  of "rock": ptRock
  of "ground": ptGround
  of "steel": ptSteel
  of "ghost": ptGhost
  of "posion": ptPoison
  of "bug": ptBug
  of "flying": ptFlying
  else: ptNull

func toItemKind*(kind: string): ItemKind =
  case kind
  of "Z Crystal": ikZCrystal
  of "Pinch Berry": ikPinchBerry
  else: ikUnique
