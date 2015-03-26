#!/bin/bash
./test/build_all_test_jsons.sh
./test/lint_all_test_cookbooks.sh
./test/append_kitchen_yml.sh
