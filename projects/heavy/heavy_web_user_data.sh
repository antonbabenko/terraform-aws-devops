#!/bin/bash

cat <<EOF_SSH > /home/ubuntu/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0sUjdTEcOWYgQ7ESnHsSkvPUO2tEvZxxQHUZYh9j6BPZgfn13iYhfAP2cfZznzrV+2VMamMtfiAiWR39LKo/bMN932HOp2Qx2la14IbiZ91666FD+yZ4+vhR2IVhZMe4D+g8FmhCfw1+zZhgl8vQBgsRZIcYqpYux59FcPv0lP1EhYahoRsUt1SEU2Gj+jvgyZpe15lnWk2VzfIpIsZ++AeUqyHoJHV0RVOK4MLRssqGHye6XkA3A+dMm2Mjgi8hxoL5uuwtkIsAll0kSfL5O2G26nsxm/Fpcl+SKSO4gs01d9V83xiOwviyOxmoXzwKy4qaUGtgq1hWncDNIVG/aQ==
EOF_SSH

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

apt-get update -y
apt-get install -y nginx stress awscli

#stress --cpu 1

cat <<"EOF_HTML" > /usr/share/nginx/html/index.html
<html>
  <head>
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  </head>
  <body>
    <script type="text/javascript">
    $(document).ready(function() {
        var timeout = setInterval(reloadCpu, 3000);
        function reloadCpu () {
            $("#cpuTxt").load("cpu.txt");
            //$("#ipTxt").load("ip.txt");
            //$("#idTxt").load("id.txt");
        }
    });
    </script>
    CPU usage: <div id="cpuTxt"></div><br /><br /><br />
    <!--
    Private IP: <div id="ipTxt"></div><br /><br /><br />
    Instance ID: <div id="idTxt"></div>
    -->
  </body>
</html>
EOF_HTML

curl -o /usr/share/nginx/html/id.txt http://169.254.169.254/latest/meta-data/instance-id
curl -o /usr/share/nginx/html/ip.txt http://169.254.169.254/latest/meta-data/local-ipv4

while true; do ps -A -o pcpu | tail -n+2 | paste -sd+ | bc > /usr/share/nginx/html/cpu.txt; sleep 1; done
