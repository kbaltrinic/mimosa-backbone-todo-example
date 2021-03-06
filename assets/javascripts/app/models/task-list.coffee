# Todo Collection
# ---------------

# The collection of todos is backed by a remote server.
define [
  'backbone', 
  'app/models/task-model'
  ], (Backbone, Todo) ->
  class TaskList extends Backbone.Collection
  
    # Reference to this collection's model.
    model: Todo

    url: "data/task-list"

    #Override default implementation to ensure models have an asigned order
    add: (models, options) ->
      models = if _.isArray(models) then models else [models]
      model.set 'order', @nextOrder() for model in models when not model.id
      super models, options
      
    # Filter down the list of all todo items that are finished.
    done: ->
      @filter (todo) ->
        todo.get "done"

  
    # Filter down the list to only todo items that are still not finished.
    remaining: ->
      @without.apply this, @done()

  
    # We keep the Todos in sequential order, despite being saved by unordered
    # GUID in the database. This generates the next order number for new items.
    nextOrder: ->
      return 1  unless @length
      @last().get("order") + 1

  
    # Todos are sorted by their original insertion order.
    comparator: (todo) ->
      todo.get "order"