# backbone-rig

Rig your Backbone applications.

##Dependencies and Usage

*Rig* extends the functionality of *Backbone* by extending `Backbone.View` and
`Backbone.Router`. Load the library into your project after *Backbone* is
available and extend from the corresponding *Rig* base classes.

##Routes

Configure your routes using an expressive and flexible syntax. For maximum
compatibility with *Backbone.Router* the standard hash map style is also
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
