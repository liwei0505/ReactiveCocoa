#! /bin/sh

# Project directories are below:
# Project Root
#   - Project
#   - Pods
#   - script
#     - build.sh

main()
{
	cd `dirname $0`
	cd ..

	echo "Clear generated files"
	# rm -rf Sword/Sword.xcodeproj/xcuserdata
	# rm -rf Sword/Pods/Pods.xcodeproj/xcuserdata
	# rm -rf Sword/Sword.xcworkspace/xcuserdata
}

main


