Notifications =

  config: ->

  add: (arg) ->
    if Types.isString(arg)
      notif = {content: arg}
    else if Types.isArray(arg)
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
