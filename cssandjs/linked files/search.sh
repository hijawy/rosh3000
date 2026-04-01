

set +v
grep -l -i  -c "$1" *.html  > SearchResult.txt
file=SearchResult.txt
rm -f SearchResult.html


 echo \<h2\> Search For [ $1 ] Found in  Files as fallow : \</h2\> >SearchResult.html


 while read -r line; do
  echo \<p\>\<a href=\"$line\"\>$line\</a\>\</p\> >>SearchResult.html
done <$file

rm -f SearchResult.txt

