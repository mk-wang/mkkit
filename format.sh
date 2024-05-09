#!/bin/sh

if command -v clang-format &> /dev/null
then
	echo "run clang-format"
	find . \( -path ./Pods \) -prune -false -o -name '*.[h,c,m,mm,cpp]' -exec clang-format -i {} \;
fi

if command -v swiftformat &> /dev/null
then
	echo "run swiftformat"
	swiftformat . --exclude Pods,Generated,R.generated.swift
fi

exit 0
