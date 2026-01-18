defmodule Surge.Events.LinkFollowed do
  @moduledoc """
  The `link.followed` event is delivered when a contact first follows a
  shortened link that was included in a message sent from a Surge number. This
  event is only triggered on the first click of each link; subsequent clicks on
  the same link do not generate additional events.
  """

  @type t :: %__MODULE__{
          id: String.t() | nil,
          message_id: String.t() | nil,
          url: String.t() | nil
        }

  defstruct [
    :id,
    :message_id,
    :url
  ]

  @doc """
  Converts JSON webhook payload to LinkFollowed struct.

  ## Examples

      iex> data = %{
      ...>   "id" => "lnk_01kedctzhxexdbr5xf2bht5q84",
      ...>   "message_id" => "msg_01jjnn7s0zfx5tdcsxjfy93et2",
      ...>   "url" => "https://yoursite.com/something?param=true"
      ...> }
      iex> Surge.Events.LinkFollowed.from_json(data)
      %Surge.Events.LinkFollowed{
        id: "lnk_01kedctzhxexdbr5xf2bht5q84",
        message_id: "msg_01jjnn7s0zfx5tdcsxjfy93et2",
        url: "https://yoursite.com/something?param=true"
      }

  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      message_id: data["message_id"],
      url: data["url"]
    }
  end
end
