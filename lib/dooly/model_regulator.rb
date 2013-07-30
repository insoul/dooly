module Dooly
  module ModelRegulator
    def model_regulator_finder(finder = nil)
      return (@model_regulator_finder || :find) if finder.nil?
      @model_regulator_finder = finder.to_sym
    end
    
    def by(*args)
      options = args.extract_options!

      if args.length > 1
        return args.map {|arg| by(arg, options)}
      end

      value = args[0]
      begin
        return value if value.is_a? self
        return self.send(model_regulator_finder, value) if value.is_a? Integer
        return self.send(model_regulator_finder, Integer(value)) if value.is_a? String
        return value.record if Dooly::IdProxy::Base === value
        
        if options[:relate]
          fn = options[:relate] == true ? "#{self.name.underscore}_id".to_sym : options[:relate].to_sym
          return self.send(model_regulator_finder, value.send(fn)) if value.respond_to?(fn)
        end
      rescue => e
        raise "Cannot find record from #{self.name} with #{value.to_s}: #{e}"
      else
        raise "Cannot find record from #{self.name} with #{value.to_s}"
      end
    end

    def id(*args)
      options = args.extract_options!

      if args.length > 1
        return args.map {|arg| id(arg, options)}
      end

      value = args[0]
      begin
        return value.id if value.is_a? self
        return value if value.is_a? Integer
        return Integer(value) if value.is_a? String
        return value.id if Dooly::IdProxy::Base === value
        
        if options[:relate]
          fn = options[:relate] == true ? "#{self.name.underscore}_id".to_sym : options[:relate].to_sym
          return value.send(fn) if value.respond_to?(fn)
        end
      rescue => e
        raise "Cannot find id from #{self.name} with #{value.to_s}: #{e}"
      else
        raise "Cannot find id from #{self.name} with #{value.to_s}"
      end
    end
  end
end