#! /bin/sh

ANDROID_GIT_ROOT="/Users/haorenjie/working/git/Android/Boat"
ANDROID_SVN_ROOT="/Users/haorenjie/working/svn/android/Boat/trunk"
IOS_GIT_ROOT="/Users/msj/Desktop/Architecture/Sword"
IOS_SVN_ROOT="/Users/msj/trunk/Sword"
SVN_STATUS_FILE="/Users/msj/svn_status.txt"

clear_generated_files() 
{
	cd $1
	./scripts/clear.sh $1
}

copy_to_svn()
{
	echo "copy_to_svn git root: $1"
	echo "copy_to_svn svn root: $2"

	cd $2
	rm -rf *
	clear_generated_files $1
	cd $1
	cp -avX * $2
}

update_git()
{
	echo "=============== update_git: $1"
	cd $1
	echo "=============== Start update git codes under $1"
	git pull
}

update_svn()
{
	echo "=============== update_svn: $1"
	cd $1
	svn update
}

check_svn_status()
{
	cat $SVN_STATUS_FILE | while read line
	do
		type=${line:0:1}
		filename=${line:8}

		hasAt=0
		if [[ ${filename} =~ "@" ]]; then
			$hasAt=1
		fi
		
		# TODO: Deal with space in filename

		if [ $type = "?" ]; then
			echo "add $filename"
			if [ $hasAt -ne 0 ]; then
				svn add ${filename/"@"/"\@"}"\@"
			else
				svn add $filename
			fi
		elif [ $type = "!" ]; then
			echo "delete $filename"
			if [ $hasAt -ne 0 ]; then
				svn delete ${filename/"@"/"\@"}"\@"
			else
				svn delete $filename
			fi
		#else
			#echo "Unknown type ${line}"
		fi
	done
}

build_project()
{
	cd $1
	./scripts/build.sh $1
}

merge()
{
	update_git $1
	if [ $? -ne 0 ]; then
        echo "=============== $1 update failed."
        return 1
    fi

	update_svn $2
	if [ $? -ne 0 ]; then
		echo "=============== $2 update failed."
		return 1
	fi

	copy_to_svn $1 $2
	if [ $? -ne 0 ]; then 
		echo "=============== $1 copy to $2 failed."
		return 1
	fi

	cd $2
	svn status > $SVN_STATUS_FILE
	if [ $? -ne 0 ]; then 
		echo "=============== Save svn status failed."
		return 1
	fi

	check_svn_status
	if [ $? -ne 0 ]; then
		echo "=============== Svn status check failed."
		return 1
	fi
	rm -f $SVN_STATUS_FILE

	build_project $2
	if [ $? -ne 0 ]; then
		echo "=============== Project $2 build failed"
		return 1
	fi

	return 0
}

main() 
{
	clear
	if [[ $1 = "Android" ]]; then
		merge $ANDROID_GIT_ROOT $ANDROID_SVN_ROOT
	elif [[ $1 = "iOS" ]]; then
		merge $IOS_GIT_ROOT $IOS_SVN_ROOT
	else
		echo "Please input parameter Android or iOS to select the merge target!"
	fi
}

main $1

# end of file
