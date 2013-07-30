require 'test_helper'

module Dooly
  class TestModelRegulator < Test::Unit::TestCase
    class ModelSample
      attr_accessor :id
      extend Dooly::ModelRegulator
      
      def self.find(id)
        instance = self.new
        instance.id = id
        instance
      end
    end
    
    class CacheSample
      attr_accessor :id
      extend Dooly::ModelRegulator
      model_regulator_finder :get_cache
      
      def self.get_cache(id)
        instance = self.new
        instance.id = id
        instance
      end
    end
    
    def setup
      super
    end
    
    context 'model_regulator' do
      setup do
        
      end
      
      should 'simply' do
        instance = ModelSample.new
        instance.id = 11
        assert_equal(11, ModelSample.by(instance).id)
        assert_equal(11, ModelSample.id(instance))
        assert_equal(11, ModelSample.by(11).id)
        assert_equal(11, ModelSample.id(11))
        assert_equal(11, ModelSample.by('11').id)
        assert_equal(11, ModelSample.id('11'))
      end
      
      should 'simple cache' do
        instance = CacheSample.new
        instance.id = 11
        assert_equal(11, CacheSample.by(instance).id)
        assert_equal(11, CacheSample.id(instance))
        assert_equal(11, CacheSample.by(11).id)
        assert_equal(11, CacheSample.id(11))
        assert_equal(11, CacheSample.by('11').id)
        assert_equal(11, CacheSample.id('11'))
      end
    end
  end
end