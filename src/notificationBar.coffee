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
    modifier = {$set: {dateRead: new Date()}}
    closeAll = getSettings(template).closeAll ? true
    if closeAll
      Notifications.getCollection().update {dateRead: $exists: false}, modifier, {multi: true}
    else
      current = Notifications.getCurrent()
      if current then Notifications.getCollection().update current._id, modifier

getCursor = (template) ->
  template = getTemplate(template)
  options = {}
  limit = getSettings(template).limit
  if limit? then options.limit = limit
  Notifications.getCollection().find({dateRead: $exists: false}, options)

getTemplate = (template) -> Templates.getNamedInstance(templateName, template)

getSettings = (template) -> getTemplate(template).data?.settings ? {}
