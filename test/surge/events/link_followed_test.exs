defmodule Surge.Events.LinkFollowedTest do
  use ExUnit.Case, async: true
  alias Surge.Events.LinkFollowed

  describe "from_json/1" do
    test "parses complete link followed event" do
      data = %{
        "id" => "lnk_01kedctzhxexdbr5xf2bht5q84",
        "message_id" => "msg_01jjnn7s0zfx5tdcsxjfy93et2",
        "url" => "https://yoursite.com/something?param=true"
      }

      event = LinkFollowed.from_json(data)

      assert event.id == "lnk_01kedctzhxexdbr5xf2bht5q84"
      assert event.message_id == "msg_01jjnn7s0zfx5tdcsxjfy93et2"
      assert event.url == "https://yoursite.com/something?param=true"
    end

    test "handles nil message id" do
      data = %{
        "id" => "lnk_01kedctzhxexdbr5xf2bht5q84",
        "url" => "https://yoursite.com/something?param=true"
      }

      event = LinkFollowed.from_json(data)

      assert event.id == "lnk_01kedctzhxexdbr5xf2bht5q84"
      refute event.message_id
      assert event.url == "https://yoursite.com/something?param=true"
    end
  end
end
