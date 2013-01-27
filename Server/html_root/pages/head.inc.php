<?php
/***
	Template-System
***/
$xtpl = new XTemplate("$template_dir/head.html");

/***
	Do the work
***/
$xtpl->assign("php_self", $_SERVER['PHP_SELF']);
$xtpl->assign("site_title", $site_title);
$xtpl->assign("server_time", date("d.m.Y - H:i:s", time()));

/***
	Parse and output Template
***/
$xtpl->parse('main');
$xtpl->out('main');
?>