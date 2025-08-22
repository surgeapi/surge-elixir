defmodule Surge.Verifications.Verification do
  @moduledoc """
  A phone number verification.
  """

  @type status :: :pending | :verified | :exhausted | :expired

  @type t :: %__MODULE__{
          id: String.t(),
          attempt_count: integer() | nil,
          phone_number: String.t() | nil,
          status: status() | nil
        }

  defstruct [
    :id,
    :attempt_count,
    :phone_number,
    :status
  ]

  @doc """
  Converts JSON response to Verification struct.

  ## Examples

      iex> data = %{"id" => "ver_123", "phone_number" => "+15551234567", "status" => "pending"}
      iex> Surge.Verifications.Verification.from_json(data)
      %Surge.Verifications.Verification{id: "ver_123", phone_number: "+15551234567", status: :pending}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      attempt_count: data["attempt_count"],
      phone_number: data["phone_number"],
      status: parse_status(data["status"])
    }
  end

  # Private

  @spec parse_status(String.t() | nil) :: status() | nil
  defp parse_status(nil), do: nil
  defp parse_status("pending"), do: :pending
  defp parse_status("verified"), do: :verified
  defp parse_status("exhausted"), do: :exhausted
  defp parse_status("expired"), do: :expired
  defp parse_status(_), do: nil
end
