require 'rubygems'
require 'json'
require 'digest/md5'

class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:show]

  def index
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def show
    @user = current_user
    @md5 = digest = Digest::MD5.hexdigest(@user.email)[0...11]
  end

  def create
    @user = User.new(params[:user])
    @user.secure_ip = nil;
    create_docker_instance
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

  # You must define the docker_path
  # the target app must be in the docker folder
  def create_docker_instance
    docker_path = '/home/vagrant/docker-master/'
    docker_name = "jwyatt/sales_app"
    instance_port = "4000"
    command_list = 'cd sales_saas && rails s -p #{instance_port}'
    container_id = `#{docker_path}docker run -d -p 11211 #{docker_name} #{command_list} -u daemon`
    cmd = "#{docker_path}docker inspect #{container_id}"
    json_infos = `#{cmd}`
    i = JSON.parse(json_infos)
    #@user.memcached = i["NetworkSettings"]["PortMapping"]["11211"]
    #@user.container_id = container_id
    #@user.docker_ip = i["NetworkSettings"]["IpAddress"]
  end
  
  def destroy_docker_instance(id)
    # search for id, delete id if found, otherwise silently continue
  end

  def list_all_instances
    # admin only function
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
