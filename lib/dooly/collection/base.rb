module Dooly
  module Collection
    class Base
      include ActiveModel::Serializers::JSON
      
      extend Forwardable
      def_delegators :@collection, *Enumerable.instance_methods
      def_delegators :@collection, :each

      include Dooly::Attachment
      
      attr_reader :collection
      
      class_attribute :include_root_in_json

      def initialize(*args)
        if args.first.respond_to?(:each)
          args = args.first
        end
        @collection = args
      end

      def as_json(options = {})
        root = options.delete(:root) || self.include_root_in_json
        jsons = block_given? ? self.as_jsons(options, &Proc.new) : self.as_jsons(options)
        if root
          if root == true
            root = begin 
                @collection[0].class.model_name.element.pluralize
              rescue
                self.class.name.underscore.split('/')[-2].pluralize rescue 'collection'
              end
          end
          {root => jsons}
        else
          jsons
        end
      end

      def as_jsons(options = {})
        @collection.map do |member|
          if block_given?
            member.as_json(options, &Proc.new)
          else
            member.as_json(options)
          end
        end
      end
      
      make_attachable_as_json
    end
  end
end