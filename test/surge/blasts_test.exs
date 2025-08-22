defmodule Surge.BlastsTest do
  use ExUnit.Case, async: true

  alias Surge.Blasts
  alias Surge.Blasts.Blast
  alias Surge.Client

  describe "create/3" do
    test "creates a blast with valid params" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Example request from OpenAPI spec
      params = %{
        attachments: [
          %{
            url: "https://example.com/image.jpg"
          }
        ],
        body: "Join us for our grand opening!",
        name: "Grand Opening Announcement",
        send_at: "2024-02-01T15:00:00Z",
        to: [
          "seg_01j9dy8mdzfn3r0e8x1tbdrdrf",
          "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf",
          "+18015551234",
          "+18015555678"
        ]
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/blasts"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["attachments"] == [%{"url" => "https://example.com/image.jpg"}]
        assert conn.params["body"] == "Join us for our grand opening!"
        assert conn.params["name"] == "Grand Opening Announcement"
        assert conn.params["send_at"] == "2024-02-01T15:00:00Z"

        assert conn.params["to"] == [
                 "seg_01j9dy8mdzfn3r0e8x1tbdrdrf",
                 "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf",
                 "+18015551234",
                 "+18015555678"
               ]

        # Example response from OpenAPI spec
        response_body = %{
          "attachments" => [
            %{
              "url" => "https://example.com/image.jpg"
            }
          ],
          "body" => "Join us for our grand opening!",
          "id" => "bst_01j9dy8mdzfn3r0e8x1tbdrdrf",
          "name" => "Grand Opening Announcement",
          "send_at" => "2024-02-01T15:00:00Z"
        }

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Blast{} = blast} = Blasts.create(client, account_id, params)
      assert blast.id == "bst_01j9dy8mdzfn3r0e8x1tbdrdrf"
      assert blast.body == "Join us for our grand opening!"
      assert blast.name == "Grand Opening Announcement"
      assert [attachment] = blast.attachments
      assert attachment.url == "https://example.com/image.jpg"
      assert blast.send_at == ~U[2024-02-01 15:00:00Z]
    end

    test "creates a blast without optional fields" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Minimal params - only required fields
      params = %{
        body: "Simple message",
        to: ["+18015551234"]
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/blasts"

        assert conn.params["body"] == "Simple message"
        assert conn.params["to"] == ["+18015551234"]

        # Response without optional fields
        response_body = %{
          "body" => "Simple message",
          "id" => "bst_simple123"
        }

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Blast{} = blast} = Blasts.create(client, account_id, params)
      assert blast.id == "bst_simple123"
      assert blast.body == "Simple message"
      assert blast.attachments == []
      assert is_nil(blast.name)
      assert is_nil(blast.send_at)
    end

    test "returns error when API request fails with validation error" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Invalid params - missing required field
      params = %{
        body: "Message without recipients"
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "The 'to' field is required and must contain at least one recipient"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Blasts.create(client, account_id, params)
      assert error.type == "validation_error"
      assert error.message == "The 'to' field is required and must contain at least one recipient"
    end

    test "returns error when account not found" do
      account_id = "acct_nonexistent"

      params = %{
        body: "Test message",
        to: ["+18015551234"]
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
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

      assert {:error, error} = Blasts.create(client, account_id, params)
      assert error.type == "not_found_error"
      assert error.message == "Account 'acct_nonexistent' not found"
    end

    test "handles connection errors" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        body: "Test message",
        to: ["+18015551234"]
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Blasts.create(client, account_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "create/2" do
    test "uses default client" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        body: "Test message",
        to: ["+18015551234"]
      }

      response_body = %{
        "id" => "bst_def456",
        "body" => "Test message"
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Blast{} = blast} = Blasts.create(account_id, params)
      assert blast.id == "bst_def456"
      assert blast.body == "Test message"
    end
  end

  describe "Blast.from_json/1" do
    test "parses blast with valid datetime" do
      data = %{
        "id" => "bst_123",
        "body" => "Test message",
        "name" => "Test Blast",
        "send_at" => "2024-02-01T15:00:00Z",
        "attachments" => [
          %{"url" => "https://example.com/image.jpg"}
        ]
      }

      blast = Blast.from_json(data)

      assert blast.id == "bst_123"
      assert blast.body == "Test message"
      assert blast.name == "Test Blast"
      assert blast.send_at == ~U[2024-02-01 15:00:00Z]
      assert [attachment] = blast.attachments
      assert attachment.url == "https://example.com/image.jpg"
    end

    test "handles invalid datetime gracefully" do
      data = %{
        "id" => "bst_456",
        "body" => "Test message",
        "send_at" => "invalid-datetime-format"
      }

      blast = Blast.from_json(data)

      assert blast.id == "bst_456"
      assert blast.body == "Test message"
      assert is_nil(blast.send_at)
    end

    test "handles nil datetime" do
      data = %{
        "id" => "bst_789",
        "body" => "Test message",
        "send_at" => nil
      }

      blast = Blast.from_json(data)

      assert blast.id == "bst_789"
      assert blast.body == "Test message"
      assert is_nil(blast.send_at)
    end

    test "handles empty attachments" do
      data = %{
        "id" => "bst_empty",
        "body" => "No attachments",
        "attachments" => []
      }

      blast = Blast.from_json(data)

      assert blast.id == "bst_empty"
      assert blast.attachments == []
    end

    test "handles nil attachments" do
      data = %{
        "id" => "bst_nil",
        "body" => "No attachments",
        "attachments" => nil
      }

      blast = Blast.from_json(data)

      assert blast.id == "bst_nil"
      assert blast.attachments == []
    end
  end
end
