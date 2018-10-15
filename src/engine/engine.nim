import 
  algorithm, sugar, sequtils, sets, math,
  uuids,
  gameObjects/gameObjects, gameData/gameData, dexes/dexes,
  state, action, damage, effectEngine, engineutils, setParser

proc assessWeather*(state: State) =
  let activeAbilities = state.allActivePokemonObj().map((p) => p.ability)
  var constantWeatherMaintained, weatherSuppressed = false

  if state.field.rawWeather.strongWeather:
    for ability in activeAbilities:
      if ability.effect.kind == ekWeather and
         ability.effect.weather.strongWeather and
         ability.effect.weather == state.field.weather:
        constantWeatherMaintained = true
    if not constantWeatherMaintained:
      state.field.changeWeather(fwkNone, 0)

  if state.field.weatherSuppressed:
    for ability in activeAbilities:
      if ability.suppressesWeather:
        weatherSuppressed = true
    state.field.weatherSuppressed = weatherSuppressed

proc assessAuras(state: State) =
  let activeAuras = state.field.auras
  let activeAbilities = state.allActivePokemonObj().map((p) => p.ability)
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
  state.assessAuras()

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
        if target.defenderItemActivates(action.move):
          if target.item.effect.activation == eakAfterAttack:
            state.applyItemEffect(target)
          if target.item.consumable:
            target.consumeItem()
        if action.move.isZ:
          team.isZUsed = true

    state.assessWeather()
    state.assessAuras()

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
  state.assessAuras()
  return state

export
  engineutils, state, action, setParser, gameObjects, gameData, dexes
