defmodule Surge.PhoneNumbers do
  @moduledoc """
  Functions for managing Surge phone numbers.
  """

  alias Surge.Client
  alias Surge.PhoneNumbers.PhoneNumber

  @doc """
  Purchases a new phone number.

  ## Examples

      iex> Surge.PhoneNumbers.purchase("acct_123", %{type: :toll_free})
      {:ok, %Surge.PhoneNumbers.PhoneNumber{}}

      iex> # Purchase with area code search
      iex> Surge.PhoneNumbers.purchase("acct_123", %{type: :local, area_code: "415"})
      {:ok, %Surge.PhoneNumbers.PhoneNumber{}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.PhoneNumbers.purchase(client, "acct_123", %{area_code: "212", type: :local})
      {:ok, %Surge.PhoneNumbers.PhoneNumber{}}
  """
  @spec purchase(String.t(), map()) :: {:ok, PhoneNumber.t()} | {:error, Surge.Error.t()}
  @spec purchase(Client.t(), String.t(), map()) ::
          {:ok, PhoneNumber.t()} | {:error, Surge.Error.t()}
  def purchase(client \\ Client.default_client(), account_id, params)

  def purchase(%Client{} = client, account_id, params) do
    case Client.request(client, :post, "/accounts/#{account_id}/phone_numbers", json: params) do
      {:ok, data} -> {:ok, PhoneNumber.from_json(data)}
      error -> error
    end
  end
end
