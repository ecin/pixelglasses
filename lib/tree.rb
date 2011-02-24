class Tree 
  attr_accessor :root
  include Enumerable

  def each(&block)
    self.root.each(&block)
  end

  def initialize(value)
    self.root = Node.new(value)
  end

  def walk(&block)
    self.root.walk(&block)
  end
  
  def to_hash
    self.root.to_hash
  end
  
  def to_json
    self.to_hash.to_json
  end

  class Node
    attr_accessor :children, :parent, :value
    include Enumerable
    
    def initialize(value, parent = nil)
      self.value = value
      self.parent = parent
      self.children = []
      yield self if block_given?
    end

    def level
      return 0 if self.parent.nil?
      1 + self.parent.level
    end

    def each(&block)
      yield self
      children.each {|child| child.each(&block) }
    end

    alias :walk :each
    
    def <<(node)
      node.parent = self
      self.children << node 
    end
    
    def to_hash
      { :value => self.value, :children => self.children.map(&:to_hash) }
    end

  end
end