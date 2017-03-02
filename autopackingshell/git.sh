#!/bin/sh

#  git.sh
#  
#
#  Created by kkserver on 13-11-6.
#
source compile.sh

function Begin(){


mecho "开始创建新目录kaoke_client_ios_"${ipafilename}

cd ${proj_dir}
git reset --hard
git pull

CreatNewBranch

}

function CreatNewBranch(){

mecho "正在创建新分支"

mecho "正在创建新分支:"${temp_dir}'/kaoke_client_ios_'${ipafilename}


rm -rf  ${temp_dir}'/kaoke_client_ios_'${ipafilename}

mecho "正在复制文件:from:"${proj_dir}"---to---"${temp_dir}'/kaoke_client_ios_'${ipafilename}


cp -r ${proj_dir}  ${temp_dir}'/kaoke_client_ios_'${ipafilename}

cd ${temp_dir}'/kaoke_client_ios_'${ipafilename}

rm -rf ${result_path}/${sourceid}${appid}

mkdir ${result_path}/${sourceid}${appid}

Compile

}

function DelBranch(){

mecho "切到master 分支 ，删除 "${ipafilename}

rm -rf "kaoke_client_ios_"${ipafilename}

}