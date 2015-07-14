Notifications =

  config: _.once (args) ->
    args = Setter.merge({}, args)
    if args.Logger
      @_bindLogger(args.Logger)

  add: (arg) ->
    if Types.isString(arg)
      arg = {content: arg}
    if Types.isArray(arg)
      _.each arg, (anArg) => @add(anArg)
    else if Types.isObjectLiteral(arg)
      arg.date ?= new Date()
      collection.insert(arg)
    else
      throw new Error('Invalid notification argument: ' + arg)

  getByDate: -> collection.find({}, {sort: {date: -1}}).fetch()

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
          level: level
          title: Strings.toTitleCase(level)
          content: argsStr
      oldMsg.call(Logger, msg, args, func)

schema = new SimpleSchema
  title:
    type: String
    optional: true
  content:
    type: String
    optional: true
  level:
    type: String
    defaultValue: 'info'
    allowedValues: ['error', 'warn', 'info', 'debug']
  date:
    type: Date
  unread:
    type: Boolean
    defaultValue: true

collection = Collections.createTemporary()
collection.attachSchema(schema)

currentId = new ReactiveVar()
Tracker.autorun ->
  notifs = Notifications.getCollection().find({unread: true}, {sort: {date: -1}}).fetch()
  currentId.set(_.first(notifs)?._id)
