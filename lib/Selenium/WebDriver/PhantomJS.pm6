
use v6;

use Selenium::WebDriver::Wire;

unit class Selenium::WebDriver::PhantomJS is Selenium::WebDriver::Wire;

has Proc::Async $.process    is rw;

method start {
  say "Starting phantomjs process" if $.debug;
  my $process = Proc::Async.new(
    'phantomjs',
    "--webdriver=" ~ $.port,
    "--webdriver-loglevel=" ~ ($.debug ?? "DEBUG" !! "WARN"),
  );
  $process.start;

  self.process = $process;
}

method stop {
  self.process.kill if self.process.defined;
}
