import sets
import pokemon

type

  Team* = ref object
    members*: HashSet[Pokemon]
    activePokemon*: Pokemon
    side*: TeamSideKind

proc makeTeam*(pokemonArray: array[6, Pokemon], side: TeamSideKind): Team =
  let activePokemon = pokemonArray[0]
  var members: HashSet[Pokemon] = initSet[Pokemon]()
  for mon in pokemonArray:
    if not isNil(mon): members.incl(mon)
  Team(members: members, activePokemon: activePokemon, side: side)

proc copy*(team: Team): Team =
  var members: HashSet[Pokemon] = initSet[Pokemon]()
  let activePokemon = copy(team.activePokemon)
  members.incl(activePokemon)
  for mon in team.members:
    members.incl(copy(mon))
  Team(members: members, activePokemon: activePokemon, side: team.side)
