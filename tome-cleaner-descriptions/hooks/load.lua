local TextzoneList = require "engine.ui.TextzoneList"

class:bindHook("ToME:runDone",
               function(self, data)
                  game.tooltip.max = 400
                  game.tooltip.default_ui = { TextzoneList.new{weakstore=true, width=game.tooltip.max, height=500, variable_height=true, font=game.tooltip.font, ui=game.tooltip.ui} }

               end
              )