# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

file = File.read('./sample-resume-text.json')
data_json = JSON.parse(file)['resumes']
app_data = []
i = 0
data_json.each do |x|
  y = x.dup
  y['id'] = i
  y['updated_at'] = DateTime.now
  y['created_at'] = DateTime.now
  app_data << y.dup
  i += 1
end
Applicant.insert_all(app_data)
text_str = File.read('./asd.txt')
text_split = text_str.split
applicants = Applicant.first(10).to_a

(1..1000).each do |x|
  app_list = []
  (1..100).each do |_y|
    app = applicants[rand(10)]
    sp = app[:text]
    val = {}
    val['email'] = app[:email]
    val['created_at'] = DateTime.now
    val['updated_at'] = DateTime.now
    val['text'] = (text_split.sample(10_000) + sp.split(' ')).shuffle.join(' ')
    app_list << val.dup
  end
  puts x, app_list.to_s.size
  Applicant.insert_all(app_list)
end
