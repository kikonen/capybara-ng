require 'rails_helper'

describe TestController, js: true do
  it 'angular js starts' do
    ng_root_selector '[ng-app]'
    visit 'http://localhost:4000'
    ng_wait
    expect(ng_eval('1 + 1')).to be 2

    # TEST model
    puts "test models"
    m = ng_model('ctrl.name')
    expect(has_ng_model?('ctrl.name')).to eq true

    expect(page).to have_ng_model('ctrl.name')
    expect(page).to have_no_ng_model('ctrl.name_nope')
    m = ng_model('ctrl.name')
    m.set('foobar')

    # TEST bindings
    puts "test bindings"
    b = ng_binding('ctrl.name', row: 0)
    expect(b.visible_text).to eq 'foobar'
    expect(ng_bindings('ctrl.name')[0].visible_text).to eq 'foobar'

    expect(m.value).to eq 'foobar'

    # TEST: options
    puts "test options"
    ng_options('item.label for item in ctrl.items track by item.id')
    expect(page).to have_ng_options('item.label for item in ctrl.items track by item.id')
    expect(page).to have_no_ng_options('item.label for item in ctrl.items_nope')

    # TEST: repeat
    puts "test repeat row"
    ng_repeater_row('item in ctrl.items', row: 0)
    expect(has_ng_repeater_row?('item in ctrl.items', row: 0)).to eq true
    expect(has_ng_repeater_row?('item in ctrl.items', row: 2)).to eq false

    # TEST repeat all rows
    puts "test repeat all row"
    rows = ng_repeater_rows('item in ctrl.items')
    expect(rows.length).to eq 2

    # TEST repeat columns
    puts "test repeat column"

    column = ng_repeater_column('item in ctrl.items', 'item.label', row: 1)
    expect(column.visible_text).to eq 'Bar'

    columns = ng_repeater_columns('item in ctrl.items', 'item.label')
    expect(columns.length).to eq 2
    expect(columns.map(&:visible_text)).to eq ['Foo', 'Bar']

    # TEST repeat element
    puts "test repeat element"
    elem = ng_repeater_elements('item in ctrl.items', 1, 'item.label')
    expect(elem.map(&:visible_text)).to eq ['Bar']
  end
end
