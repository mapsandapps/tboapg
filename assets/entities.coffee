# create or mixins namespace
Game.Mixins = {}

# define our moveable mixin
Game.Mixins.Moveable = 
  name: 'Moveable'
  tryMove: (x, y, map) ->
    tile = map.getTile(x, y)
    target = map.getEntityAt(x, y)
    # if an entity was at the tile
    if target
      # if we are an attacker, try to attack the target
      if @hasMixin('Attacker')
        @attack target
        return true
      else
        # can't move to the tile
        return false 
    # check if we can walk on the tile
    else if tile.isWalkable()
      # update the entity's position
      @_x = x
      @_y = y
      return true
    # # check if the tile is diggable and if so, try to dig
    # else if tile.isDiggable()
    #   map.dig x, y
    #   return true
    false

# main player's actor mixin
Game.Mixins.PlayerActor = 
  name: 'PlayerActor'
  groupName: 'Actor'
  act: ->
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
      overkillMessage = 'Overkill: ' + overkill + ' damage!' 
    else
      overkillMessage = ''
    # if 0 or less HP, remove from map
    if @_hp <= 0
      Game.sendMessage attacker, 'You kill the %s! %s', [
        @getName()
        overkillMessage
      ]
      Game.sendMessage this, 'You die!', [
        0 - @_hp
        overkillMessage
      ]
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

Game.sendMessage = (recipient, message, args) ->
  # make sure recipient can receive message
  if recipient.hasMixin(Game.Mixins.MessageRecipient)
    # if args were passed, format message
    message = vsprintf(message, args)  if args
    recipient.receiveMessage message
  return

Game.sendMessageNearby = (map, centerX, centerY, message, args) ->
  # if args were passed, format message
  message = vsprintf message, args  if args
  # get nearby entities
  entities = map.getEntitiesWithinRadius(centerX, centerY, 5)
  # iterate through nearby entities, sending message if
  # they can receive it
  i = 0
  while i < entities.length
    if entities[i].hasMixin(Game.Mixins.MessageRecipient)
      entities[i].receiveMessage message
    i++
  return

# player template
Game.PlayerTemplate = 
  character: ''
  foreground: 'white'
  maxHp: 40
  attackValue: 10
  mixins: [Game.Mixins.Moveable, Game.Mixins.PlayerActor,
           Game.Mixins.Attacker, Game.Mixins.Destructible,
           Game.Mixins.MessageRecipient]

Game.FungusTemplate = 
  name: 'fungus'
  character: 'F'
  foreground: 'green'
  maxHp: 10
  mixins: [Game.Mixins.FungusActor, Game.Mixins.Destructible]
