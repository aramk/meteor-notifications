templateName = 'notificationBar'
TemplateClass = Template[templateName]

TemplateClass.helpers
  notifications: -> getCursor()
  hasNotifications: -> getCursor().count() > 0
  currentNotificationLevel: -> Notifications.getCurrent()?.level

TemplateClass.events
  'click .close.button': -> 

getCursor = -> Notifications.getCollection().find()
