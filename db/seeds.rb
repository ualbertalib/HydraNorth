# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin = User.new({
      :email => "dittest@ualberta.ca",
      :password => "password",
      :password_confirmation => "password",
      :group_list => "admin" # this is the important part
    })

admin.skip_confirmation!
admin.save!
