#!/usr/bin/bash

# Check if a seed photo 
if [ -z "$1" ]; then
    echo "Usage: $0 <path/to/a/seed_photo.jpg> <distance in feet> <source_folder> <destination_folder> (Please specify seed photo i.e. a photo that seeds the gps coordinates )"
    exit 1
fi

# Check if a distance in feet from the seed photo 
if [ -z "$2" ]; then
    echo "Usage: $0 <path/to/a/seed_photo.jpg> <distance in feet> <source_folder> <destination_folder> (Please the distance in feet for a gps range e.g. 500)"
    exit 1
fi

# Check if a source folder 
if [ -z "$3" ]; then
    echo "Usage: $0 <path/to/a/seed_photo.jpg> <distance in feet> <source_folder> <destination_folder> (Please indicate a source folder)"
    exit 1
fi

# Check if a destination folder 
if [ -z "$4" ]; then
    echo "Usage: $0 <path/to/a/seed_photo.jpg> <distance in feet> <source_folder> <destination_folder> (Please indicate a destination folder)"
    exit 1
fi


seed_photo="$1"
range_in_feet="$2"
source_dir="$3"
destination_dir="$4"

# Create the destination directory if it doesn't exist
mkdir -p "$destination_dir"

# Extract GPS coordinates from the seed photo
seed_latitude=$(exiftool -n -gpslatitude -s3 "$seed_photo")
seed_longitude=$(exiftool -n -gpslongitude -s3 "$seed_photo")

# Calculate the minimum and maximum latitude and longitude values assuming 364,000 feet in a one degree
min_latitude=$(awk "BEGIN {print $seed_latitude - ($range_in_feet / 364000)}")
max_latitude=$(awk "BEGIN {print $seed_latitude + ($range_in_feet / 364000)}")
min_longitude=$(awk "BEGIN {print $seed_longitude - ($range_in_feet / (364000 * cos($seed_latitude * 3.14159 / 180)))}")
max_longitude=$(awk "BEGIN {print $seed_longitude + ($range_in_feet / (364000 * cos($seed_latitude * 3.14159 / 180)))}")

# Find all JPEG files in the source directory recursively
find "$source_dir" -type f -iname "*.jpg" -print0 | while IFS= read -r -d $'\0' image; do
    # Extract the GPS coordinates using exiftool
    latitude=$(exiftool -n -gpslatitude -s3 "$image")
    longitude=$(exiftool -n -gpslongitude -s3 "$image")

    if [ -n "$latitude"  ] || [ -n "$longitude" ]; then
        # Compare the extracted coordinates with the specified range
        if (( $(awk "BEGIN {print ($latitude >= $min_latitude && $latitude <= $max_latitude && $longitude >= $min_longitude && $longitude <= $max_longitude) ? 1 : 0}") )); then
            # Copy the image to the destination directory
            cp "$image" "$destination_dir"
            echo "Copied $image to $destination_dir"
        fi
    else
        echo "Skipping $image -- Incomplete GPS data"
    fi
done
