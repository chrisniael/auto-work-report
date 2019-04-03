EMAIL=shenyu.tommy@shandagames.com
PASSWD=sy.123

# login
# get today report
# if not exist then post

cookie_file=$(mktemp)
echo "[info] temp file, name=$cookie_file"

# Open login page
csrf_token=$(curl -s --cookie-jar $cookie_file --request GET \
  --url http://61.152.101.39/login | grep "csrf-token" \
  | awk -F '"' '{print $4}')

echo "[trace] csrf_token=$csrf_token"

# Request login
curl -s -b $cookie_file --cookie-jar $cookie_file --request POST \
  --url http://61.152.101.39/login \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data "email=${EMAIL}&password=${PASSWD}&_token=${csrf_token}" \
  | grep "home" > /dev/null

if [ $? -ne 0 ]
then
  echo "[error] login failed!"
  exit 1
fi

echo "[info] login success."

# Get today date 
date_str=$(date +%Y-%m-%d)

# 星期几，1 代表星期一
weekday_n=$(date +%u)
echo "[info] today, date=$date_str, weekday_n=$weekday_n"

if [ $weekday_n -ge 6 ]
then
  echo "[info] today is weekend, don't need work report."
  exit 0
fi

# Get today report content
get_res=$(curl -s -b $cookie_file --cookie-jar $cookie_file --request GET \
  --url http://61.152.101.39/home?day=${date_str} | grep "内容")
get_res=${get_res#*内容\">}
today_report_content=$(echo ${get_res%</textarea>} | awk '{$1=$1;print}')
echo "[info] today report, date=$date_str, content=$today_report_content, size=${#today_report_content}"

if [ ${#today_report_content} -ge 0 ]
then
  echo "[warning] today has written the work report, don't need report again."
  exit 0
fi

# Get report content in the past
today_report_content="11"
yesterday_date_str=$date_str
for i in {1..7}
do
  yesterday_timestamp=$(date +%s -d "${yesterday_date_str}")
  yesterday_timestamp=$((yesterday_timestamp-24*60*60))
  yesterday_date_str=$(date +%Y-%m-%d -d @${yesterday_timestamp})
  get_res=$(curl -s -b $cookie_file --cookie-jar $cookie_file --request GET \
    --url http://61.152.101.39/home?day=${yesterday_date_str} | grep "内容")
  get_res=${get_res#*内容\">}
  past_report_content=$(echo ${get_res%</textarea>} | awk '{$1=$1;print}')
  if [ ${#past_report_content} -ge 0 ]
  then
    echo "[info] find past report, date_str=${yesterday_date_str}, content=$past_report_content, size=${#past_report_content}"
    today_report_content=${past_report_content}
    break
  fi
done

# Visit home page
csrf_token=$(curl -s -b $cookie_file --cookie-jar $cookie_file \
  --request GET \
  --url http://61.152.101.39/home | grep "csrf-token" \
  | awk -F '"' '{print $4}')

echo "[trace] csrf_token=$csrf_token"

# Post report
curl -s -b $cookie_file --cookie-jar $cookie_file --request POST \
  --url http://61.152.101.39/service/note/save \
  --header "X-CSRF-TOKEN: ${csrf_token}" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data "day=${date_str}&content=${today_report_content}" | grep "return_message\":\"success" > /dev/null

if [ $? -eq 0 ]
then
  echo "[info] writ work report success, date=$date_str, content=$today_report_content"
else
  echo "[error] writ work report failed, date=$date_str"
fi

# Remove temp file
rm -rf $cookie_file
