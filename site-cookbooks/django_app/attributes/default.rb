default["django_app"]["name"] = "pari"
default["django_app"]["debug"] = ""
default["django_app"]["settings_module"] = "prod" 
default["django_app"]["source_path"] = "/pari" 
default["django_app"]["server_name"] = "www.ruralindiaonline.org"
default["django_app"]["db_password"] = node['postgresql']['password']['postgres']
default["django_app"]["db_user"] = "postgres"
default["django_app"]["db_name"] = "pari"
