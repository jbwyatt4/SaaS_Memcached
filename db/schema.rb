# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130502064659) do

  create_table "instances", :force => true do |t|
    t.integer  "container_id"
    t.string   "ip"
    t.string   "assigned_port"
    t.integer  "instance_type"
    t.string   "unique_hash"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "instance"
    t.integer  "user"
  end

  add_index "instances", ["assigned_port"], :name => "index_instances_on_assigned_port"
  add_index "instances", ["container_id"], :name => "index_instances_on_container_id"
  add_index "instances", ["ip"], :name => "index_instances_on_ip"
  add_index "instances", ["unique_hash"], :name => "index_instances_on_unique_hash"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "password_digest"
    t.boolean  "admin"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
