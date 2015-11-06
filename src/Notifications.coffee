Notifications =

  _options: null

  # Sets up configuration options.
  config: (options) ->
    unless @_options
      options = Setter.merge {
        getDocLabel: (doc) -> null
      }, options
      @_options = options
    @_options

  schema: new SimpleSchema
    title:
      type: String
      optional: true
    content:
      type: String
      optional: true
    label:
      type: String
      index: true
      optional: true
    dateCreated:
      type: Date
      index: true
    dateRead:
      type: Date
      index: true
      optional: true
    # Indicates the notification was not read but was ignored for later.
    dateIgnored:
      type: Date
      index: true
      optional: true
    # The Event document ID if this notification was created from one. Transient notifications will
    # not have this field.
    eventId:
      type: String
      index: true
      optional: true
