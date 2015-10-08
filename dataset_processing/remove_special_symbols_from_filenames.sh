#
### $1 - folder to search in
#

FILES=$(find $1 -type f -name  '*.bb');
#echo $FILES
echo "#########################"
for f in $FILES; do
    new_name=$(echo "$f" | tr '!' '_')
    if [ "$f" != "$new_name" ] ; then
        echo "renaming $f"
        mv $f $new_name
    fi
done;
