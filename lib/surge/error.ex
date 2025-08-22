defmodule Surge.Error do
  @moduledoc """
  An error response.
  """

  @type t :: %__MODULE__{
          type: String.t(),
          message: String.t(),
          detail: map() | nil
        }

  defstruct [
    :type,
    :message,
    :detail
  ]

  @doc """
  Converts JSON error response to Error struct.

  ## Examples

      data = %{"type" => "not_found", "message" => "The requested resource was not found."}
      Surge.Error.from_json(data)
      #=> %Surge.Error{type: "not_found", message: "The requested resource was not found."}

      data = %{"type" => "invalid_request", "message" => "Invalid phone number", "detail" => %{"field" => "phone_number"}}
      Surge.Error.from_json(data)
      #=> %Surge.Error{type: "invalid_request", message: "Invalid phone number", detail: %{"field" => "phone_number"}}

  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      type: data["type"],
      message: data["message"],
      detail: data["detail"]
    }
  end

  @doc """
  Creates an error struct from an HTTP response.

  ## Examples

      Surge.Error.from_response(400, %{"type" => "invalid_request", "message" => "Invalid phone number"})
      #=> %Surge.Error{type: "invalid_request", message: "Invalid phone number"}

      Surge.Error.from_response(500, "Internal Server Error")
      #=> %Surge.Error{type: "http_error", message: "HTTP 500 error"}

  """
  @spec from_response(integer(), map() | any()) :: t()
  def from_response(_status, %{"error" => error}) do
    from_json(error)
  end

  def from_response(status, body) do
    %__MODULE__{
      type: "http_error",
      message: "HTTP #{status} error",
      detail: body
    }
  end

  @doc """
  Creates an error struct from a connection error.

  ## Examples

      Surge.Error.from_connection_error(:timeout)
      #=> %Surge.Error{type: "connection_error", message: "Connection error: :timeout"}

  """
  @spec from_connection_error(Exception.t()) :: t()
  def from_connection_error(error) do
    %__MODULE__{
      type: "connection_error",
      message: "Connection error: #{error.__struct__.message(error)}",
      detail: %{error: error}
    }
  end
end
