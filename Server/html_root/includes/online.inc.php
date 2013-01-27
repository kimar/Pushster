<?php
if($_GET['action'] == "logout") {
	session_destroy();
}

if(isset($_SESSION['user'])) {
	$user_id = $_SESSION['user']['id'];	
	$query_online = "SELECT sessid FROM $tbl_online WHERE sessid='".$db->escape($_SESSION['user']['sessid'])."' AND user_id='".$db->escape($_SESSION['user']['id'])."'";
	$db->query($query_online);
	if($db->affected_rows == 0)
	{
		$session_error = true;
	}
	$query_user = "SELECT id, locked FROM $tbl_users WHERE id='".$db->escape($_SESSION['user']['id'])."'";
	$db->query($query_user);
	if($db->affected_rows == 0)
	{
		$session_error = true;
	}
	$array_user = $db->query_first($query_user);
	if($array_user['locked'] == 1 || $session_error) { 
		session_destroy();
		$user_online = 0; 
	}
	$query_online = "SELECT user_id, logtime, acttime FROM $tbl_online WHERE user_id='".$db->escape($_SESSION['user']['id'])."'";
	$db->query($query_online);
	if($db->affected_rows > 0) {
		$array_online = $db->query_first($query_online);
		$real_timeout = $array_online['acttime']+900;
		if($real_timeout < $unixtime) {
			$db->query("DELETE FROM $tbl_online WHERE user_id='".$_SESSION['user']['id']."'");
			session_destroy();
			$user_online = 0;
		} else {
			$db->query("UPDATE $tbl_online SET acttime='".$unixtime."' WHERE user_id='".$_SESSION['user']['id']."'");
			$user_online = 1;
		}
	} else {
		session_destroy();
		$user_online = 0;
	}	
} else {
	$user_online = 0;
}
?>