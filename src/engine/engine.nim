import 
  algorithm, future, sequtils, sets, math,
  uuids,
  gameObjects/gameObjects, gameData/gameData, dexes/dexes,
  state, action, damage, effectEngine, engineutils, setParser

proc weatherDamage(pokemon: Pokemon) =
  let damage = toInt(floor(pokemon.maxHP / 16))
  pokemon.takeDamage(damage)

proc fieldEffect(state: State, effectFn: (Pokemon) -> void, f: (Pokemon) -> bool) =
    let activePokemon = concat(state.homeActivePokemonObj, state.awayActivePokemonObj)
    var effectedPokemon = activePokemon.filter(f)
    effectedPokemon.sort((p1, p2) => cmp(p1.speed, p2.speed), SortOrder.Descending)
    for pokemon in effectedPokemon:
      effectFn(pokemon)

proc turnTeardown(state: State) =
  state.field.decrementCounters()
  if state.field.weather == fwkSand:
    state.fieldEffect(weatherDamage, (pokemon) => not (pokemon.hasType(ptRock) or pokemon.hasType(ptGround) or pokemon.hasType(ptSteel)))
  elif state.field.weather == fwkHail:
    state.fieldEffect(weatherDamage, (pokemon) => not pokemon.hasType(ptIce))

proc turn*(s: State, actions: seq[Action]): State =
  var state = copy(s)
  var orderedActions: seq[Action]
  shallowCopy(orderedActions, actions)
  orderedActions.sort((a1, a2) => state.compareActions(a1, a2), SortOrder.Descending)
  for action in orderedActions:
    var pokemon = state.getPokemonObj(action.actingPokemonID)
    if action.kind == akSwitchSelection:
      var team = state.getTeam(pokemon)
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
  state.turnTeardown()
  return state

proc newGame*(homeTeamString, awayTeamString: string): State =
  let homeTeam = parseTeam(homeTeamString, tskHome)
  let awayTeam = parseTeam(awayTeamString, tskAway)
  var state = State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())
  let activePokemonIDs = concat(state.homeActivePokemon, state.awayActivePokemon)
  var activePokemonObjs = activePokemonIDs.map((id) => state.getPokemonObj(id))
  activePokemonObjs.sort((p1, p2) => cmp(p1.speed, p2.speed), SortOrder.Descending)
  for pokemon in activePokemonObjs:
    if pokemon.ability.effect.activation == eakOnSwitchIn:
      state.applyAbilityEffect(pokemon)
  return state

export
  engineutils, state, action, setParser, gameObjects, gameData, dexes
