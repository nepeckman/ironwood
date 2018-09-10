import 
  algorithm, future,
  gameObjects/gameObjects, gameData/gameData, dexes/dexes,
  state, action, damage, setParser

proc turn*(s: State, actions: ActionSet): State =
  var state = copy(s)
  var orderedActions: seq[Action] = @[]
  for action in actions:
    orderedActions.add(action)
  orderedActions.sort((a1, a2) => state.compareActions(a1, a2), SortOrder.Descending)
  for action in orderedActions:
    var pokemon = state.getPokemon(action.actingPokemonID)
    if action.kind == akSwitchSelection:
      var team = if pokemon.side == tskHome: state.homeTeam else: state.awayTeam
      team.activePokemon = state.getPokemon(action.switchTargetID)
    else:
      let defender = state.getPokemon(action.attackTargetID)
      let damage = getAvgDamage(pokemon, defender, action.move, state.field)
      defender.currentHP = max(0, defender.currentHP - damage)
  return state

proc newGame*() =
  echo "not done yet"

proc newActionSet*() =
  echo "not done yet"

proc homeActivePokemon*() =
  echo "not done yet"

proc awayActivePokemon*() =
  echo "not done yet"

proc possibleActions*() =
  echo "not done yet"

export
  state, action, gameObjects, gameData, dexes #TODO: add movedex, export as one
