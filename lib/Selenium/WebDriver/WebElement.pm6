
use v6;

unit class Selenium::WebDriver::WebElement;

has Str $.id is rw;
has $.driver is rw;

# POST /session/:sessionId/element/:id/click
method click {
  return $.driver._execute_command(
    "POST",
    "/session/$($.driver.session_id)/element/$($.id)/click",
  );
}

# POST /session/:sessionId/element/:id/value
method send_keys(Str $keys) {
  say "/session/$($.driver.session_id)/element/$($.id)/value";
  return $.driver._execute_command(
    "POST",
    "/session/$($.driver.session_id)/element/$($.id)/value",
    {
      "value" => $keys.split('');
    }
  );
}

# POST /session/:sessionId/element/:id/submit
method submit {
  return $.driver._execute_command(
    "POST",
    "/session/$($.driver.session_id)/element/$($.id)/submit",
  );
}

method get_text {
  !!!
}

method get_value {
  !!!
}

method clear {
  !!!
}
