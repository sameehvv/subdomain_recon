#!/bin/bash

if [ "$1" == "" ]
then
    echo "$0 example.com"
else

    url=$1
    mkdir $url

    #gathering the subdomains
    echo "[+]Gathering subdomains using assetfinder"
    assetfinder -subs-only $url >> subs.txt
    echo "Done"

    echo "[+]Gathering subdomains using subfinder"
    subfinder -d $url -silent >> subs.txt
    echo "Done"

    echo "[+]Gathering subdomains using amass"
    amass enum -passive -d $url -src | cut -d']' -f 2 | awk '{print $1}' >> subs.txt
    amass enum -d $url | cut -d']' -f 2 | awk '{print $1}' >> subs.txt

    #altdns
    echo $url > altdns_domain.txt
    altdns -i altdns_domain.txt -w /home/sameeh/Desktop/work/subdomain_enum/words.txt -o altdns_domain_output.txt

    #sorting the domains
    echo "[+]Sorting domains"
    cat subs.txt altdns_domain_output.txt | sort -u | tee -a $url/unique_domains.txt

    echo "Done"
    echo -e "\n[+]Found $(cat $url/unique_domains.txt | wc -l) subdomains"


    #resolving IP
    echo "[+]Resolving IP using dnsx"
    cat $url/unique_domains.txt | dnsx -silent -a -cname -resp >> $url/dnsx_resolved.txt

    #finding valid url
    echo "[+]Finding valid url using httpx"
    cat $url/unique_domains.txt | httpx --silent >> $url/httpx_output.txt

    #remove unwanted files
    rm subs.txt altdns_domain_output.txt altdns_domain.txt
fi
