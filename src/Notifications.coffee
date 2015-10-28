Notifications =

  # Sets up configuration options.
  config: (args) ->
    args = Setter.merge({}, args)
    if args.Logger then @_bindLogger(args.Logger)

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
    Meteor.call('userEvents/readAll')

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
    delete event.access
    event.eventId = event._id

# Updating the read all date marks all event notifications as read.
Tracker.autorun ->
  readAllDate = UserEventStats.get()?.readAllDate
  # Run when notifications are added.
  collection.find()
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
