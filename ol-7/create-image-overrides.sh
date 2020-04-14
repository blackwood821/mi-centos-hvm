#!/bin/bash

# http://yum.oracle.com/ISOS/OracleLinux/OL7/u6/x86_64/OracleLinux-R7-U6-Server-x86_64-dvd.iso

DVD_BASENAME=OracleLinux-R$release-U$update-Server-x86_64-dvd.iso
DVD_PATTERN=^$DVD_BASENAME$

# Official Oracle yum repo (no checksum files available)
# ISO_URL="http://yum.oracle.com/ISOS/${distro// /}/OL$release/u$update/x86_64"

# Unofficial mirror (checksum files available)
ISO_URL="http://mirrors.kernel.org/oracle/OL$release/u$update/x86_64"

# Sets global variables iso_file and iso_sha
get_iso_file_sha() {
	local file

	if [[ -n $iso_file ]]; then
		return
	fi

	echo "Checking to see if we have the iso for $distro $release:"
	file=$DVD_BASENAME.sha256sum
	curl -s -o $iso_dir/$file $ISO_URL/$file

    # NOTE: Oracle mirror doesn't have any .sig or .asc files
	# gpg --verify $iso_dir/$file

	# As new dot releases come out, the name of the iso file changes
	# according to a predictable pattern.  The sha256sums.txt file contains
	# the proper name.
	eval $(awk -v pattern="$DVD_PATTERN" \
	    '$2 ~ pattern { printf("iso_sha=%s; iso_file=%s;", $1, $2) }' \
	    $iso_dir/$file)

	if [[ -z $iso_file || -z $iso_sha ]]; then
		echo "$0: unable to determine ISO file and/or sha256" 1>&2
		exit 1
	fi
}