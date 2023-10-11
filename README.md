# Photo_GPS_Sorter_Script
A bash script that uses exiftool to extract the GPS coordinates from photos and group them based on a given range.

Run the bash script from the command line and it will show you the usage parameters.
  - photo_gps_sorter.sh <seed_photo> <distance_in_feet> <source_folder> <destination_folder>

The script takes the GPS coordinates from the seed photo and uses those coordinates as a base target.  It then iterates through the photos in the <source_folder> to see if the GPS match the base target coordinates plus the range specified in <distance_in_feet>.  If they don't match, the photo is ignored.  If they do match, the photo is copied to the <destination_folder>.
