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

# player template
Game.PlayerTemplate = 
  character: ''
  foreground: 'white'
  maxHp: 40
  attackValue: 10
  sightRadius: 6
  mixins: [
    Game.Mixins.PlayerActor
    Game.Mixins.Attacker
    Game.Mixins.Destructible
    Game.Mixins.MessageRecipient
    Game.Mixins.Sight
  ]

Game.FungusTemplate = 
  name: 'fungus'
  character: 'F'
  foreground: 'green'
  maxHp: 10
  mixins: [
    Game.Mixins.FungusActor
    Game.Mixins.Destructible
  ]

Game.BatTemplate = 
  name: 'bat'
  character: 'B'
  foreground: 'white'
  maxHp: 5
  attackValue: 10
  mixins: [
    Game.Mixins.WanderActor
    Game.Mixins.Attacker
    Game.Mixins.Destructible
  ]

Game.NewtTemplate = 
  name: 'newt'
  character: ':'
  foreground: 'red'
  maxHp: 3
  attackValue: 10
  mixins: [
    Game.Mixins.WanderActor
    Game.Mixins.Attacker
    Game.Mixins.Destructible
  ]

# bosses (1 per level)
Game.FireTemplate = 
  name: 'fire'
  character: ''
  foreground: 'red'
  maxHp: 400
  attackValue: 0
  mixins: [
    Game.Mixins.WanderActor
    Game.Mixins.Attacker
  ]

Game.BugTemplate = 
  name: 'bug'
  character: ''
  foreground: 'red'
  maxHp: 400
  attackValue: 0
  mixins: [
    Game.Mixins.WanderActor
    Game.Mixins.Attacker
  ]

Game.LockTemplate =
  name: 'lock'
  character: ''
  foreground: 'red'
  maxHp: 500
  attackValue: 0
  mixins: [
    Game.Mixins.WanderActor
    Game.Mixins.Attacker
  ]

Game.CloudTemplate =
  name: 'cloud'
  character: ''
  foreground: 'red'
  maxHp: 500
  attackValue: 0
  mixins: [
    Game.Mixins.WanderActor
    Game.Mixins.Attacker
  ]

Game.MoonTemplate =
  name: 'moon'
  character: ''
  foreground: 'red'
  maxHp: 400
  attackValue: 0
  mixins: [
    Game.Mixins.WanderActor
    Game.Mixins.Attacker
  ]