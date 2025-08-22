defmodule Surge.Blasts do
  @moduledoc """
  Functions for managing Surge blasts.
  """

  alias Surge.Blasts.Blast
  alias Surge.Client

  @doc """
  Sends a Blast.

  ## Examples

      Surge.Blasts.create("acct_123", %{
        message: "Hello everyone!",
        recipients: ["+15551234567", "+15559876543"]
      })
      #=> {:ok, %Surge.Blasts.Blast{}}

      client = Surge.Client.new("your_api_key")
      Surge.Blasts.create(client, "acct_123", %{message: "Test blast"})
      #=> {:ok, %Surge.Blasts.Blast{}}

  """
  @spec create(String.t(), map()) :: {:ok, Blast.t()} | {:error, Surge.Error.t()}
  @spec create(Client.t(), String.t(), map()) :: {:ok, Blast.t()} | {:error, Surge.Error.t()}
  def create(client \\ Client.default_client(), account_id, params)

  def create(%Client{} = client, account_id, params) do
    opts = [json: params, path_params: [account_id: account_id]]

    case Client.request(client, :post, "/accounts/:account_id/blasts", opts) do
      {:ok, data} -> {:ok, Blast.from_json(data)}
      error -> error
    end
  end
end
