$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'sinatra'

set :public, File.expand_path( File.dirname(__FILE__) + '/../public' )
enable :inline_templates

get '/gems/:gem', :provides => :json do |lib|
  json = `bin/pixelglass -g #{lib}`
  throw :halt, [404, nil] if json.empty?
  json
end

get '/gems/:gem' do
  erb :grid
end

get '/gems/:gem/:class' do |lib, klass|
  response = `bin/document #{lib} #{klass}`
  throw :halt, [404, nil] if response.empty?
  response
end

get '/', :provides => :json do 
  json = `bin/pixelglass`
  throw :halt, [404, nil] if json.empty?
  json
end

get '/' do
  erb :grid
end

# When asked for JSON, we return the class tree in JSON format.
# Interesting problem: JSON (and perhaps Sinatra)
# adds certain modules to vanilla classes. Solution: either remove them (meh)
# or run a subprocess that doesn't have extra gems required (yay!).
get '/:klass', :provides => :json do |klass|
  json = `bin/pixelglass #{klass}`
  throw :halt, [404, nil] if json.empty?
  json
end

# i.e. /Integer or /Array
# Same URL, different responses!
get '/:klass' do
  erb :grid
end

__END__

@@grid
<!DOCTYPE html>
<html>
  <head>
    <title>pixelglass.es</title>
    <meta name='description' content='A punch of isometric fun for your Ruby documentation.' />
    <meta name='keywords' content='ruby, documentation, isometric, graph, copypastel, pixel, ecin' />
    <meta http-equiv='Content-Type' content='text/html' charset='utf-8' />
    <link rel='stylesheet' href='/css/pixel.css' />
    <script src='/js/right.js'></script>
    <script src='/js/right.autocompleter.js'></script>
    <script src='/js/right.lightbox.js'></script>
    <script src='/js/pixel.js'></script>
    <script>
    
      var centerOn = function(element){
        // reset container
        var container = $('container');
        container.style.top = 0;
        container.style.left = 0;
        
        // Get position of element we're positioning
        var pos = element.position();
        var height = element.scrollHeight;
        var width = element.scrollWidth;
        container.style.left = -pos.x + window.screen.availWidth/2.3 + 'px';
        container.style.top = -pos.y + window.screen.availHeight/2.3 + 'px';
      };
      
      var centerScrollOn = function(element){
        // Ugly follows
        // reset container pos
        var container = $('container');
        var original_top = container.style.top;
        var original_left = container.style.left;
        container.style.top = 0;
        container.style.left = 0;

        // Get position of element now.
        var pos = element.position();
        var height = element.scrollHeight;
        var width = element.scrollWidth;
 
        // Go back to original position
        container.style.top = original_top;
        container.style.left = original_left;

        // NOW scroll
        new Fx.Morph('container', {'duration': 'short', 'transition': 'Log'}).start({
          'left': -pos.x + window.screen.availWidth/2.3 + 'px', 
          'top': -pos.y + window.screen.availHeight/2.3 + 'px'
        });
      }
    
      var initialize = function(response){
        var json = response.responseJSON;
        TREE = new Graph2(json);
        new Draggable($('container'), {
          scroll: false,
          zIndex: 0,
          scrollSensitivity: 32,
          /*
          onDrag: function(draggable, event){
          var x = event.offsetX;
          var y = event.offsetY;
          console.log(event);
          body.style.backgroundPosition = x + 'px ' + y + 'px';
          },*/
          onStop: function(draggable, event){
            draggable.element.style.zIndex = 0;
          }
        });
        new Legend(Peg.modules);
        "#container div.node".on('dblclick', function(el){
          TREE.display(el.target.value);
        })
        "#container div.node > div".on('dblclick', function(el){
          TREE.display(el.target.parentNode.value);
        });
        "#container".on('dblclick', function(el){
          $('inspector').clean();
          $('docs').hide();
        });
        "html".on('dblclick', function(el){
          $('inspector').clean();
          $('docs').hide();
        });
        centerOn($$('.node').first());
        var classes = []
        TREE.each( function(el){ classes.push(el.value['class'])});
        new Autocompleter($('search'), {
          local: classes,
          minLength: 2,
          onDone: function(){
            var name = $('search').value;
            var node = TREE.find(function(node){ return  node.value['class'] == name });
            $$('#container div.node').each( function(el){ el.style.opacity = 0.3; });
            node.toElement().style.opacity = 1;
            centerScrollOn(node.toElement());
          }
        });
        //Lightbox.show($('welcome').innerHTML);
      };
    
      document.onReady( function(){
				var body = $$('body').first();
        var request = new Xhr(document.URL, 
                              { 'method': 'get',
                                'onSuccess': initialize
                              });
        request.setHeader('Accept', 'application/json');
        request.send();
      });
    </script>
  </head>
  <body>
    <input id="search" type="search" placeholder="Ruby class name">
    <div id="docs">
    </div>
    <div id='inspector'></div>
    <div id='container'></div>
  </body>
</html>
