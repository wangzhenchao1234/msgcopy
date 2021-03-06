#! /bin/bash
#Program:
#    在git上拉取最新分支，创建新的分支，替换资源文件，打包，删除分支

function mecho(){
echo ""
echo "********"$1"********"
echo ""

}
#工程路径
base_dir=${PWD}
#ipa包路径
ipafilename=$1
#app版本号
version=$2
#app渠道号
sourceid=$3
#域名net Or me
url=$4
#图标
ic_launcher=$5
#欢迎页
splash=$6
#域名net or me
domain=$7
#标题栏logo图片
ic_title=$8
#appID
appid=$9
#app_domain
app_domain=${29}

shift 9

#sina 信息
app_key=$1
app_secret=$2
app_uri=$3

#拷贝工程路径
temp_dir=$4
#打包结果路径
result_path=$5
#工程路径
proj_dir=$6
#微信ID
wx_appid=$7

#支付宝私钥
alipay_private=$8
#支付宝商户id
alipay_default_seller=$9
shift 9
#支付宝合作ID
alipay_default_partner=$1

#5张新手帮助图
h_img_0=$2
h_img_1=$3
h_img_2=$4
h_img_3=$5
h_img_4=$6

#QQ第三方登录信息
tencentApp_id=$7
version_code=$8

#微信secret
wx_secret=$9

shift 9

#微信ParternerID
wx_partner_id=$1




echo "------------------------------------------------------------------------------------------------------"

echo "********************"
mecho "******远程推送设置******"
echo "********************"

echo ipafilename	         $ipafilename
echo version	             $version
echo sourceid	             $sourceid
echo url	                 $url
echo ic_launcher	         $ic_launcher
echo splash	             $splash
echo domain	             $domain
echo ic_title	             $ic_title
echo appid	                 $appid
echo app_key	             $app_key
echo app_secret	         $app_secret
echo app_uri	             $app_uri
echo temp_dir	             $temp_dir
echo result_path	         $result_path
echo proj_dir	             $proj_dir
echo wx_appid	             $wx_appid
echo alipay_private	     $alipay_private
echo alipay_default_seller	 $alipay_default_seller
echo alipay_default_partner $alipay_default_partner
echo h_img_0	             $h_img_0
echo h_img_1	             $h_img_1
echo h_img_2	             $h_img_2
echo h_img_3	             $h_img_3
echo h_img_4	             $h_img_4
echo app_domain	             $app_domain


echo "-----------------------------------20161205-------------------------------------------------------------------"


echo "********************"
mecho "******新手帮助******"
echo "********************"

cd ../

echo "************1106********"
mecho "******清除缓存******"
echo "********************"

cd ${base_dir}



echo '-------- 初始化目录 ---------'

mecho "开始创建新目录kaoke_client_ios_"${ipafilename}


cd ${proj_dir}

#mecho "reset --  hard"

#git reset --hard

#mecho "pull 新代码"

#git pull

mecho "正在删除并创建新目录:"${temp_dir}'/kaoke_client_ios_'${ipafilename}

rm -rf  ${temp_dir}'/kaoke_client_ios_'${ipafilename}

mecho "正在复制文件:from:"
mecho ${proj_dir}
mecho "to:"
mecho ${temp_dir}'/kaoke_client_ios_'${ipafilename}
cp -r ${proj_dir}  ${temp_dir}'/kaoke_client_ios_'${ipafilename}

mecho "cd 到项目路径"

cd ${temp_dir}'/kaoke_client_ios_'${ipafilename}

mecho "删除旧的app包路径"

rm -rf ${result_path}/${sourceid}${appid}

mecho "创建新的app包路径"

mkdir ${result_path}/${sourceid}${appid}

mecho '-------- 初始化目录完毕 ---------'


mecho "--------- 开始打包 ---------" ${ipafilename}

python ${base_dir}/iosImageLoader.py ${ic_launcher} ${splash} "kaoke_client_ios_"${ipafilename} ${ic_title} ${ipafilename} ${h_img_0} ${h_img_1} ${h_img_2} ${h_img_3} ${h_img_4} &>iOSImageLoader.txt
image_result=`awk 'END {print}' iOSImageLoader.txt`
echo $image_result

if [ $image_result = "ok" ];then
echo '------ 下载素材完成 ------'
else
echo '------ 下载素材出错 ------'
exit
fi

echo '------------- 替换应用信息 -----------'

releaseDir=$(PWD)'/build/Release-iphoneos'

distDir=${result_path}

basedir=${temp_dir}'/kaoke_client_ios_'${ipafilename}'/'

echo "ipafilename=${ipafilename}"

echo "sourceid=$sourceid"

targetName="msgcopy"

rm -rdf $releaseDir

ipapath=${distDir}/${sourceid}${appid}'/kaoke_ios.ipa'


echo "**********************"
echo "******更改app名称******"
echo "**********************"




sed -ig 's/MY_PRODUCT_NAME/\"'${ipafilename}'\"/g' ${basedir}'msgcopy.xcodeproj/project.pbxproj'

mecho "----------预览  Constants.h  --------"


cat ${basedir}Headers/kAPIConst.h


echo "-----------------------------------------替换constants.h-----------------------------------------------"


echo "**************************"
echo "*******更改app domain******"
echo "**************************"



sed -ig 's/IAPI_DOMAIN_REPLACEMENT/'${domain}'/g' ${basedir}'Headers/kAPIConst.h'
sed -ig 's/APP_DOMAIN_REPLACEMENT/'${app_domain}'/g' ${basedir}'Headers/kAPIConst.h'
#sed -ig 's/iapi.msgcopy.net/'${domain}'/g' ${basedir}'Headers/kAPIConst.h'
#sed -ig 's/iapi.msgcopy.net/'${domain}'/g' ${basedir}'Headers/kAPIConst.h'



echo "**************************"
echo "********更改微博账号********"
echo "**************************"

sed -ig 's/KEY_APP_SINA/'${app_key}'/g' ${basedir}'Headers/kAPIConst.h'
sed -ig 's/SECRET_APP_SINA/'${app_secret}'/g' ${basedir}'Headers/kAPIConst.h'
oldurl='URI_APP_SINA'

newurl=${app_uri}

#mecho '${oldurl}====='${oldurl}
#mecho '${newurl}====='${newurl}

sed -ig 's$'${oldurl}'$'${newurl}'$g' ${basedir}'Headers/kAPIConst.h'

echo "**************************"
echo "********替换微信信息********"
echo "**************************"

sed -ig 's/WEIXIN_ID/'${wx_appid}'/g' ${basedir}'Headers/kAPIConst.h'
sed -ig 's/WEIXIN_SECRET/'${wx_secret}'/g' ${basedir}'Headers/kAPIConst.h'
sed -ig 's/WEIXIN_PARTNER/'${wx_partner_id}'/g' ${basedir}'Headers/kAPIConst.h'

echo "*************************"
echo "********更改渠道号********"
echo "*************************"


sed -ig 's/CHANNEL_ID/'${sourceid}'/g' ${basedir}'Headers/kAPIConst.h'


echo "*************************"
echo "********配置支付宝信息********"
echo "*************************"

sed -ig 's$ALI_PARTNER_ID$'${alipay_default_partner}'$g' ${basedir}'Headers/kAPIConst.h'
sed -ig 's$ALI_SELLER_ID$'${alipay_default_seller}'$g' ${basedir}'Headers/kAPIConst.h'
sed -ig 's$ALI_PRIV_KEY$'${alipay_private}'$g' ${basedir}'Headers/kAPIConst.h'

sed -ig 's$APP_TYPE$''Enterprise''$g' ${basedir}'Headers/kAPIConst.h'
sed -ig 's$ID_APP_QQ$'${tencentApp_id}'$g' ${basedir}'Headers/kAPIConst.h'


echo "*************************"
echo "********配置推送渠道********"
echo "*************************"


sed -ig 's$APP_SERVICE$''2''$g' ${basedir}'Headers/kAPIConst.h'
sed -ig 's$APNS_DOMAIN$''http://app.msgcopy.net/wapi''$g' ${basedir}'Headers/kAPIConst.h'

mecho "----------------------- 确认Constants.h -------------------------"

cat ${basedir}Headers/kAPIConst.h

echo "**************************"
echo "********更改app版本********"
echo "**************************"


sed -ig 's/APP-ID/'${appid}'/g' ${basedir}'msgcopy/Info.plist'
sed -ig 's/NAME_VERSION/'${version}'/g' ${basedir}'msgcopy/Info.plist'
sed -ig 's/CODE_VERSION/'${version_code}'/g' ${basedir}'msgcopy/Info.plist'

echo "**************************"
echo "********更改URLSCHEM********"
echo "**************************"

sed -ig 's/WEIXIN_ID/'${wx_appid}'/g' ${basedir}'msgcopy/Info.plist'
sed -ig 's/WEIXIN_SECRET/'${wx_secret}'/g' ${basedir}'msgcopy/Info.plist'
sed -ig 's$ID_APP_QQ$'${tencentApp_id}'$g' ${basedir}'msgcopy/Info.plist'


echo "**************************"
echo "*********更改plist*********"
echo "**************************"



sed -ig 's/DOWNLOAD_URL/http:\/\/smedia.msgcopy.net\/download\/'${sourceid}'\/kaoke_ios.ipa/g' ${basedir}enterprise.plist
sed -ig 's/APP-ID/'${appid}'/g' ${basedir}'enterprise.plist'
sed -ig 's/APP_VERSION/'${version}'/g' ${basedir}'enterprise.plist'
sed -ig 's/myapp_title/'${ipafilename}'/g' ${basedir}'enterprise.plist'
sed -ig 's$APP_ICON$'${ic_launcher}'$g' ${basedir}'enterprise.plist'


echo "*****************************"
echo "*********确认Info.plist信息********"
echo "*****************************"

echo "------------------------------------------------------------------------------------------------------"


cat ${basedir}msgcopy/Info.plist


echo "------------------------------------------------------------------------------------------------------"


echo "**********************"
echo "*****删除lauching图****"
echo "**********************"

rm -rf ${basedir}huangyingye.png

echo "**********************"
echo "***开始build app文件***"
echo "**********************"

mecho '------------- 替换应用信息完毕 -----------'


cd ${basedir}

pwd

mecho '------------- 清理xCode缓存 -----------'


xcodebuild clean -configuration Release

mecho '------------- 清理xCode缓存完毕 -----------'


mecho '------------- 导入mp文件 -----------'

mp="${basedir}all_kaoke_enterprise_apps.mobileprovision"

/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i ${mp}) &>uuid.txt

uuid=`awk 'END {print}' uuid.txt`

echo "Found UUID $uuid"

echo "copying to $output.."

cp ${mp} ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision

mecho '------------- 导入mp文件完成 -----------'


mecho '------------- 开始build项目代码 -----------'

xcodebuild -target "$targetName" -configuration Release  -sdk "iphoneos9.3" CODE_SIGN_IDENTITY="iPhone Distribution:XC: *" PROVISIONING_PROFILE="ab379c06-1228-4387-b7ef-ce847a0a5426"



#xcodebuild -workspace $(PWD)/msgcopy.xcworkspace -scheme "msgcopy" -configuration 'Release' ONLY_ACTIVE_ARCH=NO CONFIGURATION_BUILD_DIR=$(PWD)/build/Release-iphoneos OBJROOT=$(PWD)/build SYMROOT=$(PWD)/build -sdk "iphoneos9.3" CODE_SIGN_IDENTITY="iPhone Distribution:All MsgCopy Enterprise Apps" PROVISIONING_PROFILE="0496ff3b-18f2-4932-83b9-3b04c32adf2d"

mecho '------------- build项目代码完毕 -----------'


appfile=${releaseDir}/${ipafilename}.app



echo "********************"
echo "***开始打ipa渠道包****"
echo "********************"



/usr/bin/xcrun -sdk "iphoneos9.3" PackageApplication -v "$appfile" -o "$ipapath"


echo "*********1106***********"
echo "******复制plist******"
echo "********************"


plistPth=${distDir}'/'${sourceid}${appid}'/kaoke_ios.plist'

echo ${basedir}'enterprise.plist'
echo  ${plistPth}
cp ${basedir}'enterprise.plist' ${plistPth}

#rm -rf  ${temp_dir}'/kaoke_client_ios_'${ipafilename}

