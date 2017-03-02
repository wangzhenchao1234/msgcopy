#!/bin/bash

function ergodic(){
for file in `ls $1`
do
if [ -d $1"/"$file ]
then
ergodic $1"/"$file
else
local path=$1"/"$file
local name=$file
local size=`du --max-depth=1 $path|awk '{print $1}'`
echo name === $name
echo path === $path
lipo -create $path Debug/$file -output ReleaseAll/$file
lipo -info ReleaseAll/$file
fi
done
}

mkdir ReleaseAll
IFS=$'\n'
INIT_PATH="Release";
ergodic $INIT_PATH