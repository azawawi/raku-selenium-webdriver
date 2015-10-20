use v6;

use Test;
use lib 'lib';

# Methods to test
my @methods = 'current', 'close-current', 'size', 'position', 'maximize';

plan @methods.elems + 2;

use Selenium::WebDriver::WebWindow;
ok 1, "'use Selenium::WebDriver::WebWindow' worked!";

my $element = Selenium::WebDriver::WebWindow.new;
ok $element, "Selenium::WebDriver::WebWindow.new worked";

for @methods -> $method {
  ok Selenium::WebDriver::WebWindow.can($method),
    "Selenium::WebDriver::WebWindow.$method is found";
}
