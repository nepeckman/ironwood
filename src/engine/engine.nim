import 
  algorithm, future,
  uuids,
  gameObjects/gameObjects, gameData/gameData, dexes/dexes,
  state, action, damage, engineutils, setParser

proc turn*(s: State, actions: ActionSet): State =
  var state = copy(s)
  var orderedActions: seq[Action] = @[]
  for action in actions:
    orderedActions.add(action)
  orderedActions.sort((a1, a2) => state.compareActions(a1, a2), SortOrder.Descending)
  for action in orderedActions:
    var pokemon = state.getPokemon(action.actingPokemonID)
    if action.kind == akSwitchSelection:
      var team = state.getTeam(pokemon)
      team.switchPokemon(action.actingPokemonID, action.switchTargetID)
    else:
      let targets = state.getTargetedPokemon(action)
      for target in targets:
        let damage = getAvgDamage(pokemon, target, action.move, state.field)
        target.currentHP = max(0, target.currentHP - damage)
  return state

proc newGame*(homeTeamString, awayTeamString: string): State =
  let homeTeam = parseTeam(homeTeamString, tskHome)
  let awayTeam = parseTeam(awayTeamString, tskAway)
  State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())

proc homeActivePokemon*(state: State): seq[UUID] =
  result = @[]
  result.add(state.homeTeam[0].uuid)
  if state.field.format == ffkDoubles:
    result.add(state.homeTeam[1].uuid)

proc awayActivePokemon*(state: State): seq[UUID] =
  result = @[]
  result.add(state.awayTeam[0].uuid)
  if state.field.format == ffkDoubles:
    result.add(state.awayTeam[1].uuid)

proc possibleActions*(state: State, pokemon: Pokemon): seq[Action] =
  result = @[]
  for move in possibleMoves(pokemon):
    for targets in possibleTargets(state, move):
      result.add(newMoveAction(pokemon.uuid, move, targets))

export
  state, action, setParser, gameObjects, gameData, dexes
