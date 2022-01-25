#!/bin/bash
set -e # Need to fail on error
TIDY_OUT=/tmp/tidy_out.$$
apt-get update -y
apt-get install python3-pip libcurl4 -y
pip3 install html5validator 

TEAMCOUNT_HERE=$( ls _team|wc -l )
TEAMCOUNT_THERE=$( ls ../www.divd.nl/_team|wc -l )
if [[ $TEAMCOUNT_HERE -le 0 || $TEAMCOUNT_HERE -ne $TEAMCOUNT_THERE ]]; then
	echo "_team directory is not updated, run ./update.sh"
	exit 1
fi
gem install html-proofer
echo "*** Internal link check ***"
export LANG=en_US.UTF-8
htmlproofer \
	--check-html \
	--disable_external \
	--allow-hash-href  \
	--url-ignore="/#english/" \
	_site
echo "*** External link check ***"
(set +e ; htmlproofer \
	--allow-hash-href \
	--url-ignore="/www.linkedin.com/","/twitter.com/","/www.infoo.nl/","/#english/","/x1sec.com/" _site || exit 0)
(
	html5validator _site/*.html _site/*/*.html _site/*/*/*.html _site/*/*/*/*.html _site/*/*/*/*.html 
) | tee $TIDY_OUT
ERRORS=$( grep 'error:' $TIDY_OUT | wc -l )
if [[ $ERRORS -gt 0 ]] ; then
	echo "------------------------------------------------------------------------------------"
	echo "There are $ERRORS errors in html files, not good enough!"
	grep 'Error:' $TIDY_OUT
	exit 1
else
	echo "------------------------------------------------------------------------------------"
	echo " HTML checked and found flawles, \0/ \0/ \0/ \0/ \0/ \0/ "
	echo "------------------------------------------------------------------------------------"
fi