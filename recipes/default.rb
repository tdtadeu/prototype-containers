def setup_containers(users)
  create_data_directory
  setup_docker_group
  start_redis_container(users)
  start_postgres_container(users)
  start_elasticsearch_container(users)
  print_next_instructions
end

def create_data_directory
  directory "data" do
    path "/data"
    owner "999"
    group "root"
    mode "0700"
    action :create
  end
end

def setup_docker_group
  group "docker" do
    action :modify
    members "vagrant"
    append true
  end
end

def start_redis_container(users)
  users.each do |user|
    execute "redis-container" do
      command "docker run -d -i --name prototype-redis -t redis"
      user "vagrant"
      group "docker"
      action :run
      ignore_failure true
      not_if { File.exists?("/home/#{user}/.redis.semaphore") }
    end

    file "redis-semaphore" do
      path "/home/#{user}/.redis.semaphore"
      owner user
      action :create_if_missing
    end
  end
end

def start_postgres_container(users)
  users.each do |user|
    execute "postres-container" do
      command "docker run -d -i --name prototype-postgres -v /data:/var/lib/postgresql/data -t postgres"
      user "vagrant"
      group "docker"
      ignore_failure true
      not_if { File.exists?("/home/#{user}/.postgres.semaphore") }
    end

    file "postgres-semaphore" do
      path "/home/#{user}/.postgres.semaphore"
      owner user
      action :create_if_missing
    end
  end
end

def start_elasticsearch_container(users)
  users.each do |user|
    execute "elasticsearch-container" do
      command "docker run -d -i --name prototype-elasticsearch -v /data:/data dockerfile/elasticsearch /elasticsearch/bin/elasticsearch -Des.config=/elasticsearch/config/elasticsearch.yml"
      user "vagrant"
      group "docker"
      action :run
      ignore_failure true
      not_if { File.exists?("/home/#{user}/.elasticsearch.semaphore") }
    end

    file "elasticsearch-semaphore" do
      path "/home/#{user}/.elasticsearch.semaphore"
      owner user
      action :create_if_missing
    end
  end
end

def print_next_instructions
  log "string" do
    message <<-EOF
     \n
\033[0m#{"* "*80}
* Now that you have got all support containers up and running,
* Create an account at \033[0;34mhttp://hub.docker.com \033[0mand ask the team
* to add you to the project. Once you've done that, you should
* log in to your account \033[1;31minside the VM \033[0mwith the command:
* \033[1;37mdocker login
\033[0m* Then, you can start the webserver by running the command:
* \033[1;37mdocker run -i --rm --name prototype --link prototype-elasticsearch:elasticsearch --link prototype-redis:redis --link prototype-postgres:postgres -p 3000:3000 -v $(pwd):/app -t azisaka/prototype
\033[0m* Should you have any questions, ask away! Zisa is always on Slack :D
#{"* "*80}
    EOF
    level :info
  end
end

users = node[:containers][:users]

setup_containers(users)
