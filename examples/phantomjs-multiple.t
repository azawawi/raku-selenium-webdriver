#!/usr/bin/env perl6

use v6;

use lib 'lib';
use Test;
use Selenium::WebDriver::PhantomJS;

# Number of simulatenous drivers to test port collision
constant NUM_OF_DRIVERS = 5;
plan 3 * NUM_OF_DRIVERS;

# Create two phantomjs webdriver
# Please note phantomjs must be already installed
my @drivers;
for 1..NUM_OF_DRIVERS {
  diag "Driver #$_ starting up";
  my $driver = Selenium::WebDriver::PhantomJS.new;
  ok($driver.defined, "WebDriver is defined");

  @drivers.push($driver);

  # Navigate to google.com
  $driver.url( "http://google.com" );

  ok($driver.title ~~ / 'Google' /,                "Google in title");
  ok($driver.url   ~~ / ^ 'http://' .+? 'google'/, "google.com in url");
}

LEAVE {
  diag 'WebDriver(s) cleanup';
  $_.quit for @drivers;
}
