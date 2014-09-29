module Angular
  class Setup
    def initialize(page)
      @page = page
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
      @page.evaluate_script("window.angularReady === undefined")
    end

    def install
      if page_reloaded?
        ClientScript.window_scripts.each do |f|
          @page.evaluate_script(f)
        end
        setup_ready
      end
    end

    def setup_ready
      script = <<-JS
        window.angularReady = false;
        var app = angular.element(document.querySelector('[ng-app], [data-ng-app]'));
        var injector = app.injector();

        injector.invoke(function($browser) {
          $browser.notifyWhenNoOutstandingRequests(function() {
            window.angularReady = true;
          });
        });
      JS
      @page.execute_script script
    end
  end
end
