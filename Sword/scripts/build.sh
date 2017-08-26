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

build_project() 
{
	echo "build_project..."
	xcodebuild -workspace $workspace -scheme $scheme -configuration $configuration clean build
}

main()
{
	cd `dirname $0`
	cd ..

	build_project
	if [ $? -ne 0 ]; then 
		echo "Build failed."
		return 1
	fi
	
	return 0
}

main


