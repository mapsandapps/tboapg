Game.ItemMixins = {}

Game.ItemMixins.Equippable = 
  name: 'Equippable'
  init: (template) ->
    @_attackValue = template['attackValue'] or 0
    @_defenseValue = template['defenseValue'] or 0
    @_wieldable = template['wieldable'] or false
    @_wearable = template['wearable'] or false
    return
  
  getAttackValue: ->
    @_attackValue

  getDefenseValue: ->
    @_defenseValue

  isWieldable: ->
    @_wieldable

  isWearable: ->
    @_wearable
