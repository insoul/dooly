module Dooly
  module Attachment
    extend ActiveSupport::Concern
    
    included do
      class_attribute :attachment_klass
      self.attachment_klass = Dooly::Attachment::Base
    end
    
    module ClassMethods
      def make_attachable_as_json(klass = nil)
        klass = Dooly::Attachment::Base if klass.nil?
        unless klass <= Dooly::Attachment::Base
          raise "Attachment class must inherit Dooly::Attachment::Base: #{klass}"
        end
        self.attachment_klass = klass
        
        if self.instance_methods.include?(:as_json)
          self.class_eval do 
            alias :as_json_exclude_attachment :as_json
            define_method(:as_json) do |options = {}, &block|
              js = if block
                as_json_exclude_attachment(options, &block)
              else
                as_json_exclude_attachment(options)
              end
              
              js.class <= Hash ? js.merge(attachment.as_json) : js
            end
          end
        else
          self.class_eval do 
            define_method(:as_json) do |options = {}|
              attachment.as_json
            end
          end
        end
      end
    end

    def attachment
      return @attachment if @attachment
      am = self.attachment_klass.new
      am.body = self
      @attachment = am
    end
  end
end