#!/bin/sh

# Fill in all the fields below with your source and destination directories.
src=/
dst=/
svrdst=
log=/var/log/automp4.log

echo '============================================================' | tee -a "$log"
echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Starting conversions from' $src | tee -a "$log"

for file in $src/*
do
  # This gets the basename of the file (i.e. no path)
  filename=$(basename "$file")

  echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Converting:' "$filename" | tee -a "$log"

  # This removes the extension from the file (we're replacing it.)
  filename="${filename%.*}"

  # This is what we are outputting to.
  output=$dst$filename'.mp4'

  HandBrakeCLI -i "$file" -o "$output" -Z 'Normal' &> /dev/null

  echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Finished conversion of:' "$filename"'.mp4' | tee -a "$log"
done

echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Finished all conversions' | tee -a "$log"
echo

# Ask to delete all files from the source.
read -p 'Do you want to delete source files? (y/n) ' -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Source files will be deleted' | tee -a "$log"

  for f in $src/*
  do
    filename=$(basename "$f")
    rm -f "$f"

    echo "$(date +"%Y-%m-%d %H:%M:%S")" '| File deleted:' "$filename" | tee -a "$log"

  done

  echo "$(date +"%Y-%m-%d %H:%M:%S")" '| All files deleted' | tee -a "$log"

else
  echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Files will not be deleted' | tee -a "$log"
fi

# Ask if you want to move the files to another directory
read -p 'Do you want to transfer the converted files to the server? (y/n) ' -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then

  echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Converted files will be moved to the server' | tee -a "$log"

  for file in $dst/*
  do
    filename=$(basename "$f")

    echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Copying' "$filename" ' to ' "$svrdst" | tee -a "$log"
    rsync --progress "$file" "$svrdst"

    echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Comparing source and destination files.' | tee -a "$log"

    # Make sure the file has copied, then delete the original file
    srcsize=$(wc -c "$file" | cut -d' ' -f2)
    dstsize=$(wc -c "$svrdst$filename" | cut -d' ' -f2)

    if [ "$srcsize" -eq "$dstsize" ]; then
      echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Files are the same, deleting the source file:' "$file" | tee -a "$log"
      rm -f "$file"
    else
      echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Files are not the same. Transfer manually:' "$file" | tee -a "$log"
    fi

  done

  echo "$(date +"%Y-%m-%d %H:%M:%S")" '| All files transferred. Check log for any errors.' | tee -a "$log"

else
  echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Files will not be moved.' | tee -a "$log"
fi

echo "$(date +"%Y-%m-%d %H:%M:%S")" '| Finished conversion script' | tee -a "$log"
echo
echo '============================================================' | tee -a "$log"

read -p 'Press any key to exit...' -n 1 -r
