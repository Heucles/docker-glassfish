#!/bin/bash

git checkout jdk7 && git merge master && git checkout jdk8 && git merge master && git checkout master && git push --all
