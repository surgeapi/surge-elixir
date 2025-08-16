defmodule Surge.Accounts.AccountStatus do
  @moduledoc """
  Response containing account status information
  """

  @type capability :: :local_messaging
  @type capability_error :: %{
          field: String.t(),
          message: String.t(),
          type: String.t()
        }
  @type capability_status :: :error | :incomplete | :ready
  @type capability_status_info :: %{
          errors: [capability_error()],
          fields_needed: [String.t()],
          status: capability_status()
        }

  @type t :: %__MODULE__{
          capabilities: %{capability() => capability_status()}
        }

  defstruct [:capabilities]

  @doc """
  Converts JSON response to AccountStatus struct.

  ## Examples

      iex> data = %{"status" => "active", "verified" => true, "limits" => %{"daily_messages" => 1000}}
      iex> Surge.Accounts.AccountStatus.from_json(data)
      %Surge.Accounts.AccountStatus{status: "active", verified: true, limits: %{"daily_messages" => 1000}}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    capabilities =
      for {capability, status_info} <- data["capabilities"] || %{}, into: %{} do
        {String.to_existing_atom(capability), parse_capability_status_info(status_info)}
      end

    %__MODULE__{capabilities: capabilities}
  end

  # Private

  @spec parse_capability_error(map()) :: capability_error()
  defp parse_capability_error(error) do
    %{
      field: error["field"],
      message: error["message"],
      type: error["type"]
    }
  end

  @spec parse_capability_status(String.t()) :: capability_status()
  defp parse_capability_status("error"), do: :error
  defp parse_capability_status("incomplete"), do: :incomplete
  defp parse_capability_status("ready"), do: :ready

  @spec parse_capability_status_info(map()) :: capability_status_info()
  defp parse_capability_status_info(info) do
    %{
      status: parse_capability_status(info["status"]),
      errors: Enum.map(info["errors"], &parse_capability_error/1),
      fields_needed: info["fields_needed"]
    }
  end
end
