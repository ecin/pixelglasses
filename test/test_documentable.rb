require 'test_helper'
require 'documentable'
require 'camping'

class DocumentableTest < Test::Unit::TestCase
  def setup
    @class = Camping.extend Documentable
  end
  
  should 'respond to #to_doc' do
    assert @class.respond_to?(:to_doc)
  end
  
  should 'return documentation for class' do
    assert @class.to_doc =~ /The Camping Server/
  end
end