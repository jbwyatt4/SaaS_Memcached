require 'rubygems'
require 'json'
require 'digest/md5'

class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:show]
  @@docker_path = '/home/vagrant/docker-master/'
  @@docker_name = "jwyatt/sales_app"

  def index
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def new_instance
    @user = current_user

    #create_docker_instance(type, port)

    type = params[:type]
    port = params[:port]
    create_instance type, port
  end

  def delete_instance
    @user = current_user
    @instance = Instance.find_by_container_id(params[:container_id])

    if @instance.destroy
      flash[:success] = "Instance Deleted!"
    else
      flash[:error] = "Instance not deleted!"
    end
    redirect_to me_path
  end

  def show
    @user = current_user
    @instance = Instance.find_all_by_email(@user.email)
    @md5 = digest = Digest::MD5.hexdigest(@user.email)[0...11]
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome!"
      redirect_to me_path
    else
      render 'new'
    end
  end
  
  private

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def create_instance(type, port)
    instance = Instance.new
    instance.assigned_port = port
    instance.instance_type = type
    instance.email = current_user.email
    if instance.save!
      instance.container_id = SecureRandom.random_number(100000)
      instance.save!
      flash[:success] = "Instance Created!"
      redirect_to me_path
    end
  end

  # You must define the docker_path
  # the target app must be in the docker folder
  def create_docker_instance(type, port)
    instance = Instance.new
    instance.assigned_port = port
    instance.instance_type = type
    instance.user = current_user.email
    if instance.save!
      docker_path = @@docker_path
      docker_name = @@docker_name
       #where type comes into place, in the future have a model function pick this variable
      command_list = 'cd sales_saas && rails s -p #{port}'
      container_id = `#{docker_path}docker run -d -p 11211 #{docker_name} #{command_list} -u daemon`
      cmd = "#{docker_path}docker inspect #{container_id}"
      json_infos = `#{cmd}`
      i = JSON.parse(json_infos)
      instance.container_id = container_id
      instance.save!
      #@user.memcached = i["NetworkSettings"]["PortMapping"]["11211"]
      #@user.container_id = container_id
      #@user.docker_ip = i["NetworkSettings"]["IpAddress"]
      #redirect_to me_path, notice: "Server #{container_id} has now been started!"
    else
      #report error
      #redirect_to me_path, notice: "Error!"
    end
  end
  
  # start and create are seperate b/c docker create creates and starts an app
  def start_docker_instance(id)
    instance = Instance.find_by_container_id(id)

    return_result = `@@docker_path start #{id}`
  end

  def stop_docker_instance(id)
    # search for id, delete id if found, otherwise silently continue
    instance = Instance.find_by_container_id(id)

    # commands to shut it down
    return_result = `@@docker_path stop #{id}`
    #redirect_to me_path, notice: "Server #{id} has been stopped!"
  end

  def destroy_docker_instance(id)
    stop_docker_instance(id)
    # search for id, delete id if found, otherwise silently continue
    instance = Instance.find_by_container_id(id)

    # commands to shut it down
    return_result = `@@docker_path rm #{id}`
    #redirect_to me_path, notice: "Server #{id} has been destroyed!"
  end

  def list_all_instances
    # user version
    # -q=false option only displays numerical IDs
    list = `@@docker_path ps -q=false`

    #then go through each of these... well we just have to post
    return list
  end

  $VALIDATE_IP_REGEX = /^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/  
  def check_ip(i)
    if ($VALIDATE_IP_REGEX.match(i))
      return true;
    end
    return false;
  end
  
  def iptables_add_ip(i)
    cwd = Dir.pwd
    `sudo #{cwd}/iptables/add_ip #{@user.docker_ip} #{i}`
  end

  def iptables_remove_ip(i)
    cwd = Dir.pwd
    `sudo #{cwd}/iptables/remove_ip #{@user.docker_ip} #{i}`
  end

end
