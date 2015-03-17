#!/bin/bash

for D in source1/*
do
	echo $D
	find $D | grep "\.java" | grep -v "ccfx" | xargs cat | wc -l > $D.loc
done

