# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_21_014122) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "recipe_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["recipe_id", "created_at"], name: "index_comments_on_recipe_id_and_created_at"
    t.index ["recipe_id"], name: "index_comments_on_recipe_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "cook_photos", force: :cascade do |t|
    t.string "caption"
    t.datetime "created_at", null: false
    t.bigint "recipe_id", null: false
    t.text "thumbnail_base64"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["recipe_id", "created_at"], name: "index_cook_photos_on_recipe_id_and_created_at"
    t.index ["recipe_id"], name: "index_cook_photos_on_recipe_id"
    t.index ["user_id"], name: "index_cook_photos_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "recipe_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["recipe_id"], name: "index_favorites_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_favorites_on_user_id_and_recipe_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.text "aliases"
    t.string "category"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_ingredients_on_category"
    t.index ["name"], name: "index_ingredients_on_name"
  end

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "recipe_id", null: false
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["recipe_id"], name: "index_ratings_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_ratings_on_user_id_and_recipe_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "ingredient_id", null: false
    t.string "notes"
    t.string "quantity"
    t.integer "recipe_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipe_steps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "instruction"
    t.integer "recipe_id", null: false
    t.integer "step_number"
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_steps_on_recipe_id"
  end

  create_table "recipe_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "recipe_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "tag_id"], name: "index_recipe_tags_on_recipe_id_and_tag_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_tags_on_recipe_id"
    t.index ["tag_id"], name: "index_recipe_tags_on_tag_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "chef_name"
    t.integer "cook_time"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "inspired_by"
    t.integer "prep_time"
    t.tsvector "search_vector"
    t.integer "servings"
    t.string "source_type"
    t.string "source_url"
    t.text "thumbnail_base64"
    t.string "thumbnail_url"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "visibility", default: "private", null: false
    t.index ["search_vector"], name: "index_recipes_on_search_vector", using: :gin
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "shopping_list_items", force: :cascade do |t|
    t.boolean "checked", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "ingredient_id", null: false
    t.string "quantity"
    t.bigint "recipe_id"
    t.bigint "shopping_list_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_shopping_list_items_on_ingredient_id"
    t.index ["recipe_id"], name: "index_shopping_list_items_on_recipe_id"
    t.index ["shopping_list_id", "ingredient_id"], name: "idx_on_shopping_list_id_ingredient_id_f6963fd74f"
    t.index ["shopping_list_id"], name: "index_shopping_list_items_on_shopping_list_id"
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_shopping_lists_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "recipes"
  add_foreign_key "comments", "users"
  add_foreign_key "cook_photos", "recipes"
  add_foreign_key "cook_photos", "users"
  add_foreign_key "favorites", "recipes"
  add_foreign_key "favorites", "users"
  add_foreign_key "ratings", "recipes"
  add_foreign_key "ratings", "users"
  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "recipe_steps", "recipes"
  add_foreign_key "recipe_tags", "recipes"
  add_foreign_key "recipe_tags", "tags"
  add_foreign_key "recipes", "users"
  add_foreign_key "shopping_list_items", "ingredients"
  add_foreign_key "shopping_list_items", "recipes"
  add_foreign_key "shopping_list_items", "shopping_lists"
  add_foreign_key "shopping_lists", "users"
end
