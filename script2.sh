#!/bin/bash

FLAG=false
flagOfDir=false;
flagOfTxt1=false;
flagOfTxt2=false;
flagOfTxt3=false;
repoIsOK=true;
totalDirectories=0
totalTextFiles=0
totalOtherFiles=0;

if [[ ! -d  assignments ]]
then
	mkdir assignments
fi

mkdir textFilesDir 
tar xf $(find *.tar.gz) -C textFilesDir #unzip
find textFilesDir | grep .txt | while read -r LINE
do
	fileToRead=$LINE
	while IFS= read -r url && [[ "$FLAG" == false ]] # (FLAG == false) --> so that it only reads one https..
	do
		if [[ "$url" != "#"* ]] && [[ "$url" == https* ]] #ignore comments + every line that doesn't begin with https
		then
			git -C assignments clone "$url" >/dev/null 2>&1 && echo "$url: Cloning OK" || echo "$url: Cloning FAILED" >&2  #>&2 redirect output to stderr , >/dev/null 2>&1 redirect stdout and stderr to dev/null
			FLAG=true
		fi
	done < "$fileToRead"
	FLAG=false
done

ls -1 assignments | while read -r repoDir
do
	while read -r aPathOfRepoDir
    do
    	if [[ "$aPathOfRepoDir" != "assignments/$repoDir/more" ]] && [[ "$aPathOfRepoDir" != "assignments/$repoDir/dataA.txt" ]] && [[ "$aPathOfRepoDir" != "assignments/$repoDir/more/dataB.txt" ]] && [[ "$aPathOfRepoDir" != "assignments/$repoDir/more/dataC.txt" ]] 
        then
        	repoIsOK=false
        fi
        BASENAME=`basename "$aPathOfRepoDir"`
        if [[ -d "$aPathOfRepoDir" ]]; then
            totalDirectories=$((totalDirectories+1))
            if [[ "$BASENAME" == "more" ]]; then
            	if [[ "$flagOfDir" == false ]]; then #found for the first time a directory called more
            		flagOfDir=true
            	else
            		repoIsOK=false
            	fi
            else #found a directory which name isn't more --> not ok
            	repoIsOK=false
            fi
        elif [[ -f "$aPathOfRepoDir" ]] && [[ "$BASENAME" == *".txt" ]]; then
            totalTextFiles=$((totalTextFiles+1))
            if [[ "$BASENAME" == "dataA.txt" ]]; then
            	if [[ "$flagOfTxt1" == false ]]; then #found for the first time a txt file called dataA
            		flagOfTxt1=true
            	else
            		repoIsOK=false
            	fi
            elif [[ "$BASENAME" == "dataB.txt" ]]; then
            	if [[ "$flagOfTxt2" == false ]]; then #found for the first time a txt file called dataB
            		flagOfTxt2=true
            	else
            		repoIsOK=false
            	fi
            elif [[ "$BASENAME" == "dataC.txt" ]]; then
            	if [[ "$flagOfTxt3" == false ]]; then #found for the first time a txt file called dataC
            		flagOfTxt3=true
            	else
            		repoIsOK=false
            	fi
            else #found a txt file which name isn't dataA, neither dataB, neither dataC --> not ok
            	repoIsOK=false
            fi
        else
            totalOtherFiles=$((totalOtherFiles+1))
            repoIsOK=false
        fi
    done < <( find assignments/"$repoDir" | grep -v .git | grep "$repoDir"/ )
	echo "$repoDir:"
	echo "Number of directories: $totalDirectories"
	echo "Number of txt files: $totalTextFiles"
	echo "Number of other files: $totalOtherFiles"
	if [[ "$repoIsOK" == true ]]
	then
		echo "Directory structure is OK."
	else
		echo "Directory structure is NOT OK." >&2
	fi
	totalDirectories=0
	totalTextFiles=0
	totalOtherFiles=0;
	flagOfDir=false;
	flagOfTxt1=false;
	flagOfTxt2=false;
	flagOfTxt3=false;
	repoIsOK=true;
done
