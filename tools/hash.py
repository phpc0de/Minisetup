import os

for filename in os.listdir("/root/oneinstack/src/"):
    hashc = os.system('sha256sum '+ filename)
    with open("hash.txt","a+") as f:
        f.write(filename+":::"+str(hashc))
    with open("hashbak.txt","a+") as f:
        f.write(filename+":::"+str(hashc))
