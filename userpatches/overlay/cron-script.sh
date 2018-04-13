#!/bin/bash
#
# Grabbing some statistical data and send to the server
#


# make a separate config file
SERVER_IP=""
SERVER_PORT=""



read raw_temp </etc/armbianmonitor/datasources/soctemp
board_temp=$(awk '{printf("%d",$1/1000)}' <<<${raw_temp})
rootpart=$(findmnt -n -o SOURCE /)
speed=$(speedtest-cli --simple)

# read in board info
[[ -f /etc/armbian-image-release ]] && source /etc/armbian-image-release

echo "Boardid: $INSTALLATION_UUID " | tee /tmp/output.file
echo "Uptime: $(uptime -p)" | tee -a /tmp/output.file
echo "Kernel: $(uname -rv)" | tee -a /tmp/output.file
echo "$speed" | tee -a /tmp/output.file
echo "Gateway: "$(curl -s ipinfo.io/ip) | tee -a /tmp/output.file
echo "Phy: "$(curl -s ipinfo.io/loc) | tee -a /tmp/output.file
echo "Temperature: $board_temp °C" | tee -a /tmp/output.file
echo "Bye" | tee -a /tmp/output.file

# send to server
cat /tmp/output.file >/dev/udp/${SERVER_IP}/${SERVER_PORT}