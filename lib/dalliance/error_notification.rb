module Dalliance
  class ErrorNotification
    def initialize
      clear_errors
    end

    def notify(full_error)
      @errors << full_error

      if defined?(Rails) && defined?(report_error)
        report_error(@errors)
      end
    end

    def clear_errors
      @errors = []
    end
  end
end