# create our mixins namespace
Game.EntityMixins = {}

# main player's actor mixin
Game.EntityMixins.PlayerActor = 
  name: 'PlayerActor'
  groupName: 'Actor'
  init: (template) ->
    @_bossKills = template['bossKills'] or 0
    return
  getBossKills: ->
    @_bossKills
  addBossKill: ->
    @_bossKills += 1
  act: ->
    return  if @_acting
    @_acting = true
    # detect if game is over
    unless @isAlive()
      Game.Screen.playScreen.setGameEnded true
      # send a last message to the player
      Game.sendMessage this, ' You have died... Press [Enter] to continue!'

    # re-render screen
    Game.refresh()
    # lock engine and wait for player to press a key
    @getMap().getEngine().lock()
    # clear message queue
    @clearMessages()
    @_acting = false
    return

Game.EntityMixins.FungusActor =
  name: 'FungusActor'
  groupName: 'Actor'
  act: ->

# an entity that simply wanders around
Game.EntityMixins.WanderActor = 
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

Game.EntityMixins.Attacker = 
  name: 'Attacker'
  groupName: 'Attacker'
  init: (template) ->
    @_attackValue = template['attackValue'] or 1
    return
  getAttackValue: ->
    modifier = 0
    # armor and weapon
    if @hasMixin(Game.EntityMixins.Equipper)
      modifier += @getWeapon().getAttackValue()  if @getWeapon()
      modifier += @getArmor().getAttackValue()  if @getArmor()
    @_attackValue + modifier
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

Game.EntityMixins.Destructible =
  name: 'Destructible'
  init: (template) ->
    @_maxHp = template['maxHp'] or 10
    @_hp = template['hp'] or @_maxHp
    @_defenseValue = template['defenseValue'] or 0
    @_weakness = template['weakness'] or 'none'
    return
  getDefenseValue: ->
    modifier = 0
    # weapon & armor
    if @hasMixin(Game.EntityMixins.Equipper)
      modifier += @getWeapon().getDefenseValue()  if @getWeapon()
      modifier += @getArmor().getDefenseValue()  if @getArmor()
    @_defenseValue + modifier
  getHp: ->
    @_hp
  getMaxHp: ->
    @_maxHp
  takeDamage: (attacker, damage) ->
    if attacker.hasMixin(Game.EntityMixins.Equipper) and attacker._weapon isnt null
      if @_weakness is attacker.getWeapon()._name
        damage = 500  
        attacker.addBossKill()
        attacker.clearMessages()
        Game.sendMessage attacker, "You have found the %s's weakness!", [
          @getName()
        ]
        Game.sendMessage attacker, "You strike the %s for %s damage!", [
          @getName()
          damage
        ]
        Game.sendMessage attacker, 'You have killed %s out of 5 bosses!', [
          attacker.getBossKills()
        ]
        # win condition
        if attacker.getBossKills() is 5
          Game.switchScreen Game.Screen.winScreen
      @_hp -= damage
      # if 0 or less HP, remove from map
      if @_hp <= 0
        Game.sendMessage attacker, 'You kill the %s!', [
          @getName()
        ]
        @kill()
    else
      @_hp -= damage
      # if 0 or less HP, remove from map
      if @_hp <= 0
        Game.sendMessage attacker, 'You kill the %s!', [
          @getName()
        ]
        @kill()
    return

Game.EntityMixins.MessageRecipient = 
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
Game.EntityMixins.Sight =
  name: 'Sight'
  groupName: 'Sight'
  init: (template) ->
    @_sightRadius = template['sightRadius'] or 5
    return

  getSightRadius: ->
    @_sightRadius

Game.sendMessage = (recipient, message, args) ->
  # make sure recipient can receive message
  if recipient.hasMixin(Game.EntityMixins.MessageRecipient)
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
    if entities[i].hasMixin(Game.EntityMixins.MessageRecipient)
      entities[i].receiveMessage message
    i++
  return

Game.EntityMixins.InventoryHolder = 
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
    # make sure we unequip item we remove
    @unequip() @_items[i]  if @_items[i] and @hasMixin(Game.EntityMixins.Equipper)
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

Game.EntityMixins.Equipper =
  name: 'Equipper'
  init: (template) ->
    @_weapon = null
    @_armor = null
    return

  wield: (item) ->
    @_weapon = item
    return

  unwield: ->
    @_weapon = null
    return

  wear: (item) ->
    @_armor = item
    return

  takeOff: ->
    @_armor = null
    return

  getWeapon: ->
    @_weapon

  getArmor: ->
    @_armor

  unequip: (item) ->
    # helper function to be called before getting rid of an item
    @unwield()  if @_weapon is item
    @takeOff()  if @_armor is item
    return

Game.EntityMixins.Boss =
  name: 'Boss'
  init: (template) ->
    return



