require 'test_helper'
require 'tree'

class TreeTest < Test::Unit::TestCase
  def setup
    @tree = Tree.new(BasicObject)
    @tree.root << Tree::Node.new(Object)
  end
  
  should 'be enumerable' do
    assert @tree.respond_to?(:each)
    assert_equal [BasicObject, Object], @tree.map(&:value)
  end
end