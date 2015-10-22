
use v6;

use Selenium::WebDriver::Wire;
use File::Which;

unit class Selenium::WebDriver::PhantomJS is Selenium::WebDriver::Wire;

has Proc::Async $.process    is rw;

method start {
  say "Starting phantomjs process" if $.debug;

  # Find process in PATH
  my $path = which( 'phantomjs' );
  die "Cannot find phantomjs in your PATH" unless $path.defined;

  my $process = Proc::Async.new(
    $path,
    "--webdriver=" ~ $.port,
    "--webdriver-loglevel=" ~ ($.debug ?? "DEBUG" !! "WARN"),
  );
  $process.start;

  self.process = $process;
}

method stop {
  self.process.kill if self.process.defined;
}
