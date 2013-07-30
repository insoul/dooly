module Dooly
  module IdProxy
    extend ActiveSupport::Concern
    
    included do
      class_attribute :id_proxy_klass, :id_proxy_options
      self.id_proxy_klass = Dooly::IdProxy::Base
    end

    module ClassMethods
      def id_proxy_class(klass, options = {})
        raise "Id Proxy class must inherit Dooly::IdProxyBase: #{klass}" unless klass <= Dooly::IdProxy::Base
        self.id_proxy_klass = klass
        self.id_proxy_klass.model = self
        finders = options[:finders] || options[:finder]
        self.id_proxy_klass.finders = finders if finders
      end

      def id_proxy_delegate
        self.extend Forwardable
        self.def_delegators 'self.id_proxy', *self.id_proxy_klass.instance_methods(false)
      end

      def id_proxy(*args)
        options = args.extract_options!

        if args.length > 1
          return args.map {|arg| id(arg, options)}
        end

        value = args[0]
        begin
          return value.idx if value.is_a? self
          return self.id_proxy_klass.new(value) if value.is_a? Integer
          return self.id_proxy_klass.new(Integer(value)) if value.is_a? String
          return value if Dooly::IdProxy::Base === value
        
          if options[:relate]
            fn = options[:relate] == true ? "#{self.name.underscore}_id".to_sym : options[:relate].to_sym
            return self.id_proxy_klass.new(value.send(fn)) if value.respond_to?(fn)
          end
        rescue => e
          raise "Cannot make id_proxy from #{self.name} with #{value.to_s}: #{e}"
        else
          raise "Cannot make id_proxy from #{self.name} with #{value.to_s}"
        end
      end
      alias :idx :id_proxy
    end
    
    def id_proxy
      return nil unless self.id
      @id_proxy ||= self.id_proxy_klass.new(self.id)
    end
    alias :idx :id_proxy
  end
end