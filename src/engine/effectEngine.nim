import
  gameObjects/gameObjects, gameData/gameData, dexes/dexes,
  state, engineutils


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
    let targets = state.activePokemonObj(state.getOpposingTeam(actingPokemon))
    if effect.kind == ekBoost:
      for target in targets:
        target.applyBoosts(effect.boostChange)
  elif effect.target == etkField:
    if effect.kind == ekWeather:
      state.field.changeWeather(actingPokemon, effect.weather)
    elif effect.kind == ekTerrain:
      state.field.changeTerrain(effect.terrain)

