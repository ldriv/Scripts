#!/bin/sh
# 
# Script to compare lists and remove any matching items
# 2018 10.16.2018 LDRIV https://www.linkedin.com/in/ldriv/

/bin/echo -n "Specify Source List:"
read sourcelist

/bin/echo -n "Specify Items for Removal:"
read toremove

# Parse the source list and set removal flag to 0
for sitem in $sourcelist; do
remove=0

  # If item to remove exists in list, set removal flag
  for item in $toremove; do
   if [[ "$item" = "$sitem" ]] ; then
     remove=1
   fi
 done

   # If item did not match removal, add it to the new list
   if [[ "$remove" -ne 1 ]] ; then
     newlist="$newlist $sitem"
   fi
done

echo "$newlist"
