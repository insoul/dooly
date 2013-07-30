module Dooly
  class TestCollection < Test::Unit::TestCase
    class ModelSample
      attr_accessor :name
      include Dooly::Collection
      include ActiveModel::Serializers::JSON
      self.include_root_in_json = false
      include Dooly::Attachment
      
      def initialize(name)
        @name = name
      end
      
      def attributes
        {'name' => name}
      end
      
      def as_json(options = {})
        js = super
        js = yield(js) if block_given?
        js
      end
      make_attachable_as_json
    end
    
    context 'collection' do
      setup do
        @ddochi = ModelSample.new('ddochi')
        @donor = ModelSample.new('donor')
        @friends = ModelSample.collection(@ddochi, @donor)
        @friends.attachment.add(:total, 2)
      end
      
      should 'simply' do
        assert_equal([{"name"=>"ddochi"}, {"name"=>"donor"}], @friends.as_json)
        assert_equal({
          'friends' => [{"name"=>"ddochi"}, {"name"=>"donor"}],
          'total' => 2
        }, @friends.as_json(:root => 'friends'))
        assert_equal('ddochi', @friends.to_a[0].name)
      end
      
      should 'block call by member' do
        assert_equal([
          {'name'=>'ddochi', 'friend_of'=>'dooly'},
          {'name'=>'donor', 'friend_of'=>'dooly'}
        ],@friends.as_json {|f| f.merge('friend_of' => 'dooly')})
      end
      
      should 'just using base class' do
        assert_equal({
          'friends' => [{"name"=>"ddochi"}, {"name"=>"donor"}]
        }, Dooly::Collection::Base.new([@ddochi, @donor]).as_json(:root=>'friends'))
      end
    end
  end
end