defmodule Surge.CampaignsFixtures do
  @moduledoc """
  Fixtures to help with testing Campaigns.
  """

  def campaign_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "cpn_01k0qczvhbet4azgn5xm2ccfst",
      "consent_flow" =>
        "When customers bring in their car for service, they will fill out this web form for intake: https://fastauto.shop/bp108c In it they can choose to opt in to text message notifications. If they choose to opt in, we will send them notifications to let them know if our mechanics find issues and once the car is ready to go, as well as links to invoices and to leave us feedback.",
      "description" =>
        "This phone number will send auto maintenance notifications to end users that have opted in. It will also be used for responding to customer inquiries and sending some marketing offers.",
      "includes" => ["links", "phone_numbers"],
      "link_sample" => "https://l.fastauto.shop/s034ij",
      "message_samples" => [
        "You are now opted in to receive repair notifications from DT Precision Auto. Frequency varies. Msg&data rates apply. Reply STOP to opt out.",
        "You're lucky that hundred shot of NOS didn't blow the welds on the intake!",
        "Your car is ready to go. See your invoice here: https://l.fastauto.shop/s034ij"
      ],
      "privacy_policy_url" => "https://fastauto.shop/sms-privacy",
      "terms_and_conditions_url" => "https://fastauto.shop/terms-and-conditions",
      "use_cases" => ["account_notification", "customer_care", "marketing"],
      "volume" => "high"
    })
  end

  def minimal_campaign_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "cpn_minimal123",
      "description" => "Basic campaign"
    })
  end

  def campaign_with_all_includes_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "cpn_allincludes",
      "includes" => ["links", "phone_numbers", "age_gated", "direct_lending"],
      "description" => "Campaign with all includes"
    })
  end

  def campaign_with_all_use_cases_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "cpn_allusecases",
      "use_cases" => [
        "account_notification",
        "customer_care",
        "delivery_notification",
        "fraud_alert",
        "higher_education",
        "marketing",
        "polling_voting",
        "public_service_announcement",
        "security_alert",
        "two_factor_authentication"
      ],
      "description" => "Campaign with all use cases"
    })
  end

  def campaign_with_unknown_fields_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "cpn_unknown",
      "description" => "Campaign with unknown fields",
      "includes" => ["links", "unknown_include"],
      "use_cases" => ["marketing", "unknown_use_case"],
      "volume" => "medium"
    })
  end

  def campaign_with_low_volume_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "cpn_lowvol",
      "description" => "Low volume campaign",
      "volume" => "low"
    })
  end
end
