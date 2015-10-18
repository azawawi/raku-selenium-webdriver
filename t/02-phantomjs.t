use v6;

use Test;
use lib 'lib';

# Methods to test
my @methods = 'set_url', 'get_url', 'get_source', 'move_to', 'click', 'quit', 
  'get_screenshot', 'save_screenshot', 'forward', 'back', 'refresh',
  'find_element_by_class_name', 'find_element_by_css_selector', 'find_element_by_id',
  'find_element_by_name', 'find_element_by_link_text', 'find_element_by_partial_link_text',
  'find_element_by_tag_name', 'find_element_by_xpath';

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
