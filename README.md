# 自动写日报工具

## 下载脚本

```bash
git clone http://gitlab.corp.sdo.com/shenyu.tommy/auto-work-report.git
cp auto-work-report/auto-work-report.sh /usr/local/bin/
chmod a+x /usr/local/bin/auto-work-report.sh
```

## 配置账号密码

```bash
# auto-work-report.sh
EMAIL=<your-eamil>
PASSWD=<your-password>
```

## Linux 定时事件配置

```bash
su -
crontab -e
```

这里配置为每天晚上7点检查一遍

```cfg
0 7 * * * /usr/local/bin/auto-work-report.sh
```
