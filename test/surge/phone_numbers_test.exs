defmodule Surge.PhoneNumbersTest do
  use ExUnit.Case, async: true

  alias Surge.Client
  alias Surge.PhoneNumbers
  alias Surge.PhoneNumbers.PhoneNumber

  import Surge.PhoneNumbersFixtures

  describe "purchase/3" do
    test "purchases a local phone number with area code matching OpenAPI example" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Example request from OpenAPI spec
      params = %{
        type: :local,
        area_code: "801"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/phone_numbers"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["type"] == "local"
        assert conn.params["area_code"] == "801"

        # Example response from OpenAPI spec
        response_body = phone_number_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %PhoneNumber{} = phone_number} =
               PhoneNumbers.purchase(client, account_id, params)

      assert phone_number.id == "pn_01jsjwe4d9fx3tpymgtg958d9w"
      assert phone_number.number == "+18015551234"
      assert phone_number.type == :local
    end

    test "purchases a toll-free phone number" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        type: :toll_free
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/phone_numbers"

        assert conn.params["type"] == "toll_free"
        refute Map.has_key?(conn.params, "area_code")

        response_body = toll_free_phone_number_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %PhoneNumber{} = phone_number} =
               PhoneNumbers.purchase(client, account_id, params)

      assert phone_number.id == "pn_tollfree123"
      assert phone_number.number == "+18885551234"
      assert phone_number.type == :toll_free
    end

    test "purchases a local phone number without area code" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        type: :local
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["type"] == "local"
        refute Map.has_key?(conn.params, "area_code")

        response_body = phone_number_fixture(%{"number" => "+14155551234"})

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %PhoneNumber{} = phone_number} =
               PhoneNumbers.purchase(client, account_id, params)

      assert phone_number.number == "+14155551234"
      assert phone_number.type == :local
    end

    test "returns error when no phone numbers available" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        type: :local,
        area_code: "999"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "resource_unavailable",
            "message" => "No phone numbers available in area code 999"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = PhoneNumbers.purchase(client, account_id, params)
      assert error.type == "resource_unavailable"
      assert error.message == "No phone numbers available in area code 999"
    end

    test "returns error when invalid type provided" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        type: :invalid
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "Invalid phone number type. Must be 'local' or 'toll_free'"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = PhoneNumbers.purchase(client, account_id, params)
      assert error.type == "validation_error"
      assert error.message == "Invalid phone number type. Must be 'local' or 'toll_free'"
    end

    test "returns error when account not found" do
      account_id = "acct_nonexistent"

      params = %{
        type: :local
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

      assert {:error, error} = PhoneNumbers.purchase(client, account_id, params)
      assert error.type == "not_found_error"
      assert error.message == "Account 'acct_nonexistent' not found"
    end

    test "returns error when account has insufficient funds" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        type: :toll_free
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(402)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "payment_required",
            "message" => "Insufficient funds to purchase phone number"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = PhoneNumbers.purchase(client, account_id, params)
      assert error.type == "payment_required"
      assert error.message == "Insufficient funds to purchase phone number"
    end

    test "handles connection errors" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        type: :local
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = PhoneNumbers.purchase(client, account_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "purchase/3 with string type" do
    test "accepts string type and converts to API format" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Using string type (backwards compatibility)
      params = %{
        type: "local",
        area_code: "801"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        # Should still send as "local" to the API
        assert conn.params["type"] == "local"
        assert conn.params["area_code"] == "801"

        response_body = phone_number_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %PhoneNumber{} = phone_number} =
               PhoneNumbers.purchase(client, account_id, params)

      assert phone_number.type == :local
    end

    test "handles params without type field" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # No type field at all
      params = %{
        area_code: "801"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        # Type should be nil when not provided
        assert conn.params["type"] == nil
        assert conn.params["area_code"] == "801"

        response_body = phone_number_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %PhoneNumber{}} = PhoneNumbers.purchase(client, account_id, params)
    end
  end

  describe "purchase/2" do
    test "uses default client" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        type: :local,
        area_code: "415"
      }

      response_body =
        phone_number_fixture(%{
          "number" => "+14155551234"
        })

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %PhoneNumber{} = phone_number} = PhoneNumbers.purchase(account_id, params)
      assert phone_number.id == "pn_01jsjwe4d9fx3tpymgtg958d9w"
      assert phone_number.number == "+14155551234"
    end
  end
end
