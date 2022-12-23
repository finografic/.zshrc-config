echo $_g; # GREEN
echo "Cleaning Downloads..."
echo $_0;

for file in $HOME/Downloads/**/*.mp4.mp4;
  do mv $file "`echo $file | sed -E 's/.mp4.mp4/.mp4/'`";
done
