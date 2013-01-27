<?php
function normalizeNumber($number) {
	if(substr($number, 0, 2) == "00") {
		$number = substr($number, 2);
	} else if (substr($number, 0, 1) == "+") {
		$number = substr($number, 1);
	} else if(substr($number, 0, 2) == "01") { 
		$number = "49".substr($number, 1); 
	}
	$number = str_replace(" ", "", $number);
	$number = str_replace("-", "", $number);
	$number = str_replace("(", "", $number);
	$number = str_replace(")", "", $number);
	$number = str_replace("/", "", $number);
	return $number;
}

function checkGermanMobilenumber($number) {
	$isGerman = false;
	if(substr($number, 0, 2) == "00") {
		$number = substr($number, 2);
	} else if (substr($number, 0, 1) == "+") {
		$number = substr($number, 1);
	} else if(substr($number, 0, 2) == "01") { 
		$number = "49".substr($number, 1); 
	}
	$number = str_replace(" ", "", $number);
	$number = str_replace("-", "", $number);
	$number = str_replace("(", "", $number);
	$number = str_replace(")", "", $number);
	$number = str_replace("/", "", $number);
	if(substr($number, 0, 2) == "49") {
		$isGerman = true;
	}
	return $isGerman;
}

function checkEmail($email) {
  if (!ereg("^[^@]{1,64}@[^@]{1,255}$", $email)) {
    return false;
  }
  $email_array = explode("@", $email);
  $local_array = explode(".", $email_array[0]);
  for ($i = 0; $i < sizeof($local_array); $i++) {
    if
(!ereg("^(([A-Za-z0-9!#$%&'*+/=?^_`{|}~-][A-Za-z0-9!#$%&
↪'*+/=?^_`{|}~\.-]{0,63})|(\"[^(\\|\")]{0,62}\"))$",
$local_array[$i])) {
      return false;
    }
  }
  return true;
}

function destroySession() {
	global $tbl_online;
	$db=Database::obtain();
	$sql = "DELETE FROM $tbl_online WHERE sessid='".session_id()."'";
	$db->query($sql);
	session_destroy();
	$user_online = 0;
}

function validateIp($ip)
{
	return ( ! preg_match( "/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/", $ip)) ? FALSE : TRUE;
}

function logLogin($username, $password, $success)
{
  global $tbl_logins;
  $db = Database::obtain();
  $login['username'] = $username;
  if($success == 0) $login['password'] = $password; else $login['password'] = "";
  $login['password_sha1'] = sha1($password);
  $login['logtime'] = time();
  $login['logip'] = $_SERVER['REMOTE_ADDR'];
  $login['success'] = $success;
  $db->insert($tbl_logins, $login);
}
?>