defmodule Tunez.Music.Artist do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  json_api do
    type "artist"
    includes [:albums]
  end

  postgres do
    table "artists"
    repo Tunez.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "artist_name_gin_index", using: "GIN"
    end
  end

  resource do
    description "a person or group of people that makes and releases music"
  end

  actions do
    create :create do
      accept [:name, :biography]
    end

    read :search do
      argument :query, :ci_string do
        description "Return only artists with names including the given value"
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))

      pagination offset?: true, default_limit: 12

      prepare build(load: [:album_count, :latest_album_year_released, :cover_image_url])

      description "List Arists, optionally filtering by name."
    end

    read :read do
      primary? true
    end

    update :update do
      require_atomic? false
      accept [:name, :biography]

      change Tunez.Music.Changes.UpdatePreviousNames, where: [changing(:name)]
    end

    destroy :destroy do
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :biography, :string do
      public? true
    end

    attribute :previous_names, {:array, :string} do
      default []
      public? true
    end

    create_timestamp :inserted_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    has_many :albums, Tunez.Music.Album do
      public? true
    end
  end

  calculations do
  end

  aggregates do
    count :album_count, :albums do
      public? true
    end

    max :latest_album_year_released, :albums, :year_released do
      public? true
    end

    first :cover_image_url, :albums, :cover_image_url
  end

  identities do
    identity :id, [:id]
    identity :name, [:name]
  end
end
