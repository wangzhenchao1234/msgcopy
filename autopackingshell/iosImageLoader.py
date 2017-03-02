# -*- coding: utf-8 -*-
#!/usr/bin/env python

import os
import sys
import urllib2
import sys
try:
    from PIL import Image, ImageDraw, ImageFont
except:
    import Image, ImageDraw, ImageFont
from msgImage import resizeImg , clipResizeImg , waterMark

orderdir=""

def DownLoadFile(url, path):
    socket = urllib2.urlopen(url)
    data = socket.read()
    with open(path, "wb") as jpg:
        jpg.write(data)
        socket.close()
            
def CreatIosSplash(imgPath):
    ori_img = imgPath
    splash_background="%s/msgcopy/Images.xcassets/LaunchImage.launchimage/Default-568h@2x.png"%(orderdir)
    hsplash_background="%s/msgcopy/Images.xcassets/LaunchImage.launchimage/Default@2x.png"%(orderdir)
    ip6splash_background="%s/msgcopy/Images.xcassets/LaunchImage.launchimage/Default-ip6.png"%(orderdir)
    ip6plsplash_background="%s/msgcopy/Images.xcassets/LaunchImage.launchimage/Default-568h@3x.png"%(orderdir)
    
    #splash_background_filename = ori_img.split('/')[-1]
    #if splash_background_filename.lower()!="png":
    #im = Image.open(ori_img)
    
    h_w=640
    h_h=1136
    
    l_w=640
    l_h=960
    
    ip6_w=750
    ip6_h=1334
    
    ip6pl_w=1242
    ip6pl_h=2208
    
    save_q = 30
    
    clipResizeImg(ori_img=ori_img,dst_img = splash_background, dst_w =h_w,dst_h=h_h ,save_q = save_q)
    clipResizeImg(ori_img=ori_img,dst_img = hsplash_background, dst_w =l_w,dst_h=l_h ,save_q = save_q)
    
    clipResizeImg(ori_img=ori_img,dst_img = ip6splash_background, dst_w =ip6_w,dst_h=ip6_h ,save_q = 40)
    clipResizeImg(ori_img=ori_img,dst_img = ip6plsplash_background, dst_w =ip6pl_w,dst_h=ip6pl_h ,save_q = 30)


    #im.save(splash_background)
    #im.save(hsplash_background)
            
def CreatIosImags(imgPath):
    ori_img = imgPath
    
    icon_120_local = "%s/Resource/icon@2x.png"%(orderdir)
    icon_120 = "%s/msgcopy/Images.xcassets/AppIcon.appiconset/icon-120.png"%(orderdir)
    icon_small_58 = "%s/msgcopy/Images.xcassets/AppIcon.appiconset/icon-small@2x.png"%(orderdir)
    icon_small_80 = "%s/msgcopy/Images.xcassets/AppIcon.appiconset/icon-small-80.png"%(orderdir)
    
    icon2xsize = 120
    iconsmall2xsize = 58
    iconsmall80size = 80
    
    save_q = 80
    
    clipResizeImg(ori_img = ori_img, dst_img = icon_120_local , dst_w =icon2xsize ,dst_h = icon2xsize ,save_q = save_q)
    clipResizeImg(ori_img = ori_img, dst_img = icon_120 , dst_w =icon2xsize ,dst_h = icon2xsize ,save_q = save_q)
    clipResizeImg(ori_img = ori_img, dst_img = icon_small_58 , dst_w =iconsmall2xsize ,dst_h = iconsmall2xsize ,save_q = save_q)
    clipResizeImg(ori_img = ori_img, dst_img = icon_small_80 , dst_w =iconsmall80size ,dst_h = iconsmall80size ,save_q = save_q)


def CreatTextImg(str=u'你好',bgcolor=(0,0,0,0),fgcolor=(268,40,46),rect=(100,100)):
    txt = str
    font = ImageFont.truetype('/Library/Fonts/Lantinghei.ttc',24,1)
    im = Image.new("RGBA",rect,bgcolor)
    draw = ImageDraw.Draw(im)
    #draw.text( (0,50), u'你好,世界!', font=font)
    draw.text( (0,0), unicode(txt,'UTF-8'),fill=fgcolor, font=font)
    del draw
    return im

def CreateAndroidHelpImage(imgPath, idx):
    path = "%s/Resource/welcome/welcome_%s.png" % (os.getcwd(), idx)
    try:
        DownLoadFile(imgPath, path)
    except:
        print('error')
        exit()

if __name__ == "__main__":
    ic_launcher= sys.argv[1]
    splash_img=sys.argv[2]
    orderdir="%s/"%(os.getcwd())
    ic_title=sys.argv[4]
    appname=sys.argv[5]
    h_img_0 = sys.argv[6]
    h_img_1 = sys.argv[7]
    h_img_2 = sys.argv[8]
    h_img_3 = sys.argv[9]
    h_img_4 = sys.argv[10]
    help_img_idx = 0
    
    print "ic_launcher==%s"%ic_launcher
    print "splash_img==%s"%splash_img
    print "orderdir==%s"%orderdir
    print "ic_title==%s"%ic_title
    
    welcome_dir   = "%s/Resource/welcome" % (os.getcwd())
    print welcome_dir
    
    bundle_dir = "rm -rf %s.bundle"%welcome_dir
    print bundle_dir
    os.system(bundle_dir)
    os.mkdir(welcome_dir)
    
    if h_img_0 != "http://a.png/" and h_img_0 !='null':
        try:
            CreateAndroidHelpImage(h_img_0, help_img_idx)
            help_img_idx += 1
        except:
            print('error')
            exit()
    if h_img_1 != "http://a.png/" and h_img_1 !='null':
        try:
            CreateAndroidHelpImage(h_img_1, help_img_idx)
            help_img_idx += 1
        except:
            print('error')
            exit()
    if h_img_2 != "http://a.png/" and h_img_2 !='null':
        try:
            CreateAndroidHelpImage(h_img_2, help_img_idx)
            help_img_idx += 1
        except:
            print('error')
            exit()
    if h_img_3 != "http://a.png/" and h_img_3 !='null':
        try:
            CreateAndroidHelpImage(h_img_3, help_img_idx)
            help_img_idx += 1
        except:
            print('error')
            exit()
    if h_img_4 != "http://a.png/" and h_img_4 !='null':
        try:
            CreateAndroidHelpImage(h_img_4, help_img_idx)
            help_img_idx += 1
        except:
            print('error')
            exit()
    os.system("touch %s/info.txt"%(welcome_dir))
    os.system("mv %s %s/Resource/welcome.bundle"%(welcome_dir,os.getcwd()))
    if ic_title!="null":
        filename = ic_launcher.split('/')[-1]
        downloadspath="%s/Resource/%s"%(orderdir,filename)
        path ="%s/Resource/ic_title@2x.png"%(orderdir)
        try:
            DownLoadFile(ic_title, downloadspath)
        except:
            print('error')
            exit()
        im = Image.open(downloadspath)
        im.save(path)
        os.remove(downloadspath)
    else:
        print "==========CreatTextImg"
        path ="%s/Resource/ic_title@2x.png"%(orderdir)
        img_w=157
        img_h=36
        CreatTextImg(appname,rect=(img_w,img_h)).save(path)
    if ic_launcher!="null":
        filename = ic_launcher.split('/')[-1]
        path ="%s/%s"%(orderdir,filename)
        try:
            DownLoadFile(ic_launcher, path)
        except:
            print('error')
            exit()
        CreatIosImags(path)
        os.remove(path)
    if  splash_img!="null":
        splash_background_filename = splash_img.split('/')[-1]
        splash_path="%s/%s"%(orderdir,splash_background_filename)
        try:
            DownLoadFile(splash_img,splash_path)
        except:
            print('error')
            exit()
        CreatIosSplash(splash_path)
        os.remove(splash_path)
    print('ok')

