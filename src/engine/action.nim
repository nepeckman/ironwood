import pokemon, pokemove

type

  ActionKind* = enum akMoveSelection, akSwitchSelection

  Action* = ref object
    pokemon*: Pokemon
    case kind: ActionKind
    of akMoveSelection:
      move*: PokeMove
      attackTarget*: Pokemon
    of akSwitchSelection: switchTarget*: Pokemon

proc newMoveAction*(actingPokemon: Pokemon, move: PokeMove, targetPokemon: Pokemon = nil): Action =
  Action(kind: akMoveSelection, pokemon: actingPokemon, move: move, attackTarget: targetPokemon)

proc newSwitchAction*(actingPokemon, targetPokemon: Pokemon): Action = 
  Action(kind: akSwitchSelection, pokemon: actingPokemon, switchTarget: targetPokemon)
