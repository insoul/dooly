module Dooly
  module IdProxy
    class Base
      class << self
        attr_accessor :model
        attr_reader :finders
      
        def finders=(*args)
          if args[0].is_a? Array
            @finders = args[0]
          else
            @finders = args
          end
        end
        alias :finder :finders
        alias :finder= :finders=
      end

      attr_reader :id

      def initialize(id)
        raise 'idea must have id' if id.blank?
        @id = id
      end

      def record
        return @record if @record
      
        self.class.finders.each do |finder|
          f = finder.to_sym
          if self.class.model.respond_to?(f)
            @record = self.class.model.send(f, self.id)
          end
        end
      
        unless @record
          @record = self.class.model.find(self.id)
        end
      
        @record
      end

      def respond_to?(name)
        self.record.respond_to?(name) || super
      end

      def method_missing(name, *args, &block)
        self.record.send(name, *args, &block)
      end
    end
  end
end