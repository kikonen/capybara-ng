require 'rails_helper'

describe TestController, :feature do
  it 'angular js starts' do
    ng_root_selector '#app'
    visit 'http://localhost:4000'
    ng_wait
    expect(ng_eval('1 + 1')).to be 2
  end
end
