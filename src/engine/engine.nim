import 
  algorithm, future, sequtils, sets,
  uuids,
  gameObjects/gameObjects, gameData/gameData, dexes/dexes,
  state, action, damage, engineutils, setParser

proc turn*(s: State, actions: seq[Action]): State =
  var state = copy(s)
  var orderedActions: seq[Action]
  shallowCopy(orderedActions, actions)
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
        target.takeDamage(damage)
  return state

proc newGame*(homeTeamString, awayTeamString: string): State =
  let homeTeam = parseTeam(homeTeamString, tskHome)
  let awayTeam = parseTeam(awayTeamString, tskAway)
  State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())

proc activePokemon(state: State, team: Team): seq[UUID] =
  result = @[]
  if state.isActive(team[0]):
    result.add(team[0].uuid)
  if state.isActive(team[1]) and state.field.format == ffkDoubles:
    result.add(team[1].uuid)

proc homeActivePokemon*(state: State): seq[UUID] =
  state.activePokemon(state.homeTeam)

proc awayActivePokemon*(state: State): seq[UUID] =
  state.activePokemon(state.awayTeam)

proc possibleActions*(state: State, pokemonID: UUID): seq[Action] =
  result = @[]
  let pokemon = state.getPokemon(pokemonID)
  for move in possibleMoves(pokemon):
    for targets in possibleTargets(state, move):
      result.add(newMoveAction(pokemon.uuid, move, targets))

proc possibleActions*(state: State, pokemonIDs: seq[UUID]): seq[Action] =
  result = @[]
  for id in pokemonIDs:
    result = result.concat(state.possibleActions(id))

export
  state, action, setParser, gameObjects, gameData, dexes
