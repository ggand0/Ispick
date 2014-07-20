#!/bin/bash

# 全てのdaemonを起動する
script/daemons/detect_illust restart
script/daemons/download_image restart
script/daemons/search_images restart

exit