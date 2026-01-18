defmodule Surge.Events.CampaignApprovedTest do
  use ExUnit.Case, async: true
  alias Surge.Events.CampaignApproved

  describe "from_json/1" do
    test "parses complete campaign approved event" do
      data = %{
        "id" => "cpn_01jjnn7s0zfx5tdcsxjfy93et2",
        "status" => "active"
      }

      event = CampaignApproved.from_json(data)

      assert event.id == "cpn_01jjnn7s0zfx5tdcsxjfy93et2"
      assert event.status == :active
    end
  end
end
