#! /bin/bash
readonly input="$1"
# Create a read-only disk image of the contents of a folder
# This is used as a compactor of sparse disks
# Usage: make-diskimage <image_file>
#                       <src_folder>
#                       <volume_name>
#                       <applescript>


Hdiutil compact  "$1"

