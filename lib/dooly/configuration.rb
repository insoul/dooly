module Dooly
  class Configuration
    class << self
      def logger(lg = nil)
        if lg.nil?
          return @logger if @logger
          return Rails.logger if Rails.defined?
          raise 'logger undefined'
        end
        @logger = lg
      end
    end
  end
end