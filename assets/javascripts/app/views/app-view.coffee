# An example Backbone application contributed by
# [Jérôme Gravel-Niquet](http://jgn.me/). This demo uses a simple
# [LocalStorage adapter](backbone-localstorage.html)
# to persist Backbone models within your browser.

# Load the application once the DOM is ready, using `jQuery.ready`:
define [
  'jquery', 
  'underscore',
  'backbone', 
  'templates', 
  'app/models/task-list',
  'app/views/task-view',
  'app/views/stats-viewmodel'
  ], ($, _, Backbone, templates, Todos, TodoView, StatsViewModel) ->
  
  class AppView extends Backbone.View
    
    # Delegated events for creating new items, and clearing completed ones.
    events:
      "keypress #new-todo": "createOnEnter"
      "click #clear-completed": "clearCompleted"
      "click #toggle-all": "toggleAllComplete"
    
    initialize: ->
      @model = new Todos()
      @model.fetch()
      @statsModel = new StatsViewModel(@model)
      @neverPreviouslyRendered = true
    
    render: (element) ->
      # Re-rendering the App just means refreshing the statistics -- the rest
      # of the app doesn't change. So we only need to fully render it one
      if @neverPreviouslyRendered
        templates.render 'app-view', {}, (err, out) => 
          @setElement $(element).html out 
        @input = $("#new-todo")
        @allCheckbox = $("#toggle-all")[0]
        @listenTo @model, "add", @addOne
        @listenTo @model, "reset", @addAll
        @listenTo @model, "all", @render
        @footer = @$("footer")
        @main = $("#main")
        @addAll()
        @neverPreviouslyRendered = false
        
      if @statsModel.showStats
        templates.render 'stats-view', @statsModel, (err, out) => 
          @footer.html out 
        @main.show()
        @footer.show()
      else
        @main.hide()
        @footer.hide()
        
      @allCheckbox.checked = not @statsModel.remaining
    
    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (todo) ->
      view = new TodoView(model: todo)
      @$("#todo-list").append view.render().el

    
    # Add all items in the **Todos** collection at once.
    addAll: ->
      @model.each @addOne, this

    
    # If you hit return in the main input field, create new **Todo** model,
    # persisting it to storage.
    createOnEnter: (e) ->
      return  unless e.keyCode is 13
      return  unless @input.val()
      @model.create title: @input.val()
      @input.val ""

    
    # Clear all done todo items, destroying their models.
    clearCompleted: ->
      _.invoke @model.done(), "destroy"
      false

    toggleAllComplete: ->
      done = @allCheckbox.checked
      @model.each (todo) ->
        todo.save done: done
