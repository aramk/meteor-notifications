config = Notifications.config

_.extend Notifications,

  # Sets up configuration options.
  config: (options) ->
    if options?
      options = Setter.merge {
        email:
          enabled: false
          send: @_doSendEmail.bind(@)
      }, options
      if options.email then @_setUpEmail()
    config.call(Notifications, options)

  _setUpEmail: ->
    # Listen for event publications and email all users who aren't logged in to see notifications.
    Events.getCollection().after.insert (userId, doc) =>
      # Defer to prevent blocking on the server.
      _.defer Meteor.bindEnvironment => @_sendEmail(doc)

  _sendEmail: (event) ->
    emailConfig = @config().email
    return unless emailConfig.enabled
    
    collection = Collections.createTemporary()
    collection.insert(event)

    users = []
    Meteor.users.find().forEach (user) ->
      # Don't send email if the user is online and not idle.
      status = user.status
      return if status? and status.online and !status.idle
      return if _.isEmpty(user.emails)
      selector = Events.getUserSelector(user._id)
      users.push(user) if collection.findOne(selector)?._id == event._id

    Logger.debug('Sending email notification', users, event)

    _.each users, (user) ->
      emailConfig.send user: user, event: event

  _doSendEmail: (args) ->
    emailConfig = @config().email
    user = args.user
    event = args.event
    url = process.env.ROOT_URL
    Email.send
      to: user.emails[0].address
      from: emailConfig.fromAddress
      subject: "Notification: #{event.title}"
      html: "
      <p>Hi #{user.profile.name},</p>
      <p>You have a new notification:</p>
      <p><a href='#{url}'>#{event.title}</a></p>
      <p>#{event.content}</p>
      "
