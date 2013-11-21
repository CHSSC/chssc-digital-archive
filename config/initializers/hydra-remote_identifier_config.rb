# Register and configure remote identifiers for persisted objects
Hydra::RemoteIdentifier.configure do |config|
  # doi_credentials = Psych.load_file("/path/to/doi_credentials.yml")
  # config.remote_service(:doi, doi_credentials) do |doi|
  #   doi.register(PersistedObject) do |map|
  #     map.target :url
  #     map.creator {|obj| obj.person_name }
  #     map.title :title
  #     map.publisher :publisher
  #     map.publicationyear :publicationyear
  #
  #     # Make sure that this method persists the value
  #     map.set_identifier :set_doi_identifier=
  #   end
  # end
end
