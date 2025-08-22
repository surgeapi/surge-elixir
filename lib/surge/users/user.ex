defmodule Surge.Users.User do
  @moduledoc """
  A user of the app.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          metadata: map() | nil,
          photo_url: String.t() | nil
        }

  defstruct [
    :id,
    :first_name,
    :last_name,
    :metadata,
    :photo_url
  ]

  @doc """
  Converts JSON response to User struct.

  ## Examples

      iex> data = %{"id" => "usr_123", "first_name" => "John", "last_name" => "Doe"}
      iex> Surge.Users.User.from_json(data)
      %Surge.Users.User{id: "usr_123", first_name: "John", last_name: "Doe"}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      first_name: data["first_name"],
      last_name: data["last_name"],
      metadata: data["metadata"],
      photo_url: data["photo_url"]
    }
  end
end
