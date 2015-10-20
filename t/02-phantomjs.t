use v6;

use Test;
use lib 'lib';

# Methods to test
my @methods = 'url', 'source', 'move-to', 'click', 'quit',
  'screenshot', 'save-screenshot', 'forward', 'back', 'refresh',
  'find-element-by-class', 'find-element-by-css', 'find-element-by-id',
  'find-element-by-name', 'find-element-by-link-text',
  'find-element-by-partial-link-text', 'find-element-by-tag-name',
  'find-element-by-xpath', 'sessions', 'capabilities',
  'script-timeout', 'implicit-timeout', 'page-load-timeout',
  'current-window', 'windows', 'status',
  'async-script-timeout', 'implicit-wait-timeout', 'execute', 'execute-async',
  'ime-available-engines', 'ime-active-engine', 'ime-activated',
  'ime-activated', 'ime-activated', 'frame', 'frame-parent',
  'cookies', 'cookie', 'delete-all-cookies', 'delete-cookie',
  'send-keys-to-active-element', 'orientation', 'alert-text', 'accept-alert',
  'dismiss-alert';

plan @methods.elems + 14;

use Selenium::WebDriver::PhantomJS;
ok 1, "'use Selenium::WebDriver::PhantomJS' worked!";

{
  # Skip tests if phantomjs is not found
  use File::Which;
  unless which('phantomjs') {
    skip-rest("phantomjs is not installed. skipping tests...");
    exit;
  }
}

my $driver = Selenium::WebDriver::PhantomJS.new;
ok $driver, "Selenium::WebDriver::PhantomJS.new worked";

for @methods -> $method {
  ok Selenium::WebDriver::PhantomJS.can($method),
    "Selenium::WebDriver::PhantomJS.$method is found";
}

{
  my $sessions = $driver.sessions;
  ok $sessions.defined, "Sessions returned a defined value";
  ok $sessions ~~ Array, "Sessions is an array";
  ok $sessions.elems == 1, "Only One session should be there";
  ok $sessions[0]<id> ~~ Str, "And we have a sessionId";
}

{
  my $capabilities = $driver.capabilities;
  ok $capabilities.defined, "capabilities returned a defined value";
  ok $capabilities ~~ Hash, "capabilities is a hash";
  ok $capabilities<sessionId> ~~ Str, "And we have a sessionId";
}

{
  my $current-window = $driver.current-window;
  ok $current-window.defined, "current-window returned a defined value";
  ok $current-window.handle ~~ Str, "current-window handle is a string";
}

{
  my @windows = $driver.windows;
  ok @windows.defined, "windows returned a defined value";
  ok @windows.elems > 0, "windows has at least one active window";
  ok @windows[0] ~~ Selenium::WebDriver::WebWindow, "first element is a window";
}

LEAVE {
  $driver.quit if $driver.defined;
}
