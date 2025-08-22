defmodule Surge.Verifications.VerificationCheck do
  @moduledoc """
  The result of checking a Verification code.
  """

  alias Surge.Verifications.Verification

  @type result :: :ok | :incorrect | :exhausted | :expired | :already_verified

  @type t :: %__MODULE__{
          result: result() | nil,
          verification: Verification.t() | nil
        }

  defstruct [
    :result,
    :verification
  ]

  @doc """
  Converts JSON response to VerificationCheck struct.

  ## Examples

      iex> data = %{"result" => "ok"}
      iex> Surge.Verifications.VerificationCheck.from_json(data)
      %Surge.Verifications.VerificationCheck{result: :ok}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      result: parse_result(data["result"]),
      verification: parse_verification(data["verification"])
    }
  end

  # Private

  @spec parse_result(String.t() | nil) :: result() | nil
  defp parse_result(nil), do: nil
  defp parse_result("ok"), do: :ok
  defp parse_result("incorrect"), do: :incorrect
  defp parse_result("exhausted"), do: :exhausted
  defp parse_result("expired"), do: :expired
  defp parse_result("already_verified"), do: :already_verified
  defp parse_result(_), do: nil

  @spec parse_verification(map() | nil) :: Verification.t() | nil
  defp parse_verification(nil), do: nil
  defp parse_verification(data) when is_map(data), do: Verification.from_json(data)
end
