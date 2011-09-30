if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
end

require "bundler/setup"
require "minitest/unit"
require 'minitest/autorun'
require "squirm"
require "ambry"
require "ambry/adapters/yaml"

$VERBOSE = true

require "squirm/model"


$squirm_test_connection ||= {dbname: "squirm_model_test"}
Squirm.connect $squirm_test_connection

class Module
  def test(string, &block)
    define_method "test_" + string.gsub(/[^a-z0-9,]/, "_"), block
  end
end

def transaction
  Squirm.transaction do
    yield
    Squirm.rollback
  end
end

def with_api_for(model_class)
  transaction do
    Squirm.exec model_class.to_ddl
    Squirm::Model.finalize
    yield
  end
end
