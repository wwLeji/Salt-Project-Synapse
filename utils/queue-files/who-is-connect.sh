

if [ $# -eq 0 ]
  then
    sudo salt '*' test.ping > utils/queue-files/list.txt
  else
    sudo salt -N $1 test.ping > utils/queue-files/list.txt
fi
echo "" > utils/queue-files/list-true.txt
grep -B 1 True utils/queue-files/list.txt >> utils/queue-files/list-true.txt
sed -i '/True/d' utils/queue-files/list-true.txt
sed -i 's/:/ /g' utils/queue-files/list-true.txt
rm utils/queue-files/list.txt