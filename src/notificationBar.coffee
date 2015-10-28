templateName = 'notificationBar'
TemplateClass = Template[templateName]

TemplateClass.created = ->
  @overflowing = new ReactiveVar(false)

TemplateClass.rendered = ->
  $notifs = @$('.notifications')
  @autorun =>
    current = Notifications.getCurrent()
    overflowing = false
    if current
      # NOTE: We could also just find the :last element in the notifications as the current.
      $current = $('[data-id="' + current._id + '"]', $notifs)
      $content = $('.content', $current)
      heightDiff = Math.abs($current.height() - $content.height())
      overflowing = heightDiff > 5
      # $current.toggleClass('overflowing', heightDiff > 5)
    @overflowing.set(overflowing)

TemplateClass.helpers
  notifications: -> getCursor()
  hasNotifications: -> getCursor().count() > 0
  currentNotificationLevel: -> Notifications.getCurrent()?.label
  overflowing: -> if Template.instance().overflowing.get() then 'overflowing'

TemplateClass.events
  'click .close.button': (e, template) ->
    date = new Date()
    modifier = {$set: dateRead: date}
    closeAll = getSettings(template).closeAll ? true
    current = Notifications.getCurrent()
    if current then Notifications.getCollection().update current._id, modifier
    if closeAll
      # Ignores all other notifications to hide them from the bar but leave then unread in the
      # notifications list.
      selector = {dateRead: {$exists: false}, _id: {$ne: current._id}}
      Notifications.getCollection().update selector, {$set: dateIgnored: date}, {multi: true}

getCursor = (template) ->
  template = getTemplate(template)
  options = {}
  limit = getSettings(template).limit
  if limit? then options.limit = limit
  selector = {dateRead: {$exists: false}, dateIgnored: {$exists: false}}
  Notifications.getCollection().find(selector, options)

getTemplate = (template) -> Templates.getNamedInstance(templateName, template)

getSettings = (template) -> getTemplate(template).data?.settings ? {}
