#!/bin/sh


echo "This is an autoscript test."


work_tree=$(git rev-parse --show-toplevel)


cp $work_tree/checktools/pre-commit $work_tree/.git/hooks/
