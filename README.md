# NuHttp

A new (_nu_) and compact HTTP server library for Ruby.

## Features

- **Compact API.** Good for embedding in tools.
- **Some typing support.** NuHttp API is (or should be) mostly typed. `params` also recieve types based on path patterns.
- **Ractor mode.** Explore true concurrency!

To be implemented: Performance, profiling, benchmarking

## Usage

NuHttp apps are defined in `NuHttp.app` blocks.

```ruby
require 'nuhttp'
require 'nuhttp/server'

world = "World"

App = NuHttp.app do |b|
  b.get '/' do |c|
    c.res.body = "Hello, #{world}!\n"
  end

  b.get '/json' do |c|
    c.json({ message: "Hello, #{world}!" })
  end

  b.get '/users/:id' do |c|
    user_id = c.req.params[:id]
    c.json({ user_id: user_id })
  end
  
  b.get '/html' do |c|
    c.html("<!DOCTYPE html><html> ... </html>")
  end
  
  b.get '/erb' do |c|
    # HTML+ERB support by Herb (https://github.com/marcoroth/herb)
    # `herb` gem must be installed to use c.erb
    c.erb("/path/to/view.html.erb", { my_variable: 1 })
  end
end

NuHttp::Server.new(App).start
```

### As an Rack app

While NuHttp ships its own HTTP server, NuHttp apps may be mounted on other servers that implement the Rack spec. Common choices are [Puma](https://github.com/puma/puma), [Unicorn](https://yhbt.net/unicorn/), and [Falcon](https://github.com/socketry/falcon).

Define a `config.ru` file:

```ruby
# config.ru

App = NuHttp.app do |b|
  b.get '/' do |c|
    # ...
  end
end

run NuHttp::RackAdapter.new(App)
```

... then run the server of your choice.

```
$ puma
```

### Typing support on `c.req.params`

[Steep](https://github.com/soutaro/steep) users may benefit from generated type signatures for `c.req.params`.

![](/typecheck.png)

Run `nuhttp-typegen` to scan `*.rb` files and generate types.

```
nuhttp-typegen > sig/app.rbs
```

### Ractor Mode! (Ruby 4.0+)

Accept the challenge of making your app _Ractor shareable_! The HTTP server shipped with NuHttp spawns a new Ractor for each request, allowing requests to be served in a truly parallel manner.

Define your app using`NuHttp.ractor_app` and start the server with `NuHttp::Server.new(app, ractor_mode: true).start`:

```ruby
require 'nuhttp'
require 'nuhttp/server'

App = NuHttp.ractor_app do |b|
  # Think of each handlerbeing executed in Ractor.new { }
  b.get '/' do |c|
    # ...
  end
end

NuHttp::Server.new(App, ractor_mode: true).start
```

Ractor mode brings many restrictions on what can be done in handlers. While you don't have to directly call `Ractor.new` in your code, you should read [ractor.md](https://docs.ruby-lang.org/en/master/language/ractor_md.html) in the Ruby docs for a good understanding of Ractors.

Ractor mode requires `Ractor.shareable_proc`, a Ruby 4.0+ API ([Feature #21157](https://bugs.ruby-lang.org/issues/21557)).

## FAQ

### How is this different from Sinatra?

One key difference is the context where the handler is evaluated. 

In Sinatra, this code raises:

```ruby
x = "world"
class App < Sinatra::Base
  get '/' do
    "hello, #{x}"
  end
end
```

```
NameError: undefined local variable or method 'x' for an instance of App (NameError)

    "hello, #{x}"
              ^
```

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add nuhttp
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install nuhttp
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/osyoyu/nuhttp.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
