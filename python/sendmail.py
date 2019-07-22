#!/bin/python
# 2019-07-01
# jiangnan
import yagmail
yag = yagmail.SMTP(
      user='zhutongcloud@163.com',
      password='授权码',
      host='smtp.163.com',
      port='25',
      smtp_ssl=False)
yag.send(to='924316049@qq.com',
      subject='hello lisi',
      contents='this is a importment mail')
