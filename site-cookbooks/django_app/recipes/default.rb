# hostsfile_entry '127.0.0.1' do
#   hostname  node["django_app"]["server_name"]
# end

npm_package "less"

python_virtualenv "/.venv/#{node["django_app"]["name"]}" do
  owner "root"
  group "root"
  action :create
end

# bash "install_app" do
#   cwd node["django_app"]["source_path"]
#   code <<-EOH 
#     source /.venv/#{node["django_app"]["name"]}/bin/activate
#     export DJANGO_SETTINGS_MODULE=#{node["django_app"]["name"]}.settings.#{node["django_app"]["settings_module"]}
#     pip install -r requirements/#{node["django_app"]["settings_module"]}.txt
#     python manage.py syncdb --noinput
#     python manage.py migrate
#     python manage.py collectstatic --noinput
#     EOH
#   action :run
# end

gunicorn_config "/etc/gunicorn/#{node["django_app"]["name"]}.py" do
  action :create
  pid "gunicorn.pid"
end

supervisor_service "gunicorn_#{node["django_app"]["name"]}" do
  action [:enable, :start]
  autostart true
  autorestart true
  redirect_stderr true
  environment :DJANGO_SETTINGS_MODULE => "#{node["django_app"]["name"]}.settings.#{node["django_app"]["settings_module"]}", :PATH => "/.venv/#{node["django_app"]["name"]}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/vagrant/bin:"
  command "/.venv/#{node["django_app"]["name"]}/bin/gunicorn #{node["django_app"]["name"]}.wsgi:application -c #{node["django_app"]["name"]}.py -p gunicorn.pid --error-logfile error.log --log-file log.log"
  directory "/#{node["django_app"]["source_path"]}"
  user "root"
  process_name "gunicorn_#{node["django_app"]["name"]}"
end

template "/etc/nginx/sites-enabled/#{node["django_app"]["name"]}" do
    source "nginx.django.conf.erb"
    variables({
      :name => node["django_app"]["name"],
      :server_name => node["django_app"]["server_name"],
      :source_path => node["django_app"]["source_path"],
    })
    owner "root"
    group "root"
    mode "644"
    notifies :reload, "service[nginx]"
end
