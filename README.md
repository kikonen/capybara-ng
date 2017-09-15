# Angular

Basic bindings for AngularJS to be used with Capybara. Implementation is based into
logic copied from Protractor.

*NOTE* At this point of development, I would classify DSL API "unstable". This means that
DSL language may change in incompatible ways.

## Supported drivers

Based into testing following drivers should work.

- chrome
- poltergeist
- selenium (using firefox)
- webkit

## Related Projects

- https://github.com/jnicklas/capybara
- https://github.com/angular/protractor
- https://code.google.com/p/selenium/wiki/RubyBindings
- https://github.com/teampoltergeist/poltergeist
- https://github.com/colszowka/phantomjs-gem

## Installation

Add this line to your application's Gemfile:

    gem 'capybara-ng'
    gem 'capybara-ng', git: 'git@github.com:kikonen/capybara-ng.git', tag: 'v0.0.1'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capybara-ng

## Usage

### Setup

spec/spec_helper.rb
````ruby
RSpec.configure do |config|
  config.include ::Angular::DSL
  ...
end
````

## Examples

### Example test cases

````bash
cd spec/dummy
bundle
bundle exec rake rspec
bundle exec rake cucumber
````

### Experimenting features

@see https://github.com/kikonen/sampler/blob/master/dummy/spec/request/test_spec.rb

### Example test

@see https://github.com/kikonen/sampler/blob/master/dummy/spec/request/task_spec.rb

#### Running Example Test

[Download and install chrome-driver](http://chromedriver.storage.googleapis.com/index.html)

````bash
git clone git@github.com:kikonen/sampler.git
cd sampler
cd dummy
bundle
rails s -p 4000&
bundle exec rspec spec/request/test_spec.rb
bundle exec rspec spec/request/task_spec.rb
fg
CTRL^C
````


## Contributing

1. Fork it ( https://github.com/[my-github-username]/capybara/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
