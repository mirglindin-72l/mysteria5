#!/bin/sh

rm -rf ./critcl

tclsh build_wrappers.tcl

rm -rf ./package
mkdir ./package

cp -r ../mysteria5 ./package/
rm -rf ./package/mysteria5/.store
rm -rf ./package/mysteria5/TODO
rm -rf ./package/mysteria5/*.log
rm -rf ./package/mysteria5/contrib/ttkthemes
rm -rf ./package/mysteria5/.git

pushd ./package
#zip -r ./mysteria5_`date +%d%m%Y`.zip ./mysteria5
7z a -v16m ./mysteria5_`date +%d%m%Y`.7z ./mysteria5
7z a ./mysteria5_`date +%d%m%Y`.7z ./mysteria5
popd ./package

echo "For this package to be usable,"
echo "you need to unpack and run it"
echo "under target OS system with a"
echo "compiler in path, and then use"
echo "with critcl cache directory"
echo "preserved. Some Windows critcl"
echo "cache files are packaged, might"
echo "not work."
