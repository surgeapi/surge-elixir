defmodule Surge.Blasts.Blast do
  @moduledoc """
  A Blast is a message sent to multiple recipients at once.
  """

  @type attachment :: %{
          url: String.t()
        }

  @type t :: %__MODULE__{
          attachments: list(attachment()) | nil,
          body: String.t() | nil,
          id: String.t() | nil,
          name: String.t() | nil,
          send_at: DateTime.t() | nil
        }

  defstruct [
    :attachments,
    :body,
    :id,
    :name,
    :send_at
  ]

  @doc """
  Converts JSON response to Blast struct.
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      attachments: parse_attachments(data["attachments"]),
      body: data["body"],
      id: data["id"],
      name: data["name"],
      send_at: parse_datetime(data["send_at"])
    }
  end

  # Private

  @spec parse_attachments(list(map()) | nil) :: list(attachment())
  defp parse_attachments(nil), do: []

  defp parse_attachments(attachments) when is_list(attachments) do
    for attachment <- attachments, do: %{url: attachment["url"]}
  end

  @spec parse_datetime(String.t() | nil) :: DateTime.t() | nil
  defp parse_datetime(nil), do: nil

  defp parse_datetime(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end
end
