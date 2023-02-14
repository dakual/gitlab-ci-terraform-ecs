<?php
header('Content-Type: application/json');
Header('Access-Control-Allow-Origin: frontend');
Header('Access-Control-Allow-Methods: GET');

require_once('../vendor/autoload.php');

use App\Backend\Database;


$exec_loads = sys_getloadavg();
$exec_cores = trim(shell_exec("grep 'processor' /proc/cpuinfo|wc -l"));
$cpu = round($exec_loads[1]/($exec_cores + 1)*100, 0) . '%';

$exec_free = explode("\n", trim(shell_exec('free')));
$get_mem = preg_split("/[\s]+/", $exec_free[1]);
$mem = round($get_mem[2]/$get_mem[1]*100, 0) . '%';

$exec_uptime = preg_split("/[,]+/", trim(shell_exec('uptime')));
$uptime = $exec_uptime[0];


try {
  $db      = new Database();
  $created = date("Y-m-d H:i:s");
  $insert  = $db->query("INSERT INTO stats (cpu,mem,uptime,created) VALUES (?,?,?,?)", array(
    $cpu, $mem, $uptime, $created
  ));
  # echo $insert->affectedRows();
  # echo $db->query_count;
  # echo $db->lastInsertID();
  $db->close();
} catch(Exception $e) {
  error_log("[Stats] MySql database connection problem!", 0);
}


echo '{"cpu":"'.$cpu.'", "mem":"'.$mem.'", "uptime":"'.$uptime.'"}';


?>