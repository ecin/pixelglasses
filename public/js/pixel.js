var Graph = function(klasses){
  var position = {'x': 0, 'y': 1}
  
  this.pegs = new Array;
  var self = this;
  klasses.each( function(el, i){
    var peg = new Peg(el.klass, el.modules);
    console.log(el.modules);
    peg.moveTo(position.x += 2, position.y += 1);
    
    if(defined(klasses[i+1])){
      var pipe = new Cell('pipe');
      pipe.moveTo(position.x + 1, position.y);
    }
    
    self.pegs.push(peg);
  });
}

var Node = {}

var Node = function(opts){
  if(defined(opts)){
    this.value    = opts.value;
    this.children = opts.children;
  }
}

Node.prototype.draw = function(level){
  var peg = new Peg(this.value);
  peg.moveTo(Graph2.NEXT, level);
  var children = this.children
  children.each( function(node_options, i){
    var node = new Node(node_options);
    if(i>0){
      Graph2.NEXT += 2;
    }
    node.draw(level+2);
  })
}

var Graph2 = function(root){
  var position = {'x': 0, 'y': 0}
  
  this.pegs = new Array;
  var self = this;
  var root = new Node(root);
  root.draw(0);
}

Graph2.NEXT = 0;

// @discs: an array of strings, representing the name of each disc.
var Peg = function(name, discs){
  this.name = name;
  this.discs = new Array;
  this.position = {'x': 0, 'y': 0};
  
  this.el = new Element('div', {'class': 'peg', 'peg_name': name});
  this.el.insertTo($('container'));
  this.moveTo(0,0);
  
//  var position = this.toElement().position();
  this.banner = new Element('div', {'class': 'class_name', 'html': name } );
  this.banner.insertTo($('container'));
  
  var self = this;
  if(defined(discs)){
    discs.each( function(disc_name){ self.addDisc(disc_name) } );
  };
}

var Cell = function(klass){
  this.el = new Element('div', {'class': klass});
  this.el.insertTo($('container')); 
  this.moveTo(1,1);
}

Cell.prototype.toElement = function(){
  return this.el; 
}

Cell.prototype.moveTo = function(x, y){
  this.position = {'x': x, 'y': y};
  var column = x * 32; 
  var row = y * 32 + (x % 2) * 16; 
  this.toElement().moveTo(column, row);
}

// Class scope

Peg.MODULE_COUNT = 0;

// Maps module names to disc numbers for consistency
// e.g. {'Kernel': 0, 'Enumerable': 1, 'Comparable': 2}
Peg.modules = {};

Peg.registerModule = function(module_name){
  return Peg.modules[module_name] || (Peg.modules[module_name] = ++Peg.MODULE_COUNT);
}

// Instance scope

Peg.prototype.toElement = function(){
  return this.el;
}

// Move the peg to the given coordinates on the isometric map
Peg.prototype.moveTo = function(x, y){
  this.position = {'x': x, 'y': y};
  var left = x*32 + y*32; 
  var top = x*-16 + y*16 - 12; // Peg images are higher than a cell's 32px (by 12px).
  this.toElement().moveTo(left, top);
  this.toElement().style.zIndex = -x;
  
  // Make sure the discs and banner are moved alongside the peg.
  //this.repositionDiscs();
  this.repositionBanner();
}

Peg.prototype.repositionBanner = function(){
  if(defined(this.banner)){
    var position = this.toElement().position();
    this.banner.moveTo(position.x, position.y - 16);
    this.banner.style.zIndex = -this.position.x;
  }
}

/*
// Remove the given disc from the peg, moving the remaining discs accordingly
Peg.prototype.removeDisc = function(module_name){
  if(!defined(module_name)){ return false; }
  var disc_number = Peg.registermodule(module_name);
  var disc = $('.disc' + disc_number + ' [module_name~=' + module_name + ']');
  this.discs = this.discs.without(disc);
  
  this.repositionDiscs();
}*/

Peg.prototype.repositionDiscs = function(){
  var x = this.position.x;
  var y = this.position.y;
  var left = x*32 + y*32; 
  var top = x*-16 + y*16 - 12; // Peg images are higher than a cell's 32px (by 12px).
  
  // * 7: each disc is 7px high.
  this.discs.map( function(disc, i){ disc.moveTo(left, top + 7 - (7 * (i + 1))) } );
}

// Add a disc on top of the peg. module_name determines its color.
Peg.prototype.addDisc = function(disc_name){
  if(!defined(disc_name)){ return false; }
  var disc_number = Peg.registerModule(disc_name);
  var x = this.position.x;
  var y = this.position.y;
  var left = x*32 + y*32; 
  var top = x*-16 + y*16 - 7(this.discs.length + 1); // The -7n represents discs already on the stack.
  var disc = new Element('div', {'class': 'disc' + disc_number, 'disc_name': disc_name});

  disc.insertTo($('container'));
  disc.moveTo(column, row);
  this.discs.push(disc);
  return true;
}
