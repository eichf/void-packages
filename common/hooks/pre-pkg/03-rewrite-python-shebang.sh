# This hook executes the following tasks:
#	- rewrites python shebangs with the corresponding python version

hook() {
	local pyver= shebang= warn= off=

	case $pkgname in
	python-*)
		pyver=2.7;;
	python3.4-*)
		pyver=3.4;;
	python3.5-*)
		pyver=3.5;;
	*)
		for i in $pycompile_version $python_versions; do
			if [ "$pyver" ]; then
				warn=1
				break;
			fi
			pyver=$i
		done
		: ${pyver:=2.7}
		;;
	esac

	shebang="#!/usr/bin/python$pyver"
	find ${PKGDESTDIR} -type f -print0 | \
		xargs -0 grep -H -b -m 1 "^#!.*\([[:space:]]\|/\)python\([[:space:]]\|$\)" -- | while IFS=: read -r f off _; do
		[ -z "$off" ] &&  continue
		if [ "$warn" ]; then
			msg_warn "$pkgver: multiple python versions defined! (using $pyver for shebangs)\n"
			unset warn
		fi
		echo "   Unversioned shebang replaced by '$shebang': ${f#$PKGDESTDIR}"
		sed -i "1s@.*python@${shebang}@" -- "$f"
	done
}
