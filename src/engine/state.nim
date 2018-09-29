import 
  sequtils, sets,
  uuids,
  gameObjects/gameObjects, gameData/gameData,
  action

type

  State* = ref object
    homeTeam*: Team
    awayTeam*: Team
    field*: Field

  PokemonState* = ref object
    uuid*: UUID
    percentHP*: int
    currentHP*: int

  
func copy*(state: State): State =
  State(
    homeTeam: copy(state.homeTeam),
    awayTeam: copy(state.awayTeam),
    field: copy(state.field)
  )

func getTeam*(state: State, side: TeamSideKind): Team =
  if side == tskHome: state.homeTeam else: state.awayTeam

func getPokemonObj*(state: State, uuid: UUID): Pokemon =
  for pokemon in state.homeTeam:
    if pokemon == uuid: return pokemon
  for pokemon in state.awayTeam:
    if pokemon == uuid: return pokemon
  return nil

func getPokemonObj*(state: State, side: TeamSideKind, position: int): Pokemon =
  state.getTeam(side)[position]

func getPokemon*(state: State, side: TeamSideKind, position: int): UUID =
  state.getTeam(side).get(position)

func getPokemonState(pokemon: Pokemon): PokemonState =
  PokemonState(
    uuid: pokemon.uuid, 
    percentHP: toInt(pokemon.currentHP / pokemon.maxHP),
    currentHP: pokemon.currentHP)

func getPokemonState*(state: State, pokemonID: UUID): PokemonState =
  getPokemonState(state.getPokemonObj(pokemonID))

func getPokemonState*(state: State, side: TeamSideKind, position: int): PokemonState =
  let id = state.getPokemon(side, position)
  state.getPokemonState(id)
  
func getTeam*(state: State, pokemon: Pokemon): Team =
  if pokemon.side == tskHome: state.homeTeam else: state.awayTeam

func getOpposingTeam*(state: State, pokemon: Pokemon): Team =
  if pokemon.side == tskHome: state.awayTeam else: state.homeTeam

func isActive*(state: State, pokemon: Pokemon): bool =
  if isNil(pokemon):
    return false
  let team = state.getTeam(pokemon)
  if pokemon.currentHP == 0:
    return false
  elif team.position(pokemon) == 0 and state.field.format == ffkSingles:
    return true
  elif team.position(pokemon) < 2 and state.field.format == ffkDoubles:
    return true
  else:
    return false

func getEnemy(state: State, enemyTeam: Team, target: AttackTargetKind): Pokemon =
  case target
  of atkEnemyOne:
    if state.isActive(enemyTeam[0]): enemyTeam[0]
    elif state.isActive(enemyTeam[1]): enemyTeam[1]
    else: nil
  of atkEnemyTwo:
    if state.isActive(enemyTeam[1]): enemyTeam[1]
    elif state.isActive(enemyTeam[0]): enemyTeam[0]
    else: nil
  else: nil

func getAlly(state: State, allyTeam: Team, actingPokemon: Pokemon): Pokemon =
  if state.isActive(allyTeam[1]) and allyTeam[0] == actingPokemon : allyTeam[1]
  elif state.isActive(allyTeam[0]) and allyTeam[1] == actingPokemon: allyTeam[0]
  else: nil

func getTargetedPokemon*(state: State, action: Action): HashSet[Pokemon] =
  result = initSet[Pokemon]()
  let actingPokemon = state.getPokemonObj(action.actingPokemonID)
  let allyTeam = state.getTeam(actingPokemon)
  let enemyTeam = state.getOpposingTeam(actingPokemon)
  for target in action.targets:
    let targetPokemon = case target
    of atkSelf: actingPokemon
    of atkEnemyOne, atkEnemyTwo: state.getEnemy(enemyTeam, target)
    of atkAlly: state.getAlly(allyTeam, actingPokemon)
    if not isNil(targetPokemon):
      result.incl(targetPokemon)

func compareActions*(state: State, action1, action2: Action): int =
  if action1.kind == action2.kind:
    cmp(state.getPokemonObj(action1.actingPokemonID).speed(state.field), 
        state.getPokemonObj(action2.actingPokemonID).speed(state.field))
  elif action1.kind == akSwitchSelection: 1
  else: -1
