import sets, algorithm
import state, action, damage, team, field

proc turn*(s: State, actions: HashSet[Action]): State =
  var state = copy(s)
  var orderedActions: seq[Action] = @[]
  for action in actions:
    orderedActions.add(action)
  orderedActions.sort(action.cmp, SortOrder.Descending)
  for action in orderedActions:
    var pokemon = action.pokemon
    if action.kind == akSwitchSelection:
      var team = if state.getTeam(pokemon) == tskHome: state.homeTeam else: state.awayTeam
      team.activePokemon = action.switchTarget
    else:
      let damage = getAvgDamage(pokemon, action.attackTarget, action.move, state)
      action.attackTarget.currentHP = max(0, action.attackTarget.currentHP - damage)
  return state
