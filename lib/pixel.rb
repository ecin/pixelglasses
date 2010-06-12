require 'sinatra'
require 'json'

set :public, File.expand_path( File.dirname(__FILE__) + '/../public' )

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
    <script src='/js/pixel.js'></script>
    <script>
      document.onReady( function(){
        var request = new Xhr(document.URL, 
                              { 'method': 'get',
                                'onSuccess': function(response){
                                var json = response.responseJSON;
                                new Graph(json);
                                new Draggable($('container'));
                              }});
        request.setHeader('Accept', 'application/json');
        request.send();
      });
    </script>
  </head>
  <body>
    <div id='container'></div>
  </body>
</html>
