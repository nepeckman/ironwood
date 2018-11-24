import 
  algorithm, sugar, sequtils, sets, math,
  uuids,
  gameObjects/gameObjects, gameData/gameData, dexes/dexes,
  state, action, damage, effectEngine, actionAccessor, pokemonAccessor, setParser

proc assessWeather*(state: State) =
  let activeAbilities = state.allActivePokemon().map((p) => p.ability)
  var constantWeatherMaintained, weatherSuppressed = false

  if state.field.rawWeather.strongWeather:
    for ability in activeAbilities:
      if ability.effect.kind == ekWeather and
         ability.effect.weather.strongWeather and
         ability.effect.weather == state.field.weather:
        constantWeatherMaintained = true
    if not constantWeatherMaintained:
      state.field.changeWeather(fwkNone, 0)

  for ability in activeAbilities:
    if ability.suppressesWeather:
      weatherSuppressed = true
    state.field.weatherSuppressed = weatherSuppressed

proc assessAuras(state: State) =
  let activeAuras = state.field.auras
  let activeAbilities = state.allActivePokemon().map((p) => p.ability)
  var darkAuraActive, fairyAuraActive = false
  for ability in activeAbilities:
    if ability == "Dark Aura":
      darkAuraActive = true
    if ability == "Fairy Aura":
      fairyAuraActive = true

  if darkAuraActive and not (fakDark in activeAuras):
    state.field.activateDarkAura()
  elif not darkAuraActive and fakDark in activeAuras:
    state.field.removeDarkAura()

  if fairyAuraActive and not (fakFairy in activeAuras):
    state.field.activateFairyAura()
  elif not fairyAuraActive and fakFairy in activeAuras:
    state.field.removeFairyAura()

proc weatherDamage(pokemon: Pokemon) =
  let damage = toInt(floor(pokemon.maxHP / 16))
  pokemon.takeDamage(damage)

proc fieldEffect(state: State, effectFn: (Pokemon) -> void, f: (Pokemon) -> bool) =
    var effectedPokemon = state.allActivePokemon.filter(f)
    effectedPokemon.sort((p1, p2) => cmp(p1.speed(state.field), p2.speed(state.field)), SortOrder.Descending)
    for pokemon in effectedPokemon:
      effectFn(pokemon)

proc fieldAssessment(state: State) =
  state.assessWeather()
  state.assessAuras()

proc turnConditionReset(state: State) =
  for pokemon in state.allActivePokemon():
    for condition in pokemon.conditions.keys:
      if condition.oneTurnCondition:
        pokemon.conditions.del(condition)

proc turnTeardown(state: State) =
  state.field.decrementCounters()
  if state.field.weather == fwkSand:
    state.fieldEffect(weatherDamage, (pokemon) => not (pokemon.hasType(ptRock) or pokemon.hasType(ptGround) or pokemon.hasType(ptSteel)))
  elif state.field.weather == fwkHail:
    state.fieldEffect(weatherDamage, (pokemon) => not pokemon.hasType(ptIce))
  state.fieldAssessment()
  state.turnConditionReset()

proc executeSwitch(state: State, pokemon: Pokemon, team: Team, action: Action) =
  pokemon.reset()
  team.switchPokemon(action.actingPokemonID, action.switchTargetID)
  let switchIn = state.getPokemon(action.switchTargetID)
  if switchIn.ability.effect.activation == eakOnSwitchIn:
    state.applyAbilityEffect(switchIn)

proc executeAttack(state: State, pokemon: Pokemon, team: Team, action: Action) =
  let targets = state.getTargetedPokemon(action)
  let move = action.move
  for target in targets:
    let damage = getAvgDamage(pokemon, target, action.move, state.field)
    target.takeDamage(damage)
    #This might break in doubles for moves that target the attacker
    if move.effect.activation == eakAfterAttack:
      state.applyMoveEffect(pokemon, target, move.effect)
    if target.defenderItemActivates(move):
      if target.item.effect.activation == eakAfterAttack:
        state.applyItemEffect(target)
      if target.item.consumable:
        target.consumeItem()
    if target.fainted:
      state.afterKOAbility(pokemon, target)
  if move.isZ:
    team.isZUsed = true
  if pokemon.item.effect.activation == eakAfterAttack:
    state.applyItemEffect(pokemon)
  pokemon.previousMove = move
  pokemon.conditions[gckHasAttacked] = 1

proc executeMegaEvo(state: State, pokemon: Pokemon) =
  let team = state.getTeam(pokemon)
  if not team.isMegaUsed:
    pokemon.megaEvolve()
    team.isMegaUsed = true
    if pokemon.ability.activation == eakOnSwitchIn:
      state.applyAbilityEffect(pokemon)

proc executeAction(state: State, action: Action) =
  var pokemon = state.getPokemon(action.actingPokemonID)
  var team = state.getTeam(pokemon)
  if pokemon.fainted and action.kind != akSwitchSelection:
    return
  case action.kind
  of akSwitchSelection:
    state.executeSwitch(pokemon, team, action)
  of akMoveSelection:
    state.executeAttack(pokemon, team, action)
  of akMegaEvolution:
    state.executeMegaEvo(pokemon)

func turn*(s: State, actions: seq[Action]): State =
  var state = copy(s)
  var orderedActions: seq[Action]
  shallowCopy(orderedActions, actions)
  orderedActions.sort((a1, a2) => state.compareActions(a1, a2), SortOrder.Descending)
  for action in orderedActions:
    state.executeAction(action)
    state.fieldAssessment()
  state.turnTeardown()
  return state

proc newGame*(homeTeamString, awayTeamString: string): State =
  let homeTeam = parseTeam(homeTeamString, tskHome)
  let awayTeam = parseTeam(awayTeamString, tskAway)
  var state = State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())
  var activePokemon = state.allActivePokemon
  activePokemon.sort((p1, p2) => cmp(p1.speed(state.field), p2.speed(state.field)), SortOrder.Descending)
  for pokemon in activePokemon:
    if pokemon.ability.activation == eakOnSwitchIn:
      state.applyAbilityEffect(pokemon)
  state.assessWeather()
  state.assessAuras()
  return state

export
  actionAccessor, pokemonAccessor, state, action, setParser, gameObjects, gameData, dexes, uuids
