#!/bin/bash

# This file is necessary because ChakraCore check if CXX or CC is a file,
# so to add extra flags in this way can avoid the failure to pass it as a environment argument.

# The flag is for suppressing "-Werror" to prevent unnecessary building fault. 
$DXR_CXX -Wno-error=unused-command-line-argument "$@"
