defmodule Surge.CampaignsTest do
  use ExUnit.Case, async: true

  alias Surge.Campaigns
  alias Surge.Campaigns.Campaign
  alias Surge.Client

  import Surge.CampaignsFixtures

  describe "create/3" do
    test "creates a campaign with valid params matching OpenAPI example" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Example request from OpenAPI spec
      params = %{
        consent_flow:
          "When customers bring in their car for service, they will fill out this web form for intake: https://fastauto.shop/bp108c In it they can choose to opt in to text message notifications. If they choose to opt in, we will send them notifications to let them know if our mechanics find issues and once the car is ready to go, as well as links to invoices and to leave us feedback.",
        description:
          "This phone number will send auto maintenance notifications to end users that have opted in. It will also be used for responding to customer inquiries and sending some marketing offers.",
        message_samples: [
          "You are now opted in to receive repair notifications from DT Precision Auto. Frequency varies. Msg&data rates apply. Reply STOP to opt out.",
          "You're lucky that hundred shot of NOS didn't blow the welds on the intake!",
          "Your car is ready to go. See your invoice here: https://l.fastauto.shop/s034ij"
        ],
        privacy_policy_url: "https://fastauto.shop/sms-privacy",
        use_cases: [
          "account_notification",
          "customer_care",
          "marketing"
        ],
        volume: "high",
        includes: [
          "links",
          "phone_numbers"
        ],
        link_sample: "https://l.fastauto.shop/s034ij",
        terms_and_conditions_url: "https://fastauto.shop/terms-and-conditions"
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/campaigns"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["consent_flow"] == params.consent_flow
        assert conn.params["description"] == params.description
        assert conn.params["message_samples"] == params.message_samples
        assert conn.params["privacy_policy_url"] == params.privacy_policy_url
        assert conn.params["use_cases"] == params.use_cases
        assert conn.params["volume"] == params.volume
        assert conn.params["includes"] == params.includes
        assert conn.params["link_sample"] == params.link_sample
        assert conn.params["terms_and_conditions_url"] == params.terms_and_conditions_url

        # Example response from OpenAPI spec
        response_body = campaign_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Campaign{} = campaign} = Campaigns.create(client, account_id, params)
      assert campaign.id == "cpn_01k0qczvhbet4azgn5xm2ccfst"
      assert campaign.consent_flow == params.consent_flow
      assert campaign.description == params.description
      assert campaign.message_samples == params.message_samples
      assert campaign.privacy_policy_url == params.privacy_policy_url
      assert campaign.terms_and_conditions_url == params.terms_and_conditions_url
      assert campaign.use_cases == [:account_notification, :customer_care, :marketing]
      assert campaign.volume == :high
      assert campaign.includes == [:links, :phone_numbers]
      assert campaign.link_sample == params.link_sample
    end

    test "creates a campaign with minimal fields" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Minimal params - only required fields
      params = %{
        description: "Basic campaign"
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/accounts/acct_01j9a43avnfqzbjfch6pygv1td/campaigns"

        assert conn.params["description"] == "Basic campaign"

        # Response without optional fields
        response_body = minimal_campaign_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Campaign{} = campaign} = Campaigns.create(client, account_id, params)
      assert campaign.id == "cpn_minimal123"
      assert campaign.description == "Basic campaign"
      assert is_nil(campaign.consent_flow)
      assert campaign.includes == []
      assert is_nil(campaign.link_sample)
      assert campaign.message_samples == []
      assert is_nil(campaign.privacy_policy_url)
      assert is_nil(campaign.terms_and_conditions_url)
      assert campaign.use_cases == []
      assert is_nil(campaign.volume)
    end

    test "returns error when API request fails with validation error" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      # Invalid params
      params = %{}

      Req.Test.stub(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "The 'description' field is required"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Campaigns.create(client, account_id, params)
      assert error.type == "validation_error"
      assert error.message == "The 'description' field is required"
    end

    test "returns error when account not found" do
      account_id = "acct_nonexistent"

      params = %{
        description: "Test campaign"
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

      assert {:error, error} = Campaigns.create(client, account_id, params)
      assert error.type == "not_found_error"
      assert error.message == "Account 'acct_nonexistent' not found"
    end

    test "handles connection errors" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        description: "Test campaign"
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Campaigns.create(client, account_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "create/2" do
    test "uses default client" do
      account_id = "acct_01j9a43avnfqzbjfch6pygv1td"

      params = %{
        description: "Test campaign"
      }

      response_body = %{
        "id" => "cpn_def456",
        "description" => "Test campaign"
      }

      Req.Test.stub(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Campaign{} = campaign} = Campaigns.create(account_id, params)
      assert campaign.id == "cpn_def456"
      assert campaign.description == "Test campaign"
    end
  end

  describe "Campaign.from_json/1" do
    test "parses all includes types correctly" do
      data = campaign_with_all_includes_fixture()

      campaign = Campaign.from_json(data)

      assert campaign.id == "cpn_allincludes"
      assert campaign.includes == [:links, :phone_numbers, :age_gated, :direct_lending]
      assert campaign.description == "Campaign with all includes"
    end

    test "parses all use case types correctly" do
      data = campaign_with_all_use_cases_fixture()

      campaign = Campaign.from_json(data)

      assert campaign.id == "cpn_allusecases"

      assert campaign.use_cases == [
               :account_notification,
               :customer_care,
               :delivery_notification,
               :fraud_alert,
               :higher_education,
               :marketing,
               :polling_voting,
               :public_service_announcement,
               :security_alert,
               :two_factor_authentication
             ]

      assert campaign.description == "Campaign with all use cases"
    end

    test "handles unknown includes and use cases gracefully" do
      data = campaign_with_unknown_fields_fixture()

      campaign = Campaign.from_json(data)

      assert campaign.id == "cpn_unknown"
      # Unknown values should be filtered out
      assert campaign.includes == [:links]
      assert campaign.use_cases == [:marketing]
      # Unknown volume value should return nil
      assert is_nil(campaign.volume)
    end

    test "parses low volume correctly" do
      data = campaign_with_low_volume_fixture()

      campaign = Campaign.from_json(data)

      assert campaign.id == "cpn_lowvol"
      assert campaign.volume == :low
      assert campaign.description == "Low volume campaign"
    end

    test "handles nil values for all optional fields" do
      data = %{
        "id" => "cpn_niltest",
        "consent_flow" => nil,
        "description" => nil,
        "includes" => nil,
        "link_sample" => nil,
        "message_samples" => nil,
        "privacy_policy_url" => nil,
        "terms_and_conditions_url" => nil,
        "use_cases" => nil,
        "volume" => nil
      }

      campaign = Campaign.from_json(data)

      assert campaign.id == "cpn_niltest"
      assert is_nil(campaign.consent_flow)
      assert is_nil(campaign.description)
      assert campaign.includes == []
      assert is_nil(campaign.link_sample)
      assert campaign.message_samples == []
      assert is_nil(campaign.privacy_policy_url)
      assert is_nil(campaign.terms_and_conditions_url)
      assert campaign.use_cases == []
      assert is_nil(campaign.volume)
    end

    test "handles empty lists correctly" do
      data = %{
        "id" => "cpn_emptylist",
        "includes" => [],
        "message_samples" => [],
        "use_cases" => []
      }

      campaign = Campaign.from_json(data)

      assert campaign.id == "cpn_emptylist"
      assert campaign.includes == []
      assert campaign.message_samples == []
      assert campaign.use_cases == []
    end

    test "preserves message samples as strings" do
      data = %{
        "id" => "cpn_samples",
        "message_samples" => [
          "First sample message",
          "Second sample with special chars: $%&",
          "Third sample with emoji 🚗"
        ]
      }

      campaign = Campaign.from_json(data)

      assert campaign.id == "cpn_samples"

      assert campaign.message_samples == [
               "First sample message",
               "Second sample with special chars: $%&",
               "Third sample with emoji 🚗"
             ]
    end

    test "handles complete campaign data from OpenAPI spec" do
      data = campaign_fixture()

      campaign = Campaign.from_json(data)

      assert campaign.id == "cpn_01k0qczvhbet4azgn5xm2ccfst"
      assert campaign.consent_flow =~ "When customers bring in their car"
      assert campaign.description =~ "auto maintenance notifications"
      assert campaign.includes == [:links, :phone_numbers]
      assert campaign.link_sample == "https://l.fastauto.shop/s034ij"
      assert length(campaign.message_samples) == 3
      assert campaign.privacy_policy_url == "https://fastauto.shop/sms-privacy"
      assert campaign.terms_and_conditions_url == "https://fastauto.shop/terms-and-conditions"
      assert campaign.use_cases == [:account_notification, :customer_care, :marketing]
      assert campaign.volume == :high
    end
  end
end
