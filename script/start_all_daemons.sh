#!/bin/bash

# 全てのdaemonを起動する
#script/daemons/image_face start
#script/daemons/target_face start
script/daemons/detect_illust start
RAILS_ENV=production script/daemons/download_image start
RAILS_ENV=production script/daemons/copy_image start
RAILS_ENV=production script/daemons/search_images start