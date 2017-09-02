require "rails"
require "data_janitor/version"
require "data_janitor/data_janitor"
require "data_janitor/universal_validator"
require "data_janitor/audit_validatable"

module DataJanitor

  class MyRailtie < Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end
  end

end
