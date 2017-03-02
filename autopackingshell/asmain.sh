#! /bin/bash
#Program:
#    在git上拉取最新分支，创建新的分支，替换资源文件，打包，删除分支

source git.sh

base_dir=${PWD}
ipafilename=$1
version=$2
sourceid=$3
url=$4
ic_launcher=$5
splash=$6

domain=$7

ic_title=$8
appid=$9

shift 9
app_key=$1
app_secret=$2
app_uri=$3

temp_dir=$4
result_path=$5
proj_dir=$6
wx_appid=$7


alipay_private=$8
alipay_default_seller=$9
shift 9
alipay_default_partner=$1

h_img_0=$2
h_img_1=$3
h_img_2=$4
h_img_3=$5
h_img_4=$6

echo "********************"
echo "******远程推送设置******"
echo "********************"

app_type=$7
apns_service=$8
apns_domain=$9

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
echo app_type	             $app_type
echo apns_service	         $apns_service
echo apns_domain	         $apns_domain

echo -n "Enter your input: "
read input
if [ "Y" != "$input" ]; then
    exit 0
fi


function mecho(){
echo ""
echo "********"$1"********"
echo ""

}


echo "********************"
mecho "******新手帮助******"
echo "********************"

cd ../

echo "********************"
mecho "******清除缓存******"
echo "********************"

xcodebuild clean -configuration Release
cd ${base_dir}
Begin
distDir=${result_path}


releaseDir="build/Release-iphoneos"
basedir=${temp_dir}"/kaoke_client_ios_"${ipafilename}"/"
echo "ipafilename=${ipafilename}"
echo "sourceid=$sourceid"
targetName="kaoke"
rm -rdf "$releaseDir"
ipapath="${distDir}/"${sourceid}${appid}"/kaoke_ios.ipa"




echo "**********************"
echo "******更改app名称******"
echo "**********************"




sed -ig 's/MY_PRODUCT_NAME/\"'${ipafilename}'\"/g' ${basedir}Kaoke.xcodeproj/project.pbxproj

mecho "Constants.h  --------old"



cat ${basedir}Kaoke/Constants.h




echo "**************************"
echo "*******更改app domain******"
echo "**************************"



sed -ig 's/iapi.msgcopy.net/'${domain}'/g' ${basedir}kaoke/Constants.h
sed -ig 's/iapi.msgcopy.net/'${domain}'/g' ${basedir}kaoke/Constants.h
sed -ig 's/iapi.msgcopy.net/'${domain}'/g' ${basedir}kaoke/Constants.h



echo "**************************"
echo "********更改微博账号********"
echo "**************************"



sed -ig 's/2170890644/'${app_key}'/g' ${basedir}kaoke/Constants.h
sed -ig 's/0d769908b15188db16824d39a783c018/'${app_secret}'/g' ${basedir}kaoke/Constants.h
oldurl='http:\/\/www.msgcopy.com\/'

newurl=${app_uri}

mecho '${oldurl}====='${oldurl}
mecho '${newurl}====='${newurl}

sed -ig 's$'${oldurl}'$'${newurl}'$g' ${basedir}kaoke/Constants.h


echo "*************************"
echo "********更改渠道号********"
echo "*************************"


sed -ig 's/CHANNEL_ID/'${sourceid}'/g' ${basedir}kaoke/Constants.h
sed -ig 's$PARTNER_ID$'${alipay_default_partner}'$g' ${basedir}kaoke/Constants.h
sed -ig 's$SELLER_ID$'${alipay_default_seller}'$g' ${basedir}kaoke/Constants.h
sed -ig 's$PRIV_KEY$'${alipay_private}'$g' ${basedir}kaoke/Constants.h
sed -ig 's$APP_TYPE$'${app_type}'$g' ${basedir}kaoke/Constants.h
sed -ig 's$APP_SERVICE$'${apns_service}'$g' ${basedir}kaoke/Constants.h
sed -ig 's$APNS_DOMAIN$'${apns_domain}'$g' ${basedir}kaoke/Constants.h


echo "*************************"${sourceid}"*************************"
mecho "Constants.h  --------new"


cat ${basedir}Kaoke/Constants.h



echo "**************************"
echo "********更改app版本********"
echo "**************************"



sed -ig 's/WEIXIN_ID/'${wx_appid}'/g' ${basedir}kaoke/Constants.h
sed -ig 's/WEIXIN_ID/'${wx_appid}'/g' ${basedir}kaoke/kaoke-Info.plist
sed -ig 's/APP_ID/'${appid}'/g' ${basedir}kaoke/kaoke-Info.plist
sed -ig 's/9.9.9.9/'${version}'/g' ${basedir}kaoke/kaoke-Info.plist



echo "**************************"
echo "*********更改plist*********"
echo "**************************"



sed -ig 's/DOWNLOAD_URL/http:\/\/smedia.msgcopy.net\/download\/'${sourceid}'\/kaoke_ios.ipa/g' ${basedir}kaoke/enterprise.plist

sed -ig 's/APP_ID/'${appid}'/g' ${basedir}kaoke/enterprise.plist
sed -ig 's/APP_VERSION/'${version}'/g' ${basedir}kaoke/enterprise.plist
sed -ig 's/myapp_title/'${ipafilename}'/g' ${basedir}kaoke/enterprise.plist
sed -ig 's$APP_ICON$'${ic_launcher}'$g' ${basedir}kaoke/enterprise.plist

echo "**********************"
echo "*****删除lauching图****"
echo "**********************"

rm -rf ${basedir}huangyingye.png

echo "**********************"
echo "***开始build app文件***"
echo "**********************"

cd ${basedir}

xcodebuild -target "$targetName" -configuration Release -sdk "iphoneos7.1" CODE_SIGN_IDENTITY="iPhone Distribution:49me" PROVISIONING_PROFILE="3216307b-7c5e-45f7-8414-e2f4d7249967"

appfile="${releaseDir}/${ipafilename}.app"

echo "********************"
echo "***开始打ipa渠道包****"
echo "********************"



/usr/bin/xcrun -sdk "iphoneos7.1" PackageApplication -v "$appfile" -o "$ipapath" --embed ${basedir}"49me.mobileprovision"

echo "********************"
echo "******复制plist******"
echo "********************"


plistPth=${distDir}'/'${sourceid}${appid}'/kaoke_ios.plist'

echo ${basedir}'enterprise.plist'
echo  ${plistPth}
cp ${basedir}kaoke/'enterprise.plist' ${plistPth}

DelBranch


