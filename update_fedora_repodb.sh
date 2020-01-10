#!/bin/sh
#
# @file fedora_repo
# @brief yum repository database creation for Fedora
# @date $Date$
# @author Noriaki Ando <n-ando@aist.go.jp>
#
# Copyright (C) 2008-2013
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
# VERSIONS:
#   target version name of ubuntu
# ARCHS:
#   target architecture name
# ALL_DISTRO:
#   all the version names of fedora that is obtained from "fedora wiki"
#   ex. "Fedora 18 (Spherical Cow), Fedora 19 (Schlodinger's Cat)"
# SUPPORTED_DISTRO:
#   supported version names that is obtained from "fedora wiki"
# OLD_DISTRO:
#   unsupported version names that is obtained from "fedora wiki"
# OPENRTM_SUPPORTED_DISTRO:
#   OpenRTM-aist's support version names of fedora (supported + 1)
# ALL_VERSIONS:
#   all the numerical version numbers of fedora. ex. "17 18 19"
# SUPPORTED_VERSIONS:
#   numerical version numbers of supported fedora versions
# OLD_VERSIONS:
#   numerical version numbers of unsupported fedora versions
# OPENRTM_SUPPORTED_VERSIONS:
#   OpenRTM-aist's support versions of fedora (supported + 1)
#

# Base directory of repository
BASE_DIR=/home/openrtm/public_html/pub/Linux/Fedora/releases/
#DEFAULT_ARCHS="i686 i386 x86_64 source"
DEFAULT_ARCHS="i386 x86_64 source"
#DEBUG="TRUE"

#------------------------------------------------------------
# Getting distroseries
#
# ALL_DISTRO: all the version names of fedora
# SUPPORTED_DISTRO: supported version names
# OLD_DISTRO: unsupported version names
# OPENRTM_SUPPORTED_DISTRO: OpenRTM-aist's support version names
# ALL_VERSIONS: all the numerical version numbers
# SUPPORTED_VERSIONS: numerical version numbers
# OLD_VERSIONS: numerical version numbers
# OPENRTM_SUPPORTED_VERSIONS: OpenRTM-aist's support versions
#------------------------------------------------------------
get_distroseries()
{
    REL_URL=https://fedoraproject.org/wiki/Releases
    if ! test -f /tmp/fedora-release; then
        echo "downloading....0"
        wget --no-check-certificate -q -O /tmp/fedora-release $REL_URL
        touch /tmp/fedora-release
    else
        # /tmp/fedora-release exists
        touch -t `date -d '1 hour ago' +%m%d%H%M` /tmp/fedora-release.stamp
        if test /tmp/fedora-release -ot /tmp/fedora-release.stamp ; then
            rm -f /tmp/fedora-release
            echo "downloading....1"
            wget --no-check-certificate -q -O /tmp/fedora-release $REL_URL
            touch /tmp/fedora-release
        fi
        rm -f /tmp/fedora-release.stamp
    fi
    awk '/<[hH]2>.*Current Supported/ {flag = 1;}
         /<[l][i]>.<[b]>Fedora/ {
           if (flag == 1) {
             sub("<b>",""); sub("</b>","");
             print $0;
           }
         }' /tmp/fedora-release |
         sed -s 's/.*\(Fedora [^)]*)\).*$/\1/' > /tmp/fedora-current
    awk '/<[hH]2>.*Old Unsupported/ {flag = 1;}
         /Fedora.*Release Notes/ {
           if (flag == 1) {
             sub("<b>",""); sub("</b>","");
             print $0;
           }
         }' /tmp/fedora-release |
         sed -s 's/.*\(Fedora [^)]*)\).*$/\1/' > /tmp/fedora-old
    local __IFS=$IFS
    IFS='
'
    ALL_DISTRO=`cat /tmp/fedora-current ; cat /tmp/fedora-old`
    SUPPORTED_DISTRO=`cat /tmp/fedora-current`
    OLD_DISTRO=`cat /tmp/fedora-old`
    OPENRTM_SUPPORTED_DISTRO=`cat /tmp/fedora-current ;
                              head -1 /tmp/fedora-old`

    SUPPORTED_VERSIONS=`cat /tmp/fedora-current | 
                        sed -s 's/^.* \([0-9]*\) .*$/\1/'`
    SUPPORTED_VERSIONS=`echo $SUPPORTED_VERSIONS | sed -s 's/\n/ /g'`
    OLD_VERSIONS=`cat /tmp/fedora-old | 
                  sed -s 's/^.* \([0-9]*\) .*$/\1/'`
    OLD_VERSIONS=`echo $OLD_VERSIONS | sed -s 's/\n/ /g'`
    ALL_VERSIONS="$SUPPORTED_VERSIONS $OLD_VERSIONS"
    OPENRTM_SUPPORT_VERSIONS=`echo $SUPPORTED_VERSIONS ; 
                              echo $OLD_VERSIONS | awk '{print $1;}'`
    OPENRTM_SUPPORT_VERSIONS=`echo $OPENRTM_SUPPORT_VERSIONS |
                              sed -s 's/\n/ /g'`
    if test "x$DEBUG" != "x" ; then
	echo "ALL_DISTRO: " $ALL_DISTRO
	echo "SUPPORTED_DISTRO: " $SUPPORTED_DISTRO
	echo "OLD_DISTRO: " $OLD_DISTRO
	echo "OPENRTM_SUPPORTED_DISTRO: " $OPENRTM_SUPPORT_DISTRO

	echo "SUPPORTED_VERSIONS: " $SUPPORTED_VERSIONS
	echo "OLD_DISTRO: " $OLD_VERSIONS
	echo "OPENRTM_SUPPORTED_VERSIONS: " $OPENRTM_SUPPORT_VERSIONS
    fi
    IFS=$__IFS
}

print_short_usage()
{
    get_distroseries
    echo "\nUsage: $(basename $0) [OPTION]... [TARGET REPO DIR]"
    echo ""
    echo "Optinos:"
    echo "    -s               Update DB only supported versions"
    echo "                     Supported: Fedora $SUPPORTED_VERSIONS"
    echo "    -o               Update DB only OpenRTM-supported versions"
    echo "                     Supported: Fedora $OPENRTM_SUPPORT_VERSIONS"
    echo "    -v [VERSION]     Update pacakge DB only [VERSION"
    echo "    -a [ARCH]        Target architecture"
    echo "                     ex. i386, x86_64"
    echo "    -f               Force update."
    echo "    -h               Print this help"
    echo ""
}

print_usage()
{
    print_short_usage
    echo "Supported Versions:"
    local __IFS=$IFS
    IFS='
'          # SUPPORTED_LIST'S delimter is "\n"
    for dist in $SUPPORTED_DISTRO; do
        echo "    $dist"
    done
    echo ""
    echo "OpenRTM-aist Supported Versions:"
    for dist in $OPENRTM_SUPPORTED_DISTRO; do
        echo "    $dist"
    done
    IFS=$__IFS
    echo ""
    echo "EXAMPLES"
    echo "  Update package database under ~openrtm/public_html."
    echo ""
    echo "    $(basename $0) /home/openrtm/public_html/pub/Linux/Fedora"
    echo ""
    echo "  Update only supported distro version's package DB."
    echo ""
    echo "    $(basename $0) -s /home/openrtm/public_html/pub/Linux/Fedora"
    echo ""
    echo "  Update only specified distro's pacakge DB."
    echo ""
    echo "    $(basename $0) -d precise ~openrtm/public_html/pub/Linux/Fedora"
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
    while getopts "a:v:sofh" OPT; do
        case $OPT in
            \?) print_short_usage; exit 1;;
            a) ARCHS="$ARCHS $OPTARG";;
            v) VERSIONS="$VERSIONS $OPTARG";;
            s)
                get_distroseries
                VERSIONS="$SUPPORTED_VERSIONS";;
            o)
                get_distroseries
                VERSIONS="$OPENRTM_SUPPORT_VERSIONS";;
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

    # If -v/-s/-o are not specified, all distro's package DB are updated.
    if test "x$VERSIONS" = "x"; then
        get_distroseries
        VERSIONS=$ALL_VERSIONS
    fi
    if test "x$ARCHS" = "x"; then
        ARCHS=$DEFAULT_ARCHS
    fi

    # DEBUG
    if ! test "x$DEBUG" = "x"; then
        echo "BASE_DIR: " $BASE_DIR
        echo "VERSIONS: " $VERSIONS
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
    if test "x$DEBUG" != "x" ; then
	echo "have_new_pachage( $1 )"
    fi
    if test "x$FORCE_UPDATE" = "xtrue"; then
        return 0
    fi
    rpmdir=$1
    # No Packages.gz -> Packages.gz must be created: return 0
    if test ! -f $rpmdir/repodata/primary.xml.gz ; then
	if test "x$DEBUG" != "x" ; then echo "No repo db file" ; fi
        return 0
    fi
    files=`find $rpmdir -type f -newer $rpmdir/repodata/primary.xml.gz`
    if test "x$files" = "x" ; then
	if test "x$DEBUG" != "x" ; then echo "No new file" ; fi
        return 1
    fi
    # newer file exists
    if test "x$DEBUG" != "x" ; then echo "New file exists" ; fi
    return 0
}

#----------
# main
#----------
get_opt $@
cd $BASE_DIR
IFS=" "
for version in $VERSIONS; do
    for arch in $ARCHS ; do
	if test "x$arch" = "xsource" ; then
            pkg_dir=releases/$version/Fedora/source/SRPMS
	    ptype="SRPM"
	else
            pkg_dir=releases/$version/Fedora/$arch/os/Packages
	    ptype="RPM"
	fi
        if test ! -d $BASE_DIR/$pkg_dir; then
            echo ""
            echo "No package directory exists:"
            echo "    $BASE_DIR/$pkg_dir"
            continue
        fi
        if have_new_package $BASE_DIR/$pkg_dir ; then
            echo ""
            echo "Creating $ptype database under:"
            echo "    $pkg_dir"
            createrepo -v $pkg_dir
        else
            echo ""
            echo "No new packages found under: "
            echo "    $pkg_dir"
        fi

    done
done

echo ""

exit 0

