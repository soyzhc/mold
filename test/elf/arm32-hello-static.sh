#!/bin/bash
export LC_ALL=C
set -e
CC="${CC:-cc}"
CXX="${CXX:-c++}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t=out/test/elf/$testname
mkdir -p $t

echo 'int main() {}' | arm-linux-gnueabihf-gcc -o $t/exe -xc - >& /dev/null \
  || { echo skipped; exit; }

cat <<EOF | arm-linux-gnueabihf-gcc -o $t/a.o -c -g -xc -
#include <stdio.h>

int main() {
  printf("Hello world\n");
  return 0;
}
EOF

arm-linux-gnueabihf-gcc -B. -o $t/exe $t/a.o -L/usr/arm-linux-gnueabihf/lib \
  -Wl,-rpath,/usr/arm-linux-gnueabihf/lib

# readelf -p .comment $t/exe | grep -qw mold
readelf -a $t/exe | grep -Eq 'Machine:\s+ARM'
$t/exe | grep -q 'Hello world'

echo OK
