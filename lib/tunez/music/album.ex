defmodule Tunez.Music.Album do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "albums"
    repo Tunez.Repo
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :year_released, :integer do
      allow_nil? false
    end

    attribute :cover_image_url, :string do
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
