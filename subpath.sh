#!/bin/bash

if [ ! -z "$SUBDIR" ]; then
  DRUPAL_SUBDIR=${SUBDIR:=fake-subdir-placeholder}
  sed -i "s/fake-subdir-placeholder/$SUBDIR/g" /etc/nginx/conf.d/default.conf
fi
