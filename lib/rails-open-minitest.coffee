RailsOpenMinitestView = require './rails-open-minitest-view'

{CompositeDisposable} = require 'atom'
{TextEditor} = require 'atom'

fs = require 'fs'
Path = require 'path'

String::camelize =->
  @replace /(^|\-|\_)(\w)/g, (a,b,c)->
    c.toUpperCase()

module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "rails-open-minitest:open-minitest-file", => @openTestFile()

  openTestFile: ->
    sourceEditor = atom.workspace.getActiveTextEditor()
    return unless sourceEditor
    currentFilePath = sourceEditor.getPath()
    openFilePath = @findFilePath(currentFilePath)
    return unless openFilePath
    @openInSplittedPane(openFilePath, sourceEditor)

  findFilePath: (currentFilePath) ->
    rootPath = atom.project.getPaths()[0]
    relativePath = currentFilePath.substring(rootPath.length)

    if @isTestFile(relativePath)
      openFilePath = relativePath.replace /\_test\.rb$/, '.rb'
      openFilePath = openFilePath.replace /^\/test\//, "/app/"
    else
      openFilePath = relativePath.replace /\.rb$/, '_test.rb'
      openFilePath = openFilePath.replace /^\/app\//, "/test/"

    return null if relativePath == openFilePath
    Path.join(rootPath, openFilePath)

  isTestFile: (path) ->
    /_test\.rb/.test(path)

  openInSplittedPane: (openFilePath, sourceEditor) ->
    try
      fs.accessSync(openFilePath, fs.F_OK)
    catch e
      return unless @confirmCreateNewFile(openFilePath)
    openOptions = {}
    if @isSinglePane()
      openOptions = { split: 'right' }
    else
      atom.workspace.activateNextPane()

    atom.workspace.open(openFilePath, openOptions)

  isSinglePane: ->
    atom.workspace.getPanes().length == 1

  confirmCreateNewFile: (openFilePath) ->
    atom.confirm
      message: "#{openFilePath} does not exist. Are you sure you want to create it?"
      buttons:
        Yes: =>
          true
        No: =>
          false
