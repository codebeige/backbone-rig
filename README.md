# backbone-rig

Rig your Backbone applications.

## Dependencies and Usage

*Rig* extends the functionality of *Backbone* by extending `Backbone.iew` and
`Backbone.Router`. Load the library into your project after *Backbone* is
available and extend from the corresponding *Rig* base classes.



## Application startup

Bootstrap different parts of your application independetly by registering
initializers. An *Initialzer* can be a function or any object that responds to
`#initialize()`, `#start()` or both.

    Widget =

      initialize: (config, app) ->
        // returning a promise will defer startup
        jQuery.getJSON "#{config.apiRoot}/widget/defaults.json"
          .then (data) -> _(config).defaults data

      start: (config, app) ->
        // called after ALL initialize promises are resolved
        view = new Widget.View config.widget
        config.container.append view.render().el


A shared config object ist passed to all initializer calls.

    app = MyApp.create apiRoot: 'https://myapp.net/api'

    app.register Widget, widget: { with: 50, height: 200 }
    app.register -> Backbone.history.start()

    app.start container: $('#my-app')


´Rig.Application´ extends ´Backbone.Events´ so that it can be used as a central
event hub.



## Rendering views

Extending ´Rig.View´ provides sensible defaults for updating the content by
rendering a `template` from serialzed `data`.

    class TaskView extends Rig.View

      initialize: ->
        @listenTo @model, 'change', @render

      template: (data) ->
        _.template '<p><%= title %></p>', data

      data: ->
        title: @model.escape 'title'


Static `markup` can optionally be rendered once at creation. Render will only
update the defined `content`. It is also possible to render a list of elements.

    class TasksView extends Rig.View

      initialize: ->
        @listenTo @collection, 'change', @render

      markup: ->
        '<ul></ul>'

      template: (data) ->
        _.template '<li><%- title %></li>', data

      data: ->
        @collection.pluck 'title'

      content: ->
        @$ 'ul'



## Routes

Configure your routes using an expressive and flexible syntax. For maximum
compatibility with ´Backbone.Router´ the standard hash map style is also
supported.

    class TasksRouter extends Rig.Router

      namespace: 'tasks'

      routes: [
        {route: 'tasks'       , to: 'index'  }
        {route: 'tasks/:id'   , to: 'show'   }
        {route: 'tasks/search', to: 'search' }
      ]


You can lookup matching fragments and paths via centralized helper methods:

    Rig.routes.fragment_for 'tasks#show', 123     # 'tasks/123'
    Rig.routes.path_for 'tasks#search', q: 'foo'  # '/root/tasks/search?q=foo'
    Rig.routes.url_for 'tasks#index'              # 'acme.net/root/tasks'
