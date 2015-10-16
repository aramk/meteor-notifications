templateName = 'notificationListItem'
TemplateClass = Template[templateName]

TemplateClass.helpers
  date: -> moment(@doc.dateCreated).fromNow()
  readClass: -> if @doc.dateRead? then 'read'
