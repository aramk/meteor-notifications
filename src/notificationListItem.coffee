templateName = 'notificationListItem'
TemplateClass = Template[templateName]

TemplateClass.helpers
  date: -> moment(@doc.dateCreated).fromNow()
  readClass: -> unless @doc.dateRead? then 'unread'
  docLabel: -> Notifications.getDocLabel(@doc)
