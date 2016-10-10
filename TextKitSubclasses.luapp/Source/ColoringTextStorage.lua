-- Lua class extension for native class ColoringTextStorage
--    The native class implements the text-storage backing store and required NSTextStorage subclass methods;
--    This Lua extension does the actual customization

local UiKitAttributedStrings = require "UIKit.NSAttributedString"
local NSForegroundColorAttributeName = UiKitAttributedStrings.NSForegroundColorAttributeName
local NSBackgroundColorAttributeName = UiKitAttributedStrings.NSBackgroundColorAttributeName
local NSRange = struct.NSRange
local UIColor = objc.UIColor
local NsString = require "Foundation.NSString"

local tokenAttributes = { ["text"] = { [NSForegroundColorAttributeName] = UIColor:colorWithRed_green_blue_alpha(.1, .5, .9, 1) },
                          ["textkit"] = { [NSForegroundColorAttributeName] = UIColor.blueColor },
                          ["cocoa"] = { [NSForegroundColorAttributeName] = UIColor.orangeColor },
                          ["single"] = { [NSBackgroundColorAttributeName] = UIColor.yellowColor },
                          ["morning"] = { [NSBackgroundColorAttributeName] = UIColor.yellowColor },
                          -- ["container"] = { [NSBackgroundColorAttributeName] = UIColor.lightGrayColor },
                        }

local defaultAttributes = { [NSForegroundColorAttributeName] = UIColor.blackColor,
                            [NSBackgroundColorAttributeName] = UIColor.whiteColor
                          }

local ColoringTextStorage = class.extendClass(objc.ColoringTextStorage)

local superclass = ColoringTextStorage.superclass

function ColoringTextStorage:init ()
    self[objc]:init() -- call the native implementaion of the init method
    self:addMessageHandler(ColoringTextStorage, "refresh") -- will call the 'refresh' method when class ColoringTextStorage has its code changed
end

function ColoringTextStorage:processEditing()
    
    if self.dynamicTextNeedsUpdate then
        self:performColoringForCharactersInRange(self.editedRange)
    end
    
    self[superclass]:processEditing()
end

function ColoringTextStorage:performColoringForCharactersInRange (changedRange)
    
    -- Extend changedRange so that it contains entire lines
    local changedLinesRange = changedRange:union (self.string:lineRangeForRange (NSRange(changedRange.location, 0)))
    changedLinesRange = changedLinesRange:union (self.string:lineRangeForRange (NSRange(changedRange:maxLocation(), 0)))
    
    self.string:enumerateSubstringsInRange_options_usingBlock (changedLinesRange, NsString.Enumeration.ByWords,
                              function (substring, range, enclosingRange)
                                  local attributesForToken = tokenAttributes [substring.lowercaseString] 
                                                             or defaultAttributes
                                  self:addAttributes_range(attributesForToken, range)
                              end)
end

function ColoringTextStorage:refresh()
    self:beginEditing()
    self:performColoringForCharactersInRange(NSRange(0, self.length))
    self:endEditing()
end

return ColoringTextStorage