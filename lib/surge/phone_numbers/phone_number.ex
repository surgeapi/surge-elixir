defmodule Surge.PhoneNumbers.PhoneNumber do
  @moduledoc """
  A phone number that can be used to send and receive messages and calls.
  """

  @type phone_number_type :: :local | :toll_free

  @type t :: %__MODULE__{
          id: String.t(),
          number: String.t() | nil,
          type: phone_number_type() | nil
        }

  defstruct [
    :id,
    :number,
    :type
  ]

  @doc """
  Converts JSON response to PhoneNumber struct.

  ## Examples

      iex> data = %{"id" => "pn_123", "number" => "+15551234567", "type" => "local"}
      iex> Surge.PhoneNumbers.PhoneNumber.from_json(data)
      %Surge.PhoneNumbers.PhoneNumber{id: "pn_123", number: "+15551234567", type: :local}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      number: data["number"],
      type: parse_type(data["type"])
    }
  end

  # Private

  @spec parse_type(String.t() | nil) :: phone_number_type() | nil
  defp parse_type(nil), do: nil
  defp parse_type("local"), do: :local
  defp parse_type("toll_free"), do: :toll_free
  defp parse_type(_), do: nil
end
