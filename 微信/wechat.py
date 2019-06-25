
[root@master server_script]# cat wechat2.py.bak 
#!/bin/python 
import urllib,urllib2,json
import sys
params = {'corpid':'wwe0e6037b5802540a', 'corpsecret':'DeM0To1x1ZuMSdhk8griJnIeZDrlurUOZv-ePPS7cPH'}
data = urllib.urlencode(params)
url = 'https://qyapi.weixin.qq.com/cgi-bin' + '/' + 'gettoken?'
response = urllib2.Request(url + data)
result = urllib2.urlopen(response)
content = json.loads(result.read()) #将json格式转化为python的字典
access_token = content['access_token']  #获取key为access_token的值 即token
url01 = 'https://qyapi.weixin.qq.com/cgi-bin' + '/' + 'message/send?access_token=%s' % access_token #拼接出带token的链接
message01 = json.dumps({'touser':sys.argv[1],'toparty':1,'msgtype':"text",'agentid':"1000004",
        'text':{'content':sys.argv[2]},'safe':"0"})
request = urllib2.Request(url01,message01) #发送消息
result = urllib2.urlopen(request)
debug = json.loads(result.read())
print (debug)
result.close()


[root@master server_script]# python wechat2.py.bak  ZhuTongTong 1113235
