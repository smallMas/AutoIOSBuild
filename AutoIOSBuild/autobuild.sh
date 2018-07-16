#!/bin/bash
# 使用方法 
# 1、修改plist文件中的provisioningProfiles字段  key(bundleId) = value(证书名字)
# 2、执行命令 ./autobuild.sh -p /Users/love/Documents/WorkspaceGit/gitee/PEO3/PublicExamOnline/PublicExamOnline.xcodeproj -c Debug -o debug

projectPath="" #(workspace/project)工程路径
config="" #配置 Release/Debug
option="" #plist的文件是哪个 adhoc/appstore/debug
while getopts "p:c:o:" arg
do
	 case $arg in
	 	p )
			# echo "OptionB: ${OPTARG}";;
			projectPath=${OPTARG};;
		c )
			# echo "OptionC: ${OPTARG}";;
			config=${OPTARG};;
		o )
			option=${OPTARG};;
	 esac
done
echo "projectPath : $projectPath"
echo "config : $config"
echo "option : $option"

lastItem=${projectPath##*/}
echo $lastItem
scheme=${lastItem%.*} #scheme 工程名字
echo $scheme
suffix=${lastItem##*.}
echo $suffix
archivePath=./$scheme
echo $archivePath
typename=0
if [[ $suffix == 'xcodeproj' ]]; then
	typename=1
elif [[ $suffix == 'xcworkspace' ]]; then
	typename=2
fi
echo $typename

echo "开始编译-------"
if [[ $typename == 1 ]]; then
	# xcodebuild -project [.xcodeproj] -scheme [工程名] -configuration [Release/Debug] archive -archivePath [保存生成的.xcarchive包路径] -destination generic/platform=iOS
	xcodebuild -project $projectPath -scheme $scheme -configuration $config archive -archivePath $archivePath -destination generic/platform=iOS
elif [[ $typename == 2 ]]; then
	# xcodebuild -workspace [.workspace] -scheme [工程名] -configuration [Release/Debug] archive -archivePath [保存生成的.xcarchive包路径] -destination generic/platform=iOS
	xcodebuild -workspace $projectPath -scheme $scheme -configuration $config archive -archivePath $archivePath  -destination generic/platform=iOS
fi
echo "结束编译-------"

echo "开始导出ipa文件-------"
archivePath2=$archivePath.xcarchive
ipaPath=./$scheme
echo $ipaPath
plistName=""
if [[ $option == "adhoc" ]]; then
	plistName=exportAdhocOptions.plist
elif [[ $option == "appstore" ]]; then
	plistName=exportAppstoreOptions.plist
elif [[ $option == "debug" ]]; then
	plistName=exportDebugOptions.plist
fi

if [[ $plistName ]]; then
	# xcodebuild -exportArchive -archivePath [第一步生成的.xcarchive路径] -exportPath [导出的ipa路径] -exportOptionsPlist [导出过程中需要的配置文件exportAdhocOptions.plist/exportAppstoreOptions.plist]
	xcodebuild -exportArchive -archivePath $archivePath2 -exportPath $ipaPath -exportOptionsPlist $plistName
	echo "结束导出ipa文件-------"
else
	echo "plistName为空"
fi





