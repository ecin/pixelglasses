class Tree 
  attr_accessor :root
  
  def initialize(root)
    self.root = root
  end

  class Node
    attr_accessor :children, :parent, :value
    
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

    def walk(&block)
      yield self
      children.each {|c| c.walk(&block) }
    end

    def <<(node)
      node.parent = self
      self.children << node 
    end

    def find(value)
      self.children.find {|c| c.value == value}
    end
    
    def to_hash
      { :value => self.value, :children => self.children.map(&:to_hash) }
    end

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
end