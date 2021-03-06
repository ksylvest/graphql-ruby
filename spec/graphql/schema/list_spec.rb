# frozen_string_literal: true

require "spec_helper"

describe GraphQL::Schema::List do
  let(:of_type) { Jazz::Musician }
  let(:list_type) { GraphQL::Schema::List.new(of_type) }

  it "returns list? to be true" do
    assert list_type.list?
  end

  it "returns non_null? to be false" do
    refute list_type.non_null?
  end

  it "returns kind to be GraphQL::TypeKinds::LIST" do
    assert_equal GraphQL::TypeKinds::LIST, list_type.kind
  end

  it "returns correct type signature" do
    assert_equal "[Musician]", list_type.to_type_signature
  end

  describe "comparison operator" do
    it "will return false if list types 'of_type' are different" do
      new_of_type = Jazz::InspectableKey
      new_list_type = GraphQL::Schema::List.new(new_of_type)

      refute_equal list_type, new_list_type
    end

    it "will return true if list types 'of_type' are the same" do
      new_of_type = Jazz::Musician
      new_list_type = GraphQL::Schema::List.new(new_of_type)

      assert_equal list_type, new_list_type
    end
  end

  describe "to_graphql" do
    it "will return a list type" do
      assert_kind_of GraphQL::ListType, list_type.to_graphql
    end
  end

  describe "validation" do
    class ListEnumValidationSchema < GraphQL::Schema
      class Item < GraphQL::Schema::Enum
        value "A"
        value "B"
      end

      class Query < GraphQL::Schema::Object
        field :echo, [Item], null: false do
          argument :items, [Item], required: true
        end

        def echo(items:)
          items
        end
      end

      query(Query)
    end

    it "checks non-null lists of enums" do
      res = ListEnumValidationSchema.execute "{ echo(items: [A, B, \"C\"]) }"
      expected_error = "Argument 'items' on Field 'echo' has an invalid value. Expected type '[Item!]!'."
      assert_equal [expected_error], res["errors"].map { |e| e["message"] }
    end
  end
end
