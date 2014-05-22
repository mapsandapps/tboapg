Game.ItemRepository = new Game.Repository('items', Game.Item)
Game.ItemRepository.define 'bug',
  name: 'bug'
  character: ''
  foreground: 'mediumAquaMarine'
  wieldable: true
  mixins: [
    Game.ItemMixins.Equippable
  ]
,
  disableRandomCreation: true

# Game.ItemRepository.define 'sun',
#   name: 'sun'
#   character: ''
#   foreground: 'mediumAquaMarine'
#   wieldable: true
#   mixins: [
#     Game.ItemMixins.Equippable
#   ]
# ,
#   disableRandomCreation: true

Game.ItemRepository.define 'like',
  name: 'like'
  character: ''
  foreground: 'mediumAquaMarine'
  wieldable: true
  mixins: [
    Game.ItemMixins.Equippable
  ]
,
  disableRandomCreation: true

Game.ItemRepository.define 'umbrella',
  name: 'umbrella'
  character: ''
  foreground: 'mediumAquaMarine'
  wieldable: true
  mixins: [
    Game.ItemMixins.Equippable
  ]
,
  disableRandomCreation: true

Game.ItemRepository.define 'key',
  name: 'key'
  character: ''
  foreground: 'mediumAquaMarine'
  wieldable: true
  mixins: [
    Game.ItemMixins.Equippable
  ]
,
  disableRandomCreation: true

Game.ItemRepository.define 'extinguisher',
  name: 'extinguisher'
  character: ''
  foreground: 'mediumAquaMarine'
  wieldable: true
  mixins: [
    Game.ItemMixins.Equippable
  ]
,
  disableRandomCreation: true
