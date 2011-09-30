require "squirm"
require "ambry"
require "ambry/adapters/yaml"

module Squirm
  module Migrator
    yaml = File.expand_path("../migrator/ambry.yml", __FILE__)
    Ambry::Adapters::YAML.new file: yaml, name: :squirm
  end
end

require "squirm/migrator/column"
require "squirm/migrator/table"
require "squirm/migrator/template"