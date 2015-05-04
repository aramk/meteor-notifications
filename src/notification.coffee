templateName = 'notification'
TemplateClass = Template[templateName]

LevelIcons =
  info: 'info circle'
  debug: 'info circle'
  warning: 'warning'
  error: 'ban'

LevelColors =
  info: 'blue'
  debug: ''
  warning: 'yellow'
  error: 'red'

TemplateClass.helpers
  levelIcon: -> LevelIcons[@doc.level]
  levelColor: -> LevelColors[@doc.level]
