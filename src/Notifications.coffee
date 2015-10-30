Notifications =

  _options: null

  # Sets up configuration options.
  config: (options) ->
    unless @_options
      options = Setter.merge {
        getDocLabel: (doc) -> null
        open: (doc) ->
      }, options
      if options.Logger then @_bindLogger(options.Logger)
      @_options = options
    @_options

  add: (arg) -> collection.insert Events.parse(arg)

  getCurrent: -> collection.findOne(_id: currentId.get())

  getCollection: -> collection

  _bindLogger: (bindArgs) ->
    unless Logger? then throw new Error('Logger module not found - cannot bind to notifications.')
    # By default, only generate notifications for errors but continue to allow logging with Logger
    # on the existing level.
    if bindArgs == true
      bindArgs = {level: 'error'}
    bindLevel = bindArgs.level
    oldMsg = Logger.msg
    Logger.msg = (msg, args, func) ->
      level = msg.toLowerCase()
      args = _.toArray(args)
      lastArg = _.last(args)
      notify = lastArg?.notify
      if notify?
        args.pop()
      argsStr = args.join(' ')
      if notify != false && Logger.shouldLog(level, bindLevel ? level)
        Notifications.add
          label: level
          title: Strings.toTitleCase(level)
          content: argsStr
      oldMsg.call(Logger, msg, args, func)

  getUnreadCount: ->
    # Combine the number of persistent events and transient notifications.
    notifCount = collection.find(eventId: {$exists: false}, dateRead: {$exists: false}).count()
    eventCount = UserEventStats.get()?.unreadCount ? 0
    eventCount + notifCount

  readAll: (options) ->
    options = Setter.merge {events: true}, options
    modifier = {$set: {dateRead: new Date()}}
    selector = {dateRead: $exists: false}
    unless options.events then selector.eventId = {$exists: false}
    collection.update selector, modifier, {multi: true}
    Promises.serverMethodCall('userEvents/readAll')

  read: (id) ->
    doc = collection.findOne(_id: id)
    unless doc then throw new Error("Cannot mark unkown notification as read: #{id}")
    collection.update id, $set: dateRead: new Date()
    if doc.eventId then UserEvents.read(eventId: doc.eventId)

  getDocLabel: (doc) -> @_options.getDocLabel(doc)

  open: (doc) ->
    @_options.open(doc)
    @read(doc._id) if doc._id?

schema = new SimpleSchema
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

collection = Collections.createTemporary()
collection.attachSchema(schema)

# Create notifications from persistent events.
Collections.copy Events.getCollection(), collection,
  beforeInsert: (event) ->
    readAllDate = UserEventStats.get()?.readAllDate
    dateRead = UserEvents.getDateRead(eventId: event._id)
    if dateRead
      event.dateRead = dateRead
    else if readAllDate? and moment(event.dateCreated).isBefore(readAllDate)
      event.dateRead = readAllDate
    delete event.access
    delete event.doc
    event.eventId = event._id

# Reading individual events should mark their notification has read.
Collections.observe UserEvents.getCollection(),
  added: (doc) ->
    dateRead = UserEvents.getDateRead eventId: doc.eventId
    return unless dateRead?
    notification = collection.findOne eventId: doc.eventId
    Notifications.read(notification._id) if notification?

# UserEvents.getCollection().after.update (userId, doc) ->
#   dateRead = UserEvents.getDateRead eventId: doc.eventId
#   return unless dateRead?
#   notification = collection.findOne eventId: doc.eventId
#   Notifications.read(notification._id) if notification?

# Updating the read all date marks all event notifications as read.
Tracker.autorun ->
  readAllDate = UserEventStats.get()?.readAllDate
  # Run when notifications are changed.
  collection.find().count()
  return unless readAllDate?
  selector =
    eventId: {$exists: true}
    dateRead: {$exists: false}
    dateCreated: {$lte: readAllDate}
  collection.update selector, {$set: dateRead: readAllDate}, {multi: true}

currentId = new ReactiveVar()
Tracker.autorun ->
  selector = {dateRead: $exists: false}
  notifs = Notifications.getCollection().find(selector, {sort: {dateCreated: -1}}).fetch()
  currentId.set(_.first(notifs)?._id)
