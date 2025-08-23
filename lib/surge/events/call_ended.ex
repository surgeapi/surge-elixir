defmodule Surge.Events.CallEnded do
  @moduledoc """
  The `call.ended` event is delivered whenever a call is completed between a
  Surge number you own and another phone number.

  ## Common Use Cases

  * Display calls in a log in your system
  * Trigger follow-up actions
  * Update customer analytics
  """

  alias Surge.Contacts.Contact

  @type status :: :busy | :canceled | :completed | :failed | :missed | :no_answer

  @type t :: %__MODULE__{
          id: String.t() | nil,
          contact: Contact.t() | nil,
          duration: integer() | nil,
          initiated_at: DateTime.t() | nil,
          status: status() | nil
        }

  defstruct [
    :id,
    :contact,
    :duration,
    :initiated_at,
    :status
  ]

  @doc """
  Converts JSON webhook payload to CallEnded struct.

  ## Examples

      iex> data = %{
      ...>   "id" => "call_01jjnn7s0zfx5tdcsxjfy93et2",
      ...>   "contact" => %{
      ...>     "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
      ...>     "email" => "dom@toretto.family",
      ...>     "first_name" =>: "Dominic",
      ...>     "last_name" => "Toretto",
      ...>     "metadata" =>: {
      ...>       "car" =>: "1970 Dodge Charger R/T"
      ...>     },
      ...>     "phone_number" => "+18015551234"
      ...>   },
      ...>   "duration" => 184,
      ...>   "initiated_at" => "2025-03-31T21:01:37Z",
      ...>   "status" => "completed"
      ...> }
      iex> Surge.Events.CallEnded.from_json(data)
      %Surge.Events.CallEnded{
        id: "call_01jjnn7s0zfx5tdcsxjfy93et2",
        contact: %Surge.Contacts.Contact{
          id: "ctc_01ja88cboqffhswjx8zbak3ykk",
          email: "dom@toretto.family",
          first_name: "Dominic",
          last_name: "Toretto",
          metadata: %{
            "car" => "1970 Dodge Charger R/T"
          },
          phone_number: "+18015551234"
        },
        duration: 184,
        initiated_at: ~U[2025-03-31 21:01:37Z],
        status: :completed
      }

  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      contact: parse_contact(data["contact"]),
      duration: data["duration"],
      initiated_at: parse_datetime(data["initiated_at"]),
      status: parse_status(data["status"])
    }
  end

  # Private

  @spec parse_contact(map() | nil) :: Contact.t() | nil
  defp parse_contact(nil), do: nil
  defp parse_contact(data) when is_map(data), do: Contact.from_json(data)

  @spec parse_datetime(String.t() | nil) :: DateTime.t() | nil
  defp parse_datetime(nil), do: nil

  defp parse_datetime(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end

  @spec parse_status(String.t() | nil) :: status() | nil
  defp parse_status(nil), do: nil
  defp parse_status("busy"), do: :busy
  defp parse_status("canceled"), do: :canceled
  defp parse_status("completed"), do: :completed
  defp parse_status("failed"), do: :failed
  defp parse_status("missed"), do: :missed
  defp parse_status("no_answer"), do: :no_answer
  defp parse_status(_), do: nil
end

