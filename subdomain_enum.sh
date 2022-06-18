#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'


function help(){
	# echo "Unknown argument: $1"
	echo "[+]Usage:"
	echo "$0 -d domain"
	echo "$0 --domain domain"		
	echo "$0 -f targets.txt"
	echo "$0 --file targets.txt"
}

function make_dir(){
    mkdir $domain
}

function all_subdomain_enum(){
    #gathering the subdomains
    echo -e "\n[+]Gathering subdomains using assetfinder"
    assetfinder -subs-only $domain >> subs.txt
    echo "[+]Done"

    echo -e "\n[+]Gathering subdomains using subfinder"
    subfinder -d $domain -silent >> subs.txt
    echo "[+]Done"

    echo -e "\n[+]Gathering subdomains using amass"
    amass enum -passive -d $domain -src | cut -d']' -f 2 | awk '{print $1}' >> subs.txt
    amass enum -d $domain | cut -d']' -f 2 | awk '{print $1}' >> subs.txt
    echo "[+]Done"

    #altdns
    echo -e "\n[+]Gathering subdomains using altdns"
    echo $domain > altdns_domain.txt
    altdns -i altdns_domain.txt -w /home/sameeh/toolkit/altdns/words.txt -o altdns_domain_output.txt
    echo "[+]Done"

    #sorting the domains
    echo -e "\n[+]Sorting domains"
    cat subs.txt altdns_domain_output.txt | sort -u | tee -a $domain/unique_domains.txt
    echo "[+]Done"

    echo -e "\n[+]Found $(cat $domain/unique_domains.txt | wc -l) subdomains"
}


function resolving_IP(){
    echo -e "\n[+]Resolving IP using dnsx"
    cat $domain/unique_domains.txt | dnsx -silent -a -cname -resp >> $domain/dnsx_resolved.txt
}

function valid_url(){
	echo -e "\n[+]Finding valid url using httpx"
    cat $domain/unique_domains.txt | httpx --silent >> $domain/httpx_output.txt
}


function rm_file(){
	#removing unwanted files
	rm subs.txt altdns_domain_output.txt altdns_domain.txt
}
    

function funcs(){
	make_dir
	all_subdomain_enum
	resolving_IP
	valid_url
	rm_file
}


case "$1" in
	'-d'|'--domain')
		echo -e "${RED}\n[+]Domain :-${NC} $2"
		domain=$2
		funcs
		;;

	'-f'|'--file')
		echo -e "\n[+]Fetching domains list from $2"
		file=$2
		for domain in $(cat $file); do
			echo -e "${RED}\n[+]Domain :-${NC} $domain"
			funcs
		done
		;;

	'-h'|'--help')
		help
		;;

	*)
		help
		;;

esac

