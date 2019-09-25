[root@ftp ~]# cat python.sh 
#!/bin/python3
import requests,json,sys
def weather(city):
  url="https://www.apiopen.top/weatherApi?city=%s" %city
  text=requests.get(url)
  a=text.content
  b=json.loads(a)
  ls=[]
  ls.append(city)
  c=b.get("data").get("forecast")[0]
  for i in c.values():
    ls.append(i)
  ls.append(b.get("data").get("ganmao"))
  del ls[3]
  return ls
def main(city):
  print(weather(city))
main(city=sys.argv[1])

[root@ftp ~]# python3 python.sh 北京
['北京', '25日星期三', '高温 31℃', '低温 15℃', '南风', '晴', '各项气象条件适宜，发生感冒机率较低。但请避免长期处于空调房间中，以防感冒。']

###此脚本必须使用python3 执行，因为涉及到编码问题，2会出现乱码，解码不成功

