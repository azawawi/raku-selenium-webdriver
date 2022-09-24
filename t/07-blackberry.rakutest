use v6;

use Test;
use lib 'lib';

# Methods to test
my @methods = 'url', 'source', 'move-to', 'click', 'quit',
  'screenshot', 'save-screenshot', 'forward', 'back', 'refresh',
  'element-by-class', 'element-by-css', 'element-by-id',
  'element-by-name', 'element-by-link-text', 'element-by-partial-link-text',
  'element-by-tag-name', 'element-by-xpath',  'elements-by-class',
  'elements-by-css', 'elements-by-id', 'elements-by-name',
  'elements-by-link-text', 'elements-by-partial-link-text',
  'elements-by-tag-name', 'elements-by-xpath', 'sessions', 'capabilities',
  'script-timeout', 'implicit-timeout', 'page-load-timeout',
  'current-window', 'windows', 'status',
  'async-script-timeout', 'implicit-wait-timeout', 'execute', 'execute-async',
  'ime-available-engines', 'ime-active-engine', 'ime-activated',
  'ime-activated', 'ime-activated', 'frame', 'frame-parent',
  'cookies', 'cookie', 'delete-all-cookies', 'delete-cookie',
  'send-keys-to-active-element', 'orientation', 'alert-text', 'accept-alert',
  'dismiss-alert', 'button-down', 'button-up', 'double-click', 'touch-click',
  'touch-down', 'touch-up', 'touch-move', 'touch-scroll', 'touch-double-click',
  'touch-long-click', 'touch-flick', 'location',
  'local-storage', 'add-to-local-storage', 'clear-local-storage',
  'get-from-local-storage', 'delete-from-local-storage', 'local-storage-size',
  'session-storage', 'add-to-session-storage', 'clear-session-storage',
  'get-from-session-storage', 'delete-from-session-storage',
  'session-storage-size', 'log', 'log-types', 'application-cache-status';

plan @methods.elems + 14;

use Selenium::WebDriver::BlackBerry;
ok 1, "'use Selenium::WebDriver::BlackBerry' worked!";

unless %*ENV<SELENIUM_BLACKBERRY_IP> {
    skip-rest("Environment variable SELENIUM_BLACKBERRY_IP is not set. skipping tests...");
    exit;
}

my $driver = Selenium::WebDriver::BlackBerry.new(%*ENV<SELENIUM_BLACKBERRY_IP>);
ok $driver, "Selenium::WebDriver::BlackBerry.new worked";

for @methods -> $method {
  ok Selenium::WebDriver::BlackBerry.can($method),
    "Selenium::WebDriver::BlackBerry.$method is found";
}

{
  my $sessions = $driver.sessions;
  ok $sessions.defined, "Sessions returned a defined value";
  ok $sessions ~~ Array, "Sessions is an array";
  ok $sessions.elems == 1, "Only One session should be there";
  ok $sessions[0]<id> ~~ Int, "And we have a sessionId";
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

# This would make the BlackBerry Browser quit. So we avoid that.
# LEAVE {
#   $driver.quit if $driver.defined;
# }
