module Dooly
  module Attachment
    class Base < HashWithIndifferentAccess
      attr_accessor :body

      def add(k, value = nil, options = {})
        if key?(k)
          warn_duplicated(k); return fetch(k)
        end

        if value
          store(k, value)
          if block_given?
            self.as_json_procs(k, &Proc.new)
          end
        elsif block_given?
          store(k, Proc.new)
        else
          warn_unassigned_value(k)
        end

        if options[:as_json_options]
          as_json_options(k, options[:as_json_options])
        else
          as_json_options(k, options) unless options.empty?
        end
      end

      def as_json_options(k = nil, options = nil)
        @as_json_options ||= HashWithIndifferentAccess.new
        return @as_json_options if k.nil?
        return @as_json_options[k] if options.nil?

        @as_json_options[k] = options
      end

      def as_json_procs(k = nil)
        @as_json_procs ||= HashWithIndifferentAccess.new
        return @as_json_procs if k.nil?
        return @as_json_procs[k] unless block_given?

        @as_json_procs[k] = Proc.new
      end

      def as_json_procs_run(k = nil, value = nil)
        @as_json_procs_run ||= HashWithIndifferentAccess.new
        return @as_json_procs_run if k.nil?
        return @as_json_procs_run[k] if value.nil?

        @as_json_procs_run[k] = value
      end

      alias :to_hash_with_string :to_hash

      def to_hash
        to_hash_with_string.symbolize_keys
      end

      def [](key)
        value = fetch(key, nil)
        return nil if value.nil?

        if Proc === value
          value = value.call(body)
          store(key, value)
        end

        fetch(key)
      end

      def as_json
        self.each_pair do |k, v|
          if self.as_json_procs(k) and !as_json_procs_run(k)
            v = self.as_json_procs(k).call(body, v)
            self.as_json_procs_run(k, true)
          end

          if Proc === v
            self[k] = v.call(body).as_json
          elsif v.respond_to?(:as_json)
            if as_json_options(k)
              self[k] = v.as_json(as_json_options(k)).as_json
            else
              self[k] = v.as_json
            end
          else
            self[k] = v.as_json
          end
        end
        self
      end

      private
      def warn_unassigned_value(key)
        message = ["Attachment has been tried to add with none value, #{self.class.name}/#{key}"]
        message += caller if Rails.env.development?
        Configuration.logger.warn(message.join("\n"))
      end

      def warn_duplicated(key)
        message = ["Attachment has been tried to add repeatedly about key, #{self.class.name}/#{key}."]
        message += caller if Rails.env.development?
        Configuration.logger.warn(message.join("\n"))
      end
    end
  end
end