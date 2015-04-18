module Angular
module DSL
  def ng
    @ng ||= ::Angular::Setup.new(Capybara.current_session)
  end

  def ng_root_selector(root_selector = nil)
    opt = ng.page.ng_session_options
    if root_selector
      opt[:root_selector] = root_selector
    end
    opt[:root_selector] || ::Angular.root_selector
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
  def ng_location_abs(opt = {})
    selector = opt.delete(:root_selector) || ng_root_selector
    ng.make_call :getLocationAbsUrl, [selector], opt
  end

  # @return current location absolute url
  #
  def ng_location(opt = {})
    selector = opt.delete(:root_selector) || ng_root_selector
    ng.make_call :getLocation, [selector], opt
  end

  #
  # @return current location
  #
  def ng_set_location(url, opt = {})
    selector = opt.delete(:root_selector) || ng_root_selector
    ng.make_call :setLocation, [selector, url], opt
  end

  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return eval result
  #
  def ng_eval(expr, opt = {})
    selector = opt.delete(:root_selector) || ng_root_selector
    ng.make_call :evaluate, [selector, expr], opt
  end

  #
  # Does binding exist
  #
  # @param opt
  # - :exact
  # - :using
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_ng_binding?(binding, opt = {})
    ng_bindings(model, opt)
    true
  rescue NotFound
    false
  end

  #
  # Node for nth binding match
  #
  # @param opt
  # - :row
  # - :exact
  # - :using
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_binding(binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_bindings(binding, opt)[row]
  end

  #
  # All nodes matching binding
  #
  # @param opt
  # - :exact
  # - :using
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_bindings(binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes :findBindings, [binding, opt[:exact] == true], opt
  end

  #
  # Does model exist
  #
  # @param opt
  # - :using
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_ng_model?(model, opt = {})
    ng_models(model, opt)
    true
  rescue NotFound
    false
  end

  #
  # Node for nth model match
  #
  # @param opt
  # - :row
  # - :using
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_model(model, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_models(model, opt)[row]
  end

  #
  # All nodes matching model
  #
  # @param opt
  # - :using
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_models(model, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes :findByModel, [model], opt
  end

  #
  # Does option exist
  #
  # @param opt
  # - :using
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_ng_option?(options, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng_options(options, opt)
    true
  rescue NotFound
    false
  end

  #
  # Node for nth option
  #
  # @param opt
  # - :row
  # - :using
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_option(options, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_options(options, opt)[row]
  end

  #
  # All option values matching option
  #
  # @param opt
  # - :using
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_options(options, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes :findByOptions, [options], opt
  end

  #
  # Does row exist
  #
  # @param opt
  # - :using
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_ng_repeater_row?(repeater, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes(:findRepeaterRows, [repeater, 0], opt)
    true
  rescue NotFound
    false
  end

  #
  # Node for nth repeater row
  #
  # @param opt
  # - :row
  # - :using
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_repeater_row(repeater, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    data = ng.get_nodes(:findRepeaterRows, [repeater, row], opt)
    data.first
  end

  #
  # All nodes matching repeater
  #
  # @param opt
  # - :using
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_repeater_rows(repeater, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes :findAllRepeaterRows, [repeater], opt
  end

  #
  # Node for column binding value in row
  #
  # @param opt
  # - :row
  # - :using
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_repeater_column(repeater, binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_repeater_columns(repeater, binding, opt)[row]
  end

  #
  # Node for column binding value in all rows
  #
  # @param opt
  # - :using
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_repeater_columns(repeater, binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes :findRepeaterColumn, [repeater, binding], opt
  end

  #
  # @param opt
  # - :row
  # - :using
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_repeater_element(repeater, index, binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_repeater_elements(repeater, index, binding, opt)[row]
  end

  #
  # @param opt
  # - :using
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_repeater_elements(repeater, index, binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes :findRepeaterElement, [repeater, index, binding], opt
  end
end
end
