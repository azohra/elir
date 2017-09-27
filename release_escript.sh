#!/usr/bin/env bash

MIX_ENV=prod mix escript.build
tar -czvf elir.tar.gz elir