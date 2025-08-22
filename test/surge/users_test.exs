defmodule Surge.UsersTest do
  use ExUnit.Case, async: true

  alias Surge.Client
  alias Surge.Users
  alias Surge.Users.User

  import Surge.UsersFixtures

  describe "create/3" do
    test "creates a user with valid params matching OpenAPI example" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Example request from OpenAPI spec
      params = %{
        first_name: "Brian",
        last_name: "O'Conner",
        metadata: %{
          "email" => "boconner@toretti.family",
          "user_id" => 1234
        },
        photo_url: "https://toretti.family/people/brian.jpg"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/users"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["first_name"] == "Brian"
        assert conn.params["last_name"] == "O'Conner"
        assert conn.params["metadata"]["email"] == "boconner@toretti.family"
        assert conn.params["metadata"]["user_id"] == 1234
        assert conn.params["photo_url"] == "https://toretti.family/people/brian.jpg"

        # Example response from OpenAPI spec
        response_body = user_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %User{} = user} = Users.create(client, account_id, params)
      assert user.id == "usr_01j9dwavghe1ttppewekjjkfrx"
      assert user.first_name == "Brian"
      assert user.last_name == "O'Conner"
      assert user.metadata == %{"email" => "boconner@toretti.family", "user_id" => 1234}
      assert user.photo_url == "https://toretti.family/people/brian.jpg"
    end

    test "creates a minimal user with just first name" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        first_name: "John"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/users"

        assert conn.params["first_name"] == "John"

        response_body = minimal_user_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %User{} = user} = Users.create(client, account_id, params)
      assert user.id == "usr_minimal123"
      assert user.first_name == "John"
      assert is_nil(user.last_name)
      assert is_nil(user.metadata)
      assert is_nil(user.photo_url)
    end

    test "creates a user without name fields" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        metadata: %{
          "internal_id" => "abc123"
        },
        photo_url: "https://example.com/photo.jpg"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["metadata"]["internal_id"] == "abc123"
        assert conn.params["photo_url"] == "https://example.com/photo.jpg"

        response_body = user_without_name_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %User{} = user} = Users.create(client, account_id, params)
      assert user.id == "usr_noname456"
      assert is_nil(user.first_name)
      assert is_nil(user.last_name)
      assert user.metadata == %{"internal_id" => "abc123"}
      assert user.photo_url == "https://example.com/photo.jpg"
    end

    test "creates a user with complex metadata" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        first_name: "Letty",
        last_name: "Ortiz",
        metadata: %{
          "preferences" => %{
            "notifications" => true,
            "language" => "es"
          },
          "tags" => ["mechanic", "racer"],
          "score" => 9.8,
          "joined_at" => "2024-01-15T10:30:00Z"
        },
        photo_url: "https://toretti.family/people/letty.jpg"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["metadata"]["preferences"]["notifications"] == true
        assert conn.params["metadata"]["tags"] == ["mechanic", "racer"]

        response_body = user_with_complex_metadata_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %User{} = user} = Users.create(client, account_id, params)
      assert user.metadata["preferences"]["notifications"] == true
      assert user.metadata["tags"] == ["mechanic", "racer"]
      assert user.metadata["score"] == 9.8
    end

    test "returns error when API request fails with validation error" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{}

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "At least one field must be provided"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Users.create(client, account_id, params)
      assert error.type == "validation_error"
      assert error.message == "At least one field must be provided"
    end

    test "returns error when account not found" do
      account_id = "acct_nonexistent"

      params = %{
        first_name: "Test"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "not_found_error",
            "message" => "Account 'acct_nonexistent' not found"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Users.create(client, account_id, params)
      assert error.type == "not_found_error"
      assert error.message == "Account 'acct_nonexistent' not found"
    end

    test "handles connection errors" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        first_name: "Test"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Users.create(client, account_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "create/2" do
    test "uses default client" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        first_name: "Test"
      }

      response_body = %{
        "id" => "usr_def456",
        "first_name" => "Test"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %User{} = user} = Users.create(account_id, params)
      assert user.id == "usr_def456"
      assert user.first_name == "Test"
    end
  end

  describe "get/2" do
    test "retrieves a user by ID matching OpenAPI example" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/users/usr_01j9dwavghe1ttppewekjjkfrx"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]

        # Example response from OpenAPI spec
        response_body = user_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %User{} = user} = Users.get(client, user_id)
      assert user.id == "usr_01j9dwavghe1ttppewekjjkfrx"
      assert user.first_name == "Brian"
      assert user.last_name == "O'Conner"
      assert user.metadata == %{"email" => "boconner@toretti.family", "user_id" => 1234}
      assert user.photo_url == "https://toretti.family/people/brian.jpg"
    end

    test "retrieves a minimal user" do
      user_id = "usr_minimal123"

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/users/usr_minimal123"

        response_body = minimal_user_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %User{} = user} = Users.get(client, user_id)
      assert user.id == "usr_minimal123"
      assert user.first_name == "John"
      assert is_nil(user.last_name)
      assert is_nil(user.metadata)
      assert is_nil(user.photo_url)
    end

    test "returns error when user not found" do
      user_id = "usr_nonexistent"

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "not_found_error",
            "message" => "User 'usr_nonexistent' not found"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Users.get(client, user_id)
      assert error.type == "not_found_error"
      assert error.message == "User 'usr_nonexistent' not found"
    end
  end

  describe "get/1" do
    test "uses default client" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      response_body = user_fixture()

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %User{} = user} = Users.get(user_id)
      assert user.id == "usr_01j9dwavghe1ttppewekjjkfrx"
    end
  end

  describe "update/3" do
    test "updates a user with valid params matching OpenAPI example" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      # Example request from OpenAPI spec
      params = %{
        first_name: "Brian",
        last_name: "O'Conner",
        metadata: %{
          "email" => "boconner@toretti.family",
          "user_id" => 1234
        },
        photo_url: "https://toretti.family/people/brian.jpg"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "PATCH"
        assert conn.request_path == "/users/usr_01j9dwavghe1ttppewekjjkfrx"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["first_name"] == "Brian"
        assert conn.params["last_name"] == "O'Conner"
        assert conn.params["metadata"]["email"] == "boconner@toretti.family"
        assert conn.params["metadata"]["user_id"] == 1234
        assert conn.params["photo_url"] == "https://toretti.family/people/brian.jpg"

        # Example response from OpenAPI spec
        response_body = user_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %User{} = user} = Users.update(client, user_id, params)
      assert user.id == "usr_01j9dwavghe1ttppewekjjkfrx"
      assert user.first_name == "Brian"
      assert user.last_name == "O'Conner"
      assert user.metadata == %{"email" => "boconner@toretti.family", "user_id" => 1234}
      assert user.photo_url == "https://toretti.family/people/brian.jpg"
    end

    test "updates only specific fields" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      # Update only last name and metadata
      params = %{
        last_name: "O'Conner-Toretto",
        metadata: %{
          "email" => "brian@fbi.gov",
          "user_id" => 1234,
          "status" => "undercover"
        }
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "PATCH"
        assert conn.params["last_name"] == "O'Conner-Toretto"
        assert conn.params["metadata"]["status"] == "undercover"

        response_body = updated_user_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %User{} = user} = Users.update(client, user_id, params)
      assert user.last_name == "O'Conner-Toretto"
      assert user.metadata["email"] == "brian@fbi.gov"
      assert user.metadata["status"] == "undercover"
    end

    test "updates a single field" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      params = %{
        photo_url: "https://new-photo.com/brian.jpg"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "PATCH"
        assert conn.params["photo_url"] == "https://new-photo.com/brian.jpg"
        assert Map.keys(conn.params) == ["photo_url"]

        response_body = user_fixture(%{"photo_url" => "https://new-photo.com/brian.jpg"})

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %User{} = user} = Users.update(client, user_id, params)
      assert user.photo_url == "https://new-photo.com/brian.jpg"
    end

    test "returns error when user not found" do
      user_id = "usr_nonexistent"

      params = %{
        first_name: "Test"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "not_found_error",
            "message" => "User 'usr_nonexistent' not found"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Users.update(client, user_id, params)
      assert error.type == "not_found_error"
      assert error.message == "User 'usr_nonexistent' not found"
    end

    test "returns error when validation fails" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      params = %{
        metadata: "invalid"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "Metadata must be an object"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Users.update(client, user_id, params)
      assert error.type == "validation_error"
      assert error.message == "Metadata must be an object"
    end

    test "handles connection errors" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      params = %{
        first_name: "Test"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Users.update(client, user_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "update/2" do
    test "uses default client" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      params = %{
        first_name: "Updated"
      }

      response_body = user_fixture(%{"first_name" => "Updated"})

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %User{} = user} = Users.update(user_id, params)
      assert user.first_name == "Updated"
    end
  end

  describe "create_token/3" do
    test "creates a user token with duration" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      params = %{
        duration_seconds: 3600
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/users/usr_01j9dwavghe1ttppewekjjkfrx/tokens"
        assert conn.params["duration_seconds"] == 3600

        response_body = token_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, token} = Users.create_token(client, user_id, params)
      assert token =~ "eyJ"
    end

    test "creates a user token without parameters" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      params = %{}

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/users/usr_01j9dwavghe1ttppewekjjkfrx/tokens"
        assert conn.params == %{}

        response_body = token_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, token} = Users.create_token(client, user_id, params)
      assert is_binary(token)
    end

    test "returns error when user not found for token creation" do
      user_id = "usr_nonexistent"

      params = %{}

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "not_found_error",
            "message" => "User 'usr_nonexistent' not found"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Users.create_token(client, user_id, params)
      assert error.type == "not_found_error"
    end

    test "handles connection errors for token creation" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      params = %{}

      Req.Test.expect(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Users.create_token(client, user_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "create_token/2" do
    test "uses default client" do
      user_id = "usr_01j9dwavghe1ttppewekjjkfrx"

      params = %{duration_seconds: 7200}

      response_body = token_fixture()

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, token} = Users.create_token(user_id, params)
      assert is_binary(token)
    end
  end

  describe "User.from_json/1" do
    test "handles nil fields correctly" do
      data = user_with_nil_fields_fixture()

      user = User.from_json(data)

      assert user.id == "usr_nilfields"
      assert is_nil(user.first_name)
      assert is_nil(user.last_name)
      assert is_nil(user.metadata)
      assert is_nil(user.photo_url)
    end

    test "preserves complex metadata structure" do
      data = user_with_complex_metadata_fixture()

      user = User.from_json(data)

      assert user.id == "usr_complex789"
      assert user.first_name == "Letty"
      assert user.last_name == "Ortiz"
      assert user.metadata["preferences"]["notifications"] == true
      assert user.metadata["preferences"]["language"] == "es"
      assert user.metadata["tags"] == ["mechanic", "racer"]
      assert user.metadata["score"] == 9.8
      assert user.metadata["joined_at"] == "2024-01-15T10:30:00Z"
    end

    test "handles empty map" do
      data = %{}

      user = User.from_json(data)

      assert is_nil(user.id)
      assert is_nil(user.first_name)
      assert is_nil(user.last_name)
      assert is_nil(user.metadata)
      assert is_nil(user.photo_url)
    end

    test "handles complete user data from OpenAPI spec" do
      data = user_fixture()

      user = User.from_json(data)

      assert user.id == "usr_01j9dwavghe1ttppewekjjkfrx"
      assert user.first_name == "Brian"
      assert user.last_name == "O'Conner"
      assert user.metadata == %{"email" => "boconner@toretti.family", "user_id" => 1234}
      assert user.photo_url == "https://toretti.family/people/brian.jpg"
    end
  end
end
