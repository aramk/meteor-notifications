templateName = 'notification'
TemplateClass = Template[templateName]

LevelIcons =
  info: 'info circle'
  debug: 'info circle'
  warn: 'warning sign'
  error: 'ban'

LevelColors =
  info: 'blue'
  debug: ''
  warn: 'yellow'
  error: 'red'

TemplateClass.helpers
  levelIcon: -> LevelIcons[@doc.level]
  levelColor: -> LevelColors[@doc.level]
