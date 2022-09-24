
use v6;

use File::Which;
use Selenium::WebDriver::Wire;

unit class Selenium::WebDriver::Chrome is Selenium::WebDriver::Wire;

has Proc::Async $.process    is rw;

method start {
  say "Launching Chrome Driver" if self.debug;

  # Find process in PATH
  my $chrome-driver = which("chromedriver");
  die "Cannot find chromedriver in your PATH" unless $chrome-driver.defined;

  # Run it
  say "Chrome found at '$chrome-driver'" if self.debug;
  my $p = Proc::Async.new($chrome-driver, "--port=" ~ self.port);
  $p.start;

  self.process = $p;
}

method stop {
  self.process.kill if self.process.defined;
}
