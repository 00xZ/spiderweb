#!/bin/bash
## colors
BOLD="\e[1m"
CYAN='\033[0;36m'
RED='\033[0;31m'
black='\033[0;30m'
green='\033[0;32m'
yellow='\033[0;33m'
magenta='\033[0;35m'
NC='\033[0m' # No Color

main_loop() {
    #trap ":" INT 
    while true
    do
            echo -e "\n$RED${BOLD} [!] Scanning The Web [!]${NC}$CYAN"
            python3 emap.py 80 15 ips.txt
            echo -e "$RED${BOLD} 10 Sec Sleep : needed for gdn "
            sec=10
            while [ $sec -ge 0 ]; do
                echo -ne "Time: $sec\033[0K\r"
                let "sec=sec-1"
                sleep 1
            done
            echo -e "$magenta${BOLD} [x] Pulling domains [x]${NC}$green${BOLD}"
            cat ips.txt | gdn |awk '{print $2}' | tee output/targets.txt
            #cat output/targets.txt | sort -u | uniq | tee output/targets.txt
            echo -e "$yellow[+] Grabbing info[+] ${NC}$magenta"
            cat output/targets.txt | anew output/raw_db.txt
            cat output/targets.txt | httpx -sc -title | anew output/database.txt
            cat ips.txt | httpx -sc -title | anew output/ip_database.txt
            echo -e "$magenta$ [+] Parsing [+] "
            cat output/database.txt | grep "200" | awk '{print $1}' | anew all.txt
            rm ips.txt
            echo -e  "$green${BOLD} [+] Spidering [+] ${NC}"
            cat output/targets.txt | httpx -silent | katana | tee spider/spidered.txt
            echo -e "$green${BOLD} [+] Parsing xss [+] "
            cat spider/spidered.txt | gf xss > spider/xss.txt
            cat spider/spidered.txt | anew spider/all_spidered.txt
            echo -e "$RED${BOLD} [+] GXSS [+] "
            (trap - INT; cat spider/xss.txt | gxss > spider/live-gxss.txt)
            cat spider/live-gxss.txt | anew spider/gxss.txt
            (trap - INT; cat spider/live-gxss.txt | trashcompactor > spider/live_xss.txt)
            cat spider/live_xss.txt | anew spider/swdalfox_db.txt
            xss_scan
            #(trap - INT; cat spider/live_xss.txt | dalfox pipe | anew Vuln_xss.txt)
            #rm target.txt
            #killall gdn
            echo " [!] LOOP [!] "
    done
}
xss_scan() {

        cat spider/live_xss.txt | dalfox pipe | anew Vuln_xss.txt
        main_loop

}
help() {
    echo -e "$CYAN${BOLD}Usage:${NC}"
    echo -e "${BOLD}    -help            Shows the help menu${NC}"
    echo -e "$magenta${BOLD}    -scan           Loop[emap/find webservers|katana/spider|gf/parse${NC}"
    echo -e "$RED${BOLD}    -xss           Scan the database for XSS(dalfox)${NC}"
    echo -e "$magenta${BOLD} ____________________________________________________${NC}"
    exit 0
}

if [ "$1" == "-scan" ]; then
    main_loop
elif [ "$1" == "-xss" ]; then
    xss_scan
else
    echo -e "${RED}Unknown option: $1 ${NC}"
    help
fi
