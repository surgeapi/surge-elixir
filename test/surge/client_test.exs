defmodule Surge.ClientTest do
  use ExUnit.Case, async: true

  alias Surge.Client
  alias Surge.Error

  describe "new/2" do
    test "creates client with API key and default base URL" do
      client = Client.new("sk_test_123")

      assert client.api_key == "sk_test_123"
      assert client.base_url == "https://api.surge.app"
      assert client.req_options == []
    end

    test "creates client with custom base URL" do
      client = Client.new("sk_test_456", base_url: "https://custom.surge.app")

      assert client.api_key == "sk_test_456"
      assert client.base_url == "https://custom.surge.app"
      assert client.req_options == []
    end

    test "creates client with custom req_options" do
      req_opts = [connect_options: [timeout: 10_000], retry: false]
      client = Client.new("sk_test_789", req_options: req_opts)

      assert client.api_key == "sk_test_789"
      assert client.base_url == "https://api.surge.app"
      assert client.req_options == req_opts
    end

    test "creates client with all custom options" do
      req_opts = [connect_options: [timeout: 5_000], max_retries: 3]

      client =
        Client.new("sk_test_000",
          base_url: "https://staging.surge.app",
          req_options: req_opts
        )

      assert client.api_key == "sk_test_000"
      assert client.base_url == "https://staging.surge.app"
      assert client.req_options == req_opts
    end
  end

  describe "default_client/0" do
    test "creates client from application config" do
      client = Client.default_client()

      assert client.api_key == "sk_default_123"
      assert client.base_url == "https://api.surge.app"
      assert client.req_options[:connect_options] == [timeout: 15_000]
    end
  end

  describe "request/4" do
    test "successful GET request returns parsed body" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/accounts/123/status"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        user_agent_header = Plug.Conn.get_req_header(conn, "user-agent")
        assert length(user_agent_header) == 1
        assert hd(user_agent_header) =~ "surge-elixir/"

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(%{"status" => "active", "id" => "acct_123"})
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:ok, body} = Client.request(client, :get, "/accounts/123/status")
      assert body == %{"status" => "active", "id" => "acct_123"}
    end

    test "successful POST request with JSON body" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts"
        assert conn.params == %{"name" => "Test Account"}

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(%{"id" => "acct_new", "name" => "Test Account"})
      end)

      client = Client.new("sk_test_456", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:ok, body} =
               Client.request(client, :post, "/accounts", json: %{name: "Test Account"})

      assert body == %{"id" => "acct_new", "name" => "Test Account"}
    end

    test "includes custom headers in request" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        assert "custom-value" in Plug.Conn.get_req_header(conn, "x-custom-header")

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(%{"success" => true})
      end)

      client = Client.new("sk_test_789", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:ok, _body} =
               Client.request(client, :get, "/test",
                 headers: [{"x-custom-header", "custom-value"}]
               )
    end

    test "uses custom base URL from client" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        # The URL construction happens in Req, but we can verify the path
        assert conn.request_path == "/custom/endpoint"

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(%{"endpoint" => "custom"})
      end)

      client =
        Client.new("sk_test_000",
          base_url: "https://custom.surge.app",
          req_options: [plug: {Req.Test, Surge.ClientTest}]
        )

      assert {:ok, body} = Client.request(client, :get, "/custom/endpoint")
      assert body == %{"endpoint" => "custom"}
    end

    test "handles 400 validation error" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "Invalid parameters"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:error, %Error{} = error} = Client.request(client, :post, "/accounts", json: %{})
      assert error.type == "validation_error"
      assert error.message == "Invalid parameters"
    end

    test "handles 401 authentication error" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        conn
        |> Plug.Conn.put_status(401)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "authentication_error",
            "message" => "Invalid API key"
          }
        })
      end)

      client = Client.new("sk_invalid", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:error, %Error{} = error} = Client.request(client, :get, "/accounts")
      assert error.type == "authentication_error"
      assert error.message == "Invalid API key"
    end

    test "handles 404 not found error" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "not_found_error",
            "message" => "Resource not found"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:error, %Error{} = error} = Client.request(client, :get, "/accounts/nonexistent")
      assert error.type == "not_found_error"
      assert error.message == "Resource not found"
    end

    test "handles 429 rate limit error" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        conn
        |> Plug.Conn.put_status(429)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "rate_limit_error",
            "message" => "Too many requests"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:error, %Error{} = error} = Client.request(client, :post, "/messages", json: %{})
      assert error.type == "rate_limit_error"
      assert error.message == "Too many requests"
    end

    test "handles 500 internal server error" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        conn
        |> Plug.Conn.put_status(500)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "api_error",
            "message" => "Internal server error"
          }
        })
      end)

      client =
        Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}, retry: false])

      assert {:error, %Error{} = error} = Client.request(client, :get, "/accounts")
      assert error.type == "api_error"
      assert error.message == "Internal server error"
    end

    test "handles non-JSON error response" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        conn
        |> Plug.Conn.put_status(503)
        |> Plug.Conn.put_resp_content_type("text/plain")
        |> Plug.Conn.send_resp(503, "Service Unavailable")
      end)

      client =
        Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}, retry: false])

      assert {:error, %Error{} = error} = Client.request(client, :get, "/health")
      assert error.type == "http_error"
      assert error.message == "HTTP 503 error"
      assert error.detail == "Service Unavailable"
    end

    test "handles connection timeout error" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client =
        Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}, retry: false])

      assert {:error, %Error{} = error} = Client.request(client, :get, "/accounts")
      assert error.type == "connection_error"
      assert error.message =~ "timeout"
    end

    test "handles connection refused error" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        Req.Test.transport_error(conn, :econnrefused)
      end)

      client =
        Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}, retry: false])

      assert {:error, %Error{} = error} = Client.request(client, :get, "/accounts")
      assert error.type == "connection_error"
      assert error.message =~ "connection refused"
    end

    test "handles other connection error" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        Req.Test.transport_error(conn, :nxdomain)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:error, %Error{} = error} = Client.request(client, :get, "/accounts")
      assert error.type == "connection_error"
    end

    test "merges req_options from client and request" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(%{"merged" => true})
      end)

      # Client has base options
      client =
        Client.new("sk_test_123",
          req_options: [
            plug: {Req.Test, Surge.ClientTest},
            receive_timeout: 10_000
          ]
        )

      # Request adds additional options
      assert {:ok, body} =
               Client.request(client, :get, "/test",
                 retry: false,
                 max_retries: 0
               )

      assert body == %{"merged" => true}
    end

    test "supports DELETE method" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        assert conn.method == "DELETE"
        assert conn.request_path == "/accounts/123"

        conn
        |> Plug.Conn.put_status(204)
        |> Plug.Conn.send_resp(204, "")
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}])

      # 204 No Content returns empty string
      assert {:ok, ""} = Client.request(client, :delete, "/accounts/123")
    end

    test "supports PUT method with JSON body" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        assert conn.method == "PUT"
        assert conn.request_path == "/accounts/123"
        assert conn.params == %{"name" => "Updated Account"}

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(%{"id" => "123", "name" => "Updated Account"})
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:ok, body} =
               Client.request(client, :put, "/accounts/123", json: %{name: "Updated Account"})

      assert body == %{"id" => "123", "name" => "Updated Account"}
    end

    test "supports PATCH method" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        assert conn.method == "PATCH"
        assert conn.request_path == "/accounts/123"
        assert conn.params == %{"status" => "active"}

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(%{"id" => "123", "status" => "active"})
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:ok, body} =
               Client.request(client, :patch, "/accounts/123", json: %{status: "active"})

      assert body == %{"id" => "123", "status" => "active"}
    end

    test "includes correct user agent with version" do
      Req.Test.stub(Surge.ClientTest, fn conn ->
        [user_agent] = Plug.Conn.get_req_header(conn, "user-agent")

        # Get the actual version from mix.exs
        vsn = Application.spec(:surge_api, :vsn) |> to_string()
        assert user_agent == "surge-elixir/#{vsn}"

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(%{"ok" => true})
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.ClientTest}])

      assert {:ok, _body} = Client.request(client, :get, "/test")
    end
  end
end
