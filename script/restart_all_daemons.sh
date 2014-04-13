#!/bin/bash

# 全てのdaemonを起動する
script/daemons/image_face restart
script/daemons/target_face restart
script/daemons/detect_illust restart
script/daemons/download_image restart