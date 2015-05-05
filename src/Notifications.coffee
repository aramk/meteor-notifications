Notifications =

  config: (args) ->
    args = Setter.merge({}, args)
    if args.Logger
      @_bindLogger()

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

  getCurrent: ->
    id = current.get()
    if id then collection.findOne(id)

  getCollection: -> collection

  _bindLogger: ->
    unless Logger? then throw new Error('Logger module not found - cannot bind to notifications.')
    oldMsg = Logger.msg
    Logger.msg = (msg, args, func) ->
      level = msg.toLowerCase()
      args = _.toArray(args)
      lastArg = _.last(args)
      notify = Types.isObject(lastArg) && lastArg.notify
      if notify?
        args.pop()
      argsStr = args.join(' ')
      unless notify == false
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
  level:
    type: String
    defaultValue: 'info'
    allowedValues: ['error', 'warning', 'info', 'debug']
  date:
    type: Date
  unread:
    type: Boolean
    defaultValue: true

collection = Collections.createTemporary()
collection.attachSchema(schema)

current = new ReactiveVar()

Tracker.autorun ->
  notifs = Notifications.getCollection().find({unread: true}, {sort: {date: -1}}).fetch()
  current.set(_.first(notifs))
