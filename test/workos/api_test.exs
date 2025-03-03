defmodule WorkOS.ApiTest do
  use ExUnit.Case
  doctest WorkOS.SSO
  import Tesla.Mock

  alias WorkOS.API

  setup do
    mock(fn
      %{method: :get, url: "https://api.workos.com/test"} ->
        %Tesla.Env{status: 200, body: "hello"}

      %{method: :post, url: "https://api.workos.com/test"} ->
        %Tesla.Env{status: 200, body: "hello"}

      %{method: :put, url: "https://api.workos.com/test"} ->
        %Tesla.Env{status: 200, body: "hello"}

      %{method: :delete, url: "https://api.workos.com/test"} ->
        %Tesla.Env{status: 200, body: "hello"}
    end)

    :ok
  end

  describe "#get/3" do
    test "returns a response object" do
      assert {:ok, "hello"} = API.get("/test")
    end
  end

  describe "#post/3" do
    test "returns a response object" do
      assert {:ok, "hello"} = API.post("/test")
    end
  end

  describe "#put/3" do
    test "returns a response object" do
      assert {:ok, "hello"} = API.put("/test")
    end
  end

  describe "#delete/3" do
    test "returns a response object" do
      assert {:ok, "hello"} = API.delete("/test")
    end
  end

  describe "#handle_response/1" do
    test "returns an okay when status is <400" do
      assert API.handle_response({:ok, %{status: 200, body: "OKAY"}}) == {:ok, "OKAY"}
    end

    test "returns an error when status is >=400" do
      assert API.handle_response({:ok, %{status: 400, body: "BAD"}}) == {:error, "BAD"}
    end

    test "returns an error when request errors" do
      assert API.handle_response({:error, "BAD"}) == {:error, "BAD"}
    end
  end

  describe "#process_response/1" do
    test "removes message fluff and returns just the message" do
      assert %{body: %{"message" => "test"}}
             |> API.process_response() ==
               "test"
    end

    test "removes data fluff and returns just the data" do
      assert %{body: %{"data" => ["test"]}}
             |> API.process_response() ==
               ["test"]
    end

    test "returns the response body otherwise" do
      assert %{body: %{"type" => "test"}}
             |> API.process_response() ==
               %{"type" => "test"}
    end

    test "returns the raw argument when a body isn't defined" do
      assert API.process_response("test") == "test"
    end
  end

  describe "#process_params/3" do
    test "only takes allowed params" do
      assert %{test: 1, blocked: 1}
             |> API.process_params([:test]) ==
               %{test: 1}
    end

    test "merges default params" do
      assert %{test: 1}
             |> API.process_params([:test], %{merged: 1}) ==
               %{test: 1, merged: 1}
    end

    test "overrides default params" do
      assert %{test: 1, overrides: 1}
             |> API.process_params([:test], %{overrides: 0}) ==
               %{test: 1, overrides: 1}
    end
  end
end
