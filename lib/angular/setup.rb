module Angular
  class Setup
    attr_reader :page

    def initialize(page)
      @page = page
    end

    def ng_wait
      install
      Waiter.new(self).wait_until_ready
    end

    def make_call(method, params, nodes)
      ng_wait

      js_params = params.map do |p|
        if p.nil?
          'null'
        elsif p.is_a? String
          escaped = p.gsub(/'/, "\\\\'").gsub(/"/, '\\\\"')
          "'#{escaped}'"
        else
          p.to_s
        end
      end

      js = "#{method}(#{js_params.join(', ')});"
      logger.info js

      js_result = page.evaluate_script(js);
      logger.info js_result

      if nodes
        make_result method, params, js_result
      else
        js_result
      end
    end


    def make_result(method, params, js_result)
      if js_result.nil? || js_result.empty?
        raise NotFound.new("#{method}: #{params.inspect}")
      end

      js_result.map do |el|
        el ? Capybara::Selenium::Node.new(page.driver, el) : nil
      end
    end

    def angular_app?
      begin
        js = "(typeof angular !== 'undefined') && "
        js += "angular.element(document.querySelector('[ng-app], [data-ng-app]')).length > 0"
        @page.evaluate_script js
      rescue Capybara::NotSupportedByDriverError
        false
      end
    end

    def page_reloaded?
      @page.evaluate_script("window.ngInstalled === undefined")
    end

    def mark_installed
      @page.evaluate_script("window.ngInstalled = true")
    end

    def install
      if page_reloaded?
        ClientScript.window_scripts.each do |f|
          @page.evaluate_script(f)
        end
        mark_installed
      end
    end
  end
end
