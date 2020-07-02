#!/bin/sh
#
# @file Ubuntu_repo
# @brief apt-deb repository database creation for Ubuntu
# @date $Date$
# @author Noriaki Ando <n-ando@aist.go.jp>
#
# Copyright (C) 2008-2020
#     Noriaki Ando
#     Intelligent Systems Research Institute,
#     National Institute of
#         Advanced Industrial Science and Technology (AIST), Japan
#     All rights reserved.
#
# $Id$
#

# Global variables:
#
# DEBUG:
#   debug print flag
# BASE_DIR:
#   pacakge base directory that is ending in the name 'ubuntu.'
# CODENAMES:
#   target codenames of ubuntu
# VERSIONS:
#   target version name of ubuntu
# ARCHS:
#   target architecture name
# ALL_DISTRO:
#   all the distroseries name of ubuntu that is obtained from "meta-release"
# SUPPORTED:
#   supported distro names that is obtained from "meta-release"
# SUPPORTED_LIST:
#   supported distro names with version numbers.
#

# Base directory of repository
BASE_DIR=/home/openrtm/public_html/pub/Linux/raspbian
DEFAULT_ARCHS="i386 amd64 armel armhf"
#DEBUG="TRUE"

#------------------------------------------------------------
# Getting distroseries
#
# ALL_DISTRO: all distro names
# SUPPORTED: supported distro names
# SUPPORTED_LIST: supported distro names with version numbers.
#------------------------------------------------------------
get_distroseries()
{
    REL_URL=http://changelogs.ubuntu.com/meta-release
#    if ! test -f /tmp/meta-release; then
#	echo "downloading....0"
#        wget -q -O /tmp/meta-release $REL_URL
#	touch /tmp/meta-release
#    else
        # /tmp/meta-release exists
#	touch -t `date -d '1 hour ago' +%m%d%H%M` /tmp/meta-release.stamp
#	if test /tmp/meta-release -ot /tmp/meta-release.stamp ; then
#	    rm -f /tmp/meta-release
#	    echo "downloading....1"
#	    wget -q -O /tmp/meta-release $REL_URL
#	    touch /tmp/meta-release
#	fi
#	rm -f /tmp/meta-release.stamp
#    fi
#    ALL_DISTRO=`awk 'BEGIN{RS="";FS="\n";}{sub("Dist: ",""); sub(" ","",$1); printf("%s ",$1);}END{printf("\n")}' /tmp/meta-release`
#    SUPPORTED=`awk 'BEGIN{RS="";FS="\n";}{if ($5 == "Supported: 1"){sub("Dist: ",""); sub(" ","",$1); printf("%s ",$1);}}END{printf("\n")}' /tmp/meta-release`
#    SUPPORTED_LIST=`awk 'BEGIN{RS="";FS="\n";}{if ($5 == "Supported: 1"){sub("Dist: ",""); sub("Version: ",""); printf("%s\t%s,",$1,$3);}}' /tmp/meta-release`
    ALL_DISTRO="wheezy jessie stretch buster"
    SUPPORTED="wheezy jessie stretch buster"
    SUPPORTED_LIST="wheezy jessie stretch buster"
}

print_short_usage()
{
#    get_distroseries
    echo "\nUsage: $(basename $0) [OPTION]... [TARGET REPO DIR]"
    echo ""
    echo "Optinos:"
    echo "    -s               Update package DB only supported distro"
    echo "                     Supported: $SUPPORTED"
    echo "    -d [DISTRONAME]  Update pacakge DB only [DISTRONAME]"
    echo "    -a [ARCH]        Target architecture"
    echo "                     ex. i386, amd64"
    echo "    -f               Force update."
    echo "    -h               Print this help"
    echo ""
}

print_usage()
{
    print_short_usage
    echo "Supported Distroseries:"
    local __IFS=$IFS
    IFS=","          # SUPPORTED_LIST'S delimter is ","
    for dist in $SUPPORTED_LIST; do
        echo "    $dist"
    done
    IFS=$__IFS
    echo ""
    echo "EXAMPLES"
    echo "  Update package database under ~openrtm/public_html."
    echo ""
    echo "    $(basename $0) /home/openrtm/public_html/pub/Linux/ubuntu"
    echo ""
    echo "  Update only supported distro version's package DB."
    echo ""
    echo "    $(basename $0) -s /home/openrtm/public_html/pub/Linux/ubuntu"
    echo ""
    echo "  Update only specified distro's pacakge DB."
    echo ""
    echo "    $(basename $0) -d precise ~openrtm/public_html/pub/Linux/ubuntu"
    echo ""
    exit 0
}

get_opt()
{
    # -s                   only supported distro
    # -d <distro name>     only specified distro
    #
    BASE_DIR=""
    ARCHS=""
    while getopts "a:d:sfh" OPT; do
        case $OPT in
            \?) print_short_usage; exit 1;;
	    a) ARCHS="$ARCHS $OPTARG";;
            d) CODENAMES="$CODENAMES $OPTARG";;
            s)
		get_distroseries
		CODENAMES="$SUPPORTED";;
	    f) FORCE_UPDATE="YES";;
            h) print_usage; exit 0;
        esac
    done
    shift $(( $OPTIND - 1))

    # Target directory must be specified.
    if test $# -eq 0; then
	echo "Error: please specify target directory."
        print_short_usage
        exit 1
    else
	BASE_DIR=$1
    fi

    # If -d/-s are not specified, all distro's package DB are updated.
    if test "x$CODENAMES" = "x"; then
#	get_distroseries
	CODENAMES=$ALL_DISTRO
    fi
    if test "x$ARCHS" = "x"; then
	ARCHS=$DEFAULT_ARCHS
    fi

    # DEBUG
    if ! test "x$DEBUG" = "x"; then
	echo "BASE_DIR: " $BASE_DIR
        echo "CODENAMES: " $CODENAMES
        echo "ARCHS   : " $ARCHS
    fi
}




#------------------------------------------------------------
# Check if newer package than Pakcage.gz
#
# have_new_package <directory>
#   have new pacakge: returns 0
#   have no new pacakge: returns 1
#------------------------------------------------------------
have_new_package()
{
    if test "x$FORCE_UPDATE" = "xYES"; then
	return 0
    fi
    debdir=$1
    # No Packages.gz -> Packages.gz must be created: return 0
    if test ! -f $debdir/Packages.gz ; then
	return 0
    fi
    files=`find $debdir -type f -newer $debdir/Packages.gz`
    if test "x$files" = "x" ; then
	return 1
    fi
    # newer file exists
    return 0
}


#----------
# main
#----------
get_distroseries
get_opt $@
cd  $BASE_DIR

for codename in $CODENAMES; do
    for arch in $ARCHS ; do
	pkg_dir=dists/$codename/main/binary-$arch
	if test ! -d $pkg_dir; then
	    echo ""
	    echo "No package directory exists:"
	    echo "    $pkg_dir"
	    continue
	fi
	if have_new_package $BASE_DIR/$pkg_dir ; then
	    echo ""
	    echo "Creating apt-dev database under:"
	    echo "    $pkg_dir"
	    dpkg-scanpackages -m $pkg_dir > $BASE_DIR/$pkg_dir/Packages
	    gzip -c $BASE_DIR/$pkg_dir/Packages > $BASE_DIR/$pkg_dir/Packages.gz
            apt-ftparchive \
		-o APT::FTPArchive::Release::Origin="OpenRTM-aist" \
                -o APT::FTPArchive::Release::Label="Packages hosted by OpenRTM-aist" \
                -o APT::FTPArchive::Release::Suite="$codename" \
                -o APT::FTPArchive::Release::Codename="$codename" \
                -o APT::FTPArchive::Release::Architectures="armhf" \
                -o APT::FTPArchive::Release::Components="main" \
                -o APT::FTPArchive::Release::Description="Debian armhf distribution for Raspberry Pi" \
	    	release dists/$codename > dists/$codename/Release
            gpg2 -abs --yes --digest-algo SHA256 --batch --passphrase-file /home/openrtm/.openrtm-key-psw -o dists/$codename/Release.gpg dists/$codename/Release
            gpg2 -as --clearsign --yes --digest-algo SHA256 --batch --passphrase-file /home/openrtm/.openrtm-key-psw -o dists/$codename/InRelease dists/$codename/Release
	else
	    echo ""
	    echo "No new packages found under: "
	    echo "    $pkg_dir"
	fi

    done
done

echo ""

exit 0
