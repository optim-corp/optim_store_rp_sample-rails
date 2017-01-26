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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161117083825) do

  create_table "connect_clients", force: :cascade do |t|
    t.integer  "contract_id"
    t.string   "identifier",  null: false
    t.string   "secret",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["contract_id"], name: "index_connect_clients_on_contract_id"
    t.index ["identifier"], name: "index_connect_clients_on_identifier", unique: true
  end

  create_table "contracts", force: :cascade do |t|
    t.string   "identifier",       null: false
    t.text     "their_public_key", null: false
    t.text     "our_private_key",  null: false
    t.integer  "license_pool",     null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["identifier"], name: "index_contracts_on_identifier", unique: true
  end

  create_table "scim_clients", force: :cascade do |t|
    t.integer  "contract_id"
    t.string   "identifier",  null: false
    t.string   "secret",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["contract_id"], name: "index_scim_clients_on_contract_id"
    t.index ["identifier"], name: "index_scim_clients_on_identifier", unique: true
  end

  create_table "tokens", force: :cascade do |t|
    t.integer  "client_id"
    t.string   "access_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["access_token"], name: "index_tokens_on_access_token", unique: true
    t.index ["client_id"], name: "index_tokens_on_client_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer  "contract_id"
    t.string   "identifier",                 null: false
    t.boolean  "active",      default: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["contract_id"], name: "index_users_on_contract_id"
    t.index ["identifier"], name: "index_users_on_identifier", unique: true
  end

end
