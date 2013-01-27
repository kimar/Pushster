<?php
if($user_online == 1)
{
  $sql = "SELECT * FROM $tbl_settings";
  $rows = $db->query($sql);
  
  /***
   * Get Settings
  ***/
  while($row = $db->fetch($rows))
  {
    $settings[$row['key']] = $row['value'];
  }
       
}
?>