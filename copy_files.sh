#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./copy_files.sh [-r pattern] <source_directory> <target_directory>
#
# Examples:
#   ./copy_files.sh ~/Downloads/source ~/Documents/collected
#   ./copy_files.sh -r "file_###" ~/Downloads/source ~/Documents/collected

RENAME_PATTERN=""
while getopts ":r:" opt; do
  case "$opt" in
    r) RENAME_PATTERN="$OPTARG" ;;
    *) echo "Usage: $0 [-r rename_pattern] <source> <target>" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 [-r rename_pattern] <source> <target>" >&2
  exit 1
fi

SRC="$1"
DST="$2"

# Ensure source exists
if [ ! -d "$SRC" ]; then
  echo "Error: Source directory '$SRC' does not exist." >&2
  exit 1
fi

# Create target if missing
mkdir -p "$DST"
SOURCE_DIR="$(cd "$SRC" && pwd)"
TARGET_DIR="$(cd "$DST" && pwd)"
SOURCE_DIR="${SOURCE_DIR%/}"
TARGET_DIR="${TARGET_DIR%/}"

if [ "$SOURCE_DIR" = "$TARGET_DIR" ]; then
  echo "Source and target cannot be the same directory." >&2
  exit 1
fi

counter=1

# Make videos subdir if needed
VIDEOS_DIR="$TARGET_DIR/videos"
mkdir -p "$VIDEOS_DIR"

# Find files safely
while IFS= read -r -d '' file; do
  filename=$(basename "$file")
  ext="${filename##*.}"
  base="${filename%.*}"

  # Decide if file is a video
  is_video=false
  if [[ "${ext}" == "mp4" ]]; then
    is_video=true
  fi

  # Apply rename pattern if provided
  if [ -n "$RENAME_PATTERN" ]; then
    num=$(printf "%03d" "$counter")
    if [[ "$RENAME_PATTERN" == *"###"* ]]; then
      newbase="${RENAME_PATTERN//###/$num}"
    else
      newbase="${RENAME_PATTERN}_${num}"
    fi

    if [ "$ext" != "$filename" ]; then
      newname="${newbase}.${ext}"
    else
      newname="$newbase"
    fi
    counter=$((counter+1))
  else
    newname="$filename"
    # Handle conflicts if no renaming pattern
    dest_dir=$TARGET_DIR
    if $is_video; then dest_dir=$VIDEOS_DIR; fi
    if [ -e "$dest_dir/$newname" ]; then
      relpath="${file#$SOURCE_DIR/}"
      hash=$(printf '%s' "$relpath" | shasum -a 1 | awk '{print substr($1,1,8)}')
      if [ "$ext" != "$filename" ]; then
        newname="${base}_${hash}.${ext}"
      else
        newname="${base}_${hash}"
      fi
    fi
  fi

  # Final destination directory
  if $is_video; then
    dest="$VIDEOS_DIR/$newname"
  else
    dest="$TARGET_DIR/$newname"
  fi

  # Copy file instead of moving
  cp -- "$file" "$dest"
done < <(find "$SOURCE_DIR" -type f -not -path "$TARGET_DIR/*" -print0)

echo "Done: files copied to '$TARGET_DIR' (videos in '$VIDEOS_DIR')."
