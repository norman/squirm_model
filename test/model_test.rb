require_relative "helper"

class ModelTest < MiniTest::Unit::TestCase

  class Person
    extend Squirm::Model
    sample do |p|
      p.id   = 1.freeze
      p.name = "John Doe"
    end
  end

  test "should create" do
    with_api_for(Person) do
      person = Person.create(Person.sample.to_hash)
      assert_instance_of Person, person
    end
  end

  test "should get by id" do
    with_api_for(Person) do
      person = Person.create(Person.sample.to_hash)
      assert_equal Person.sample.name, Person.get(1).name
    end
  end

  test "should update" do
    with_api_for(Person) do
      person = Person.create(Person.sample.to_hash)
      person.update name: "John Doe II"
      assert_equal "John Doe II", Person.get(1).name
    end
  end

  test "should delete" do
    with_api_for(Person) do
      begin
        Person.create(Person.sample.to_hash)
        assert Person.get(1)
        Person.delete(1)
        refute Person.get(1)
      rescue Squirm::Model::NotFound
        assert true
      end
    end
  end

  test "should save and create" do
    with_api_for(Person) do
      person = Person.sample(Person.new)
      assert person.save
      assert Person.get(person.id)
    end
  end

  test "should save and update" do
    with_api_for(Person) do
      Person.create(Person.sample.to_hash)
      assert person = Person.get(1)
      person.name = "John Doe II"
      assert person.save
      assert_equal "John Doe II", Person.get(1).name
    end
  end

end
