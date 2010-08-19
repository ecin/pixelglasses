$:.unshift File.expand_path(File.dirname(__FILE__))

require 'sinatra'

set :public, File.expand_path( File.dirname(__FILE__) + '/../public' )
enable :inline_templates

get '/tree', :provides => :json do 
  json = `bin/tree`
  throw :halt, [404, nil] if json.empty?
  json
end

get '/tree' do
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

Sinatra::Application.run!

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
    <script src='/js/pixel.js'></script>
    <script>
    
      var centerOn = function(element){
        var pos = element.position();
        var height = element.scrollHeight;
        var width = element.scrollWidth;
        $(window).scrollTo(pos.x - (window.screen.availWidth/2) + (width/2), pos.y - (window.screen.availHeight/2) + (height/2));
      };
      
      var centerScrollOn = function(element){
        var fx = new Fx.Scroll(window);
        var pos = element.position();
        var height = element.scrollHeight;
        var width = element.scrollWidth;
        fx.start({
          'x': pos.x - (window.screen.availWidth/2) + (width/2), 
          'y': pos.y - (window.screen.availHeight/2) + (height/2)
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
        });
        "html".on('dblclick', function(el){
          $('inspector').clean();
        });
        $('container').style.top = Math.abs($$('.node').last().position().y) + window.screen.height + 'px';
        $('container').style.left = Math.abs($$('.node').first().position().x) + window.screen.width + 'px';
        $('container').style.width = $('container').scrollWidth + window.screen.width + 'px';
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
    <div id='inspector'></div>
    <div id='container'></div>
  </body>
</html>
