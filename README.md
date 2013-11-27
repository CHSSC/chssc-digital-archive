# CURATE APP

## Installing this Curate Base App

Clone this application from the Github repository:
```bash
$ git clone git@github.com:nomadicoder/curate_app.git
```

Install the applicable ruby gems:
```bash
$ cd curate_app
$ bundle
```

Then generate the curate files
```bash
$ rails generate curate
```

The Curate generator overwrites the route and configuration files. Put them back the way they were when you cloned the curate_app repostiory
```bash
$ git checkout -- config/routes.rb app/controllers/application_controller.rb
```

Migrate the database
```bash
$ rake db:migrate
```

Install hydra jetty
```bash
$ rails g hydra:jetty
```

## Run the application

Startup hydra jetty
```bash
$ rake jetty:start
```

Give the jetty server some time to spin up. In your browser, visit localhost:8983. 
If nothing happens, wait a few seconds and refresh.
when you see that the server has started, start the rails server
```bash
$ rails s
```

When the rails server has started, visit 0.0.0.0:3000 and you're ready to go.

## Customization

