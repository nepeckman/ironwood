import 
  algorithm, future,
  uuids,
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
      team.switchPokemon(action.actingPokemonID, action.switchTargetID)
    else:
      let targets = state.getTargetedPokemon(action)
      for target in targets:
        let damage = getAvgDamage(pokemon, target, action.move, state.field)
        target.currentHP = max(0, target.currentHP - damage)
  return state

proc newGame*() =
  echo "not done yet"

proc newActionSet*() =
  echo "not done yet"

proc homeActivePokemon*() =
  echo "not done yet"

proc awayActivePokemon*() =
  echo "not done yet"

proc possibleActions*(pokemonID: UUID) =
  echo "not done yet"

export
  state, action, setParser, gameObjects, gameData, dexes
