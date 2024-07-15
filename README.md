### Scan the whole internet for XSS

# webspider.sh -scan

### Whats it do

Its generates random IP's and checks them for a webserver, once found it uses GDN to grab a domain from that server. Its next step is to check if its alive and if so it will spider it. Once spidered will use GF/patterns to pull all likely xss urls. runs through gxss(check for reflection) trashcompactor(clean things up).

Dalfox is the main tool for the XSS scanning but could use other like knoxss/XSStrike. 

The output folder keeps a log of all sites scanned/ip's plus titles of sites from httpx. the main dir has the all.txt which is the full raw database.

In spider directory youll find the full history database of all the sites spidered(all_spidered.txt), along with (spidered.txt) the most recent scan. Will have a live-gxss.txt which is the most recent gxss scan, along with gxss.txt as a historical database

### Why

Ive love finding random website and checking out whats under the hood and this is what ive made it for. The XSS testing is just a PoC to show what could be done but I encourage you to get creative with this. Though about making my own "google" be able to quire through all the scans but showdan got me beat though haha.

### Install

python3.9

https://github.com/kmskrishna/gdn (backbone of this framework)

https://github.com/projectdiscovery/httpx

https://github.com/tomnomnom/gf with https://github.com/1ndianl33t/Gf-Patterns

https://github.com/hahwul/dalfox

https://github.com/tomnomnom/anew
