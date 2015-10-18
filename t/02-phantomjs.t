use v6;

use Test;
use lib 'lib';

# Methods to test
my @methods = 'set_url', 'get_url', 'get_source', 'move_to', 'click', 'quit', 
  'get_screenshot', 'save_screenshot', 'forward', 'back', 'refresh';

plan @methods.elems + 2;

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
  ok Selenium::WebDriver::PhantomJS.can($method), "Selenium::WebDriver::PhantomJS.$method is found";
}

$driver.quit;
