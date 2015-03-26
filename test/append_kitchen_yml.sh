#!/bin/bash

for i in tmp/*
do
  DIR=$(echo ${i} | awk -F'/' '{print $2}')
  echo -e "\nsuites:" >> ${i}/.kitchen.yml
  echo "  - name: ${DIR}" >> ${i}/.kitchen.yml
  echo "    run_list:" >> ${i}/.kitchen.yml
  echo "      - recipe[${DIR}::kitchen_test]" >> ${i}/.kitchen.yml
done
