defmodule Surge.MessagesTest do
  use ExUnit.Case, async: true

  alias Surge.Client
  alias Surge.Messages
  alias Surge.Messages.Attachment
  alias Surge.Messages.Message

  import Surge.MessagesFixtures

  describe "create/3" do
    test "creates a message with valid params matching OpenAPI example" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Example request from OpenAPI spec
      params = %{
        attachments: [
          %{
            url: "https://toretto.family/coronas.gif"
          }
        ],
        body: "Thought you could leave without saying goodbye?",
        conversation: %{
          contact: %{
            first_name: "Dominic",
            last_name: "Toretto",
            phone_number: "+18015551234"
          }
        }
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/messages"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert [attachment] = conn.params["attachments"]
        assert attachment["url"] == "https://toretto.family/coronas.gif"
        assert conn.params["body"] == "Thought you could leave without saying goodbye?"
        assert conn.params["conversation"]["contact"]["first_name"] == "Dominic"
        assert conn.params["conversation"]["contact"]["last_name"] == "Toretto"
        assert conn.params["conversation"]["contact"]["phone_number"] == "+18015551234"

        # Example response from OpenAPI spec
        response_body = message_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Message{} = message} = Messages.create(client, account_id, params)
      assert message.id == "msg_01j9e0m1m6fc38gsv2vkfqgzz2"
      assert message.body == "Thought you could leave without saying goodbye?"

      assert [attachment] = message.attachments
      assert attachment.id == "att_01j9e0m1m6fc38gsv2vkfqgzz2"
      assert attachment.type == "image"
      assert attachment.url == "https://api.surge.app/attachments/att_01jbwyqj7rejzat7pq03r7fgmf"

      assert message.conversation.id == "cnv_01j9e0dgmdfkj86c877ws0znae"
      assert message.conversation.contact.id == "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"
      assert message.conversation.contact.phone_number == "+18015551234"
      assert message.conversation.contact.first_name == "Dominic"
      assert message.conversation.contact.last_name == "Toretto"
      assert message.conversation.phone_number.id == "pn_01jsjwe4d9fx3tpymgtg958d9w"
      assert message.conversation.phone_number.number == "+18015552345"
      assert message.conversation.phone_number.type == :local
    end

    test "creates a minimal message with just body" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        body: "Simple message",
        to: "+18015555678"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.params["body"] == "Simple message"
        assert conn.params["to"] == "+18015555678"

        response_body = minimal_message_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Message{} = message} = Messages.create(client, account_id, params)
      assert message.id == "msg_minimal123"
      assert message.body == "Simple message"
      assert message.attachments == []
    end

    test "creates a message with attachments only (no body)" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        attachments: [
          %{url: "https://example.com/image.jpg"}
        ],
        from: "+18015551111",
        to: "+18015550000"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["from"] == "+18015551111"
        assert conn.params["to"] == "+18015550000"
        assert [attachment] = conn.params["attachments"]
        assert attachment["url"] == "https://example.com/image.jpg"

        response_body = message_without_body_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Message{} = message} = Messages.create(client, account_id, params)
      assert message.id == "msg_nobody456"
      assert is_nil(message.body)
      assert [attachment] = message.attachments
      assert attachment.type == "image"
      assert message.conversation.phone_number.type == :toll_free
    end

    test "creates a message with multiple attachments" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        body: "Check out these files",
        attachments: [
          %{url: "https://example.com/image1.jpg"},
          %{url: "https://example.com/video.mp4"},
          %{url: "https://example.com/document.pdf"}
        ],
        to: "+18015552222"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["body"] == "Check out these files"
        assert length(conn.params["attachments"]) == 3

        response_body = message_with_multiple_attachments_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Message{} = message} = Messages.create(client, account_id, params)
      assert length(message.attachments) == 3

      [first, second, third] = message.attachments
      assert first.type == "image"
      assert second.type == "video"
      assert third.type == "document"
    end

    test "creates a message with scheduled send_at" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        body: "Scheduled message",
        to: "+18015551234",
        send_at: "2028-10-14T18:06:00Z"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["send_at"] == "2028-10-14T18:06:00Z"

        response_body = minimal_message_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Message{}} = Messages.create(client, account_id, params)
    end

    test "returns error when neither body nor attachments provided" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        to: "+18015551234"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "Either body or attachments must be provided"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Messages.create(client, account_id, params)
      assert error.type == "validation_error"
      assert error.message == "Either body or attachments must be provided"
    end

    test "returns error when both conversation and to fields provided" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        body: "Test message",
        to: "+18015551234",
        conversation: %{
          contact: %{phone_number: "+18015555678"}
        }
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "Cannot provide both 'to' and 'conversation' fields"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Messages.create(client, account_id, params)
      assert error.type == "validation_error"
      assert error.message == "Cannot provide both 'to' and 'conversation' fields"
    end

    test "returns error when account not found" do
      account_id = "acct_nonexistent"

      params = %{
        body: "Test message",
        to: "+18015551234"
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

      assert {:error, error} = Messages.create(client, account_id, params)
      assert error.type == "not_found_error"
      assert error.message == "Account 'acct_nonexistent' not found"
    end

    test "handles connection errors" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        body: "Test message",
        to: "+18015551234"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Messages.create(client, account_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "create/2" do
    test "uses default client" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        body: "Test message",
        to: "+18015551234"
      }

      response_body = minimal_message_fixture()

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Message{} = message} = Messages.create(account_id, params)
      assert message.id == "msg_minimal123"
      assert message.body == "Simple message"
    end
  end

  describe "get/2" do
    test "retrieves a message by ID matching OpenAPI example" do
      message_id = "msg_01j9e0m1m6fc38gsv2vkfqgzz2"

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/messages/msg_01j9e0m1m6fc38gsv2vkfqgzz2"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]

        # Example response from OpenAPI spec
        response_body = message_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])
      assert {:ok, %Message{} = message} = Messages.get(client, message_id)

      assert message.id == "msg_01j9e0m1m6fc38gsv2vkfqgzz2"
      assert [attachment] = message.attachments
      assert attachment.id == "att_01j9e0m1m6fc38gsv2vkfqgzz2"
      assert attachment.type == "image"
      assert attachment.url == "https://api.surge.app/attachments/att_01jbwyqj7rejzat7pq03r7fgmf"
      assert message.body == "Thought you could leave without saying goodbye?"
      assert message.conversation.id == "cnv_01j9e0dgmdfkj86c877ws0znae"
      assert message.conversation.contact.id == "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"
      assert message.conversation.contact.phone_number == "+18015551234"
      assert message.conversation.contact.first_name == "Dominic"
      assert message.conversation.contact.last_name == "Toretto"
      assert message.conversation.phone_number.id == "pn_01jsjwe4d9fx3tpymgtg958d9w"
      assert message.conversation.phone_number.number == "+18015552345"
      assert message.conversation.phone_number.type == :local
      assert message.metadata["external_id"] == "12345"
    end

    test "retrieves a minimal message" do
      message_id = "msg_minimal123"

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/messages/msg_minimal123"

        response_body = minimal_message_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Message{} = message} = Messages.get(client, message_id)
      assert message.id == "msg_minimal123"
      assert message.attachments == []
      assert message.body == "Simple message"
      assert message.conversation.id == "cnv_minimal"
      assert message.conversation.contact.id == "ctc_minimal"
      assert message.conversation.contact.phone_number == "+18015555678"
      refute message.conversation.contact.first_name
      refute message.conversation.contact.last_name
      assert message.conversation.phone_number.id == "pn_minimal"
      assert message.conversation.phone_number.number == "+18015559999"
      assert message.conversation.phone_number.type == :local
      refute message.metadata
    end

    test "returns error when message not found" do
      message_id = "msg_nonexistent"

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "not_found_error",
            "message" => "Message 'msg_nonexistent' not found"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Messages.get(client, message_id)
      assert error.type == "not_found_error"
      assert error.message == "Message 'msg_nonexistent' not found"
    end
  end

  describe "get/1" do
    test "uses default client" do
      message_id = "msg_01j9e0m1m6fc38gsv2vkfqgzz2"

      response_body = message_fixture()

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Message{} = message} = Messages.get(message_id)
      assert message.id == "msg_01j9e0m1m6fc38gsv2vkfqgzz2"
    end
  end

  describe "Message.from_json/1" do
    test "parses complete message with all fields" do
      data = message_fixture()

      message = Message.from_json(data)

      assert message.id == "msg_01j9e0m1m6fc38gsv2vkfqgzz2"
      assert message.body == "Thought you could leave without saying goodbye?"
      assert length(message.attachments) == 1
      assert message.conversation.id == "cnv_01j9e0dgmdfkj86c877ws0znae"
    end

    test "handles nil body and attachments" do
      data = message_with_nil_fields_fixture()

      message = Message.from_json(data)

      assert message.id == "msg_nilfields"
      assert is_nil(message.body)
      assert message.attachments == []
    end

    test "handles unknown phone type" do
      data = message_with_unknown_phone_type_fixture()

      message = Message.from_json(data)

      assert message.id == "msg_unknowntype"
      # Unknown phone type should be parsed as nil
      assert is_nil(message.conversation.phone_number.type)
    end

    test "parses multiple attachments correctly" do
      data = message_with_multiple_attachments_fixture()

      message = Message.from_json(data)

      assert length(message.attachments) == 3
      assert Enum.all?(message.attachments, &is_struct(&1, Attachment))
    end

    test "handles empty attachments list" do
      data = %{
        "id" => "msg_empty",
        "body" => "No attachments",
        "attachments" => [],
        "conversation" => %{
          "id" => "cnv_empty",
          "contact" => %{"id" => "ctc_empty"},
          "phone_number" => %{"id" => "pn_empty"}
        }
      }

      message = Message.from_json(data)

      assert message.attachments == []
    end
  end

  describe "Attachment.from_json/1" do
    test "parses complete attachment" do
      data = attachment_fixture()

      attachment = Attachment.from_json(data)

      assert attachment.id == "att_01j9e0m1m6fc38gsv2vkfqgzz2"
      assert attachment.type == "image"
      assert attachment.url == "https://api.surge.app/attachments/att_01jbwyqj7rejzat7pq03r7fgmf"
    end

    test "handles nil fields" do
      data = minimal_attachment_fixture()

      attachment = Attachment.from_json(data)

      assert attachment.id == "att_minimal"
      assert is_nil(attachment.type)
      assert is_nil(attachment.url)
    end

    test "handles empty map" do
      data = %{}

      attachment = Attachment.from_json(data)

      assert is_nil(attachment.id)
      assert is_nil(attachment.type)
      assert is_nil(attachment.url)
    end

    test "handles various attachment types" do
      types = ["image", "video", "document", "audio"]

      for type <- types do
        data = %{"id" => "att_#{type}", "type" => type, "url" => "https://example.com/#{type}"}
        attachment = Attachment.from_json(data)
        assert attachment.type == type
      end
    end
  end
end
