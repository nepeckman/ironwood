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
