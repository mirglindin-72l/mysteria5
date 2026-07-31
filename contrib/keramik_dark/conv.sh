#!/bin/sh

for file in `ls -1 ./keramik`
do
	echo $file
	convert +level-colors '#000000','#bbbbbb' ./keramik/$file ./keramik_dark/$file
done

for file in `ls -1 ./keramik|grep button`
do
	echo $file
	convert +level-colors '#000000','#777777' ./keramik/$file ./keramik_dark/$file
done
