# player template
Game.PlayerTemplate = 
  character: ''
  foreground: 'white'
  maxHp: 40
  attackValue: 10
  sightRadius: 6
  inventorySlots: 10
  mixins: [
    Game.EntityMixins.PlayerActor
    Game.EntityMixins.Attacker
    Game.EntityMixins.Destructible
    Game.EntityMixins.InventoryHolder
    Game.EntityMixins.MessageRecipient
    Game.EntityMixins.Sight
    Game.EntityMixins.Equipper
  ]

# Create our central entity repository
Game.EntityRepository = new Game.Repository('entities', Game.Entity)
Game.EntityRepository.define 'fungus',
  name: 'fungus'
  character: 'F'
  foreground: 'green'
  maxHp: 10
  mixins: [
    Game.EntityMixins.FungusActor
    Game.EntityMixins.Destructible
  ]

Game.EntityRepository.define 'bat',
  name: 'bat'
  character: 'B'
  foreground: 'white'
  maxHp: 5
  attackValue: 4
  mixins: [
    Game.EntityMixins.WanderActor
    Game.EntityMixins.Attacker
    Game.EntityMixins.Destructible
  ]

Game.EntityRepository.define 'newt',
  name: 'newt'
  character: ':'
  foreground: 'yellow'
  maxHp: 3
  attackValue: 2
  mixins: [
    Game.EntityMixins.WanderActor
    Game.EntityMixins.Attacker
    Game.EntityMixins.Destructible
  ]

# create our boss repository
Game.BossRepository = new Game.Repository('entities', Game.Entity)
Game.BossRepository.define 'plant',
  name: 'plant'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.EntityMixins.WanderActor
  ]
,
  disableRandomCreation: true

Game.BossRepository.define 'moon',
  name: 'moon'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.EntityMixins.WanderActor
  ]
,
  disableRandomCreation: true
  
Game.BossRepository.define 'cloud',
  name: 'cloud'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.EntityMixins.WanderActor
  ]
,
  disableRandomCreation: true
  
Game.BossRepository.define 'lock',
  name: 'lock'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.EntityMixins.WanderActor
  ]
,
  disableRandomCreation: true
  
Game.BossRepository.define 'fire',
  name: 'fire'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.EntityMixins.WanderActor
  ]
,
  disableRandomCreation: true