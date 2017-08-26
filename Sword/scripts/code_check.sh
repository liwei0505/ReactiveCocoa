#! /bin/sh

# Project directories are below:
# Project Root
#   - Project
#   - Pods
#   - script
#     - code_check.sh

workspace="Sword.xcworkspace"
scheme="Sword"
configuration="Release"
buildLogFile="build.log"
analyzeLogFile="analyze.log"

build_project() 
{
	echo "build_project..."
	xcodebuild -workspace "${workspace}" -scheme "${scheme}" -configuration "${configuration}" clean build | tee "${buildLogFile}" | xcpretty -r json-compilation-database
}

analyze_project() 
{
	xcodebuild -workspace "${workspace}" -scheme "${scheme}" -configuration "${configuration}" analyze | tee "${analyzeLogFile}" | xcpretty -r json-compilation-database
}

generate_report()
{
	echo "OCLint generating the report..."
	oclint-json-compilation-database -e Pods -- -report-type html -o oclint_report.html
}

clean() 
{
	echo "Cleaning ..."
	rm -rf ./build
	rm -f compile_commands.json
	rm -f oclint_report.html
}

main()
{
	cd `dirname $0`
	cd ..
	
	clean
	echo "Start check code ..."
	build_project
	if [ $? -ne 0 ]; then 
		echo "Build failed."
		return 1
	fi

	echo "Moving compilation_db.json file ..."
	mv build/reports/compilation_db.json compile_commands.json

	if [ $? -ne 0 ]; then 
		echo "Move compilation_db.json file failed."
		return 1
	fi

	generate_report
	if [ $? -ne 0 ]; then 
		echo "Generate html report failed."
		return 1
	fi

	echo "OCLint report generated!"
	
	return 0
}

main


