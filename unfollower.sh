# Unfollower v1.0
# Author: https://github.com/thelinuxchoice/unfollower

printf "\e[1;93m  _   _        __       _ _                         \n"
printf " | | | |_ __  / _| ___ | | | _____      _____ _ __  \n"
printf " | | | | '_ \| |_ / _ \| | |/ _ \ \ /\ / / _ \ '__| \n"
printf " | |_| | | | |  _| (_) | | | (_) \ V  V /  __/ |    \n"
printf "  \___/|_| |_|_|  \___/|_|_|\___/ \_/\_/ \___|_|    \e[0m\n\n"
printf "    \e[1;77mInstagram Unfollower, v1.0 by @linux_choice\e[0m\n\n"
                                                   

csrftoken=$(curl https://www.instagram.com/accounts/login/ajax -L -i -s | grep "csrftoken" | cut -d "=" -f2 | cut -d ";" -f1)
unfollow() {

while [ true ]; do

printf "\e[1;77m[+] Creating followers list\e[0m\n" 
curl -s -b cookies.txt 'https://www.instagram.com/'$username'/following' -L > following_request.txt
grep -o '"id":"[0-9]\{10\}"' following_request.txt | cut -d '"' -f4 > following_id

for line in $(cat following_id); do
printf "\e[1;77m[*] Trying to unfollow user id:\e[0m\e[1;93m %s\e[0m\n" $line

{( trap '' SIGINT && unfollow=$(curl -b cookies.txt -H 'Cookie: csrftoken='$csrftoken'' -H 'X-Instagram-AJAX: 1' -H 'Referer: https://www.instagram.com/' -H 'X-CSRFToken:'$csrftoken'' -H 'X-Requested-With: XMLHttpRequest' "https://www.instagram.com/web/friendships/$line/unfollow/" -s -L --request POST | grep -o '"status": "ok"'); if [[ "$unfollow" == *'"status": "ok"'* ]]; then printf "\e[1;92m[*] User unfollowed. Sleeping 10 sec...\e[0m\n" ; sleep 10 ; else printf "\e[1;93m[!] User not unfollowed. Sleeping 5min\e[0m\n" ; sleep 300 ; fi )} & wait $!;

done
done
}


login_user() {

IFS=$'\n'
default_username=""
default_password=""

if [[ "$default_username" == "" ]]; then
read -p $'\e[1;92m[*] Username: \e[0m' username
else
username="${username:-${default_username}}"
fi

if [[ "$default_password" == "" ]]; then
read -s -p $'\e[1;92m[*] Password: \e[0m' password
else
password="${password:-${default_password}}"
fi

printf "\e[\n1;77m[*] Trying to login as\e[0m\e[1;77m %s\e[0m\n" $username
check_login=$(curl  -c cookies.txt 'https://www.instagram.com/accounts/login/ajax/' -H 'Cookie: csrftoken='$csrftoken'' -H 'X-Instagram-AJAX: 1' -H 'Referer: https://www.instagram.com/' -H 'X-CSRFToken:'$csrftoken'' -H 'X-Requested-With: XMLHttpRequest' --data 'username='$username'&password='$password'&intent' -L --compressed -s | grep -o '"authenticated": true')

if [[ "$check_login" == *'"authenticated": true'* ]]; then
printf "\e[1;92m[*] Login Successful!\e[0m\n"

unfollow

else
printf "\e[1;93m[!] Check your login data or IP! Dont use Tor, VPN, Proxy. It's requires your usual IP.\n\e[0m"
exit 1
fi

}
login_user
