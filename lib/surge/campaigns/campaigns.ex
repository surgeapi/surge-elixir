defmodule Surge.Campaigns do
  @moduledoc """
  Functions for managing Surge campaigns.
  """

  alias Surge.Campaigns.Campaign
  alias Surge.Client

  @doc """
  Creates a campaign to register account to send text messages.

  ## Examples

      iex> Surge.Campaigns.create("acct_123", %{
      ...>   consent_flow: "People will sign up through a long flow.",
      ...>   description: "This campaign will be used to send people messages.",
      ...>   message_samples: ["Get 20% off!"]
      ...> })
      {:ok, %Surge.Campaigns.Campaign{}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Campaigns.create(client, "acct_123", %{consent_flow: "People will opt in"})
      {:ok, %Surge.Campaigns.Campaign{}}

  """
  @spec create(String.t(), map()) :: {:ok, Campaign.t()} | {:error, Surge.Error.t()}
  @spec create(Client.t(), String.t(), map()) :: {:ok, Campaign.t()} | {:error, Surge.Error.t()}
  def create(client \\ Client.default_client(), account_id, params)

  def create(%Client{} = client, account_id, params) do
    case Client.request(client, :post, "/accounts/#{account_id}/campaigns", json: params) do
      {:ok, data} -> {:ok, Campaign.from_json(data)}
      error -> error
    end
  end
end
