#!/bin/python
# 2019-07-01
# jiangnan
import requests,json,time
url_mem={'公网xxx':'http://xxx.com/Mintel/servlet/getUserRecord?userId=demo'}
def wechat(data):
	url='https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=xxx&corpsecret=xxx'
	#url='https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=xxx&corpsecret=xxx'
	access_token1=requests.get(url)
	request_json = access_token1.json()
	access_token = request_json['access_token']
	send_message_url='https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=%s'%(access_token)
	me = {"touser":'@all',"msgtype":"text", "agentid":1000004,"text":{ "content":data},"safe":0}
	fs=requests.post(send_message_url,data=json.dumps(me))
def main():
	ls=[]
	current_time = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
	ls.append("===英语记忆登陆检查===")
	ls.append("检查时间:%s" %current_time )
	for  url in url_mem:
		if url != '用户中心':
			try:
				r = requests.get(url_mem[url], timeout=5)
				a=r.text.find('新标准高中必修1(2007)')
			except Exception as e:
				ls.append('%s:  Error' %url)
				continue
			if a != -1:
				ls.append('%s:  OK' %url)
			else:
				ls.append('%s:  Error' %url)
		else:
			try:
				r = requests.get(url_mem[url], timeout=5)
				a=r.text.find('用户中心欢迎你')
			except Exception as e:
				ls.append ('%s:  Error' %url)
				continue
			if a != -1:
				ls.append('%s:  OK' %url)
			else:
				ls.append('%s:  Error' %url)
	status='\n'.join(ls)
	print (status)
	wechat(data=status)

if __name__=='__main__':
	main()
