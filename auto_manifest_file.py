import os
import hashlib
import time
#1cd033c84fe9a6c34659a81a4685f4c2
#20e7bb4a3343ab96c399cc5a70e7c4fe
def getFileMd5(filename):
    if not os.path.isfile(filename):
        return
    myhash = hashlib.md5()# create a md5 object
    f = file(filename,'rb')
    while True:
        b = f.read(8096)# get file content.
        if not b :
            break
        myhash.update(b)#encrypt the file
    f.close()
    return myhash.hexdigest()

def getAssetsMd5(path, prefix):
    global xml
    fl = os.listdir(path) # get what we have in the dir.
    for f in fl:
        if os.path.isdir(os.path.join(path,f)): # if is a dir.
            if prefix == '':
                getAssetsMd5(os.path.join(path,f), f)
            else:
                getAssetsMd5(os.path.join(path,f), prefix + '/' + f)
        else:
            md5 = getFileMd5(os.path.join(path,f))
            xml += "\n\t\t\"%s\" : {\n\t\t\t\"md5\" : \"%s\"\n\t\t}, " % (prefix + '/' + f, md5) # output to the md5 value to a string in xml format.
if __name__ == "__main__": 
    timeStr = time.strftime("%Y%m%d%H%M%S",time.localtime(time.time()))
    # if not os.path.exists(os.getcwd() + '\\manifest'):
    #     os.mkdir(os.getcwd() + '\\manifest')
    #generate project.manifest
    xml = '{\
    \n\t"packageUrl" : "http://192.168.10.202:8088/",\
    \n\t"remoteVersionUrl" : "http://192.168.10.202:8088/version.manifest",\
    \n\t"remoteManifestUrl" : "http://192.168.10.202:8088/project.manifest",\
    \n\t"version" : "0.0.%s",\
    \n\t"engineVersion" : "Cocos2d-x v3.x",\
    \n\n\t"assets" : {' % timeStr
    getAssetsMd5(os.getcwd() + '/../src', 'src')
    getAssetsMd5(os.getcwd() + '/../res', 'res')
    xml = xml[:-2]
    xml += '\n\t},\
    \n\t"searchPaths" : [\
    \n\t]\
    \n}'
    f = file("project.manifest", "w+")
    f.write(xml)
    print 'generate version.manifest finish.'
    #generate version.manifest
    xml = '{\
    \n\t"packageUrl" : "http://192.168.10.202:8088/",\
    \n\t"remoteVersionUrl" : "http://192.168.10.202:8088/version.manifest",\
    \n\t"remoteManifestUrl" : "http://192.168.10.202:8088/project.manifest",\
    \n\t"version" : "0.0.%s",\
    \n\t"engineVersion" : "Cocos2d-x v3.x"\n}' % timeStr
    f = file("version.manifest", "w+")
    f.write(xml)
    print 'generate version.manifest finish.'
