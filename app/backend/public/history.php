<?php
header('Content-Type: application/json');
Header('Access-Control-Allow-Origin: frontend');
Header('Access-Control-Allow-Methods: GET');

require_once('../vendor/autoload.php');

use App\Backend\Database;

try {
  $db    = new Database();
  $limit = !empty($_GET["limit"]) ? $_GET["limit"] : 10;
  $stats = $db->query('SELECT * FROM stats ORDER BY id DESC LIMIT ?', array($limit))->fetchAll();
  $stats = json_encode($stats);

  echo '{"history":'.$stats.'}';

  $db->close();
} catch(Exception $e) {
  error_log("[Histoory] MySql database connection problem!", 0);
}
