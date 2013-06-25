#
# Cookbook Name:: django_app
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

npm_package "less"

# python_virtualenv "/.venv/pari" do
#   owner "root"
#   group "root"
#   action :create
#   notifies :run, "bash[install_app]"
# end

# bash "install_app" do
#   cwd "/pari"
#   code <<-EOH 
#     source /.venv/pari/bin/activate
#     export DJANGO_SETTINGS_MODULE=pari.settings.prod
#     pip install -r requirements/prod.txt
#     python manage.py syncdb --noinput
#     python manage.py migrate
#     python manage.py collectstatic --noinput
#     EOH
#   action :run
# end

gunicorn_config "/etc/gunicorn/pari.py" do
  action :create
  pid "gunicorn.pid"
end

supervisor_service "gunicorn_pari" do
  action [:enable, :start]
  autostart true
  autorestart true
  redirect_stderr true
  environment :DJANGO_DEBUG => "true", :DJANGO_SETTINGS_MODULE => "pari.settings.prod", :PATH => "/.venv/pari/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/vagrant/bin:"
  command "/.venv/pari/bin/gunicorn pari.wsgi:application -c pari.py -p gunicorn.pid --error-logfile error.log --log-file log.log"
  directory "/pari"
  user "root"
  process_name "gunicorn_pari"
end

template "/etc/nginx/sites-enabled/pari" do
    source "nginx.django.conf.erb"
    owner "root"
    group "root"
    mode "644"
    notifies :reload, "service[nginx]"
end
