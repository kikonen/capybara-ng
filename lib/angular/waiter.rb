module Angular
  class Waiter
    def initialize(page)
      @page = page
      @setup = Setup.new(page)
    end

    def wait_until_ready
      return unless @setup.angular_app?

      @setup.install

      start = Time.now
      until ready?
        timeout! if timeout?(start)
        @setup.install
        sleep(0.01)
      end
    end

    private

    def timeout?(start)
      Time.now - start > Capybara.default_wait_time
    end

    def timeout!
      raise TimeoutError.new("timeout while waiting for angular")
    end

    def ready?
      @page.evaluate_script("window.angularReady")
    end

  end
end
