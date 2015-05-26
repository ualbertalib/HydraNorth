require './lib/tasks/migration/migration_logger'

namespace :migration do
  desc "migrate users from era to hydranorth"
  task :user_migration, [:user_file] => :environment do |t, args|
    begin 
      MigrationLogger.info "***************START: User Migration ***************"
      user_mysql_file = args.user_file
      if File.exists?(user_mysql_file) && File.file?(user_mysql_file)
        migrate_users(user_mysql_file)
      else
        MigrationLogger.fatal "Invalid file #{user_mysql_file}"
      end
      MigrationLogger.info "****************FINISH: User Migration **************"
    rescue
      raise
    end
  end

  def migrate_users(user_mysql_file)
    File.open(user_mysql_file, "r") do |f|
      n = 1
      f.each_line do |line|
        begin
          fields = line.split('~')
          id = fields[0].strip
          first_name = fields[1].strip.gsub(/"+/,'') if !fields[1].nil? && !fields[1].blank?
          last_name = fields[2].strip.gsub(/"+/,'') if !fields[2].nil? && !fields[2].blank?
          username = fields[3].strip.gsub(/"+/,'') if !fields[3].nil? && !fields[3].blank?
          password = fields[4].strip.gsub(/"+/,'') if !fields[4].nil? && !fields[4].blank?
          email = fields[5].strip.gsub(/"+/,'') if !fields[5].nil? && !fields[5].blank?
          ccid = fields[6].strip.gsub(/"+/,'') if !fields[6].nil? && !fields[6].blank?
          display_name = first_name + " " +last_name if first_name && last_name
          description = fields[7].strip.gsub(/"/,'') if !fields[7].nil? && !fields[7].blank?
          institution = fields[8].strip.gsub(/"/,'') if !fields[8].nil? && !fields[8].blank?
          address = fields[9].strip.gsub(/"/,'') if !fields[9].nil? && !fields[9].blank?
          telephone = fields[10].strip.gsub(/"/,'') if !fields[10].nil? && !fields[10].blank?
          fax = fields[11].strip.gsub(/"/,'') if !fields[11].nil? && !fields[11].blank?
          website = fields[12].strip.gsub(/"/,'') if !fields[12].nil? && !fields[12].blank?
          MigrationLogger.info "Migrate user #{id}: #{username}"
          if !User.find_by_user_key(email)

            user=User.new({
              :first_name => first_name,
              :last_name => last_name,
              :username => username,
              :password => password,
              :password_confirmation => password,
              :display_name => display_name,
              :email => email,
              :ccid => ccid,
              :description => description,
              :institution => institution,
              :address => address,
              :telephone => telephone,
              :fax => fax,
              :website => website,
              :legacy_password => password,
              :confirmed_at => Time.now
              }) 
            MigrationLogger.info "User #{username} migrated successfully"
            user.skip_confirmation! 
            user.save!
          end
          if User.find_by_user_key(email) 
            MigrationLogger.info "User #{id} #{username} is migrated successfully"
          else
            MigrationLogger.info "FAILED: User #{id} #{username} has not migrated."
          end
          n = n + 1
          ActiveRecord::Base.connection.close
        rescue Exception => e
          puts "FAILED: User #{id} migration at #{n}!"
          puts e.message
          puts e.backtrace.inspect
          MigrationLogger.error "#{$!}, #{$@}"
          next
        end  
      end
    end
  end

end
