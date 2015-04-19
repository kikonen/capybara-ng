require 'rails_helper'

describe TestController, js: true do
  it 'angular js starts' do
    ng_root_selector '[ng-app]'
    visit 'http://localhost:4000'
    ng_wait
    expect(ng_eval('1 + 1')).to be 2

    # TEST model
    m = ng_model('ctrl.name')
    expect(has_ng_model?('ctrl.name')).to eq true

    expect(page).to have_ng_model('ctrl.name')
    m = ng_model('ctrl.name')
    m.set('foobar')

    # TEST bindings
    b = ng_binding('ctrl.name', row: 0)
    expect(b.visible_text).to eq 'foobar'
    expect(ng_bindings('ctrl.name')[0].visible_text).to eq 'foobar'

    expect(m.value).to eq 'foobar'

    # TEST: options
    ng_options('item.label for item in ctrl.items track by item.id')
  end
end
