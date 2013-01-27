<?php
/***
	Access the raw post input
***/
function get_raw_post(){
  $data = @file_get_contents('php://input');  
  if ($data){
    return $data;
  }
  return FALSE;
}

?>