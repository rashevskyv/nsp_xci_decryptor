import os
from binascii import hexlify

d=os.getenv("tempdir")
path = d + "/title.tik"
f=open(path,"rb")
f.seek(0x180)
temp=f.read(16)

path = d + ".txt"
f=open(path,"wb")
text=hexlify(temp)
f.write(text)
f.close()
