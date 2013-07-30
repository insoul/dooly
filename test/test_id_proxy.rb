module Dooly
  class TestIdProxy < Test::Unit::TestCase
    class ModelSample
      attr_accessor :id
      
      class IdProxyClass < Dooly::IdProxy::Base
        def proxy_method_sample(arg)
          ['class', arg, self.id.to_s].join(' ')
        end
      end
      
      include Dooly::IdProxy
      id_proxy_class IdProxyClass, :finder => :get_cache
      id_proxy_delegate
      
      def instance_method_sample(arg)
        ['instance', arg, @id.to_s].join(' ')
      end
      
      def self.get_cache(id)
        instance = self.new
        instance.id = id
        instance
      end
    end
    
    class DefaultSample
      attr_accessor :id
      include Dooly::IdProxy
    end
    
    context 'id_proxy' do
      setup do
        @model = ModelSample.new
        @model.id = 11
      end
      
      should 'simply' do
        assert_equal('class simply 11', @model.proxy_method_sample('simply'))
        assert_equal('instance simply 11', ModelSample.id_proxy(11).instance_method_sample('simply'))
      end
      
      should 'default id proxy class' do
        assert_equal(Dooly::IdProxy::Base, DefaultSample.idx(11).class)
      end
    end
  end
end