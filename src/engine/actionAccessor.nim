import
  math, sequtils, sets, sugar, options,
  uuids,
  gameData/gameData,
  gameObjects/gameObjects,
  state, action, pokemonAccessor

func moveValidator(state: State, pokemon: Pokemon, move: PokeMove): bool =
  let allyTeam = state.getTeam(pokemon)
  return `not`((gckTaunted in pokemon.conditions or pokemon.item == "Assualt Vest") and move.category == pmcStatus) and
    `not`(move.isZ and allyTeam.isZUsed)
  # TODO: Choice lock, tormet lock. Both can be done by implementing last move used. Also would help mimic.
  # Disabled lock
  # Check move failure, don't provide moves that will always fail

func switchValidator(state: State, actingPokemon, teammate: Pokemon): bool =
  not state.isActive(teammate) and not teammate.fainted and state.isOnField(actingPokemon)

func targetValidator(state: State, move: PokeMove, targets: set[AttackTargetKind]): bool =
  if move.target in {pmtUser, pmtAlly, pmtSelectedTarget} and targets.card > 1:
    return false
  if move.target == pmtUser and `not`(atkSelf in targets):
    return false
  if move.target == pmtAlly and `not`(atkAlly in targets):
    return false
  if move.target == pmtSelectedTarget and atkSelf in targets:
    return false
  for target in targets:
    if state.field.format == ffkSingles and target in {atkEnemyTwo, atkAlly}:
      return false
  return true

func defaultTargets(state: State, move: PokeMove): set[AttackTargetKind] =
  case move.target
  of pmtUser: {atkSelf}
  of pmtAlly: {atkAlly}
  of pmtSelectedTarget: {atkEnemyOne}
  of pmtAllOpponents:
    if state.field.format == ffkSingles: {atkEnemyOne} else: {atkEnemyOne, atkEnemyTwo}
  of pmtAllOthers:
    if state.field.format == ffkSingles: {atkEnemyOne} else: {atkAlly, atkEnemyOne, atkEnemyTwo}

func idsToTargets(state: State, actingPokemon: Pokemon, ids: HashSet[UUID]): set[AttackTargetKind] =
  let allyTeam = state.getTeam(actingPokemon)
  let enemyTeam = state.getOpposingTeam(actingPokemon)
  for id in ids:
    let targetPokemon = state.getPokemon(id)
    if targetPokemon.side == allyTeam:
      let target = if targetPokemon == actingPokemon: atkSelf else: atkAlly
      result.incl(target)
    else:
      let target = if targetPokemon == enemyTeam[0]: atkEnemyOne else: atkEnemyTwo
      result.incl(target)

func getMoveAction*(state: State, pokemonID: UUID, moveStr: string, targetIDs: HashSet[UUID] = initSet[UUID]()): Option[Action] =
  let pokemon = state.getPokemon(pokemonID)
  let moveIdx = pokemon.moves.find(moveStr)
  let move = if moveIdx > -1: pokemon.moves[moveIdx] else: nil
  if isNil(move) or not state.moveValidator(pokemon, move):
    result = none[Action]()
  elif targetIDs.len == 0:
    result = some(newMoveAction(pokemonID, move, state.defaultTargets(move)))
  else:
    let targets = state.idsToTargets(pokemon, targetIDs)
    result =
      if state.targetValidator(move, targets): some(newMoveAction(pokemonID, move, targets))
      else: none[Action]()

func getSwitchAction*(state: State, pokemonID: UUID, switchTargetID: UUID): Option[Action] =
  let actingPokemon = state.getPokemon(pokemonID)
  let teammate = state.getPokemon(switchTargetID)
  if state.switchValidator(actingPokemon, teammate):
    result = some(newSwitchAction(pokemonID, switchTargetID))
  else:
    result = none[Action]()

func getMegaEvolutionAction*(state: State, pokemonID: UUID): Option[Action] =
  let pokemon = state.getPokemon(pokemonID)
  let team = state.getTeam(pokemon)
  if pokemon.item.kind == ikMegaStone and
    pokemon.item.basePokemonName == pokemon.name and
    not team.isMegaUsed:
        result = some(newMegaAction(pokemonID))
  else: result = none[Action]()

export options
