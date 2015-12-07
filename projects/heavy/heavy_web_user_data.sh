#!/bin/bash

cat <<EOF_SSH > /home/ubuntu/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0sUjdTEcOWYgQ7ESnHsSkvPUO2tEvZxxQHUZYh9j6BPZgfn13iYhfAP2cfZznzrV+2VMamMtfiAiWR39LKo/bMN932HOp2Qx2la14IbiZ91666FD+yZ4+vhR2IVhZMe4D+g8FmhCfw1+zZhgl8vQBgsRZIcYqpYux59FcPv0lP1EhYahoRsUt1SEU2Gj+jvgyZpe15lnWk2VzfIpIsZ++AeUqyHoJHV0RVOK4MLRssqGHye6XkA3A+dMm2Mjgi8hxoL5uuwtkIsAll0kSfL5O2G26nsxm/Fpcl+SKSO4gs01d9V83xiOwviyOxmoXzwKy4qaUGtgq1hWncDNIVG/aQ==
EOF_SSH

#apt-get update -y
#apt-get upgrade -y
apt-get install -y nginx stress

#stress --cpu 1
while true; do ps -A -o pcpu | tail -n+2 | paste -sd+ | bc > /usr/share/nginx/html/cpu.txt; sleep 1; done

cat <<EOF_HTML > /usr/share/nginx/html/index.html
<html>
  <head>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script type="text/javascript">
    google.load('visualization', '1', {'packages':['corechart']});
    google.setOnLoadCallback(drawChart);
    function drawChart() {
      var jsonData = $.ajax({
          url: "https://gist.githubusercontent.com/antonbabenko/526783bbb4a5011f8b50/raw/data.json",
          dataType: "json",
          async: false
          }).responseText;
      var data = new google.visualization.DataTable(jsonData);
      var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
      chart.draw(data, {width: 600, height: 400});
    }
    </script>
  </head>
  <body>
    <div id="chart_div"></div>

    <script type="text/javascript">
    $(document).ready(function() {
        var timeout = setInterval(reloadCpu, 1000);
        function reloadCpu () {
            $("#cpuTxt").load("cpu.txt");
        }
    });
    </script>
    CPU usage: <div id="cpuTxt"></div>

  </body>
</html>
EOF_HTML