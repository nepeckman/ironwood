import
  uuids,
  pokemon

type

  Team* = ref object
    members*: seq[Pokemon]
    side*: TeamSideKind

proc makeTeam*(members: seq[Pokemon], side: TeamSideKind): Team =
  Team(members: members, side: side)

proc copy*(team: Team): Team =
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
