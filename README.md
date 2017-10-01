# Elir

> This is our take on supercharging the test-automation tools with the ability to run supervised tests (RSpec/Minitest/etc) concurrently, in the simplest way possible - if possible :)

Prototype made for demo purposes, during the Ruby Open Source Testing Code Hackathon, 22-23 Sept 2017, hosted by Loblaw Digital, in Toronto.

## Installation

Get the project:

    git clone https://github.com/azohra/elir.git

Get dependencies, Compile and Test (1st):

    cd elir
    mix do deps.get, compile
    mix test

If everything is fine, then build Elir to be used as cli app/script:

    cd elir
    MIX_ENV=prod mix escript.build

You should now have an executable: `elir`, in your **elir** project folder.

## Configuration and usage

At this very moment, Elir's solely role is to run a command of your choice, in a command shell of the target OS, captures the standard output of the command, and returns this result as a string. But with a twist: it runs the same command in multiple "sessions", each session receiving its own ENV containing the `env` variables you defined in the `elir.yml` file. The env variables will be mixed among themselves if they are lists of values. 

For example, check the demo folder: `./rspec_demo`. In this folder, which looks like this:

```
rspec_demo
├── Gemfile
├── Gemfile.lock
├── elir.yml
└── spec
   ├── env_spec.rb
   └── spec_helper.rb
```

we must define the `elir.yml` file, in the `rspec_demo` folder. This is the file used by Elir. 

## Configuring Elir

Example of a custom Elir configuration file (elir.yml):

```yml
elir:
  inflector: true
  
  # create a cartesian product with the elements below
  env:
    - languages: fr, en
    - devices: mobile, desktop
    - servers: local
  
  # pour the next values into the environment, as is
  context_env:
    - alpha: beta
    - gamma: delta
  
  # every run will receive a process id following the formatting hints below
  process:
    name: RUN_ID
    length: 20
    # prefix: KE
    # suffix: WL
    # sep: "-"
  
  # and run this command for every combination above
  cmd: bundle exec rspec
  # uncomment next, to write the cmd output to a file of your choice
  # log_file: results.log

  # pool management
  pool_size: 20
  max_overflow: 5
  # suite_timeout: :infinity
```

With other words, we configure Elir to: mix the values defined by the env variables above: `devices`, `languages`, etc, and to run `bundle exec rspec` in the folder we want. For every run the ENV will contain the singular form of your variables defined in the `env:` and their respective value for that run. Remember, the System ENV contents are **not** interpolated, every run receiving a clean ENV! Example of run:

```sh
cd elir
./elir ./rspec_demo
```

And you'll see something like this (excerpt):

```sh
11:01:44.009 [info]  ==> Running bundle exec rspec ./rspec_demo/, with: [{"language", "en"}, {"device", "desktop"}, {"server", "local"}], args: []

11:01:44.009 [info]  ==> Running bundle exec rspec ./rspec_demo/, with: [{"language", "fr"}, {"device", "desktop"}, {"server", "local"}], args: []
.

Finished in 0.00284 seconds (files took 0.08017 seconds to load)
1 example, 0 failures

F

Failures:

  1) ENV can find variables in the system environment
     Failure/Error: expect("#{ENV['language']}").to eql("en")

       expected: "en"
            got: "fr"

       (compared using eql?)
     # ./spec/env_spec.rb:7:in `block (2 levels) in <top (required)>'

Finished in 0.01273 seconds (files took 0.08013 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/env_spec.rb:4 # ENV can find variables in the system environment


11:01:44.343 [error] Shutting down; 1

```

Also, the env variables from the `elir.yml`, their singular form, are also available in the ENV, as: `ENV["labels"]`, to simplify the implementation of various custom (RSpec, etc) formatters. For example:

    puts ENV["labels"]
    # server, language, device


Notice the log containing the cartesian product resulting from mixing your `env` variables, for every run:

```elixir
[{"language", "en"}, {"device", "desktop"}, {"server", "local"}]
```

**Please Observe!**

- Elir can use an inflector to obtain the singular form of your variable names: `languages` => `language`. You'll get the singular form, in the ENV! You can disable the inflector, by setting the `inflector` config variable to: `false`

## Docker

> this part is currently under development

You can run elir using docker. Example:

    docker run --rm -v ~/temp/rspec_demo:/app/test_dir azohra/elir ./elir test_dir

(work in progress)
