#!/bin/sh

#  Compile.sh
#  
#
#  Created by kkserver on 13-11-6.
#

function  Compile(){

mecho "正在打包" ${ipafilename}
DownLoadResource
}

function DownLoadResource(){

mecho '-----------------------------------开始裁图------------------------------------------'

python ${base_dir}/iosImageLoader.py ${ic_launcher} ${splash} "kaoke_client_ios_"${ipafilename} ${ic_title} ${ipafilename} ${h_img_0} ${h_img_1} ${h_img_2} ${h_img_3} ${h_img_4}

mecho '-----------------------------------裁图结束------------------------------------------'

}



 


