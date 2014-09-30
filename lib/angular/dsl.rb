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
  def ng_get_location_url(using = 'body')
    ng.make_call :getLocationAbsUrl, [using], false
  end

  # @return current location absolute url
  #
  def ng_get_location(using = 'body')
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
  # @return node first matching query
  #
  def ng_repeater_row(repeater, row = 0)
    ng_repeater_rows(repeater, row).first
  end

  #
  # @return [node, ...]
  #
  def ng_repeater_rows(repeater, row = 0, using = nil , rootSelector = 'body')
    ng.make_call :findRepeaterRows, [repeater, row, using, rootSelector], true
  end

  #
  # @return [node, ...]
  #
  def ng_all_repeater_rows(repeater, using = nil , rootSelector = 'body')
    ng.make_call :findAllRepeaterRows, [repeater, using, rootSelector], true
  end

  #
  # @return first node
  #
  def ng_repeater_column(repeater, binding, using = nil , rootSelector = 'body')
    ng_repeater_column(repeater, binding, using, rootSelector).first
  end

  #
  # @return [node, ...]
  #
  def ng_repeater_columns(repeater, binding, using = nil , rootSelector = 'body')
    ng.make_call :findRepeaterColumn, [repeater, binding, using, rootSelector], true
  end

  #
  # @return first node
  #
  def ng_repeater_element(repeater, index, binding, using = nil, rootSelector = 'body')
    ng_repeater_elements(repeater, index, binding, using, rootSelector).first
  end

  #
  # @return [node, ...]
  #
  def ng_repeater_elements(repeater, index, binding, using = nil, rootSelector = 'body')
    ng.make_call :findRepeaterColumn, [repeater, index, binding, using, rootSelector], true
  end

  #
  # @return first node
  #
  def ng_binding(binding, exact = false, using = nil , rootSelector = 'body')
    ng_bindings(binding, exact, using , rootSelector).first
  end

  #
  # @return [node, ...]
  #
  def ng_bindings(binding, exact = false, using = nil , rootSelector = 'body')
    ng.make_call :findBindings, [binding, exact, using, rootSelector], true
  end

  #
  # @return first node
  #
  def ng_model(model, using = nil , rootSelector = 'body')
    ng_models(model, using, rootSelector).first
  end

  #
  # @return [node, ...]
  #
  def ng_models(model, using = nil , rootSelector = 'body')
    ng.make_call :findByModel, [model, using, rootSelector], true
  end

  #
  # @return first node
  #
  def ng_option(options, using = nil , rootSelector = 'body')
    ng_options(options, using, rootSelector).first
  end

  #
  # @return [node, ...]
  #
  def ng_options(options, using = nil , rootSelector = 'body')
    ng.make_call :findByOptions, [options, using, rootSelector], true
  end
end
end
