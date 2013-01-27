<?php

/***
	We wont access this file directly
***/
if (!defined('PUSHSTER')) die('Ooops, something went wrong!');

/***
	Let's go!
***/
$post_data = get_raw_post();
$json_request = json_decode($post_data);

/***
	Translate the request
***/
$json_command = $json_request->{'command'};
$json_udid = $json_request->{'udid'};
$json_reqid = $json_request->{'reqid'};
$json_messageid = $json_request->{'message_id'};
if(!$json_reqid) $json_reqid = 0;

if(!isset($json_command) || !isset($json_udid))
{
	$error_code = 9999;
	$error_msg = "Parameter missing";
	send_json_error_response($error_code, $error_msg, $json_reqid);
}
else
{
	/***
		Check if this device has been used before
	***/
	$sql = "SELECT * FROM $tbl_devices WHERE de_udid = '".$db->escape($json_udid)."'";
	$db->query($sql);
	$count = $db->affected_rows;
	if($count == 0)
	{
		/***
			First usage of this device
		***/
		$new_device = array();
		$new_device['de_udid'] = $json_udid;
		$new_device['de_token'] = $json_request->{'token'};
		$new_device['de_secret'] = sha1($json_udid);
		$new_device['de_regtime'] = $time;
		$new_device['de_usetime'] = 0;
		$db->insert($tbl_devices, $new_device);
	}
	
	/***
		Update usage
	***/
	$device = array();
	$device['de_usetime'] = $time;
	$db->update($tbl_devices, $device, "de_udid = '$json_udid'");
	
	/***
		Functionality
	***/
	if($json_command == "reg_apns")
	{
		$json_token = $json_request->{'token'};
		if(!isset($json_token) || strlen($json_token) == 0)
		{
			$error_code = 9997;
			$error_msg = "Token missing";
			send_json_error_response($error_code, $error_msg, $json_reqid);
		}
		else
		{
			$sql = "SELECT id FROM $tbl_devices WHERE de_udid = '".$db->escape($json_udid)."'";
			$db->query($sql);
			$count = $db->affected_rows;
			
			if($count > 0)
			{
				$sql = "UPDATE $tbl_devices SET de_token = '".$db->escape($json_token)."' WHERE de_udid = '".$db->escape($json_udid)."'";
				$db->query($sql);
				$json_output = array('error_code' => 1000, 'error_message' => 'Request ok');
				send_json_response($json_output);
			}
			else
			{
				$error_code = 9996;
				$error_msg = "Device error - not found in database";
				send_json_error_response($error_code, $error_msg, $json_reqid);
			}
		}
	}
	else if($json_command == "get_messages")
	{
		$sql = "SELECT id FROM $tbl_devices WHERE de_udid = '".$db->escape($json_udid)."'";
		$device = $db->query_first($sql);
		
		$sql = "SELECT * FROM $tbl_messages WHERE de_id = '".$device['id']."' AND me_invisible = 0";
		$db->query($sql);
		$message_count = $db->affected_rows;
		
		if($message_count > 0)
		{
			$messages_array = array();
			while($message = $db->fetch())
			{
				$messages_array[] = array('id'=>intval($message['id']),'time' => $message['me_time'], 'message' => $message['me_message']);
			}
			$json_output = array('error_code' => 1000, 'error_message' => 'Request ok', 'messages' => $messages_array);
			send_json_response($json_output);
		}
		else
		{
			$messages_array = array(array('id'=>0,'time' => $time, 'message' => "No new Notifications"));
			$json_output = array('error_code' => 1000, 'error_message' => 'Request ok', 'messages' => $messages_array);
			send_json_response($json_output);
		}
	}
	else if($json_command=="del_message")
	{
		$sql = "SELECT id FROM $tbl_devices WHERE de_udid = '".$db->escape($json_udid)."'";
		$device = $db->query_first($sql);
		
		$sql = "UPDATE $tbl_messages SET me_invisible = 1 WHERE de_id = '".$device['id']."' AND id='".$db->escape($json_messageid)."'";
		$db->query($sql);
		
		$message_count = $db->affected_rows;
					
		if($message_count > 0)
		{
			$json_output = array('error_code' => 1000, 'error_message' => 'Request ok');
			send_json_response($json_output);
		}
		else
		{
			$messages_array = array(array('time' => $time, 'message' => "No new Notifications"));
			$json_output = array('error_code' => 9995, 'error_message' => 'Request failed, no such message (id='.$json_messagid.')!');
			send_json_response($json_output);
		}
	}
	else if($json_command=="add_rss")
	{
		$sql = "SELECT id FROM $tbl_devices WHERE de_udid = '".$db->escape($json_udid)."'";
		$device = $db->query_first($sql);
		
		if($db->affected_rows>0)
		{
			$rssfeed=array(	'de_id'=>$device['id'],
						'rss_url'=>$json_request->{'url'});
			$db->insert($tbl_rssfeeds,$rssfeed);
			
			$json_output = array('error_code' => 1000, 'error_message' => 'Request ok');
			send_json_response($json_output);
		}
		else
		{
			$json_output = array('error_code' => 9994, 'error_message' => 'Request failed');
			send_json_response($json_output);
		}
		
		
	}
	else
	{
		$error_code = 9998;
		$error_msg = "Unknown command";
		send_json_error_response($error_code, $error_msg, $json_reqid);
	}
}

?>