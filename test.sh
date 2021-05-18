#!/bin/sh

db_backup=$1
ending=.tar.gz
if test $db_backup != "*\.tar\.gz"; then
  echo adding $ending to filename $db_backup
  db_backup=$db_backup$ending
fi
echo Filename is now $db_backup
