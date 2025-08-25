defmodule Surge.Webhook do
  @moduledoc """
  Functions for verifying webhook signatures from Surge.

  Surge signs webhook payloads with HMAC-SHA256 to ensure authenticity and integrity.
  This module provides functions to verify these signatures and construct event structs
  from webhook payloads.
  """

  alias Surge.Events.Event

  @default_tolerance 300

  @doc """
  Constructs an Event from a webhook payload after verifying the signature.

  The signature header format is:
  ```
  t=1737830031,v1=41f947e88a483327c878d6c08b27b22fbe7c9ea5608b035707c6667d1df866dd
  ```

  ## Options
    * `:tolerance` - Maximum age in seconds for the webhook (default: 300 seconds / 5 minutes)

  ## Examples

      iex> payload = ~s({"type":"message.received","account_id":"acct_123"})
      iex> signature = "t=1737830031,v1=41f947e88a483327c878d6c08b27b22fbe7c9ea5608b035707c6667d1df866dd"
      iex> secret = "whsec_test123"
      iex> Surge.Webhook.construct_event(payload, signature, secret)
      {:ok, %Surge.Events.Event{}}

      iex> Surge.Webhook.construct_event(payload, signature, secret, tolerance: 600)
      {:ok, %Surge.Events.Event{}}

  """
  @spec construct_event(binary(), binary(), binary(), Keyword.t()) ::
          {:ok, Event.t()} | {:error, atom() | String.t()}
  def construct_event(payload, signature, secret, opts \\ []) do
    tolerance = Keyword.get(opts, :tolerance, @default_tolerance)

    with :ok <- verify_signature(payload, signature, secret, tolerance),
         {:ok, json} <- Jason.decode(payload) do
      {:ok, Event.from_json(json)}
    end
  end

  @doc """
  Verifies a webhook signature.

  ## Examples

      iex> payload = ~s({"type":"message.received"})
      iex> signature = "t=1737830031,v1=abc123..."
      iex> secret = "whsec_test123"
      iex> Surge.Webhook.verify_signature(payload, signature, secret)
      :ok

  """
  @spec verify_signature(binary(), binary(), binary(), non_neg_integer()) ::
          :ok | {:error, atom() | String.t()}
  def verify_signature(payload, signature_header, secret, tolerance \\ @default_tolerance) do
    with {:ok, timestamp, signatures} <- parse_signature_header(signature_header),
         :ok <- verify_timestamp(timestamp, tolerance),
         signed_payload = "#{timestamp}.#{payload}",
         expected_signature = compute_signature(signed_payload, secret),
         true <- verify_signatures(signatures, expected_signature) do
      :ok
    else
      false -> {:error, :invalid_signature}
      error -> error
    end
  end

  # Private functions

  @spec parse_signature_header(binary()) ::
          {:ok, integer(), [binary()]} | {:error, :invalid_signature_header}
  defp parse_signature_header(header) when is_binary(header) do
    parts =
      header
      |> String.split(",")
      |> Enum.map(&String.split(&1, "=", parts: 2))
      |> Enum.reduce(%{t: nil, v1: []}, fn
        ["t", timestamp], acc ->
          case Integer.parse(timestamp) do
            {ts, ""} -> %{acc | t: ts}
            _ -> acc
          end

        ["v1", signature], acc ->
          %{acc | v1: [signature | acc.v1]}

        _, acc ->
          acc
      end)

    case parts do
      %{t: timestamp, v1: signatures} when is_integer(timestamp) and signatures != [] ->
        {:ok, timestamp, Enum.reverse(signatures)}

      _ ->
        {:error, :invalid_signature_header}
    end
  end

  defp parse_signature_header(_), do: {:error, :invalid_signature_header}

  @spec verify_timestamp(integer(), non_neg_integer()) :: :ok | {:error, :timestamp_too_old}
  defp verify_timestamp(timestamp, tolerance) do
    now = System.system_time(:second)

    if abs(now - timestamp) <= tolerance do
      :ok
    else
      {:error, :timestamp_too_old}
    end
  end

  @spec compute_signature(binary(), binary()) :: binary()
  defp compute_signature(payload, secret) do
    :crypto.mac(:hmac, :sha256, secret, payload)
    |> Base.encode16(case: :lower)
  end

  @spec verify_signatures([binary()], binary()) :: boolean()
  defp verify_signatures(signatures, expected_signature) do
    Enum.any?(signatures, &constant_time_compare(&1, expected_signature))
  end

  @spec constant_time_compare(binary(), binary()) :: boolean()
  defp constant_time_compare(a, b) when byte_size(a) == byte_size(b) do
    a_list = :binary.bin_to_list(a)
    b_list = :binary.bin_to_list(b)

    result =
      Enum.zip(a_list, b_list)
      |> Enum.reduce(0, fn {x, y}, acc -> Bitwise.bor(acc, Bitwise.bxor(x, y)) end)

    result == 0
  end

  defp constant_time_compare(_, _), do: false
end