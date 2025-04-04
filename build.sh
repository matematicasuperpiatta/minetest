#!/bin/bash

cmake . -DRUN_IN_PLACE=TRUE -DBUILD_SERVER=TRUE -DBUILD_CLIENT=FALSE
make -j $(nproc)