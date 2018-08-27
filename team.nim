import hashes, uuids
import sets
import pokemon, field

type

  Team* = ref object
    members*: HashSet[Pokemon]
    activePokemon*: Pokemon
    side*: TeamSideKind

#proc makeTeam*(pokemonArray: array[6, Pokemon], side: TeamSideKind): Team =
#  let activePokemon = pokemonArray[0]
#  let members: HashSet[Pokemon] = initSet[Pokemon]()
#  for mon in pokemonArray:
#    incl(members, mon)
#  Team(members: members, activePokemon: activePokemon, side: side)

type

  Person = ref object
    uuid: UUID
    name: string

proc hash*(person: Person): Hash =
  hash(person.uuid)

proc people*(personArray: array[6, Person]): HashSet[Person] =
  let peopleSet = initSet[Person]()
  for p in personArray:
    peopleSet.incl(p)
  return peopleSet
