#coding:utf-8
'''
    python图片处理
    @author:fc_lamp
    @blog:http://fc-lamp.blog.163.com/
'''
from PIL import Image as image
import math
import os

#等比例压缩图片
def resizeImg(**args):
    args_key = {'ori_img':'','dst_img':'','dst_w':'','dst_h':'','save_q':40}
    arg = {}
    for key in args_key:
        if key in args:
            arg[key] = args[key]
        
    im = image.open(arg['ori_img'])
    ori_w,ori_h = im.size
    widthRatio = heightRatio = None
    ratio = 1
    if (ori_w and ori_w > arg['dst_w']) or (ori_h and ori_h > arg['dst_h']):
        if arg['dst_w'] and ori_w > arg['dst_w']:
            widthRatio = float(arg['dst_w']) / ori_w #正确获取小数的方式
        if arg['dst_h'] and ori_h > arg['dst_h']:
            heightRatio = float(arg['dst_h']) / ori_h

        if widthRatio and heightRatio:
            if widthRatio < heightRatio:
                ratio = widthRatio
            else:
                ratio = heightRatio

        if widthRatio and not heightRatio:
            ratio = widthRatio
        if heightRatio and not widthRatio:
            ratio = heightRatio
            
        newWidth = int(ori_w * ratio)
        newHeight = int(ori_h * ratio)
    else:
        newWidth = ori_w
        newHeight = ori_h
        
    im.resize((newWidth,newHeight),image.ANTIALIAS).save(arg['dst_img'],quality=arg['save_q'])

    '''
    image.ANTIALIAS还有如下值：
    NEAREST: use nearest neighbour
    BILINEAR: linear interpolation in a 2x2 environment
    BICUBIC:cubic spline interpolation in a 4x4 environment
    ANTIALIAS:best down-sizing filter
    '''

#裁剪压缩图片
def clipResizeImg(**args):
    
    args_key = {'ori_img':'','dst_img':'','dst_w':'','dst_h':'','save_q':75}
    arg = {}
    for key in args_key:
        if key in args:
            arg[key] = args[key]

    im = image.open(arg['ori_img'])
    #为了计算精确所有的变量都是float型

    ori_w = ori_h = dst_w = dst_h = 1.0
    iw,ih = im.size
    ori_h = float(ih)
    ori_w = float(iw)
    dst_w = float(arg['dst_w'])
    dst_h = float(arg['dst_h'])

    x = y = w = h = 0.0

    scale_h = scale_w = 1.0

    if (ori_w and ori_w >= dst_w) and (ori_h and ori_h >= dst_h):
        print "缩小"
        min_scale = max(ori_w/dst_w,ori_h/dst_h)
        scale_w = ori_w/min_scale
        scale_h = ori_h/min_scale

        if ori_w/dst_w < ori_h/dst_h :
            w = scale_w
            h = scale_w*dst_h/dst_w
            x = 0.0
            y = (scale_h - dst_h)/2.0
        else :
            h = scale_h
            w = scale_h*dst_w/dst_h
            x = (scale_w - dst_w)/2.0
            y = 0.0
    else:
        print "放大"
        max_scale = max(dst_w/ori_w,dst_h/ori_h)
        scale_w = ori_w*max_scale
        scale_h = ori_h*max_scale

        if dst_w/ori_w>dst_h/ori_h:
            w = scale_w
            h = w*dst_h/dst_w
            x = 0.0
            y = (scale_h-dst_h)/2.0
        else:
            h = scale_h
            w = h*dst_w/dst_h
            x = (scale_w-dst_w)/2.0
            y = 0.0

    #裁剪
    orderdir="%s/"%(os.getcwd())
    
    #缩放图片路径
    imagepath="%stmp%s.png"%(orderdir,dst_w)
    
    #转换成int
    tmp_w = int(math.ceil(scale_w))
    tmp_h = int(math.ceil(scale_h))
    
    #将图片等比缩放到最适合大小
    im.resize((tmp_w,tmp_h),image.ANTIALIAS).save(imagepath,quality=arg['save_q'])
    imagename="tmp%s.png"%(dst_w)
    new_img = image.open(imagename)
    
    #裁剪图片
    print "裁剪"
    crop_x1 = int(math.floor(x))
    crop_y1 = int(math.floor(y))
    crop_x2 = int(math.ceil(w+x))
    crop_y2 = int(math.ceil(h+y))
    box = (crop_x1,crop_y1,crop_x2,crop_y2)
    
    #这里的参数可以这么认为：从某图的(x,y)坐标开始截，截到(width+x,height+y)坐标
    #所包围的图像，crop方法与php中的imagecopy方法大为不一样
    final_image = new_img.crop(box)
    im = None
    
    #压缩
    print "原图宽==%s   原图高===%s"%(int(ori_w),int(ori_h))
    print "裁剪宽==%s   裁剪高===%s"%(int(dst_w),int(dst_h))
    
    #转换成int
    rst_w = int(math.ceil(dst_w))
    rst_h = int(math.ceil(dst_h))
    
    #最后缩放图片到精确的分辨率
    final_image.resize((rst_w,rst_h),image.ANTIALIAS).save(arg['dst_img'],quality=arg['save_q'])


#水印(这里仅为图片水印)
def waterMark(**args):
    args_key = {'ori_img':'','dst_img':'','mark_img':'','water_opt':''}
    arg = {}
    for key in args_key:
        if key in args:
            arg[key] = args[key]
        
    im = image.open(arg['ori_img'])
    ori_w,ori_h = im.size

    mark_im = image.open(arg['mark_img'])
    mark_w,mark_h = mark_im.size
    option ={'leftup':(0,0),'rightup':(ori_w-mark_w,0),'leftlow':(0,ori_h-mark_h),
             'rightlow':(ori_w-mark_w,ori_h-mark_h)
             }
    
    im.paste(mark_im,option[arg['water_opt']],mark_im.convert('RGBA'))
    im.save(arg['dst_img'])
    