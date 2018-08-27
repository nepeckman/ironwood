import sets
import pokemon, field

type

  Team* = ref object
    members*: HashSet[Pokemon]
    activePokemon*: Pokemon
    side*: TeamSideKind

proc makeTeam*(pokemonArray: array[6, Pokemon], side: TeamSideKind): Team =
  let activePokemon = pokemonArray[0]
  var members: HashSet[Pokemon] = initSet[Pokemon]()
  for mon in pokemonArray:
    members.incl(mon)
  Team(members: members, activePokemon: activePokemon, side: side)
