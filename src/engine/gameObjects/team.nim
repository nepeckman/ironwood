import
  uuids,
  pokemon

type

  Team* = ref object
    members: seq[Pokemon]
    side*: TeamSideKind

func makeTeam*(members: seq[Pokemon], side: TeamSideKind): Team =
  Team(members: members, side: side)

func copy*(team: Team): Team =
  var members: seq[Pokemon] = @[]
  for mon in team.members:
    members.add(copy(mon))
  Team(members: members, side: team.side)

proc switchPokemon*(team: Team, actingPokemonID, switchTargetID: UUID) =
  let actingIdx = team.members.find(actingPokemonID)
  let switchIdx = team.members.find(switchTargetID)
  let tmp = team.members[actingIdx]
  team.members[actingIdx] = team.members[switchIdx]
  team.members[switchIdx] = tmp

func position*(team: Team, pokemon: Pokemon): int =
  team.members.find(pokemon) #TODO throw error

func `[]`*(team: Team, idx: int): Pokemon =
  if idx < team.members.len: team.members[idx]
  else: nil

func get*(team: Team, idx: int): UUID =
  team[idx].uuid

iterator items*(team: Team): Pokemon =
  for pokemon in team.members:
    yield pokemon
