defmodule Surge.MessagesFixtures do
  @moduledoc """
  Fixtures to help with testing Messages.
  """

  def message_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "msg_01j9e0m1m6fc38gsv2vkfqgzz2",
      "attachments" => [
        %{
          "id" => "att_01j9e0m1m6fc38gsv2vkfqgzz2",
          "type" => "image",
          "url" => "https://api.surge.app/attachments/att_01jbwyqj7rejzat7pq03r7fgmf"
        }
      ],
      "body" => "Thought you could leave without saying goodbye?",
      "conversation" => %{
        "id" => "cnv_01j9e0dgmdfkj86c877ws0znae",
        "contact" => %{
          "id" => "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf",
          "phone_number" => "+18015551234",
          "first_name" => "Dominic",
          "last_name" => "Toretto"
        },
        "phone_number" => %{
          "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
          "number" => "+18015552345",
          "type" => "local"
        }
      }
    })
  end

  def minimal_message_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "msg_minimal123",
      "body" => "Simple message",
      "conversation" => %{
        "id" => "cnv_minimal",
        "contact" => %{
          "id" => "ctc_minimal",
          "phone_number" => "+18015555678"
        },
        "phone_number" => %{
          "id" => "pn_minimal",
          "number" => "+18015559999",
          "type" => "local"
        }
      }
    })
  end

  def message_without_body_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "msg_nobody456",
      "attachments" => [
        %{
          "id" => "att_image123",
          "type" => "image",
          "url" => "https://example.com/image.jpg"
        }
      ],
      "conversation" => %{
        "id" => "cnv_nobody",
        "contact" => %{
          "id" => "ctc_nobody",
          "phone_number" => "+18015550000"
        },
        "phone_number" => %{
          "id" => "pn_nobody",
          "number" => "+18015551111",
          "type" => "toll_free"
        }
      }
    })
  end

  def message_with_multiple_attachments_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "msg_multiattach",
      "body" => "Check out these files",
      "attachments" => [
        %{
          "id" => "att_first",
          "type" => "image",
          "url" => "https://example.com/image1.jpg"
        },
        %{
          "id" => "att_second",
          "type" => "video",
          "url" => "https://example.com/video.mp4"
        },
        %{
          "id" => "att_third",
          "type" => "document",
          "url" => "https://example.com/document.pdf"
        }
      ],
      "conversation" => %{
        "id" => "cnv_multiattach",
        "contact" => %{
          "id" => "ctc_multiattach",
          "phone_number" => "+18015552222"
        },
        "phone_number" => %{
          "id" => "pn_multiattach",
          "number" => "+18015553333",
          "type" => "local"
        }
      }
    })
  end

  def message_with_nil_fields_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "msg_nilfields",
      "body" => nil,
      "attachments" => nil,
      "conversation" => %{
        "id" => "cnv_nilfields",
        "contact" => %{
          "id" => "ctc_nilfields"
        },
        "phone_number" => %{
          "id" => "pn_nilfields"
        }
      }
    })
  end

  def message_with_unknown_phone_type_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "msg_unknowntype",
      "body" => "Unknown phone type",
      "conversation" => %{
        "id" => "cnv_unknowntype",
        "contact" => %{
          "id" => "ctc_unknowntype",
          "phone_number" => "+18015554444"
        },
        "phone_number" => %{
          "id" => "pn_unknowntype",
          "number" => "+18015555555",
          "type" => "international"
        }
      }
    })
  end

  def attachment_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "att_01j9e0m1m6fc38gsv2vkfqgzz2",
      "type" => "image",
      "url" => "https://api.surge.app/attachments/att_01jbwyqj7rejzat7pq03r7fgmf"
    })
  end

  def minimal_attachment_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "att_minimal",
      "type" => nil,
      "url" => nil
    })
  end
end
