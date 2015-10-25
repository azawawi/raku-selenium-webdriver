
#
# JSON Wire Protocol Perl 6 implementation
# Please see 
# https://code.google.com/p/selenium/wiki/JsonWireProtocol
#

use v6;

=begin markdown
=end markdown
unit class Selenium::WebDriver::Wire;

use HTTP::UserAgent;
use JSON::Tiny;
use MIME::Base64;
use Selenium::WebDriver::WebElement;
use Selenium::WebDriver::WebWindow;
use Selenium::WebDriver::X::Error;

has Bool        $.debug      is rw;
has Str         $.host       is rw;
has Int         $.port       is rw;
has Str         $.url-prefix is rw;
has Str         $.session-id is rw;

=begin markdown
=end markdown
submethod BUILD(
  Str $host        = '127.0.0.1',
  Int :$port       = -1,
  Str :$url-prefix = '';
  Bool :$debug     = False )
{

  # Attributes
  self.debug      = $debug;
  self.host       = $host;
  self.url-prefix = $url-prefix;

  # We need to find an empty port given that no port was given
  self.port       = $port == -1 ?? self._empty-port !! $port;

  # Start behavior (normally implemented in children)
  self.start;

  # Try to create a session for n times
  my constant MAX-ATTEMPTS = 10;
  my $session;
  for 1..MAX-ATTEMPTS {
    # Try to create session
    $session = self._new-session;
    last if $session.defined;

    CATCH {
      default {
        # Retry session creation failure after timeout
        say "Attempt $_ to create session" if self.debug;
        sleep 1;
      }
    }
  }

  # No session could be created
  die "Cannot obtain a session after $(MAX-ATTEMPTS) attempts" unless $session.defined;

  self.session-id = $session<sessionId>;
  die "Session id is not defined" unless self.session-id.defined;
}

# Normally implemented in subclasses
method start { }

# Normally implemented in subclasses
method stop { }

=begin markdown
=end markdown
# POST /session
method _new-session {
  return self._execute-command(
    "POST",
    "/session",
    {
        "desiredCapabilities"  => {},
        "requiredCapabilities" => {},
    }
  );
}

=begin markdown
=end markdown
# GET /sessions
method sessions {
  my $result = self._execute-command( "GET", "/sessions" );

  return unless $result.defined;
  return $result<value>;
}

# GET /session/:sessionId
method capabilities {
  return self._execute-command( "GET", "/session/$(self.session-id)" );
}

# DELETE /session/:sessionId
method _delete_session {
  return self._execute-command( "DELETE", "/session/$(self.session-id)" );
}

# POST /session/:sessionId/timeouts
method _timeouts(Str $type, Int $timeout_millis) {
  return self._post(
    'timeouts',
    {
      type => $type,
      ms => $timeout_millis
    }
  );
}

method script-timeout(Int $timeout_millis) {
  return self._timeouts( 'script', $timeout_millis );
}

method implicit-timeout(Int $timeout_millis) {
  return self._timeouts( 'implicit', $timeout_millis );
}

method page-load-timeout(Int $timeout_millis) {
  return self._timeouts( 'page load', $timeout_millis );
}

# POST /session/:sessionId/timeouts/async_script
method async-script-timeout(Int $timeout_millis) {
  return self._post( 'timeouts/async_script', { ms => $timeout_millis } );
}

# POST /session/:sessionId/timeouts/implicit_wait
method implicit-wait-timeout(Int $timeout_millis) {
  return self._post( 'timeouts/implicit_wait', { ms => $timeout_millis } );
}

# GET /session/:sessionId/window_handle
method current-window returns Selenium::WebDriver::WebWindow {
  my $handle = self._get( 'window_handle' );
  return Selenium::WebDriver::WebWindow.new( :handle($handle), :driver(self) );
}

# GET /session/:sessionId/window_handles
method windows returns Array[Selenium::WebDriver::WebWindow] {
  my @handles = @( self._get( 'window_handles' ) );
  my Selenium::WebDriver::WebWindow @results = gather {
    take Selenium::WebDriver::WebWindow.new(
      :handle($_),
      :driver(self)
    ) for @handles;
  };

  return @results;
}

# GET /status
method status returns Hash {
  return self._get( 'status' );
}

# POST /session/:sessionId/execute
=begin markdown

    my $script = q{
      return arguments[0] + arguments[1];
    };
    my $result = $driver.execute( $script, [1, 2] );

=end markdown
method execute(Str $script, Array $args = []) {
  my $result = self._post( 'execute', { script => $script, args => $args } );
  return unless $result.defined;
  return $result<value>;
}

# POST /session/:sessionId/execute_async
=begin markdown

    my $script = q{
      var callback = arguments[arguments.length-1];
      callback( arguments[0] + arguments[1] );
    };
    my $result = $driver.execute-async( $script, [1, 2] );

=end markdown
method execute-async(Str $script, Array $args = []) {
  my $result = self._post( 'execute_async', { script => $script, args => $args } );
  return unless $result.defined;
  return $result<value>;
}

# GET /session/:sessionId/ime/available_engines
method ime-available-engines returns Array {
  return self._get( 'ime/available_engines' );
}

# GET /session/:sessionId/ime/active_engine
method ime-active-engine returns Str {
  return self._get( 'ime/active_engine' );
}

# GET /session/:sessionId/ime/activated
method ime-activated returns Bool {
  return self._get( 'ime/activated' );
}

# POST /session/:sessionId/ime/deactivate
method ime-deactivate {
  return self._post( 'ime/deactivate' );
}

# POST /session/:sessionId/ime/activate
method ime-activate(Str $engine) {
  return self._post( 'ime/activate', { engine => $engine } );
}

# POST /session/:sessionId/frame
method _frame(Any $id) {
  return self._post( 'frame', { id => $id } );
}

multi method frame(Str $id) {
  return self._frame($id);
}

multi method frame(Int $id) {
  return self._frame($id);
}

multi method frame(Selenium::WebDriver::WebElement $id) {
  return self._frame($id);
}

# POST /session/:sessionId/frame/parent
multi method frame-parent {
  return self._post( 'frame/parent' );
}

# GET /session/:sessionId/cookie
method cookies returns Array {
  return self._get( 'cookie' );
}

# POST /session/:sessionId/cookie
=begin markdown

    my $cookie = {
      name   => 'Name',
      value  => 'Value',
      path   => '/',
      domain => 'domain.com',
    };
    $driver.cookie( $cookie );

=end markdown
multi method cookie(Hash $cookie) {
  return self._post( 'cookie', { cookie => $cookie } );
}

# DELETE /session/:sessionId/cookie
method delete-all-cookies {
  return self._delete( 'cookie' );
}

# DELETE /session/:sessionId/cookie/:name
method delete-cookie(Str $name) {
  return self._delete( "cookie/$name" );
}

=begin markdown
=end markdown
# POST /session/:sessionId/url
multi method url(Str $url) {
  return self._post( "url", { url => $url } );
}

=begin markdown
=end markdown
# GET /session/:sessionId/url
multi method url {
  return self._get( 'url' );
}

=begin markdown
=end markdown
# GET /session/:sessionId/title
method title {
  return self._get( 'title' );
}

=begin markdown
=end markdown
# GET /session/:sessionId/source
method source {
  return self._get( 'source' );
}

=begin markdown
=end markdown
# POST /session/:sessionId/moveto
method move-to(Str $element, Int $xoffset, Int $yoffset) {
  return self._post(
    "moveto",
    {
        element => $element,
        xoffset => $xoffset,
        yoffset => $yoffset,
    }
  );
}

=begin markdown
=end markdown
# POST /session/:sessionId/click
method click {
  return self._post( "click" );
}

=begin markdown
=end markdown
method quit {
  self._delete_session if self.session-id.defined;
  LEAVE {
    self.stop;
  }
};

=begin markdown
=end markdown
# GET /session/:sessionId/screenshot
method screenshot {
  return self._get('screenshot');
}

=begin markdown
=end markdown
method save-screenshot(Str $filename) {
  my $result = self.screenshot;
  $filename.IO.spurt(MIME::Base64.decode( $result ));
}


=begin markdown
=end markdown
# POST /session/:sessionId/forward
method forward {
  return self._post( "forward" );
}

=begin markdown
=end markdown
# POST /session/:sessionId/back
method back {
  return self._post( "back" );
}

=begin markdown
=end markdown
# POST /session/:sessionId/refresh
method refresh {
  return self._post( "refresh" );
}

=begin markdown
=end markdown
# POST /session/:sessionId/element
method _element(Str $using, Str $value) {
  my $result = self._post(
    "element",
    {
      'using' => $using,
      'value' => $value,
    }
  );

  return unless $result.defined;
  return Selenium::WebDriver::WebElement.new(
    :id( $result<value><ELEMENT> ),
    :driver( self )
  );
}

=begin markdown
=end markdown
method element-by-class(Str $class) {
  return self._element( 'class name', $class );
}

=begin markdown
=end markdown
method element-by-css(Str $selector) {
  return self._element( 'css selector', $selector );
}

=begin markdown
=end markdown
method element-by-id(Str $id) {
  return self._element( 'id', $id );
}

=begin markdown
=end markdown
method element-by-name(Str $name) {
  return self._element( 'name', $name );
}

=begin markdown
=end markdown
method element-by-link-text(Str $link-text) {
  return self._element( 'link text', $link-text );
}

=begin markdown
=end markdown
method element-by-partial-link-text(Str $partial-link-text) {
  return self._element( 'partial link text', $partial-link-text );
}

=begin markdown
=end markdown
method element-by-tag-name(Str $tag-name) {
  return self._element( 'tag name', $tag-name );
}

=begin markdown
=end markdown
method element-by-xpath(Str $xpath) {
  return self._element( 'xpath', $xpath );
}

=begin markdown
=end markdown
# POST /session/:sessionId/elements
method _elements(Str $using, Str $value) {
  my @elements = self._post(
    "elements",
    {
      'using' => $using,
      'value' => $value,
    }
  );

  return unless @elements.defined;
  my @results = gather {
      take Selenium::WebDriver::WebElement.new(
        :id( $_<value><ELEMENT> ),
        :driver( self )
      ) for @elements;
  };

  return @results;
}

=begin markdown
=end markdown
method elements-by-class(Str $class) {
  return self._elements( 'class name', $class );
}

=begin markdown
=end markdown
method elements-by-css(Str $selector) {
  return self._elements( 'css selector', $selector );
}

=begin markdown
=end markdown
method elements-by-id(Str $id) {
  return self._elements( 'id', $id );
}

=begin markdown
=end markdown
method elements-by-name(Str $name) {
  return self._elements( 'name', $name );
}

=begin markdown
=end markdown
method elements-by-link-text(Str $link-text) {
  return self._elements( 'link text', $link-text );
}

=begin markdown
=end markdown
method elements-by-partial-link-text(Str $partial-link-text) {
  return self._elements( 'partial link text', $partial-link-text );
}

=begin markdown
=end markdown
method elements-by-tag-name(Str $tag-name) {
  return self._elements( 'tag name', $tag-name );
}

=begin markdown
=end markdown
method elements-by-xpath(Str $xpath) {
  return self._elements( 'xpath', $xpath );
}

=begin markdown
=end markdown
# POST /session/:sessionId/keys
method send-keys-to-active-element(Str $keys) {
  return self._post( "keys", value => $keys.split('') );
}

# GET /session/:sessionId/orientation
multi method orientation {
  return self._get( 'orientation' );
}

# POST /session/:sessionId/orientation
multi method orientation(Str $orientation) {
  return self._post( 'orientation', orientation => $orientation );
}

# GET /session/:sessionId/alert_text
multi method alert-text {
  return self._get( 'alert_text' );
}

# POST /session/:sessionId/alert_text
multi method alert-text(Str $text) {
  return self._post( 'alert_text', text => $text );
}

# POST /session/:sessionId/accept_alert
method accept-alert {
  return self._post( 'accept_alert' );
}

# POST /session/:sessionId/dismiss_alert
method dismiss-alert {
  return self._post( 'dismiss_alert' );
}

# POST /session/:sessionId/buttondown
method button-down(Int $button where $_ eq any(0..2)) {
  return self._post( 'buttondown', button => $button );
}

# POST /session/:sessionId/buttonup
method button-up(Int $button where $_ eq any(0..2)) {
  return self._post( 'buttonup', button => $button );
}

# POST /session/:sessionId/doubleclick
method double-click {
  return self._post( 'doubleclick' );
}

# POST /session/:sessionId/touch/click
method touch-click(Str $element) {
  return self._post( 'touch/click', { element => $element} );
}

# POST /session/:sessionId/touch/down
method touch-down(Int $x, Int $y) {
  return self._post( 'touch/down', { x => $x, y => $y } );
}

# POST /session/:sessionId/touch/up
method touch-up(Int $x, Int $y) {
  return self._post( 'touch/up', { x => $x, y => $y } );
}

# POST session/:sessionId/touch/move
method touch-move(Int $x, Int $y) {
  return self._post( 'touch/move', { x => $x, y => $y } );
}

# POST session/:sessionId/touch/scroll
multi method touch-scroll(Str $element, Int $x-offset, Int $y-offset) {
  return self._post(
    'touch/scroll',
    { element => $element, xoffset => $x-offset, yoffset => $y-offset }
  );
}

multi method touch-scroll(Int $x-offset, Int $y-offset) {
  return self._post(
    'touch/scroll',
    { xoffset => $x-offset, yoffset => $y-offset }
  );
}

# POST session/:sessionId/touch/doubleclick
method touch-double-click(Str $element) {
  return self._post( 'touch/doubleclick', { element => $element} );
}

# POST session/:sessionId/touch/longclick
method touch-long-click(Str $element) {
  return self._post( 'touch/longclick', { element => $element} );
}

# POST session/:sessionId/touch/flick
multi method touch-flick(
  Str $element,
  Int $x-offset,
  Int $y-offset,
  Int $speed)
{
  return self._post(
    'touch/flick',
    {
      element => $element,
      xoffset => $x-offset,
      yoffset => $y-offset,
      speed   => $speed
    }
  );
}

multi method touch-flick(Int $x-speed, Int $y-speed) {
  return self._post(
    'touch/flick',
    {
      xspeed => $x-speed,
      yspeed => $y-speed
    }
  );
}

# GET /session/:sessionId/location
multi method location {
  return self._get( 'location' );
}

# POST /session/:sessionId/location
multi method location(Hash $location) {
  return self._post( 'location', location => $location );
}

# GET /session/:sessionId/local_storage
method local-storage {
  return self._get( 'local_storage' );
}

# POST /session/:sessionId/local_storage
method add-to-local-storage(Str $key, Str $value) {
  return self._post( 'local_storage', key => $key, value => $value );
}

# DELETE /session/:sessionId/local_storage
method clear-local-storage {
  return self._delete( 'local_storage' );
}

# GET /session/:sessionId/local_storage/key/:key
method get-from-local-storage(Str $key) {
  return self._get( "local_storage/key/$key" );
}

# DELETE /session/:sessionId/local_storage/key/:key
method delete-from-local-storage(Str $key) {
  return self._delete( "local_storage/key/$key" );
}

# GET /session/:sessionId/local_storage/size
method local-storage-size(Str $key) returns Int {
  return self._get( 'local_storage/size' );
}

# GET /session/:sessionId/session_storage
method session-storage {
  return self._get( 'session_storage' );
}

# POST /session/:sessionId/session_storage
method add-to-session-storage(Str $key, Str $value) {
  return self._post( 'session_storage', key => $key, value => $value );
}

# DELETE /session/:sessionId/session_storage
method clear-session-storage {
  return self._delete( 'session_storage' );
}

# GET /session/:sessionId/session_storage/key/:key
method get-from-session-storage(Str $key) {
  return self._get( 'session_storage/key/$key' );
}

# DELETE /session/:sessionId/session_storage/key/:key
method delete-from-session-storage(Str $key) {
  return self._delete( 'session_storage/key/$key' );
}

# GET /session/:sessionId/session_storage/size
method session-storage-size(Str $key) returns Int {
  return self._get( 'session_storage/size' );
}

# POST /session/:sessionId/log
method log(Str $type) {
  return self._post( 'log', type => $type );
}

# GET /session/:sessionId/log/types
method log-types {
  return self._get( 'log/types' );
}

# GET /session/:sessionId/application_cache/status
method application-cache-status {
  return self._get( 'application_cache/status' );
}

method _die(Str $method, Str $command, Any $message) {
  say "content:\n";
  say $message.response.content;
  say "end of content\n";
  my $o = from-json($message.response.content);

  my $error = $o<value>;
  Selenium::WebDriver::X::Error.new(
    reason     => $error<message>,
    screenshot => $error<screen>,
    class      => $error<class>
  ).throw;
}
=begin markdown
=end markdown
method _execute-command(Str $method, Str $command, Hash $params = {}) {
  say "POST $command with params " ~ $params.perl if self.debug;

  my $ua = HTTP::UserAgent.new(:throw-exceptions);
  $ua.timeout = 5;
  my $url = "http://"  ~ self.host ~ ":" ~ self.port ~ self.url-prefix ~ $command;
  my $response;
  if ( $method eq 'POST' ) {
    my $content = to-json($params);
    my $request = HTTP::Request.new(
      :POST($url),
      :Content-Length($content.chars),
      :Content-Type("application/json;charset=UTF-8"),
      :Connection("close"),
    );
    $request.add-content($content);
    $response = $ua.request($request);

    CATCH {
      default {
        self._die($method, $command, $_);
      }
    }
  }
  elsif ( $method eq 'GET' ) {
    $response = $ua.get( $url );

    CATCH {
      default {
        self._die($method, $command, $_);
      }
    }
  }
  elsif ( $method eq 'DELETE' ) {
    my $request = HTTP::Request.new(
      :DELETE($url),
      :Content-Type("application/json;charset=UTF-8"),
      :Connection("close"),
    );
    $response = $ua.request($request);

    CATCH {
      default {
        self._die($method, $command, $_);
      }
    }
  }
  else {
    die qq{Unknown method "$method"};
  }

  # Since we didnt get a response here, return nothing
  return unless $response.defined;

  my $result;
  if ( $response.is-success ) {
      $result = from-json( $response.content );
  }
  else {
      warn "FAILED: " ~ $response.status-line if self.debug;
  }

  return $result;
}

method _get(Str $command) {
  my $result = self._execute-command(
    "GET",
    "/session/$(self.session-id)/$command",
  );

  return unless $result.defined;
  return $result<value>;
}

method _post(Str $command, Hash $params = {}) {
  return self._execute-command(
    "POST",
    "/session/$(self.session-id)/$command",
    $params
  );
}

method _delete(Str $command, Hash $params = {}) {
  return self._execute-command(
    "DELETE",
    "/session/$(self.session-id)/$command",
    $params
  );
}

=begin markdown
### _empty-port

Find a random port in the dynamic/private range

According to [IANA](http://www.iana.org/assignments/port-numbers), dynamic
and/or private are in the range 49152 to 65535

=end markdown
method _empty-port {
  while 1 {
    # Find a random port in the dynamic/private range
    my $port = (49152..65535).pick;

    # Open and close a TCP connection to it
    my $socket = IO::Socket::INET.new( :host('127.0.0.1'), :port($port) );
    $socket.close;

    CATCH {
      default {
        # If it fails, it may mean that this port is not bound
        return $port;
      }
    }
  }
}
