<?php
/***
	Template-System
***/
$xtpl = new XTemplate("$template_dir/blank.html");

/***
	Do the work
***/
$xtpl->assign("php_self", $_SERVER['PHP_SELF']);

/***
	Parse and output Template
***/
$xtpl->parse('main');
$xtpl->out('main');

?>