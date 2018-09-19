import
  gameObjects/gameObjects, gameData/gameData, dexes/dexes


proc applyEffect*(actingPokemon, attackTarget: Pokemon, effect: Effect) =
  let target = 
    if effect.target == etkSelf: actingPokemon else: attackTarget
  if effect.kind == ekBoost:
    target.applyBoosts(effect.boostChange)
