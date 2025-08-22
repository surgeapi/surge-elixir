defmodule Surge.Campaigns.Campaign do
  @moduledoc """
  A campaign represents the context in which one or more of your phone numbers
  communicates with your contacts. Consent and opt-outs are tied to the
  campaign.
  """

  @type include :: :links | :phone_numbers | :age_gated | :direct_lending

  @type use_case ::
          :account_notification
          | :customer_care
          | :delivery_notification
          | :fraud_alert
          | :higher_education
          | :marketing
          | :polling_voting
          | :public_service_announcement
          | :security_alert
          | :two_factor_authentication

  @type volume :: :high | :low

  @type t :: %__MODULE__{
          id: String.t(),
          consent_flow: String.t() | nil,
          description: String.t() | nil,
          includes: list(include()),
          link_sample: String.t() | nil,
          message_samples: list(String.t()),
          privacy_policy_url: String.t() | nil,
          terms_and_conditions_url: String.t() | nil,
          use_cases: list(use_case()),
          volume: volume() | nil
        }

  defstruct [
    :id,
    :consent_flow,
    :description,
    :includes,
    :link_sample,
    :message_samples,
    :privacy_policy_url,
    :terms_and_conditions_url,
    :use_cases,
    :volume
  ]

  @doc """
  Converts JSON response to Campaign struct.

  ## Examples

      iex> data = %{"id" => "cmp_123", "volume" => "high"}
      iex> Surge.Campaigns.Campaign.from_json(data)
      %Surge.Campaigns.Campaign{id: "cmp_123", volume: :high}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      consent_flow: data["consent_flow"],
      description: data["description"],
      includes: parse_includes(data["includes"]),
      link_sample: data["link_sample"],
      message_samples: parse_message_samples(data["message_samples"]),
      privacy_policy_url: data["privacy_policy_url"],
      terms_and_conditions_url: data["terms_and_conditions_url"],
      use_cases: parse_use_cases(data["use_cases"]),
      volume: parse_volume(data["volume"])
    }
  end

  # Private

  @spec parse_includes(list(String.t()) | nil) :: list(include())
  defp parse_includes(nil), do: []

  defp parse_includes(includes) when is_list(includes) do
    includes
    |> Enum.map(&parse_include/1)
    |> Enum.reject(&is_nil/1)
  end

  @spec parse_include(String.t()) :: include()
  defp parse_include("links"), do: :links
  defp parse_include("phone_numbers"), do: :phone_numbers
  defp parse_include("age_gated"), do: :age_gated
  defp parse_include("direct_lending"), do: :direct_lending
  defp parse_include(_), do: nil

  @spec parse_message_samples(list(String.t()) | nil) :: list(String.t())
  defp parse_message_samples(nil), do: []
  defp parse_message_samples(samples) when is_list(samples), do: samples

  @spec parse_use_cases(list(String.t()) | nil) :: list(use_case())
  defp parse_use_cases(nil), do: []

  defp parse_use_cases(use_cases) when is_list(use_cases) do
    use_cases
    |> Enum.map(&parse_use_case/1)
    |> Enum.reject(&is_nil/1)
  end

  @spec parse_use_case(String.t()) :: use_case()
  defp parse_use_case("account_notification"), do: :account_notification
  defp parse_use_case("customer_care"), do: :customer_care
  defp parse_use_case("delivery_notification"), do: :delivery_notification
  defp parse_use_case("fraud_alert"), do: :fraud_alert
  defp parse_use_case("higher_education"), do: :higher_education
  defp parse_use_case("marketing"), do: :marketing
  defp parse_use_case("polling_voting"), do: :polling_voting
  defp parse_use_case("public_service_announcement"), do: :public_service_announcement
  defp parse_use_case("security_alert"), do: :security_alert
  defp parse_use_case("two_factor_authentication"), do: :two_factor_authentication
  defp parse_use_case(_), do: nil

  @spec parse_volume(String.t()) :: volume()
  defp parse_volume(nil), do: nil
  defp parse_volume("high"), do: :high
  defp parse_volume("low"), do: :low
  defp parse_volume(_), do: nil
end
