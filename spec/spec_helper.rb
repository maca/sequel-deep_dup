require 'bundler/setup'
Bundler.require

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'sequel/extensions/migration'
load 'support/migrations.rb'

DB = Sequel.sqlite
Sequel::Migration.descendants.each { |m| m.apply(DB, :up) }


RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.around :each do |example|
    load 'support/models.rb'

    DB.transaction do
      example.run
      raise Sequel::Rollback
    end

    %w(Program Course Assignment Student Enrollment Category).each do |const|
      Object.send :remove_const, const
    end
  end
end

FactoryGirl.definition_file_paths = %w(spec/support)
FactoryGirl.reload