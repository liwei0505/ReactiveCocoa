#! /bin/sh

# Project directories are below:
# Project Root
#   - Project
#   - Pods
#   - script
#     - build.sh

workspace="Sword.xcworkspace"
scheme="Sword"
configuration="Release"
configurationBuildDir="./build/Release-iphoneos"
productsBiuldDir="./build/Release-iphoneos"
podsBuildDir="./build/Pods.build"
podsConfigurationBuildDir="./build/Release-iphoneos"
codeSignIdentity="iPhone Distribution: BEIJING MJSFAX FINANCIAL ASSETS EXCHANGE CO., LTD. (7NC535VVH6)"
appStoreProvisioningProfile="21708f3b-fc2d-4ca0-a65d-64590821c30a"
archivePath="./archive/mjs.xcarchive"
ipaPath="./archive"
exportOptions="./scripts/exportOptions.plist"

build_pods() {
	xcodebuild -project ./Pods/Pods.xcodeproj -alltargets -configuration Release clean build
}

build_project() 
{
	build_pods
	if [ $? -ne 0 ]; then
		echo "Build Pods failed!"
	else
		echo "Start build project ..."
		xcodebuild -workspace "${workspace}" -scheme "${scheme}" -configuration "${configuration}" clean build
    fi
}

archive() 
{
	xcodebuild archive -workspace "${workspace}" -scheme "${scheme}" -configuration "${configuration}" -archivePath "${archivePath}" \
	CONFIGURATION_BUILD_DIR="${configurationBuildDir}" CODE_SIGN_IDENTITY="${codeSignIdentity}" PROVISIONING_PROFILE="${appStoreProvisioningProfile}" \
	BUILT_PRODUCTS_DIR="${productsBiuldDir}" PODS_BUILD_DIR="${podsBuildDir}" PODS_CONFIGURATION_BUILD_DIR="${podsConfigurationBuildDir}"
}

export_ipa() {
	xcodebuild -exportArchive -archivePath "${archivePath}" -exportPath "${ipaPath}" -exportOptionsPlist "${exportOptions}"
}

main()
{
	cd `dirname $0`
	cd ..
	build_pods
	if [ $? -ne 0 ]; then
		echo "Project build failed!"
	else
		echo "Start archive ..."
		archive
	fi

	if [ $? -ne 0 ]; then 
		echo "Archive failed!"
	else
		echo "Start export the ipa..."
		export_ipa
	fi

	if [ $? -ne 0 ]; then
		echo "Export ipa failed!"
		return 1
	fi

	echo "Ipa file created!"
	return 0
}

main



