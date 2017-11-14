defmodule Absinthe.Execution.OrderedDefaultResolverTest do
  use Absinthe.Case, async: false, ordered: true
  use OrdMap

  @root %{:foo => "baz", "bar" => "quux"}
  @query "{ foo bar }"

  context "without a custom default resolver defined" do

    defmodule NormalSchema do
      use Absinthe.Schema

      query do
        field :foo, :string
        field :bar, :string
      end

    end

    it "should resolve using atoms" do
      assert {:ok, %{data: o%{"foo" => "baz", "bar" => nil}}} == Absinthe.run(@query, NormalSchema, root_value: @root)
    end

  end

  context "with a custom default resolver defined" do

    defmodule CustomSchema do
      use Absinthe.Schema

      query do
        field :foo, :string
        field :bar, :string
      end

      def middleware(middleware, %{name: name, identifier: identifier} = field, obj) do
        middleware_spec = Absinthe.Resolution.resolver_spec(fn parent, _, _ ->
          case parent do
            %{^name => value} -> {:ok, value}
            %{^identifier => value} -> {:ok, value}
            _ -> {:ok, nil}
          end
        end)

        Absinthe.Schema.replace_default(middleware, middleware_spec, field, obj)
      end
      def middleware(middleware, _, _) do
        middleware
      end

    end

    it "should resolve using as defined" do
      assert {:ok, %{data: o%{"foo" => "baz", "bar" => "quux"}}} == Absinthe.run(@query, CustomSchema, root_value: @root)
    end

  end

end