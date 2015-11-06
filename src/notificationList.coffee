templateName = 'notificationList'
TemplateClass = Template[templateName]

elementClass = '.notification-list'

TemplateClass.created = ->
  @hasMoreNotifications = new ReactiveVar(false)
  @autorun =>
    # Update state of more button when user event stats change.
    UserEventStats.get()
    updateHasMore(@)

TemplateClass.rendered = ->
  # Scroll to the top if an unread event is added.
  $list = @$(elementClass)
  @autorun => if Notifications.getUnreadCount() > 0 then TemplateClass.scrollToTop($list)

TemplateClass.helpers
  notifications: -> getCursor()
  hasNotifications: -> getCursor().count() > 0
  hasMoreNotifications: -> getTemplate().hasMoreNotifications.get()

TemplateClass.events
  'click .more.button': (e, template) ->
    Meteor.call 'events/publish/more', (err, result) -> updateHasMore(template)
  'click .notification.item': (e, template) -> Notifications.open(@doc)

TemplateClass.scrollToTop = (em) ->
  $em = $(em)
  unless $(em).is(elementClass) then $em = $(elementClass, em)
  $em.scrollTop(0)

updateHasMore = _.throttle (template) ->
  template = getTemplate(template)
  # Wait until publication is complete to ensure count can be calculated.
  Events.subscribe().then ->
    Meteor.call 'events/publish/count', (err, result) ->
      if err then return console.log('Failed to count events', err)
      template.hasMoreNotifications.set(result.published < result.total)
, 1000

getCursor = (template) ->
  template = getTemplate(template)
  options = {sort: dateCreated: -1}
  limit = getSettings(template).limit
  if limit? then options.limit = limit
  Notifications.getCollection().find({}, options)

getTemplate = (template) -> Templates.getNamedInstance(templateName, template)

getSettings = (template) -> getTemplate(template).data?.settings ? {}
