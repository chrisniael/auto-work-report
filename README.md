# 预防漏写日报工具

这个脚本主要的逻辑是：自动登录日报系统，检查今天是否已经提交日报，如果没有，则去离今天最近且提交过日报的一天，把这一天提交的日报内容作为今天的日报内容提交上去。

要使用这个脚本的功能，只需要配置定时任务，让其每天定时定时执行就好。

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
