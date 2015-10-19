use v6;

use Test;
use lib 'lib';

# Methods to test
my @methods = 'click', 'send-keys', 'tag-name', 'selected', 'enabled', 'attr',
  'equals-by-id', 'displayed', 'location', 'location-in-view', 'size' ,
  'css', 'submit', 'text', 'clear';

plan @methods.elems + 2;

use Selenium::WebDriver::WebElement;
ok 1, "'use Selenium::WebDriver::WebElement' worked!";

my $driver = Selenium::WebDriver::WebElement.new;
ok $driver, "Selenium::WebDriver::WebElement.new worked";

for @methods -> $method {
  ok Selenium::WebDriver::WebElement.can($method), "Selenium::WebDriver::WebElement.$method is found";
}

$driver.quit;
