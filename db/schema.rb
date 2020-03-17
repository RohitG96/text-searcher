# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_200_316_071_917) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'applicants', force: :cascade do |t|
    t.text 'text'
    t.string 'email'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end
end

text_str = File.read('./asd.txt')
text_split = text_str.split
applicants = Applicant.first(10).to_a
app_list = []
(10..10_000).each do |x|
  app = applicants[rand(10)]
  sp = app[:text].split(' ')
  val = {}
  val['email'] = app[:email]
  val['id'] = x
  val['created_at'] = DateTime.now
  val['updated_at'] = DateTime.now
  val['email'] = (text_split.sample(10_000) + sp).shuffle.join(' ').dup
  app_list << val
end
Applicant.insert_all(app_list)
