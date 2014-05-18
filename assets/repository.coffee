# A repository has a name and a constructor. The constructor is used to create
# items in the repository.
Game.Repository = (name, ctor) ->
  @_name = name
  @_templates = {}
  @_ctor = ctor
  return


# Define a new named template.
Game.Repository::define = (name, template) ->
  @_templates[name] = template
  return


# Create an object based on a template.
Game.Repository::create = (name) ->
  
  # Make sure there is a template with the given name.
  template = @_templates[name]
  throw new Error("No template named '" + name + "' in repository '" + @_name + "'")  unless template
  
  # Create the object, passing the template as an argument
  new @_ctor(template)


# Create an object based on a random template
Game.Repository::createRandom = ->
  
  # Pick a random key and create an object based off of it.
  @create Object.keys(@_templates).random()