module Dooly
  module Collection
    extend ActiveSupport::Concern
    
    included do
      class_attribute :collection_klass
      self.collection_klass = Dooly::Collection::Base
    end
    
    module ClassMethods
      def collection_class(klass)
        unless klass <= Dooly::Collection::Base
          raise "Collection class must inherit Dooly::Colletion::Base: #{klass}"
        end
        self.collection_klass = klass
      end
      
      def collection(*args)
        self.collection_klass.new(*args)
      end
    end
  end
end