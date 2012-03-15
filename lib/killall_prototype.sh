rm *.process
list=`ps -ef | grep ruby | grep -v grep | awk ' { print $2} '`
for id in `echo $list`
do
kill -9 $id
echo killed $id
done
