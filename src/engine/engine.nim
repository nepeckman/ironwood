import sets, algorithm, future
import state, action, damage, team, field

proc compareActions*(state: State, action1, action2: Action): int =
  if action1.kind == action2.kind:
    cmp(state.getPokemon(action1.actingPokemonID), state.getPokemon(action2.actingPokemonID))
  elif action1.kind == akSwitchSelection: 1
  else: -1

proc turn*(s: State, actions: HashSet[Action]): State =
  var state = copy(s)
  var orderedActions: seq[Action] = @[]
  for action in actions:
    orderedActions.add(action)
  orderedActions.sort((a1, a2) => state.compareActions(a1, a2), SortOrder.Descending)
  for action in orderedActions:
    var pokemon = state.getPokemon(action.actingPokemonID)
    if action.kind == akSwitchSelection:
      var team = if state.getTeam(pokemon) == tskHome: state.homeTeam else: state.awayTeam
      team.activePokemon = state.getPokemon(action.switchTargetID)
    else:
      let defender = state.getPokemon(action.attackTargetID)
      let damage = getAvgDamage(pokemon, defender, action.move, state)
      defender.currentHP = max(0, defender.currentHP - damage)
  return state
