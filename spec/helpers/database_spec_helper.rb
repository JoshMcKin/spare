require 'active_record/connection_adapters/mysql2_adapter.rb'
module ActiveRecord
  class Base
    # Establishes a connection to the database that's used by all Active Record objects.
    def self.mysql2_connection(config)
      config[:username] = 'root' if config[:username].nil?
      if Mysql2::Client.const_defined? :FOUND_ROWS
        config[:flags] = Mysql2::Client::FOUND_ROWS | Mysql2::Client::MULTI_STATEMENTS
      end
      client = Mysql2::Client.new(config.symbolize_keys)
      options = [config[:host], config[:username], config[:password], config[:database], config[:port], config[:socket], 0]
      ConnectionAdapters::Mysql2Adapter.new(client, logger, options, config)
    end
  end
end

class TestDB
  def self.yml
    YAML::load(File.open(File.join(File.dirname(__FILE__),'..',"database.yml")))
  end

  def self.connect(logging=false)
    
    ActiveRecord::Base.configurations = yml
    ActiveRecord::Base.establish_connection(:test)
    ActiveRecord::Base.logger = Logger.new(STDOUT) if logging
  end

  def self.clean
    DBSpecManagement.connection.execute("DELETE FROM sp_test.foos")
  end

  #Class to clean tables
  class DBSpecManagement < ActiveRecord::Base
  end
end

#Put all the test migrations here
class TestMigrations < ActiveRecord::Migration
  # all the ups
  def self.up
    ActiveRecord::Base.establish_connection(:without_db)
    begin
      ActiveRecord::Base.connection.execute("CREATE DATABASE IF NOT EXISTS sp_test;")
    rescue => e
      puts "Error creating database: #{e}"
    end

    ActiveRecord::Base.establish_connection(:test)
    begin
      create_table "foos" do |t|
        t.string :name
        t.decimal :bar
        t.date :date
      end
    rescue => e
      puts "tables failed to create: #{e}"
    end

    begin
      conn = ActiveRecord::Base.connection
      puts "Dropping \"sp_insert\""
      conn.execute("DROP procedure IF EXISTS `sp_insert`;")
      puts "Creating \"sp_insert\""
      conn.execute(%q{CREATE PROCEDURE `sp_insert`(
                        IN  p_name    VARCHAR(255)  ,
                        IN  p_deci    DECIMAL(10,2) ,
                        IN  p_date    DATE          ,
                        OUT o_id      INT,
                        INOUT in_out_add INT
                      )
                      BEGIN
                      SET in_out_add =  in_out_add + 1;
                      INSERT INTO foos (
                        name,
                        bar,
                        date
                      )
                      VALUES (
                        p_name,
                        p_deci,
                        p_date
                      );
                      SET o_id = LAST_INSERT_ID();
                      END})

    rescue => e
      puts "sp failed to create: #{e}"
    end
  end

  # all the downs
  def self.down
    begin
      drop_table "sp_test.foos"
    rescue => e
      puts "tables were not dropped: sp_test"
    end
  end
end
