require 'test_helper'

module Dooly
  class TestAttachment < Test::Unit::TestCase
    
    class ModelSample
      include ActiveModel::Serializers::JSON
      self.include_root_in_json = false
      include Dooly::Attachment

      attr_accessor :name
      
      def attributes
        {'name' => name}
      end
      
      make_attachable_as_json
    end
    
    class ValueSample
      attr_accessor :value
    end
    
    class DefaultSample
      include Dooly::Attachment
    end
    
    def setup
      super
    end
    
    context 'attachment' do
      setup do
        @model = ModelSample.new
        @model.name = 'ddochi'
      end
      
      should 'simply' do
        assert_equal({'name'=>'ddochi'}, @model.as_json)
      end
      
      should 'defalut attachment class' do
        assert_equal(Dooly::Attachment::Base, DefaultSample.new.attachment.class)
      end
      
      should 'attach key-value' do
        @model.attachment.add(:friend, 'donor')
        assert_equal({'name'=>'ddochi', 'friend'=>'donor'}, @model.as_json)
      end
      
      should 'attach key-block' do
        @model.attachment.add(:friend) do |body|
          body.name + " and donor"
        end
        assert_equal({'name'=>'ddochi', 'friend'=>'ddochi and donor'}, @model.as_json)
        
        # block must be called only once
        assert_equal({'name'=>'ddochi', 'friend'=>'ddochi and donor'}, @model.as_json)
      end
      
      should 'attach key-value with block' do
        v = ValueSample.new
        v.value = 'donor'
        @model.attachment.add(:friend, v) do |body, value|
          "#{body.name} #{value.value}"
        end
        assert_equal({'name'=>'ddochi', 'friend'=>'ddochi donor'}, @model.as_json)
        
        # block must be called only once
        assert_equal({'name'=>'ddochi', 'friend'=>'ddochi donor'}, @model.as_json)
      end
    end
  end
end