#!/bin/sh

if command -v clang-format &> /dev/null
then
	echo "run clang-format"
	find . \( -path ./Pods -or -path ./MuPDF \) -prune -false -o -name '*.[h,c,m,mm,cpp]' -exec clang-format -i {} \;
fi

if command -v swiftformat &> /dev/null
then
	echo "run swiftformat"
	swiftformat . --swiftversion 5.7 --exclude Pods,Generated,R.generated.swift
fi

exit 0
