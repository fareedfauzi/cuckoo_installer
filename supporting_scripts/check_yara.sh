#!/bin/bash
gitdir=$PWD
function dir_check()
{

if [ ! -d $1 ]; then
	echo "$1 does not exist. Creating.."
	mkdir -p $1
else
	echo "$1 already exists. (No problem, We'll use it anyhow)"
fi

}
echo "What is your Cuckoo user account?"
read name
dir_check /home/$name/.cuckoo/yara/test/
dir_check /home/$name/.cuckoo/yara/test/allrules
dir_check /home/$name/Desktop/yararesults
dir_check /home/$name/Desktop/yararesults/

rules_path=/home/$name/.cuckoo/yara/test/
out_dir=/home/$name/Desktop/yararesults/

cd $rules_path
git clone https://github.com/yara-rules/rules.git 

cp $rules_path/rules/**/*.yar $rules_path/allrules/
rm $rules_path/allrules/Android*
rm $rules_path/allrules/base64*
ls $rules_path/allrules/ > $rules_path/rules.txt
cores=$(cat /proc/cpuinfo | grep processor | wc -l)

#cat $rules_path/rules.txt | xargs --max-procs="$cores" -n1 $gitdir/call_volatility.sh
cd $gitdir
mkfifo pipe

for x in $(cat $rules_path/rules.txt)
do
  if [ $(ps aux | grep vol.py | wc -l) -lt $(cat /proc/cpuinfo | grep processor | wc -l) ]; then # we are under the limit
     echo $x
     vol.py -f /home/cuckoo/.cuckoo/storage/analyses/12/memory.dmp --profile=Win7SP1x64 yarascan --yara-file=$rules_path/allrules/$x --output=text --output-file=$out_dir/$x.log &>pipe 
  else
     wait -n
  fi
done

#cat /home/$name/Desktop/error.txt | grep Cannot | cut -d"/" -f9 | cut -d"("  -f1 > /home/$name/Desktop/badrules.txt






