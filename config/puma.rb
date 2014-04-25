root = '/var/www/Ispick'

bind "unix://#{root}/shared/tmp/sockets/puma.sock"
pidfile "#{root}/shared/tmp/pid"
state_path "#{root}/shared/tmp/state"
activate_control_app