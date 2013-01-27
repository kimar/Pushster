<?php
$time = time();
define('PUSHSTER', true);

/***
	Direcotries
***/
$pages_dir = "./pages";
$template_dir = "./templates";

/***
	Tables
***/
$tbl_prefix = "pu_";
$tbl_devices = $tbl_prefix."devices";
$tbl_messages = $tbl_prefix."messages";
$tbl_online = $tbl_prefix."online";
$tbl_logins = $tbl_prefix."logins";
$tbl_settings = $tbl_prefix."settings";
?>