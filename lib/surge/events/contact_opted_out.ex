defmodule Surge.Events.ContactOptedOut do
  @moduledoc """
  The `contact.opted_out` event is delivered whenever a contact opts out of
  receiving messages by sending a keyword message (STOP, CANCEL, UNSUBSCRIBE,
  etc.).
  """

  @type t :: %__MODULE__{
          id: String.t() | nil
        }

  defstruct [
    :id
  ]

  @doc """
  Converts JSON webhook payload to ContactOptedOut struct.

  ## Examples

      iex> data = %{
      ...>   "id" => "ctc_01ja88cboqffhswjx8zbak3ykk"
      ...> }
      iex> Surge.Events.ContactOptedOut.from_json(data)
      %Surge.Events.ContactOptedOut{
        id: "ctc_01ja88cboqffhswjx8zbak3ykk"
      }

  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"]
    }
  end
end
