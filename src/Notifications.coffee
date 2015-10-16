Notifications =

  # Sets up configuration options.
  config: (args) ->
    args = Setter.merge({}, args)
    if args.Logger then @_bindLogger(args.Logger)

  add: (arg) ->
    event = Events.parse(arg)
    # if event.level? and !event.label?
    #   event.label = event.level
    #   delete event.level
    collection.insert(event)

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

collection = Collections.createTemporary()
collection.attachSchema Events.getCollection().simpleSchema()

currentId = new ReactiveVar()
Tracker.autorun ->
  selector = {dateRead: $exists: false}
  notifs = Notifications.getCollection().find(selector, {sort: {dateCreated: -1}}).fetch()
  currentId.set(_.first(notifs)?._id)
