EMAIL=shenyu.tommy@shandagames.com
PASSWD=sy.123

csrf_token=$(curl -s --cookie-jar cookies.tmp --request GET \
  --url http://61.152.101.39/login | grep "csrf-token" | awk -F '"' '{print $4}')

echo $csrf_token

curl -s -b cookies.tmp --cookie-jar cookies.tmp --request POST \
  --url http://61.152.101.39/login \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data "email=${EMAIL}&password=${PASSWD}&_token=${csrf_token}" > /dev/null

csrf_token=$(curl -s -b cookies.tmp --cookie-jar cookies.tmp --request GET \
  --url http://61.152.101.39/home | grep "csrf-token" | awk -F '"' '{print $4}')

echo $csrf_token

curl -s -b cookies.tmp --cookie-jar cookies.tmp --request POST \
  --url http://61.152.101.39/service/note/save \
  --header "X-CSRF-TOKEN: ${csrf_token}" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data "day=2019-04-03&content=aaa"

echo

curl -s -b cookies.tmp --cookie-jar cookies.tmp --request GET \
  --url http://61.152.101.39/home?day=2019-04-02 | grep "内容"

rm -rf cookies.tmp
