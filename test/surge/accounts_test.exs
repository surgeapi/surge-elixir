defmodule Surge.AccountsTest do
  use ExUnit.Case, async: true

  alias Surge.Accounts
  alias Surge.Accounts.Account
  alias Surge.Accounts.AccountStatus
  alias Surge.AccountsFixtures
  alias Surge.Client

  describe "archive/2" do
    test "archives an account by ID" do
      account_id = "acct_abc123"

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.method == "DELETE"
        assert conn.request_path == "/accounts/acct_abc123"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]

        response_body =
          AccountsFixtures.account_fixture(%{
            "id" => "acct_abc123",
            "name" => "Test Account"
          })

        Req.Test.json(conn, response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])
      assert {:ok, %Account{} = account} = Accounts.archive(client, account_id)

      assert account.id == "acct_abc123"
      assert account.name == "Test Account"
    end

    test "returns error when API request fails" do
      account_id = "acct_abc123"

      Req.Test.stub(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(500)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "internal_server_error",
            "message" => "Something went wrong on Surge's end."
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])
      assert {:error, error} = Accounts.archive(client, account_id)
      assert error.type == "internal_server_error"
      assert error.message == "Something went wrong on Surge's end."
    end

    test "handles connection errors" do
      account_id = "acct_abc123"

      Req.Test.stub(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Accounts.archive(client, account_id)
      assert error.type == "connection_error"
    end
  end

  describe "archive/1" do
    test "uses default client" do
      account_id = "acct_abc123"

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        response_body =
          AccountsFixtures.account_fixture(%{
            "id" => "acct_abc123",
            "name" => "Test Account"
          })

        Req.Test.json(conn, response_body)
      end)

      assert {:ok, %Account{} = account} = Accounts.archive(account_id)

      assert account.id == "acct_abc123"
      assert account.name == "Test Account"
    end
  end

  describe "create/2" do
    test "creates an account with valid params" do
      # Example request from OpenAPI spec
      params = %{
        name: "Account #2840 - DT Precision Auto",
        brand_name: "DT Precision Auto",
        organization: %{
          address: %{
            country: "US",
            line1: "2640 Huron St",
            line2: nil,
            locality: "Los Angeles",
            name: "DT Precision Auto",
            postal_code: "90065",
            region: "CA"
          },
          contact: %{
            email: "dom@dtprecisionauto.com",
            first_name: "Dominic",
            last_name: "Toretto",
            phone_number: "+13235556439",
            title: "other",
            title_other: "Owner"
          },
          country: "US",
          email: "dom@dtprecisionauto.com",
          identifier: "123456789",
          identifier_type: "ein",
          industry: "automotive",
          mobile_number: "+13235556439",
          regions_of_operation: [
            "usa_and_canada"
          ],
          registered_name: "DT Precision Auto LLC",
          stock_exchange: nil,
          stock_symbol: nil,
          type: "llc",
          website: "https://dtprecisionauto.com"
        },
        time_zone: "America/Los_Angeles"
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["name"] == "Account #2840 - DT Precision Auto"
        assert conn.params["brand_name"] == "DT Precision Auto"
        assert conn.params["organization"]["address"]["country"] == "US"
        assert conn.params["organization"]["address"]["line1"] == "2640 Huron St"
        assert is_nil(conn.params["organization"]["address"]["line2"])
        assert conn.params["organization"]["address"]["locality"] == "Los Angeles"
        assert conn.params["organization"]["address"]["name"] == "DT Precision Auto"
        assert conn.params["organization"]["address"]["postal_code"] == "90065"
        assert conn.params["organization"]["address"]["region"] == "CA"
        assert conn.params["organization"]["contact"]["email"] == "dom@dtprecisionauto.com"
        assert conn.params["organization"]["contact"]["first_name"] == "Dominic"
        assert conn.params["organization"]["contact"]["last_name"] == "Toretto"
        assert conn.params["organization"]["contact"]["phone_number"] == "+13235556439"
        assert conn.params["organization"]["contact"]["title"] == "other"
        assert conn.params["organization"]["contact"]["title_other"] == "Owner"
        assert conn.params["organization"]["country"] == "US"
        assert conn.params["organization"]["email"] == "dom@dtprecisionauto.com"
        assert conn.params["organization"]["identifier"] == "123456789"
        assert conn.params["organization"]["identifier_type"] == "ein"
        assert conn.params["organization"]["industry"] == "automotive"
        assert conn.params["organization"]["mobile_number"] == "+13235556439"
        assert conn.params["organization"]["regions_of_operation"] == ["usa_and_canada"]
        assert conn.params["organization"]["registered_name"] == "DT Precision Auto LLC"
        assert is_nil(conn.params["organization"]["stock_exchange"])
        assert is_nil(conn.params["organization"]["stock_symbol"])
        assert conn.params["organization"]["type"] == "llc"
        assert conn.params["organization"]["website"] == "https://dtprecisionauto.com"
        assert conn.params["time_zone"] == "America/Los_Angeles"

        # Example response from OpenAPI spec
        response_body =
          AccountsFixtures.account_fixture(%{
            "brand_name" => "DT Precision Auto",
            "id" => "acct_01jpqjvfg9enpt7pyxd60pcmxj",
            "name" => "Account #2840 - DT Precision Auto",
            "organization" => %{
              "address" => %{
                "country" => "US",
                "line1" => "2640 Huron St",
                "line2" => nil,
                "locality" => "Los Angeles",
                "name" => "DT Precision Auto",
                "postal_code" => "90065",
                "region" => "CA"
              },
              "contact" => %{
                "email" => "dom@dtprecisionauto.com",
                "first_name" => "Dominic",
                "last_name" => "Toretto",
                "phone_number" => "+13235556439",
                "title" => "other",
                "title_other" => "Owner"
              },
              "country" => "US",
              "email" => "dom@dtprecisionauto.com",
              "identifier" => "123456789",
              "identifier_type" => "ein",
              "industry" => "automotive",
              "mobile_number" => "+13235556439",
              "regions_of_operation" => [
                "usa_and_canada"
              ],
              "registered_name" => "DT Precision Auto LLC",
              "stock_exchange" => nil,
              "stock_symbol" => nil,
              "type" => "llc",
              "website" => "https://dtprecisionauto.com"
            },
            "time_zone" => "America/Los_Angeles"
          })

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Account{} = account} = Accounts.create(client, params)
      assert account.id == "acct_01jpqjvfg9enpt7pyxd60pcmxj"
      assert account.name == "Account #2840 - DT Precision Auto"
      assert account.brand_name == "DT Precision Auto"
      assert account.time_zone == "America/Los_Angeles"

      assert account.organization.address.country == "US"
      assert account.organization.address.line1 == "2640 Huron St"
      assert is_nil(account.organization.address.line2)
      assert account.organization.address.locality == "Los Angeles"
      assert account.organization.address.name == "DT Precision Auto"
      assert account.organization.address.postal_code == "90065"
      assert account.organization.address.region == "CA"

      assert account.organization.contact.email == "dom@dtprecisionauto.com"
      assert account.organization.contact.first_name == "Dominic"
      assert account.organization.contact.last_name == "Toretto"
      assert account.organization.contact.phone_number == "+13235556439"
      assert account.organization.contact.title == :other
      assert account.organization.contact.title_other == "Owner"

      assert account.organization.country == "US"
      assert account.organization.email == "dom@dtprecisionauto.com"
      assert account.organization.identifier == "123456789"
      assert account.organization.identifier_type == :ein
      assert account.organization.industry == :automotive
      assert account.organization.mobile_number == "+13235556439"
      assert account.organization.regions_of_operation == [:usa_and_canada]
      assert account.organization.registered_name == "DT Precision Auto LLC"
      assert is_nil(account.organization.stock_exchange)
      assert is_nil(account.organization.stock_symbol)
      assert account.organization.type == :llc
      assert account.organization.website == "https://dtprecisionauto.com"
    end

    test "returns error when API request fails" do
      params = %{name: "Test Account"}

      Req.Test.stub(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "invalid_request_error",
            "message" => "Invalid parameters provided"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Accounts.create(client, params)
      assert error.type == "invalid_request_error"
      assert error.message == "Invalid parameters provided"
    end

    test "handles connection errors" do
      params = %{name: "Test Account"}

      Req.Test.stub(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Accounts.create(client, params)
      assert error.type == "connection_error"
    end
  end

  describe "create/1" do
    test "uses default client" do
      params = %{name: "Test Account"}

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        response_body =
          AccountsFixtures.account_fixture(%{
            "id" => "acct_def456",
            "name" => "Test Account"
          })

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Account{} = account} = Accounts.create(params)
      assert account.id == "acct_def456"
      assert account.name == "Test Account"
    end
  end

  describe "get_status/3" do
    test "retrieves account status with capabilities" do
      account_id = "acct_abc123"
      capabilities = [:local_messaging]

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/accounts/acct_abc123/status"
        assert conn.params["capabilities"] == "local_messaging"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]

        response_body = %{
          "capabilities" => %{
            "local_messaging" => %{
              "errors" => [],
              "fields_needed" => [],
              "status" => "ready"
            }
          }
        }

        Req.Test.json(conn, response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %AccountStatus{} = status} =
               Accounts.get_status(client, account_id, capabilities)

      assert status.capabilities.local_messaging.status == :ready
      assert status.capabilities.local_messaging.errors == []
      assert status.capabilities.local_messaging.fields_needed == []
    end

    test "handles capability with incomplete status" do
      account_id = "acct_abc123"
      capabilities = [:local_messaging]

      response_body = %{
        "capabilities" => %{
          "local_messaging" => %{
            "status" => "incomplete",
            "errors" => [],
            "fields_needed" => ["business_address", "website"]
          }
        }
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        Req.Test.json(conn, response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %AccountStatus{} = status} =
               Accounts.get_status(client, account_id, capabilities)

      assert status.capabilities.local_messaging.status == :incomplete
      assert status.capabilities.local_messaging.fields_needed == ["business_address", "website"]
    end

    test "handles capability with error status" do
      account_id = "acct_abc123"
      capabilities = [:local_messaging]

      response_body = %{
        "capabilities" => %{
          "local_messaging" => %{
            "status" => "error",
            "errors" => [
              %{
                "field" => "organization.registered_name",
                "message" => "The provided EIN doesn't match the organization's registered name.",
                "type" => "ein_mismatch"
              }
            ],
            "fields_needed" => []
          }
        }
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        Req.Test.json(conn, response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %AccountStatus{} = status} =
               Accounts.get_status(client, account_id, capabilities)

      assert status.capabilities.local_messaging.status == :error
      assert [error] = status.capabilities.local_messaging.errors
      assert error.field == "organization.registered_name"
      assert error.message == "The provided EIN doesn't match the organization's registered name."
      assert error.type == "ein_mismatch"
    end

    test "handles multiple capabilities" do
      account_id = "acct_abc123"
      capabilities = [:local_messaging, :other_capability]

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.params["capabilities"] == "local_messaging,other_capability"
        Req.Test.json(conn, %{"capabilities" => %{}})
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %AccountStatus{}} = Accounts.get_status(client, account_id, capabilities)
    end

    test "returns error when account not found" do
      account_id = "acct_abc123"
      capabilities = [:local_messaging]

      Req.Test.stub(Surge.TestClient, fn conn ->
        error_response = %{
          "error" => %{
            "type" => "not_found",
            "message" => "The requested resource could not be found."
          }
        }

        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(error_response)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Accounts.get_status(client, account_id, capabilities)
      assert error.type == "not_found"
      assert error.message == "The requested resource could not be found."
    end
  end

  describe "get_status/2" do
    test "uses default client" do
      account_id = "acct_abc123"
      capabilities = [:local_messaging]

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        response_body = %{
          "capabilities" => %{
            "local_messaging" => %{
              "status" => "ready",
              "errors" => [],
              "fields_needed" => []
            }
          }
        }

        Req.Test.json(conn, response_body)
      end)

      assert {:ok, %AccountStatus{}} = Accounts.get_status(account_id, capabilities)
    end
  end

  describe "update/3" do
    test "updates an account with valid params" do
      account_id = "acct_01jpqjvfg9enpt7pyxd60pcmxj"

      # Example request from OpenAPI spec
      params = %{
        "name" => "Account #2840 - DT Precision Auto",
        "brand_name" => "DT Precision Auto",
        "time_zone" => "America/Los_Angeles",
        "organization" => %{
          "type" => "llc",
          "country" => "US",
          "identifier_type" => "ein",
          "identifier" => "123456789",
          "registered_name" => "DT Precision Auto LLC",
          "industry" => "automotive",
          "website" => "https://dtprecisionauto.com",
          "regions_of_operation" => ["usa_and_canada"],
          "stock_exchange" => nil,
          "stock_symbol" => nil,
          "email" => "dom@dtprecisionauto.com",
          "mobile_number" => "+13235556439",
          "address" => %{
            "name" => "DT Precision Auto",
            "line1" => "2640 Huron St",
            "line2" => nil,
            "locality" => "Los Angeles",
            "region" => "CA",
            "postal_code" => "90065",
            "country" => "US"
          },
          "contact" => %{
            "first_name" => "Dominic",
            "last_name" => "Toretto",
            "email" => "dom@dtprecisionauto.com",
            "phone_number" => "+13235556439",
            "title" => "other",
            "title_other" => "Owner"
          }
        }
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.method == "PATCH"
        assert conn.request_path == "/accounts/acct_01jpqjvfg9enpt7pyxd60pcmxj"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]

        assert conn.params["name"] == "Account #2840 - DT Precision Auto"
        assert conn.params["brand_name"] == "DT Precision Auto"
        assert conn.params["time_zone"] == "America/Los_Angeles"
        assert conn.params["organization"]["type"] == "llc"
        assert conn.params["organization"]["country"] == "US"
        assert conn.params["organization"]["identifier_type"] == "ein"
        assert conn.params["organization"]["identifier"] == "123456789"
        assert conn.params["organization"]["registered_name"] == "DT Precision Auto LLC"
        assert conn.params["organization"]["industry"] == "automotive"
        assert conn.params["organization"]["website"] == "https://dtprecisionauto.com"
        assert conn.params["organization"]["regions_of_operation"] == ["usa_and_canada"]
        assert is_nil(conn.params["organization"]["stock_exchange"])
        assert is_nil(conn.params["organization"]["stock_symbol"])
        assert conn.params["organization"]["email"] == "dom@dtprecisionauto.com"
        assert conn.params["organization"]["mobile_number"] == "+13235556439"
        assert conn.params["organization"]["address"]["name"] == "DT Precision Auto"
        assert conn.params["organization"]["address"]["line1"] == "2640 Huron St"
        assert is_nil(conn.params["organization"]["address"]["line2"])
        assert conn.params["organization"]["address"]["locality"] == "Los Angeles"
        assert conn.params["organization"]["address"]["region"] == "CA"
        assert conn.params["organization"]["address"]["postal_code"] == "90065"
        assert conn.params["organization"]["address"]["country"] == "US"
        assert conn.params["organization"]["contact"]["first_name"] == "Dominic"
        assert conn.params["organization"]["contact"]["last_name"] == "Toretto"
        assert conn.params["organization"]["contact"]["email"] == "dom@dtprecisionauto.com"
        assert conn.params["organization"]["contact"]["phone_number"] == "+13235556439"
        assert conn.params["organization"]["contact"]["title"] == "other"
        assert conn.params["organization"]["contact"]["title_other"] == "Owner"

        response_body = %{
          "id" => "acct_01jpqjvfg9enpt7pyxd60pcmxj",
          "name" => "Account #2840 - DT Precision Auto",
          "brand_name" => "DT Precision Auto",
          "time_zone" => "America/Los_Angeles",
          "organization" => %{
            "type" => "llc",
            "country" => "US",
            "identifier_type" => "ein",
            "identifier" => "123456789",
            "registered_name" => "DT Precision Auto LLC",
            "industry" => "automotive",
            "website" => "https://dtprecisionauto.com",
            "regions_of_operation" => ["usa_and_canada"],
            "stock_exchange" => nil,
            "stock_symbol" => nil,
            "email" => "dom@dtprecisionauto.com",
            "mobile_number" => "+13235556439",
            "address" => %{
              "name" => "DT Precision Auto",
              "line1" => "2640 Huron St",
              "line2" => nil,
              "locality" => "Los Angeles",
              "region" => "CA",
              "postal_code" => "90065",
              "country" => "US"
            },
            "contact" => %{
              "first_name" => "Dominic",
              "last_name" => "Toretto",
              "email" => "dom@dtprecisionauto.com",
              "phone_number" => "+13235556439",
              "title" => "other",
              "title_other" => "Owner"
            }
          }
        }

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Account{} = account} = Accounts.update(client, account_id, params)
      assert account.id == "acct_01jpqjvfg9enpt7pyxd60pcmxj"
      assert account.name == "Account #2840 - DT Precision Auto"
      assert account.brand_name == "DT Precision Auto"
      assert account.time_zone == "America/Los_Angeles"
      assert account.organization.type == :llc
      assert account.organization.country == "US"
      assert account.organization.identifier_type == :ein
      assert account.organization.identifier == "123456789"
      assert account.organization.registered_name == "DT Precision Auto LLC"
      assert account.organization.industry == :automotive
      assert account.organization.website == "https://dtprecisionauto.com"
      assert account.organization.regions_of_operation == [:usa_and_canada]
      assert is_nil(account.organization.stock_exchange)
      assert is_nil(account.organization.stock_symbol)
      assert account.organization.email == "dom@dtprecisionauto.com"
      assert account.organization.mobile_number == "+13235556439"
      assert account.organization.address.name == "DT Precision Auto"
      assert account.organization.address.line1 == "2640 Huron St"
      assert is_nil(account.organization.address.line2)
      assert account.organization.address.locality == "Los Angeles"
      assert account.organization.address.region == "CA"
      assert account.organization.address.postal_code == "90065"
      assert account.organization.address.country == "US"
      assert account.organization.contact.first_name == "Dominic"
      assert account.organization.contact.last_name == "Toretto"
      assert account.organization.contact.email == "dom@dtprecisionauto.com"
      assert account.organization.contact.phone_number == "+13235556439"
      assert account.organization.contact.title == :other
      assert account.organization.contact.title_other == "Owner"
    end

    test "handles partial updates" do
      account_id = "acct_abc123"

      # Only updating the name
      params = %{name: "Updated Name"}

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.params["name"] == params.name

        response_body =
          AccountsFixtures.account_fixture(%{
            "id" => "acct_abc123",
            "name" => "Updated Name",
            "brand_name" => "Original Brand"
          })

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Account{} = account} = Accounts.update(client, account_id, params)
      assert account.name == "Updated Name"
      assert account.brand_name == "Original Brand"
    end

    test "returns error when update fails" do
      account_id = "acct_abc123"
      params = %{name: ""}

      Req.Test.stub(Surge.TestClient, fn conn ->
        error_response = %{
          "error" => %{
            "type" => "validation_error",
            "message" => "Name cannot be empty"
          }
        }

        conn
        |> Plug.Conn.put_status(422)
        |> Req.Test.json(error_response)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Accounts.update(client, account_id, params)
      assert error.type == "validation_error"
      assert error.message == "Name cannot be empty"
    end
  end

  describe "update/2" do
    test "uses default client" do
      account_id = "acct_abc123"
      params = %{name: "Updated Account"}

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        response_body =
          AccountsFixtures.account_fixture(%{
            "id" => "acct_abc123",
            "name" => "Updated Account"
          })

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Account{}} = Accounts.update(account_id, params)
    end
  end
end
