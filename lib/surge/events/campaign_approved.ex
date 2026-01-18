defmodule Surge.Events.CampaignApproved do
  @moduledoc """
  The `campaign.approved` event is delivered whenever a campaign is approved by
  all of the US carriers and able to start sending text messages.
  """

  @type status :: :active

  @type t :: %__MODULE__{
          id: String.t() | nil,
          status: status() | nil
        }

  defstruct [
    :id,
    :status
  ]

  @doc """
  Converts JSON webhook payload to CampaignApproved struct.

  ## Examples

      iex> data = %{
      ...>   "id" => "cpn_01jjnn7s0zfx5tdcsxjfy93et2",
      ...>   "status" => "active"
      ...> }
      iex> Surge.Events.CampaignApproved.from_json(data)
      %Surge.Events.CampaignApproved{
        id: "call_01jjnn7s0zfx5tdcsxjfy93et2",
        status: :active
      }

  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      status: parse_status(data["status"])
    }
  end

  # Private

  @spec parse_status(String.t() | nil) :: status() | nil
  defp parse_status("active"), do: :active
  defp parse_status(_), do: nil
end

