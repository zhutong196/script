#!/bin/python
# 2019-07-01
# zhutongcloud
import requests,json,time
url_quizii = {"公网xxx":['http://www.xxx.com/xxx/login',{'j_username': 'xxxx' , 'j_password': 'xxxxxxx'},'http://www.quizii.com/quizii/student#profile']}
def wechat(data):
  url='https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=xxxxxxxxxxxxxxxxxxx&corpsecret=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  #url='https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=xxxxxxxxxxxxxxxxxx&corpsecret=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  access_token1=requests.get(url)
  request_json = access_token1.json()
  access_token = request_json['access_token']
  send_message_url='https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=%s'%(access_token)
  me = {"touser":'@all',"msgtype":"text", "agentid":1000004,"text":{ "content":data},"safe":0}
  fs=requests.post(send_message_url,data=json.dumps(me))
class Login(object):
    def __init__(self,url,data,urll):
        self.session=requests.Session()
        self.url=url
        self.urll=urll
        self.data=data
    def quizii_login(self):
        headers = {'user-agent':'Mozilla/5.0'}
        response = self.session.post(url=self.url, headers=headers, data=self.data)
        response = self.session.get(url=self.urll, headers=headers)
        a=response.content.decode('utf-8')
        a=a.find('词汇记忆')
        return (a)
def main():
  ls=[]
  current_time = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
  ls.append ("===英语quizii登陆检查=== " )
  ls.append ("检查时间: %s" %current_time )
  for i in url_quizii:
    try:  
      session = {}
      login_test = Login(url_quizii[i][0],url_quizii[i][1],url_quizii[i][2])  
      c=login_test.quizii_login()
    except Exception as e:
      ls.append ("%s:  Error" % i)
      continue
    if c != -1:
      ls.append ("%s:  OK" % i)
    else:
      num = 0
      while num < 5:
        login_test = Login(url_quizii[i][0],url_quizii[i][1],url_quizii[i][2])                                                                                        
        c=login_test.quizii_login()                                                                                                                                   
        if c != -1:
          out = "OK"                                                                                                                                                   
          break
        else:
          num +=1
          out = "Error"
      ls.append ("%s:  %s(%s次检查结果)" %(i,out,num))
  status = '\n'.join(ls)
  print (status)
  wechat(data=status)
if __name__=='__main__':
  main()
