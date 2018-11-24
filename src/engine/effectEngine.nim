# TODO: decide on a better interface for effect application
# Maybe write functions with a finer scope
import
  gameObjects/gameObjects, gameData/gameData, dexes/dexes,
  state, pokemonAccessor

func defenderItemActivates*(defender: Pokemon, move: PokeMove): bool =
  case defender.item.kind
  of ikPinchBerry: defender.percentHP <= defender.item.activationPercent
  of ikResistBerry: defender.item.associatedType == move.pokeType
  else: false

proc changeWeather(field: Field, pokemon: Pokemon, weather: FieldWeatherKind) =
  if weather.normalWeather and
     not field.weather.strongWeather:
    field.changeWeather(weather)
  elif weather.strongWeather:
    field.changeWeather(weather, -1)

proc applyMoveEffect*(state: State, actingPokemon, attackTarget: Pokemon, effect: Effect) =
  let target = if effect.target == etkSelf: actingPokemon else: attackTarget
  if effect.kind == ekBoost:
    target.applyBoosts(effect.boostChange)
  elif effect.kind == ekWeather:
    state.field.changeWeather(actingPokemon, effect.weather)
  elif effect.kind == ekTerrain:
    state.field.changeTerrain(effect.terrain)

proc applyAbilityEffect*(state: State, actingPokemon: Pokemon) =
  let effect = actingPokemon.ability.effect
  if effect.target == etkPokemon:
    let targets = state.activePokemon(state.getOpposingTeam(actingPokemon))
    if effect.kind == ekBoost:
      for target in targets:
        target.applyBoosts(effect.boostChange)
  elif effect.target == etkField:
    if effect.kind == ekWeather:
      state.field.changeWeather(actingPokemon, effect.weather)
    elif effect.kind == ekTerrain:
      state.field.changeTerrain(effect.terrain)

proc applyItemEffect*(state: State, actingPokemon: Pokemon) =
  let item = actingPokemon.item
  let effect = item.effect
  if effect.target == etkSelf:
    if effect.kind == ekHPPercent:
      actingPokemon.changeHPByPercent(effect.hpPercentChange)

func greater(first: int, rest: openArray[int]): bool =
  for n in rest:
    if first >= n:
      return true
  return false

proc beastBoost(pokemon: Pokemon) =
  let stats = pokemon.rawStats
  if greater(stats.atk, [stats.def, stats.spa, stats.spd, stats.spe]):
    pokemon.applyBoosts((atk: 1, def: 0, spa: 0, spd: 0, spe: 0))
  elif greater(stats.def, [stats.atk, stats.spa, stats.spd, stats.spe]):
    pokemon.applyBoosts((atk: 0, def: 1, spa: 0, spd: 0, spe: 0))
  elif greater(stats.spa, [stats.atk, stats.def, stats.spd, stats.spe]):
    pokemon.applyBoosts((atk: 0, def: 0, spa: 1, spd: 0, spe: 0))
  elif greater(stats.spd, [stats.atk, stats.def, stats.spa, stats.spe]):
    pokemon.applyBoosts((atk: 0, def: 0, spa: 0, spd: 1, spe: 0))
  elif greater(stats.spe, [stats.atk, stats.def, stats.spa, stats.spd]):
    pokemon.applyBoosts((atk: 0, def: 0, spa: 0, spd: 0, spe: 1))

proc afterKOAbility*(state: State, actingPokemon, faintedPokemon: Pokemon) =
  let effect = actingPokemon.ability.effect
  if effect.kind == ekNull:
    if actingPokemon.ability == "Beast Boost":
      beastBoost(actingPokemon)
