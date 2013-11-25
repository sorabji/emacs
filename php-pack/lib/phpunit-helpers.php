<?php

/**
 * Define an xdebug breakpoint when debugger() is called.  Similar to the debugger javascript feature in firebug and chrome.
 *
 * include it w/ a php ini setting:
 * auto_prepend_file = "/path/to/phpunit-helpers.php"
 */
if (!function_exists('debugger')) {
    function debugger() {
        // If stopped here, step out to see who called debugger().
    }
}