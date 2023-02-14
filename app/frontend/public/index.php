<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <meta name="generator" content="">
    <title>Blog Template</title>
    <link href="/css/bootstrap.min.css" rel="stylesheet">
    <link href="/css/style.css" rel="stylesheet">
    <script src="/js/jquery-3.6.0.min.js"></script>
    <script src="/js/bootstrap.bundle.min.js"></script>
  </head>
  <body>


    <main role="main" class="container pt-4">
      <div class="row">
        <div class="col-sm-4">
          <div class="card text-white bg-primary mb-3">
            <div class="card-header">CPU Usage</div>
            <div class="card-body">
              <h1 class="card-title text-center" id="cpu"></h1>
            </div>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="card text-dark bg-warning mb-3">
            <div class="card-header">Memory Usage</div>
            <div class="card-body">
              <h1 class="card-title text-center" id="mem"></h1>
            </div>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="card text-white bg-success mb-3">
            <div class="card-header">Uptime</div>
            <div class="card-body">
              <h1 class="card-title text-center" id="uptime"></h1>
            </div>
          </div>      
        </div>
      </div>


      <div class="p-5 mb-4 bg-light mt-4">
        <div class="container-fluid py-5">

          <button type="button" class="btn btn-primary load" data-limit="10">Load Last 10 History</button>
          <button type="button" class="btn btn-primary load" data-limit="25">Load Last 25 History</button>
          <button type="button" class="btn btn-primary load" data-limit="50">Load Last 50 History</button>
          <button type="button" class="btn btn-primary load" data-limit="100">Load Last 100 History</button>

          <table class="table">
            <thead>
              <tr>
                <th scope="col">#</th>
                <th scope="col">CPU</th>
                <th scope="col">MEMORY</th>
                <th scope="col">UPTIME</th>
                <th scope="col">CREATED</th>
              </tr>
            </thead>
            <tbody></tbody>
          </table>

        </div>
      </div>

    </main>

    
    <script>
    $(document).ready(function(){
      setInterval(function() {
        $.get("/stats.php", function(data){
          console.log(data);
          $("#cpu").html(data["cpu"]);
          $("#mem").html(data["mem"]);
          $("#uptime").html(data["uptime"]);
        });        
      },3000);

      $('.load').on('click', function () {
        var limit = $(this).attr("data-limit");
        $.get("/history.php?limit=" + limit, function(data){
          console.log(data);
          $('.table tbody').empty();
          $.each(data["history"], function(){
            var html = '<tr><th scope="row">' + this.id + '</th><td>' + this.cpu + '</td><td>' + this.mem + '</td><td>' + this.uptime + '</td><td>' + this.created + '</td></tr>';
            $('.table').append(html);
          });
        });        
      });
    });
    </script>
  </body>
</html>