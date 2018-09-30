import strutils
import effects, fieldConditions

type

  Ability* = ref object
    name: string
    effect: Effect

func name*(a: Ability): string =
  if isNil(a): "" else: a.name

func effect*(a: Ability): Effect =
  if isNil(a): nil else: a.effect

func `==`*(a: Ability, s: string): bool =
  if isNil(a): "" == s else: a.name == s

func `==`*(s: string, a: Ability): bool =
  if isNil(a): "" == s else: a.name == s

func `contains`*(arr: openArray[string], ability: Ability): bool =
  if isNil(ability): false else: find(arr, ability.name) >= 0

func newAbility*(name: string, effect: Effect): Ability = 
  Ability(name: name, effect: effect)

func suppressesWeather*(ability: Ability): bool =
  ability in ["Cloud Nine", "Air Lock"]

func weatherSpeedAbility*(ability: Ability): bool =
  ability in ["Chlorophyll", "Sand Rush", "Slush Rush", "Swift Swim"]

func terrainSpeedAbility*(ability: Ability): bool =
  ability in ["Surge Surfer"]

func weatherSpeedBoost*(ability: Ability, weather: FieldWeatherKind): float = 
  if ability == "Chlorophyll" and weather.sunny: 2f
  elif ability == "Swift Swim" and weather.rainy: 2f
  elif ability == "Sand Rush" and weather == fwkSand: 2f
  elif ability == "Slush Rush" and weather == fwkHail: 2f
  else: 1f

func terrainSpeedBoost*(ability: Ability, terrain: FieldTerrainKind): float =
  if ability == "Surge Surfer" and terrain == ftkElectric: 2f
  else: 1f
