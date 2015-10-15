use v6;

use Test;
use lib 'lib';

plan 2;

use Selenium::WebDriver;
ok 1, "'use Selenium::WebDriver' worked!";

{
  # Skip tests if the electron executable is not found
  use File::Which;
  unless which('phantomjs') {
    skip-rest("phantomjs is not installed. skipping tests...");
    exit;
  }
}

my $driver = Selenium::WebDriver.new;
ok $driver, "Selenium::WebDriver.new worked";

$driver.quit;
