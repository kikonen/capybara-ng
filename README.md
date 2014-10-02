# Angular

Basic bindings for AngularJS to be used with Capybara. Implementation is based into
logic copied from Protractor.

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

````ruby
require 'spec_helper'

describe 'capybara', type: :feature  do
  include Angular::DSL

  it 'test' do
    visit 'http://localhost:4000/sampler'

    p ng_set_location '/hello'
    expect(ng_location_abs).to end_with '/hello'

    ng_wait
    ap ng_location
    ap ng_eval 'body', '1 + 1'

    ng_repeater_row('view in views', 1).click
    expect(ng_model('server.url').value).to eq 'http://localhost:3001'
    expect(ng_binding('hello').visible_text).to eq 'foo'
    expect(ng_option("r for r in ['GET', 'POST', 'PUT', 'DELETE']").visible_text).to eq 'GET'

    # trying out various node query options

    p "==== ng_options"
    p ng_options("r for r in ['GET', 'POST', 'PUT', 'DELETE']")
    p ng_options("r for r in ['GET', 'POST', 'PUT', 'DELETE']").map(&:visible_text)
    p ng_option("r for r in ['GET', 'POST', 'PUT', 'DELETE']", 1).visible_text

    p "==== ng_bindings"
    p ng_bindings('hello')
    p ng_bindings('hello').map(&:visible_text)
    p ng_binding('hello', false, 1).visible_text

    p "==== ng_models"
    p ng_models('server.url')
    p ng_models('server.url').map(&:value)
    p ng_model('server.url').value

    p "==== ng_repeater_rows"
    p ng_repeater_rows('row in tableData')
    p ng_repeater_rows('row in tableData').map { |n| n['class'] }
    p ng_repeater_row('row in tableData', 2)['class']

    p "==== ng_repeater_columns"
    p ng_repeater_columns('row in tableData', '{{row.color}}')
    p ng_repeater_columns('row in tableData', '{{row.color}}').map(&:visible_text)
    p ng_repeater_column('row in tableData', '{{row.color}}', 1).visible_text

    p "==== ng_repeater_elements"
    p ng_repeater_elements('row in tableData', 1, '{{row.color}}')
    p ng_repeater_elements('row in tableData', 1, '{{row.color}}').map(&:visible_text)
    p ng_repeater_element('row in tableData', 1, '{{row.color}}', 1).visible_text
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/capybara/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
