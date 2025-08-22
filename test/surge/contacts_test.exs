defmodule Surge.ContactsTest do
  use ExUnit.Case, async: true

  alias Surge.Client
  alias Surge.Contacts
  alias Surge.Contacts.Contact

  import Surge.ContactsFixtures

  describe "create/3" do
    test "creates a contact with valid params matching OpenAPI example" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Example request from OpenAPI spec
      params = %{
        phone_number: "+18015551234",
        email: "dom@toretto.family",
        first_name: "Dominic",
        last_name: "Toretto",
        metadata: %{
          "car" => "1970 Dodge Charger R/T"
        }
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/contacts"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["phone_number"] == "+18015551234"
        assert conn.params["email"] == "dom@toretto.family"
        assert conn.params["first_name"] == "Dominic"
        assert conn.params["last_name"] == "Toretto"
        assert conn.params["metadata"] == %{"car" => "1970 Dodge Charger R/T"}

        # Example response from OpenAPI spec
        response_body = contact_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Contact{} = contact} = Contacts.create(client, account_id, params)
      assert contact.id == "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"
      assert contact.email == "dom@toretto.family"
      assert contact.first_name == "Dominic"
      assert contact.last_name == "Toretto"
      assert contact.metadata == %{"car" => "1970 Dodge Charger R/T"}
      assert contact.phone_number == "+18015551234"
    end

    test "creates a contact with minimal fields" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Minimal params - only phone number
      params = %{
        phone_number: "+18015555678"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/contacts"

        assert conn.params["phone_number"] == "+18015555678"

        # Response without optional fields
        response_body = minimal_contact_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Contact{} = contact} = Contacts.create(client, account_id, params)
      assert contact.id == "ctc_minimal123"
      assert contact.phone_number == "+18015555678"
      assert is_nil(contact.email)
      assert is_nil(contact.first_name)
      assert is_nil(contact.last_name)
      assert is_nil(contact.metadata)
    end

    test "creates a contact without phone number" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        email: "brian@oconner.gov",
        first_name: "Brian",
        last_name: "O'Conner"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["email"] == "brian@oconner.gov"
        assert conn.params["first_name"] == "Brian"
        assert conn.params["last_name"] == "O'Conner"

        response_body = contact_without_phone_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Contact{} = contact} = Contacts.create(client, account_id, params)
      assert contact.id == "ctc_nophone456"
      assert contact.email == "brian@oconner.gov"
      assert contact.first_name == "Brian"
      assert contact.last_name == "O'Conner"
      assert is_nil(contact.phone_number)
    end

    test "creates a contact with complex metadata" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        phone_number: "+18015559999",
        metadata: %{
          "preferences" => %{
            "notifications" => true,
            "language" => "en"
          },
          "tags" => ["vip", "fast_and_furious"],
          "score" => 9.5
        }
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["metadata"]["preferences"]["notifications"] == true
        assert conn.params["metadata"]["tags"] == ["vip", "fast_and_furious"]

        response_body = contact_with_complex_metadata_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Contact{} = contact} = Contacts.create(client, account_id, params)
      assert contact.metadata["preferences"]["notifications"] == true
      assert contact.metadata["tags"] == ["vip", "fast_and_furious"]
      assert contact.metadata["score"] == 9.5
    end

    test "returns error when API request fails with validation error" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Invalid params - empty
      params = %{}

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "Either phone_number or email is required"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Contacts.create(client, account_id, params)
      assert error.type == "validation_error"
      assert error.message == "Either phone_number or email is required"
    end

    test "returns error when account not found" do
      account_id = "acct_nonexistent"

      params = %{
        phone_number: "+18015551234"
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

      assert {:error, error} = Contacts.create(client, account_id, params)
      assert error.type == "not_found_error"
      assert error.message == "Account 'acct_nonexistent' not found"
    end

    test "handles connection errors" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        phone_number: "+18015551234"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Contacts.create(client, account_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "create/2" do
    test "uses default client" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        phone_number: "+18015551234"
      }

      response_body = %{
        "id" => "ctc_def456",
        "phone_number" => "+18015551234"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Contact{} = contact} = Contacts.create(account_id, params)
      assert contact.id == "ctc_def456"
      assert contact.phone_number == "+18015551234"
    end
  end

  describe "get/2" do
    test "retrieves a contact by ID matching OpenAPI example" do
      contact_id = "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/contacts/ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]

        # Example response from OpenAPI spec
        response_body = contact_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Contact{} = contact} = Contacts.get(client, contact_id)
      assert contact.id == "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"
      assert contact.email == "dom@toretto.family"
      assert contact.first_name == "Dominic"
      assert contact.last_name == "Toretto"
      assert contact.metadata == %{"car" => "1970 Dodge Charger R/T"}
      assert contact.phone_number == "+18015551234"
    end

    test "retrieves a minimal contact" do
      contact_id = "ctc_minimal123"

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/contacts/ctc_minimal123"

        response_body = minimal_contact_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Contact{} = contact} = Contacts.get(client, contact_id)
      assert contact.id == "ctc_minimal123"
      assert contact.phone_number == "+18015555678"
      assert is_nil(contact.email)
      assert is_nil(contact.first_name)
      assert is_nil(contact.last_name)
      assert is_nil(contact.metadata)
    end

    test "returns error when contact not found" do
      contact_id = "ctc_nonexistent"

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "not_found_error",
            "message" => "Contact 'ctc_nonexistent' not found"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Contacts.get(client, contact_id)
      assert error.type == "not_found_error"
      assert error.message == "Contact 'ctc_nonexistent' not found"
    end
  end

  describe "get/1" do
    test "uses default client" do
      contact_id = "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"

      response_body = contact_fixture()

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Contact{} = contact} = Contacts.get(contact_id)
      assert contact.id == "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"
    end
  end

  describe "update/3" do
    test "updates a contact with valid params matching OpenAPI example" do
      contact_id = "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"

      # Example request from OpenAPI spec
      params = %{
        phone_number: "+18015551234",
        email: "dom@toretto.family",
        first_name: "Dominic",
        last_name: "Toretto",
        metadata: %{
          "car" => "1970 Dodge Charger R/T"
        }
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "PATCH"
        assert conn.request_path == "/contacts/ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["phone_number"] == "+18015551234"
        assert conn.params["email"] == "dom@toretto.family"
        assert conn.params["first_name"] == "Dominic"
        assert conn.params["last_name"] == "Toretto"
        assert conn.params["metadata"] == %{"car" => "1970 Dodge Charger R/T"}

        # Example response from OpenAPI spec
        response_body = contact_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Contact{} = contact} = Contacts.update(client, contact_id, params)
      assert contact.id == "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"
      assert contact.email == "dom@toretto.family"
      assert contact.first_name == "Dominic"
      assert contact.last_name == "Toretto"
      assert contact.metadata == %{"car" => "1970 Dodge Charger R/T"}
      assert contact.phone_number == "+18015551234"
    end

    test "updates only specific fields" do
      contact_id = "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"

      # Update only email and metadata
      params = %{
        email: "dom@racewars.com",
        metadata: %{
          "car" => "1970 Plymouth Road Runner",
          "crew" => "Family"
        }
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "PATCH"
        assert conn.params["email"] == "dom@racewars.com"
        assert conn.params["metadata"]["car"] == "1970 Plymouth Road Runner"
        assert conn.params["metadata"]["crew"] == "Family"

        response_body = updated_contact_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Contact{} = contact} = Contacts.update(client, contact_id, params)
      assert contact.email == "dom@racewars.com"
      assert contact.metadata["car"] == "1970 Plymouth Road Runner"
      assert contact.metadata["crew"] == "Family"
    end

    test "updates a single field" do
      contact_id = "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"

      params = %{
        first_name: "Dom"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "PATCH"
        assert conn.params["first_name"] == "Dom"
        assert Map.keys(conn.params) == ["first_name"]

        response_body = contact_fixture(%{"first_name" => "Dom"})

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Contact{} = contact} = Contacts.update(client, contact_id, params)
      assert contact.first_name == "Dom"
    end

    test "returns error when contact not found" do
      contact_id = "ctc_nonexistent"

      params = %{
        email: "test@example.com"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "not_found_error",
            "message" => "Contact 'ctc_nonexistent' not found"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Contacts.update(client, contact_id, params)
      assert error.type == "not_found_error"
      assert error.message == "Contact 'ctc_nonexistent' not found"
    end

    test "returns error when validation fails" do
      contact_id = "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"

      params = %{
        phone_number: "invalid"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "Invalid phone number format"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Contacts.update(client, contact_id, params)
      assert error.type == "validation_error"
      assert error.message == "Invalid phone number format"
    end

    test "handles connection errors" do
      contact_id = "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"

      params = %{
        email: "test@example.com"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Contacts.update(client, contact_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "update/2" do
    test "uses default client" do
      contact_id = "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"

      params = %{
        email: "updated@example.com"
      }

      response_body = contact_fixture(%{"email" => "updated@example.com"})

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Contact{} = contact} = Contacts.update(contact_id, params)
      assert contact.email == "updated@example.com"
    end
  end

  describe "Contact.from_json/1" do
    test "handles nil fields correctly" do
      data = contact_with_nil_fields_fixture()

      contact = Contact.from_json(data)

      assert contact.id == "ctc_nilfields"
      assert is_nil(contact.email)
      assert is_nil(contact.first_name)
      assert is_nil(contact.last_name)
      assert is_nil(contact.metadata)
      assert contact.phone_number == "+18015550000"
    end

    test "preserves complex metadata structure" do
      data = contact_with_complex_metadata_fixture()

      contact = Contact.from_json(data)

      assert contact.id == "ctc_complex789"
      assert contact.metadata["preferences"]["notifications"] == true
      assert contact.metadata["preferences"]["language"] == "en"
      assert contact.metadata["tags"] == ["vip", "fast_and_furious"]
      assert contact.metadata["score"] == 9.5
    end

    test "handles empty map" do
      data = %{}

      contact = Contact.from_json(data)

      assert is_nil(contact.id)
      assert is_nil(contact.email)
      assert is_nil(contact.first_name)
      assert is_nil(contact.last_name)
      assert is_nil(contact.metadata)
      assert is_nil(contact.phone_number)
    end

    test "handles complete contact data from OpenAPI spec" do
      data = contact_fixture()

      contact = Contact.from_json(data)

      assert contact.id == "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf"
      assert contact.email == "dom@toretto.family"
      assert contact.first_name == "Dominic"
      assert contact.last_name == "Toretto"
      assert contact.metadata == %{"car" => "1970 Dodge Charger R/T"}
      assert contact.phone_number == "+18015551234"
    end
  end
end
