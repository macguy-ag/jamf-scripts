#!/usr/bin/python

import httplib
conn = http.client.HTTPSConnection("https://jss.thebernardgroup.com")


headers = {
'authorization': "Basic <removedcreds>"
}


conn.request("GET", "/JSSResource/computers/id/8", headers=headers)


res = conn.getresponse()
data = res.read()


print(data.decode("utf-8"))
