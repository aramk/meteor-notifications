templateName = 'notificationListItem'
TemplateClass = Template[templateName]

TemplateClass.helpers
  date: -> moment(@doc.dateCreated).fromNow()
  readClass: -> unless @doc.dateRead? then 'unread'
  docLabel: -> Notifications.config().getDocLabel(@doc)
  iconClass: -> Notifications.config().getIconClass(@doc)
