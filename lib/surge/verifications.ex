defmodule Surge.Verifications do
  @moduledoc """
  Functions for managing Surge verifications.
  """

  alias Surge.Client
  alias Surge.Verifications.Verification
  alias Surge.Verifications.VerificationCheck

  @doc """
  Creates a new verification.

  ## Examples

      iex> Surge.Verifications.create(%{phone_number: "+18015551234"})
      {:ok, %Surge.Verifications.Verification{id: "vfn_123"}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Verifications.create(client, %{to: "+18015551234"})
      {:ok, %Surge.Verifications.Verification{id: "vfn_456"}}

  """
  @spec create(map()) :: {:ok, Verification.t()} | {:error, Surge.Error.t()}
  @spec create(Client.t(), map()) :: {:ok, Verification.t()} | {:error, Surge.Error.t()}
  def create(client \\ Client.default_client(), params)

  def create(%Client{} = client, params) do
    case Client.request(client, :post, "/verifications", json: params) do
      {:ok, data} -> {:ok, Verification.from_json(data)}
      error -> error
    end
  end

  @doc """
  Checks a verification code.

  ## Examples

      iex> Surge.Verifications.check("vfn_123", %{code: "123456"})
      {:ok, %Surge.Verifications.VerificationCheck{result: :ok}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Verifications.check(client, "verification_123", %{code: "000000"})
      {:ok, %Surge.Verifications.VerificationCheck{result: :expired}}
  """
  @spec check(String.t(), map()) :: {:ok, VerificationCheck.t()} | {:error, Surge.Error.t()}
  @spec check(Client.t(), String.t(), map()) ::
          {:ok, VerificationCheck.t()} | {:error, Surge.Error.t()}
  def check(client \\ Client.default_client(), verification_id, params)

  def check(%Client{} = client, verification_id, params) do
    opts = [json: params, path_params: [verification_id: verification_id]]

    case Client.request(client, :post, "/verifications/:verification_id/checks", opts) do
      {:ok, data} -> {:ok, VerificationCheck.from_json(data)}
      error -> error
    end
  end
end
