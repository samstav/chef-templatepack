#!/bin/bash

for i in tmp/*
do
  rubocop -c .rubocop.yml ${i}
  if [ "$?" -ne "0" ]; then
    echo "Rubocop for ${i} failed"
    exit 1
  fi
  foodcritic --tags ~FC041 ${i}
  if [ "$?" -ne "0" ]; then
    echo "Foodcritic for ${i} failed"
    exit 1
  fi
done
