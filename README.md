# Angular

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'capybara-ng'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capybara-ng

## Usage

````ruby
require 'spec_helper'

describe 'capybara', type: :feature  do
  include Angular::DSL

  it 'test' do
    visit 'http://localhost:4000/sampler'
    ng_repeater_row('view in views', 1).click
    expect(ng_model('server.url').value).to eq 'http://localhost:3001'
    expect(ng_binding('hello').visible_text).to eq 'foo'
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/capybara/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
