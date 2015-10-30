templateName = 'notificationUserMenu'
TemplateClass = Template[templateName]

TemplateClass.rendered = ->
  $popup = @$('.ui.popup')
  @$menu = @$('.ui.notifications.menu')
  @$menu.popup
    position: 'bottom right'
    on: 'click'
    onVisible: ->
      # Scroll to the top of the notification list if unread items exist so they're visible.
      if Notifications.getUnreadCount() > 0 then Template.notificationList.scrollToTop($popup)

TemplateClass.helpers
  userName: -> Meteor.user()?.profile.name
  hasUnreadNotifications: -> Notifications.getUnreadCount() > 0
  buttonsTemplateName: -> @settings?.buttonsTemplateName ? 'userMenuButtons'

TemplateClass.events
  'click .clear-all': -> Notifications.readAll()
  'click .column.buttons .item': (e, template) -> hidePopup(template)
  'click .notification.item': (e, template) -> hidePopup(template)

hidePopup = (template) -> template.$menu.popup('hide')
