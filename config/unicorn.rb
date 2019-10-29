app_root = File.expand_path('../../', __FILE__)

# Worker
worker_processes 2

# Sockets
listen 8080
listen "#{app_root}/tmp/hagibis.sock"
pid "#{app_root}/tmp/hagibis.pid"

# Log files
stdout_path "#{app_root}/logs/unicorn.log"
stderr_path "#{app_root}/logs/unicorn.log"
