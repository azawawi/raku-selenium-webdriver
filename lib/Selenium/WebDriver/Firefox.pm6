
use v6;

use Selenium::WebDriver::Wire;
use File::Which;

unit class Selenium::WebDriver::Firefox is Selenium::WebDriver::Wire;

has Proc::Async $.process    is rw;

method start {
  say "Starting firefox process" if $.debug;

  # Find process in PATH
  my $path = which( 'firefox' );
  die "Cannot find firefox in your PATH" unless $path.defined;

  my $process = Proc::Async.new(
    $path,
    "--webdriver=" ~ $.port,
  );
  $process.start;

  self.process = $process;
}

method stop {
  self.process.kill if self.process.defined;
}
