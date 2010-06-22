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

var Node = function(opts, parent){
  if(defined(opts)){
    this.value    = opts.value;
    this.children = opts.children;
  }
  this.parent = parent;
}

Node.prototype.draw = function(level){
  level = level || 0;
  var peg = new Peg(this.value['class'], this.value['modules']);
  peg.moveTo(Graph2.NEXT, level);
  var self = this;
  this.nodize(); // Turn all children into Nodes if they're not already.
  this.children.each( function(node, i){
    if(i>0){
      Graph2.NEXT += 2;
    }
      node.draw(level+2);
  })
}

Node.prototype.ancestors = function(){
  var ancestors = [];
  var current_node = this;
  
  while(defined(current_node.parent)){
    ancestors.push(current_node.parent);
    current_node = current_node.parent;
  }
  
  return ancestors;
}

Node.prototype.nodize = function(){
  var children = [];
  var parent = this;
  
  this.children.each( function(child){
    if( typeof(child) != Node ){ children.push( new Node(child, parent) ); }
    else{ children.push(child); }
  });
  
  this.children = children;
}

var Graph2 = function(root){
  var position = {'x': 0, 'y': 0}
  
  this.root = new Node(root);
  this.root.draw();
}

Graph2.NEXT = 0;

// @discs: an array of strings, representing the name of each disc.
var Peg = function(name, discs){
  this.name = name;
  this.discs = new Array;
  this.position = {'x': 0, 'y': 0};
  
  this.el = new Element('div', {'class': 'node', 'value': name});
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
  
  // Make sure the banner is moved alongside the peg.
  this.repositionBanner();
}

Peg.prototype.repositionBanner = function(){
  if(defined(this.banner)){
    var position = this.toElement().position();
    this.banner.style.zIndex = -this.position.x + 1;
    this.banner.moveTo(position.x, position.y - 16);
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


// Add a disc on top of the peg. module_name determines its color.
Peg.prototype.addDisc = function(disc_name){
  if(!defined(disc_name)){ return false; }
  var disc_number = Peg.registerModule(disc_name);
  var top = -7*(this.discs.length); // The -7n represents discs already on the stack.
  var disc = $E('div', {'class': 'disc' + disc_number, 'value': disc_name});

  disc.style.top = top + 'px';
  disc.insertTo(this.toElement());
  this.discs.push(disc);
  return true;
}

// Legend for modules. We pass it in Peg.modules, and it does its thang
Legend = function(modules){
  var legend = new Element('div', {'id': 'legend'});
  var title = new Element('div', {'class': 'title', 'html': 'Modules Legend'});

  title.insertTo(legend);
  
  Object.keys(modules).each( function(key){
    console.log(key);
    var item = new Element('div', {'class': 'key'});
    var label = new Element('div', {'class': 'label', 'html': key});
    var disc = new Element('div', {'class': 'legend_disc' + modules[key]});
    
    item.insert([label, disc]);
    item.insertTo(legend);
  });
  
  legend.insertTo($$('body')[0]);
}
/*
 <div id='branch'>
    <div class='title'>Struct</div>
    <div class="class_name" style="z-index: 1; position: relative; margin: 0 auto; -webkit-border-radius: 0px;">BasicObject</div>
    <div class="peg" peg_name="BasicObject" style="position: relative; margin: 0 auto; margin-top: 5px; margin-bottom: 5px; z-index: 0; "></div>
    <div class="class_name" style="z-index: 1; position: relative; margin: 0 auto; -webkit-border-radius: 0px;">Object</div>
    <div class="peg" peg_name="BasicObject" style="position: relative; margin: 0 auto; margin-top: 5px; margin-bottom: 5px; z-index: 0; ">
      <div class="disc1" disc_name="Kernel" style="z-index: 0; margin: 0 auto; top: 0px; "></div>
    </div>
  </div>
*/

// class should have a @ancestors property and a @value property
Inspector = function(node){
  var branch = new Element('div', {'class': 'branch'});
  var title = new Element('div', {'class': 'title', 'html': node.value })
  
  branch.insert(title);
  
  node.ancestors.each( function(ancestor){
    var class_name = new Element('div', {'class': 'class_name', 'html': ancestor.value });
    var peg = new Element('div', {'class': 'node', 'value': ancestor.value });

    branch.insert[class_name, peg];
  })
  
  $('container').insert(branch);
}

Array.prototype.find = function(value){
  var index = this.indexOf(value);
  return index != -1 ? this[index] : null;
}