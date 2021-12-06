#!/bin/bash

git add .
git commit -m "updated from: ${ZENV}";
git pull;
git push;