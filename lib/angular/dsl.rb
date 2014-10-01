module Angular
module DSL
  def ng
    @ng ||= Angular::Setup.new(Capybara.current_session)
  end

  def ng_install
    ng.install
  end

  def ng_wait
    ng.ng_wait
  end

  #
  # @return current location absolute url
  #
  def ng_location_abs(using = 'body')
    ng.make_call :getLocationAbsUrl, [using], false
  end

  # @return current location absolute url
  #
  def ng_location(using = 'body')
    ng.make_call :getLocation, [using], false
  end

  #
  # @return current location
  #
  def ng_set_location(url, using = 'body')
    ng.make_call :setLocation, [using, url], false
  end

  #
  # @return eval result
  #
  def ng_eval(selector, expr)
    ng.make_call :evaluate, [selector, expr], false
  end

  #
  # Node for nth binding match
  # @return nth node
  #
  def ng_binding(binding, exact = false, row = 0, using = nil , rootSelector = 'body')
    ng_bindings(binding, exact, using , rootSelector)[row]
  end

  #
  # All nodes matching binding
  #
  # @return [node, ...]
  #
  def ng_bindings(binding, exact = false, using = nil , rootSelector = 'body')
    ng.make_call :findBindings, [binding, exact, using, rootSelector], true
  end

  #
  # Node for nth model match
  #
  # @return nth node
  #
  def ng_model(model, row = 0, using = nil , rootSelector = 'body')
    ng_models(model, using, rootSelector)[row]
  end

  #
  # All nodes matching model
  #
  # @return [node, ...]
  #
  def ng_models(model, using = nil , rootSelector = 'body')
    ng.make_call :findByModel, [model, using, rootSelector], true
  end

  #
  # Node for nth option
  #
  # @return nth node
  #
  def ng_option(options, row = 0, using = nil , rootSelector = 'body')
    ng_options(options, using, rootSelector)[row]
  end

  #
  # All option values matching option
  # @return [node, ...]
  #
  def ng_options(options, using = nil , rootSelector = 'body')
    ng.make_call :findByOptions, [options, using, rootSelector], true
  end

  #
  # Node for nth repeater row
  # @return nth node
  #
  def ng_repeater_row(repeater, row = 0, using = nil , rootSelector = 'body')
    ng.make_call(:findRepeaterRows, [repeater, row, using, rootSelector], true).first
  end

  #
  # All nodes matching repeater
  #
  # @return [node, ...]
  #
  def ng_repeater_rows(repeater, using = nil , rootSelector = 'body')
    ng.make_call :findAllRepeaterRows, [repeater, using, rootSelector], true
  end

  #
  # Node for column binding value in row
  #
  # @return nth node
  #
  def ng_repeater_column(repeater, binding, row = 0, using = nil , rootSelector = 'body')
    ng_repeater_columns(repeater, binding, using, rootSelector)[row]
  end

  #
  # Node for column binding value in all rows
  #
  # @return [node, ...]
  #
  def ng_repeater_columns(repeater, binding, using = nil , rootSelector = 'body')
    ng.make_call :findRepeaterColumn, [repeater, binding, using, rootSelector], true
  end

  #
  # @return nth node
  #
  def ng_repeater_element(repeater, index, binding, row = 0, using = nil, rootSelector = 'body')
    ng_repeater_elements(repeater, index, binding, using, rootSelector)[row]
  end

  #
  # @return [node, ...]
  #
  def ng_repeater_elements(repeater, index, binding, using = nil, rootSelector = 'body')
    ng.make_call :findRepeaterElement, [repeater, index, binding, using, rootSelector], true
  end
end
end
