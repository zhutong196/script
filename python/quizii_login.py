#!/bin/python
# 2019-07-01
# jiangnan
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
	for a in ls:
		if a[-5:] == 'Error':
			b = a.split(":")[0]
			num = 0
			while num < 5:
				try:
					session = {}
					login_test = Login(url_quizii[b][0],url_quizii[b][1],url_quizii[b][2])
					c = login_test.quizii_login()
					if c != -1:
						out = "OK"
						break
				except Exception as e:
					num +=1
					time.sleep (5)
					out ="Error"
			f="%s: %s(%s次检查结果)"  %(b,out,num)
			suoyin= ls.index(a)
			ls[suoyin]=f
		else:
			pass
	current_time = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
	ls1=[]
	ls1.append ("===英语quizii登陆检查=== " )
	ls1.append ("检查时间: %s" %current_time )
	ls1.extend(ls)
	status = '\n'.join(ls1)
	print(status)
	wechat(data=status)
if __name__=='__main__':
	main()
