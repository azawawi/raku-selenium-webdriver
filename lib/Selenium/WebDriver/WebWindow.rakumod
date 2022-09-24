use v6;

unit class Selenium::WebDriver::WebWindow;

has Str $.handle is rw;
has $.driver     is rw;

# POST /session/:sessionId/window
method current(Str $name) {
  return $.driver._post( 'window', { name => $name } );
}

# DELETE /session/:sessionId/window
method close-current {
  return $.driver._delete( 'window' );
}

# POST /session/:sessionId/window/:windowHandle/size
multi method size(Int $width, Int $height) {
  return $.driver._post(
    "window/$.handle/size",
    { width  => $width, height => $height }
  );
}

# GET /session/:sessionId/window/:windowHandle/size
multi method size returns Hash {
  return $.driver._get( "window/$.handle/size" );
}

# POST /session/:sessionId/window/:windowHandle/position
multi method position(Int $x, Int $y) returns Hash {
  return $.driver._post( "window/$.handle/position", { x  => $x, y  => $y } );
}

# GET /session/:sessionId/window/:windowHandle/position
multi method position returns Hash {
  return $.driver._get( "window/$.handle/position" );
}

# POST /session/:sessionId/window/:windowHandle/maximize
multi method maximize {
  return $.driver._post( "window/$.handle/maximize" );
}
