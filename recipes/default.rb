def setup_containers
  setup_docker_group
  start_redis_container
  create_data_directory
  start_postgres_container
  start_elasticsearch_container
  print_next_instructions
end

def setup_docker_group
  group "docker" do
    action :modify
    members "vagrant"
    append true
  end
end

def start_redis_container
  execute "redis-container" do
    command "docker run -d -i --name prototype-redis -t redis"
    action :run
  end
end

def create_data_directory
  directory "/data" do
    owner "vagrant"
    group "vagrant"
    mode "0755"
    action :create
  end
end

def start_postgres_container
  execute "postres-container" do
    command "docker run -d -i --name prototype-postgres -v /data:/var/lib/postgresql/data -t postgres"
    action :run
  end
end

def start_elasticsearch_container
  execute "elasticsearch-container" do
    command "docker run -d -i --name prototype-elasticsearch -v /data:/data dockerfile/elasticsearch /elasticsearch/bin/elasticsearch -Des.config=/elasticsearch/config/elasticsearch.yml"
    action :run
  end
end

def print_next_instructions
  bash "echo-instructions" do
    code <<-EOF
      echo "#{"* "*80}\n"\
           "Now that you have got all support containers up and running,\n"\
           "Create an account at http://hub.docker.com and ask the team\n"\
           "to add you to the project. Once you've done that, you should\n"\
           "log in to your account \033[0;31min the VM\033[0m with the command:\n"\
           "docker login\n"\
           "Then, you can start the webserver by running the command:\n"\
           "docker run -i --rm --name prototype --link prototype-elasticsearch:elasticsearch --link prototype-redis:redis --link prototype-postgres:postgres -p 3000:3000 -v $(pwd):/app -t azisaka/prototype\n"\
           "Should you have any questions, ask away! Zisa is always on Slack :D"
    EOF
  end
end

setup_containers
