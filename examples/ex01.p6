#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Selenium::WebDriver;

my $driver = Selenium::WebDriver.new(:debug);
$driver.set_url("http://google.com");
$driver.save_screenshot('test.png');
$driver.quit;
