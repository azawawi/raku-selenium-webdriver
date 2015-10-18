use v6;

use Test;
use lib 'lib';

plan 2;

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

$driver.quit;
