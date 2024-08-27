import threading
import sys, math
import socket, ftplib
import random
import pickle ###serialize shit/ or make it kill itself before it gets too big a buffer
import time
import requests
print("     ______                       ")
print("    / ____/  ____ ___  ____ _____ ")
print("   / __/    / __ `__ \/ __ `/ __ \ ")
print("  / /___   / / / / / / /_/ / /_/ /")
print(" /_____/  /_/ /_/ /_/\__,_/ .___/ ")
print("                         /_/      ")
#print("\n")
print("     github/00xZ - Eyezik")
#print("\n")
#print (" [+] use: emap.py [Port] [Threads] [Output] [Amount of IP's  to find] \n")
count = 0


port = int(sys.argv[1])
amount2scan = int(sys.argv[4])
if len(sys.argv) > 2:
    threads = str(sys.argv[2])
else:
    threads = (50)


if len(sys.argv) > 3:
    ipf=open((sys.argv[3]), 'w')
    ipf.write('')
    ipf.close()
    output_list = (sys.argv[3])
else:
    ipf=open('list.txt', 'w')
    ipf.write('')
    ipf.close()
    output_list = ("list.txt")


user_agents = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148',
        'Mozilla/5.0 (Linux; Android 11; SM-G960U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Mobile Safari/537.36'
]
def yadigg():
    global running
    running = (0)
#    for x in range(50):
    while running < amount2scan: #lazy mans thread killing by making tog switch/doesnt need on linux but the windows is fucky
            p=random.randint(1,254)
            q=random.randint(1,254)
            r=random.randint(1,254)
            s=random.randint(1,254)
            #global running
            ip=str(p) + "." +str(q) + "." +str(r) + "." +str(s)
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(1.5)
                result = sock.connect((ip, port))
                try:
                    print (" [x] : " + ip )
                    ipf=open(output_list, 'a')
                    ipf.write(ip +  '\n')
                    ipf.close()
                    running = running + 1
                    try:
                        user_agent = random.choice(user_agents)
                        headers = {'User-Agent': user_agent}
                        site = ("https://" + ip)
                        r = requests.get(site, timeout=10, verify=True, headers=headers)
                        print("   [+] WebServer Found: " + site)
                        open_site=open('site.txt', 'a')
                        open_site.write(site +  '\n')
                        open_site.close()
                        soup = BeautifulSoup(r.content, 'lxml')
                        title = (soup.select_one('title').text)
                        print("     [!] WebServer Title: " + site + " [-] " + title + " [!]")
                        fotitle = open("output_with_title.txt", "a+")
                        fotitle.write(site + " ___ " + title +  "\n")
                        fotitle.close
                    except Exception:
                        dns, alias, addresslist = socket.gethostbyaddr(ip)
                        dns.replace("'", '')
                        #print(dns)
                        try:
                            dns_site = ("https://" + dns)
                            r2 = requests.get(dns_site, timeout=10, verify=True, headers=headers)
                            print("   [+] DNS Found WebServer: " + dns_site)
                            open_dns=open('dns.txt', 'a+')
                            open_dns.write(dns_site +  '\n')
                            open_dns.close()
                            soupy = BeautifulSoup(r2.content, 'lxml')
                            titley = (soup.select_one('title').text)
                            print("     [!] DNS Serv. : " + dns_site + " [-] Title: " + titley + " [-] \n")
                            open_dns_title=open('dns_title.txt', 'a+')
                            open_dns_title.write(dns_site + " ___ " + titley +  "\n")
                            open_dns_title.close()
                        except Exception:
                            pass
                except Exception:
                    pass
            except Exception:
                pass
for threads in range(0, int(threads)):
        try:
                count = count + 1
                t = threading.Thread(target=yadigg)
                #t.daemon=True
                t.start()
        except:
                print('Thread failed: ' + str(count))
#print('Threads: ' + str(count))
#print('Output: ' + output_list)
print('[ /Port: ' + str(port) + ' /Amount: ' + str(amount2scan) +' /Threads: ' + str(count) + ' /Output: ' + output_list+ ' ] \n')
#print('Amount: ' + str(amount2scan) + '\n')
