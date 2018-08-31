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

