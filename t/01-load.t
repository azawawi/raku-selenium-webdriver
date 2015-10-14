use v6;

use Test;
use lib 'lib';

plan 2;

use Selenium::WebDriver;
ok 1, "'use Selenium::WebDriver' worked!";
ok Selenium::WebDriver.new, "Selenium::WebDriver.new worked";
