require 'rubygems'
require 'yard'

module Documentable
  
  class << self
    include Enumerable
    
    def load(name)
      return false unless path = gem_path(name)
      
      yardoc = File.join(path, '.yardoc')
      lib    = File.join(path, 'lib/**/*.rb')
      ext    = File.join(path, 'etc/**/*.c')
      `yardoc --no-stats -b #{yardoc} #{lib} #{ext}`
      YARD::Registry.load!(yardoc)
      true
    end
    
    def each(&block)
      YARD::Registry.all.select {|object| object.type == :class }.each(&block)
    end
    
    def clear!
      !!YARD::Registry.clear
    end
    
    def docs_for(lib, klass, format = nil)
      spec = Gem.source_index.find_name(lib).max {|a, b| a.version <=> b.version }
      return if spec.nil?
      path = spec.full_gem_path
      yardoc = File.join path, '.yardoc'
      lib = File.join path, 'lib/**/*.rb'
      ext = File.join path, 'etc/**/*.c'
      YARD::Registry.load!(yardoc)
      YARD::Registry.at(klass).format(:format => :html, :markup => :rdoc)
    end
    
    private
    
    def gem_path(name)
      spec = Gem.source_index.find_name(name.downcase).max {|a, b| a.version <=> b.version }
      spec && spec.full_gem_path
    end
  end
  
  def to_doc(format = nil)
    return @doc if @doc
    yardoc = File.join gem_path, '.yardoc'
    lib = File.join gem_path, 'lib/**/*.rb'
    ext = File.join gem_path, 'etc/**/*.c'
    `yardoc --no-stats -b #{yardoc} #{lib} #{ext}`
    YARD::Registry.load!(yardoc)
    @doc ||= YARD::Registry.at(self.name).format(:format => format, :markup => :rdoc)
  end
    
  private
  
  def gem_path
    spec = Gem.source_index.find_name(self.name.downcase).max {|a, b| a.version <=> b.version }
    spec && spec.full_gem_path
  end
  
end