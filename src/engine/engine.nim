import 
  algorithm, sugar, sequtils, sets, math,
  uuids,
  gameObjects/gameObjects, gameData/gameData, dexes/dexes,
  state, action, damage, effectEngine, engineutils, setParser

proc weatherDamage(pokemon: Pokemon) =
  let damage = toInt(floor(pokemon.maxHP / 16))
  pokemon.takeDamage(damage)

proc fieldEffect(state: State, effectFn: (Pokemon) -> void, f: (Pokemon) -> bool) =
    var effectedPokemon = state.allActivePokemonObj.filter(f)
    effectedPokemon.sort((p1, p2) => cmp(p1.speed(state.field), p2.speed(state.field)), SortOrder.Descending)
    for pokemon in effectedPokemon:
      effectFn(pokemon)

proc turnTeardown(state: State) =
  state.field.decrementCounters()
  if state.field.weather == fwkSand:
    state.fieldEffect(weatherDamage, (pokemon) => not (pokemon.hasType(ptRock) or pokemon.hasType(ptGround) or pokemon.hasType(ptSteel)))
  elif state.field.weather == fwkHail:
    state.fieldEffect(weatherDamage, (pokemon) => not pokemon.hasType(ptIce))
  state.assessWeather()

func turn*(s: State, actions: seq[Action]): State =
  var state = copy(s)
  var orderedActions: seq[Action]
  shallowCopy(orderedActions, actions)
  orderedActions.sort((a1, a2) => state.compareActions(a1, a2), SortOrder.Descending)
  for action in orderedActions:
    var pokemon = state.getPokemonObj(action.actingPokemonID)
    var team = state.getTeam(pokemon)
    if pokemon.fainted:
      continue
    if action.kind == akSwitchSelection:
      team.switchPokemon(action.actingPokemonID, action.switchTargetID)
      let switchIn = state.getPokemonObj(action.switchTargetID)
      if switchIn.ability.effect.activation == eakOnSwitchIn:
        state.applyAbilityEffect(switchIn)
    else:
      let targets = state.getTargetedPokemon(action)
      for target in targets:
        let damage = getAvgDamage(pokemon, target, action.move, state.field)
        target.takeDamage(damage)
        if action.move.effect.activation == eakAfterAttack:
          state.applyMoveEffect(pokemon, target, action.move.effect)
        if action.move.isZ:
          team.isZUsed = true

    state.assessWeather()

  state.turnTeardown()
  return state

proc newGame*(homeTeamString, awayTeamString: string): State =
  let homeTeam = parseTeam(homeTeamString, tskHome)
  let awayTeam = parseTeam(awayTeamString, tskAway)
  var state = State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())
  var activePokemon = state.allActivePokemonObj
  activePokemon.sort((p1, p2) => cmp(p1.speed(state.field), p2.speed(state.field)), SortOrder.Descending)
  for pokemon in activePokemon:
    if pokemon.ability.effect.activation == eakOnSwitchIn:
      state.applyAbilityEffect(pokemon)
  state.assessWeather()
  return state

export
  engineutils, state, action, setParser, gameObjects, gameData, dexes
