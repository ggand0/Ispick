root = '/var/www/Ispick'

bind "unix:///#{root}/tmp/sockets/puma.sock"
pidfile "#{root}/tmp/pid"
state_path "#{root}/tmp/state"
activate_control_app