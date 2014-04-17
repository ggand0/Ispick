#!/bin/bash

# 全てのdaemonを起動する
#script/daemons/image_face restart
#script/daemons/target_face restart
RAILS_ENV=production script/daemons/detect_illust restart
RAILS_ENV=production script/daemons/download_image restart
RAILS_ENV=production script/daemons/copy_image restart
RAILS_ENV=production script/daemons/search_images restart