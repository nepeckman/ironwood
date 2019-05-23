import sets
import ../src/engine/engine

template checkHP*(state: State, pokemon: UUID, hp: int) =
  check(state.getPokemonState(pokemon).currentHP == hp)

type GameSetup* = tuple[state: State, homePoke, awayPoke: UUID]

template gameSetup*(homeString, awayString: string): GameSetup =
  var state = newGame(homeString, awayString)
  let homePoke = state.getPokemonID(tskHome, 0)
  let awayPoke = state.getPokemonID(tskAway, 0)
  (state: state, homePoke: homePoke, awayPoke: awayPoke)

func switch*(state: State, actingPokemon, switchTarget: UUID): Action =
  state.getSwitchAction(actingPokemon, switchTarget).get()

func attack*(state: State, pokemonID: UUID, moveStr: string, targetIDs: HashSet[UUID] = initSet[UUID]()): Action =
  state.getMoveAction(pokemonID, moveStr, targetIDs).get()

func megaEvolve*(state: State, pokemonID: UUID): Action =
  state.getMegaEvolutionAction(pokemonID).get()

export engine
