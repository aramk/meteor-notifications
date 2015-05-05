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
  currentNotificationLevel: -> Notifications.getCurrent()?.level
  overflowing: -> if Template.instance().overflowing.get() then 'overflowing'

TemplateClass.events
  'click .close.button': ->
    current = Notifications.getCurrent()
    if current
      Notifications.getCollection().update(current._id, {$set: {unread: false}})

getCursor = -> Notifications.getCollection().find({unread: true})
