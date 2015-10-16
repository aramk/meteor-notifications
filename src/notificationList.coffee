templateName = 'notificationList'
TemplateClass = Template[templateName]

TemplateClass.created = ->

TemplateClass.rendered = ->

TemplateClass.helpers
  notifications: -> getCursor()
  hasNotifications: -> getCursor().count() > 0

getCursor = (template) ->
  template = getTemplate(template)
  options = {sort: dateCreated: -1}
  limit = getSettings(template).limit
  if limit? then options.limit = limit
  Notifications.getCollection().find({}, options)

getTemplate = (template) -> Templates.getNamedInstance(templateName, template)

getSettings = (template) -> getTemplate(template).data?.settings ? {}
