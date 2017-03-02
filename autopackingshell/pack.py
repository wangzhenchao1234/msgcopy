#coding:utf-8
'''
    手工打包
'''
import json
import os,sys
import sys
reload(sys)
sys.setdefaultencoding('utf8')
def ret (x):
    return x

basedir = '/Users/gavin/Documents/dev/kaoke_client_ios/autopackingshell'
if __name__ == "__main__":
    print len(sys.argv)
    if len(sys.argv) <=1:
        print 'argv must be than 0'
        exit(0)

    jf = file(os.path.join(basedir,'%s.json'%sys.argv[1]))
    j = json.load(jf)

#排序

    jj=[(k,j[k]) for k in sorted(j.keys())]

#遍历
    v = [v1 and v1 or 'null' for k1,v1 in jj]

    print ' '.join(v)
    os.system(u'%s %s'%(os.path.join(basedir,'main.sh'),u' '.join(v)))

