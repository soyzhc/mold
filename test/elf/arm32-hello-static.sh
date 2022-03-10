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

[ "$(uname -m)" = x86_64 ] || { echo skipped; exit; }

echo 'int main() {}' | arm-linux-gnueabi-gcc -o $t/exe -xc - >& /dev/null \
  || { echo skipped; exit; }

cat <<EOF | arm-linux-gnueabi-gcc -o $t/a.o -c -g -xc -
#include <stdio.h>

int main() {
  printf("Hello world\n");
  return 0;
}
EOF

arm-linux-gnueabi-gcc -B. -o $t/exe $t/a.o

# readelf -p .comment $t/exe | grep -qw mold

# readelf -a $t/exe > $t/log
grep -Eq 'Machine:\s+ARM' $t/log
qemu-arm -L /usr/arm-linux-gnueabi $t/exe | grep -q 'Hello world'

echo OK
