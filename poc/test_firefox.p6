#!/usr/bin/env perl6

use v6;

use lib 'lib';
use Selenium::WebDriver::Firefox;

my $driver = Selenium::WebDriver::Firefox.new;
$driver.url("http://doc.perl6.org");

sleep 5;

LEAVE {
  $driver.quit if $driver.defined;
}