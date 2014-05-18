# create or mixins namespace
Game.Mixins = {}

# main player's actor mixin
Game.Mixins.PlayerActor = 
  name: 'PlayerActor'
  groupName: 'Actor'
  act: (overkillMessage) ->
    # detect if game is over
    if @getHp() < 1
      Game.Screen.playScreen.setGameEnded true
      # send a last message to the player
      Game.sendMessage this, overkillMessage + ' You have died... Press [Enter] to continue!'

    # re-render screen
    Game.refresh()
    # lock engine and wait for player to press a key
    @getMap().getEngine().lock()
    # clear message queue
    @clearMessages()
    return

Game.Mixins.FungusActor =
  name: 'FungusActor'
  groupName: 'Actor'
  act: ->

# an entity that simply wanders around
Game.Mixins.WanderActor = 
  name: 'WanderActor'
  groupName: 'Actor'
  act: ->
    # flip coin to determine if moving by 1 in positive or negative direction
    moveOffset = (if (Math.round(Math.random()) is 1) then 1 else -1)

    # flip coin to determine x or y
    if Math.round(Math.random()) is 1
      @tryMove @getX() + moveOffset, @getY(), @getZ()
    else
      @tryMove @getX(), @getY() + moveOffset, @getZ()
    return

Game.Mixins.Attacker = 
  name: 'Attacker'
  groupName: 'Attacker'
  init: (template) ->
    @_attackValue = template['attackValue'] or 1
    return
  getAttackValue: ->
    @_attackValue
  attack: (target) ->
    # if target is destructible,
    # calculate damage from attack & defense values
    if target.hasMixin('Destructible')
      attack = @getAttackValue()
      defense = target.getDefenseValue()
      max = Math.max(0, attack - defense)
      damage = 1 + Math.floor(Math.random() * max)

      Game.sendMessage this, 'You strike the %s for %d damage!', [
        target.getName()
        damage
      ]
      Game.sendMessage target, 'The %s strikes you for %d damage!', [
        @getName()
        damage
      ]
      target.takeDamage this, damage
    return

Game.Mixins.Destructible =
  name: 'Destructible'
  init: (template) ->
    @_maxHp = template['maxHp'] or 10
    @_hp = template['hp'] or @_maxHp
    @_defenseValue = template['defenseValue'] or 0
    return
  getDefenseValue: ->
    @_defenseValue
  getHp: ->
    @_hp
  getMaxHp: ->
    @_maxHp
  takeDamage: (attacker, damage) ->
    @_hp -= damage
    overkill = 0 - @_hp
    if overkill > 0
      overkillMessage = '%c{red}Overkill: ' + overkill + ' damage!' 
    else
      overkillMessage = ''
    # if 0 or less HP, remove from map
    if @_hp <= 0
      Game.sendMessage attacker, 'You kill the %s! %s', [
        @getName()
        overkillMessage
      ]
      # check if the player died. if so, call their act method to prompt user
      if @hasMixin(Game.Mixins.PlayerActor)
        @act(overkillMessage)
      else
        @getMap().removeEntity this
    return

Game.Mixins.MessageRecipient = 
  name: 'MessageRecipient'
  init: (template) ->
    @_messages = []
    return
  receiveMessage: (message) ->
    @_messages.push(message)
    return
  getMessages: ->
    @_messages
  clearMessages: ->
    @_messages = []
    return

# this signifies our entity possesses a fov of a given radius
Game.Mixins.Sight =
  name: 'Sight'
  groupName: 'Sight'
  init: (template) ->
    @_sightRadius = template['sightRadius'] or 5
    return

  getSightRadius: ->
    @_sightRadius

Game.sendMessage = (recipient, message, args) ->
  # make sure recipient can receive message
  if recipient.hasMixin(Game.Mixins.MessageRecipient)
    # if args were passed, format message
    message = vsprintf(message, args)  if args
    recipient.receiveMessage message
  return

Game.sendMessageNearby = (map, centerX, centerY, centerZ, message, args) ->
  # if args were passed, format message
  message = vsprintf message, args  if args
  # get nearby entities
  entities = map.getEntitiesWithinRadius(centerX, centerY, centerZ, 5)
  # iterate through nearby entities, sending message if
  # they can receive it
  i = 0
  while i < entities.length
    if entities[i].hasMixin(Game.Mixins.MessageRecipient)
      entities[i].receiveMessage message
    i++
  return

Game.Mixins.InventoryHolder = 
  name: 'InventoryHolder'
  init: (template) ->
    # default to 8 slots
    inventorySlots = template['inventorySlots'] or 8
    # set up an empty inventory
    @_items = new Array(inventorySlots)
    return

  getItems: ->
    @_items

  getItem: (i) ->
    @_items[i]

  addItem: (item) ->
    # try to find a slot, returning true only if we could add the item
    i = 0
    while i < @_items.length
      unless @_items[i]
        @_items[i] = item
        return true
      i++
    false

  removeItem: (i) ->
    # clear the inventory slot
    @_items[i] = null
    return

  canAddItem: ->
    # check if we have an empty slot
    i = 0
    while i < @_items.length
      return true  unless @_items[i]
      i++
    false

  pickupItems: (indices) ->
    # allows the user to pick up items from the map
    # indices is the indices for the array returned by map.getItemsAt
    mapItems = @_map.getItemsAt(@getX(), @getY(), @getZ())
    added = 0
    # iterate through a ll indices
    i = 0
    while i < indices.length
      # try to add the item
      # if inventory is not full, splice item out of list of items
      # offset number of items already added
      if @addItem(mapItems[indices[i] - added])
        mapItems.splice indices[i] - added, 1
        added++
      else
        # inventory is full
        break
      i++
    # update the map items
    @_map.setItemsAt @getX(), @getY(), @getZ(), mapItems
    # return true only if we added all the items
    added is indices.length

  dropItem: (i) ->
    # drop item to current tile
    if @_items[i]
      if @_map
        @_map.addItem @getX(), @getY(), @getZ(), @_items[i]
      @removeItem(i)
    return



# player template
Game.PlayerTemplate = 
  character: ''
  foreground: 'white'
  maxHp: 40
  attackValue: 10
  sightRadius: 6
  inventorySlots: 10
  mixins: [
    Game.Mixins.PlayerActor
    Game.Mixins.Attacker
    Game.Mixins.Destructible
    Game.Mixins.InventoryHolder
    Game.Mixins.MessageRecipient
    Game.Mixins.Sight
  ]

# Create our central entity repository
Game.EntityRepository = new Game.Repository('entities', Game.Entity)
Game.EntityRepository.define 'fungus',
  name: 'fungus'
  character: 'F'
  foreground: 'green'
  maxHp: 10
  mixins: [
    Game.Mixins.FungusActor
    Game.Mixins.Destructible
  ]

Game.EntityRepository.define 'bat',
  name: 'bat'
  character: 'B'
  foreground: 'white'
  maxHp: 5
  attackValue: 4
  mixins: [
    Game.Mixins.WanderActor
    Game.Mixins.Attacker
    Game.Mixins.Destructible
  ]

Game.EntityRepository.define 'newt',
  name: 'newt'
  character: ':'
  foreground: 'yellow'
  maxHp: 3
  attackValue: 2
  mixins: [
    Game.Mixins.WanderActor
    Game.Mixins.Attacker
    Game.Mixins.Destructible
  ]

# create our boss repository
Game.BossRepository = new Game.Repository('entities', Game.Entity)
Game.BossRepository.define 'plant',
  name: 'plant'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.Mixins.WanderActor
  ]

Game.BossRepository.define 'moon',
  name: 'moon'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.Mixins.WanderActor
  ]
  
Game.BossRepository.define 'cloud',
  name: 'cloud'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.Mixins.WanderActor
  ]
  
Game.BossRepository.define 'lock',
  name: 'lock'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.Mixins.WanderActor
  ]
  
Game.BossRepository.define 'fire',
  name: 'fire'
  character: ''
  foreground: 'hotPink'
  maxHp: 10
  mixins: [
    Game.Mixins.WanderActor
  ]