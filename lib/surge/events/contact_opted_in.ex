defmodule Surge.Events.ContactOptedIn do
  @moduledoc """
  The `contact.opted_in` event is delivered whenever a contact opts back in to
  receiving messages by sending a keyword message (START, YES, UNSTOP).
  """

  @type t :: %__MODULE__{
          id: String.t() | nil
        }

  defstruct [
    :id
  ]

  @doc """
  Converts JSON webhook payload to ContactOptedIn struct.

  ## Examples

      iex> data = %{
      ...>   "id" => "ctc_01ja88cboqffhswjx8zbak3ykk"
      ...> }
      iex> Surge.Events.ContactOptedIn.from_json(data)
      %Surge.Events.ContactOptedIn{
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
