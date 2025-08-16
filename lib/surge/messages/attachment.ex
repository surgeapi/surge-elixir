defmodule Surge.Messages.Attachment do
  @moduledoc """
  A file that can be sent with a message.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          type: String.t() | nil,
          url: String.t() | nil
        }

  defstruct [
    :id,
    :type,
    :url
  ]

  @doc """
  Converts JSON response to Attachment struct.

  ## Examples

      iex> data = %{"id" => "att_123", "type" => "image", "url" => "https://example.com/image.jpg"}
      iex> Surge.Messages.Attachment.from_json(data)
      %Surge.Messages.Attachment{id: "att_123", type: "image", url: "https://example.com/image.jpg"}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      type: data["type"],
      url: data["url"]
    }
  end
end
