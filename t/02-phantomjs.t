use v6;

use Test;
use lib 'lib';

# Methods to test
my @methods = 'url', 'source', 'move-to', 'click', 'quit',
  'screenshot', 'save-screenshot', 'forward', 'back', 'refresh',
  'find-element-by-class', 'find-element-by-css', 'find-element-by-id',
  'find-element-by-name', 'find-element-by-link-text',
  'find-element-by-partial-link-text', 'find-element-by-tag-name',
  'find-element-by-xpath', 'sessions', 'capabilities';

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
