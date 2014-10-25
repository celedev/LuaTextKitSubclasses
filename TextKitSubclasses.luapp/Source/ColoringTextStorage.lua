-- Class extension for native class ColoringTextStorage

local UiKitAttributedStrings = require "UIKit.NSAttributedString"
local NSForegroundColorAttributeName = UiKitAttributedStrings.NSForegroundColorAttributeName
local NSBackgroundColorAttributeName = UiKitAttributedStrings.NSBackgroundColorAttributeName

local UIColor = objc.UIColor
local NsString = require "Foundation.NSString"
local NsRange = require "Foundation.NSRange"

local defaultAttributesToken = "##default"

local tokenAttributes = { ["text"] = { [NSForegroundColorAttributeName] = UIColor.redColor },
                          ["textkit"] = { [NSForegroundColorAttributeName] = UIColor.blueColor },
                          ["cocoa"] = { [NSForegroundColorAttributeName] = UIColor.orangeColor },
                          ["asterix"] = { [NSBackgroundColorAttributeName] = UIColor.yellowColor },
                          ["astérix"] = { [NSBackgroundColorAttributeName] = UIColor.yellowColor },
                          -- ["container"] = { [NSBackgroundColorAttributeName] = UIColor.lightGrayColor },
                          [defaultAttributesToken] = { [NSForegroundColorAttributeName] = UIColor.blackColor,
                                                       [NSBackgroundColorAttributeName] = UIColor.whiteColor
                                                     }
                        }

local NSTextStorage = objc.NSTextStorage

local ColoringTextStorage = class.extendClass(objc.ColoringTextStorage --[[@inherits NSTextStorage]])

function ColoringTextStorage:init ()
    
    self = self[NSTextStorage]:init()
    
    if self then
        self.backingStore = objc.NSMutableAttributedString:new()
        
        self:addMessageHandler("ColoringTextStorage updated", "refresh")
    end
    
    return self
end

function ColoringTextStorage:processEditing()
    
    if self.dynamicTextNeedsUpdate then
        self:performReplacementsForCharactersInRange(self.editedRange)
    end
    
    self[NSTextStorage]:processEditing()
end

function ColoringTextStorage:performReplacementsForCharactersInRange (changedRange)
    
    local extendedRange = NsRange.NSUnionRange(changedRange, self.backingStore.string:lineRangeForRange (NsRange.NSMakeRange(changedRange.location, 0)))
    extendedRange = NsRange.NSUnionRange(extendedRange, self.backingStore.string:lineRangeForRange (NsRange.NSMakeRange(NsRange.NSMaxRange(changedRange), 0)))
    
    local defaultAttributes = tokenAttributes [defaultAttributesToken]
    
    self.backingStore.string:enumerateSubstringsInRange_options_usingBlock
                             (extendedRange, NsString.EnumerationOptions.ByWords,
                              function (substring, range, enclosingRange)
                                  local attributesForToken = tokenAttributes [substring:lowercaseString()] or defaultAttributes
                                  self:addAttributes_range(attributesForToken, range)
                              end)
end

function ColoringTextStorage:refresh()
    self:beginEditing()
    self:performReplacementsForCharactersInRange(NsRange.NSMakeRange(0, self.backingStore.length))
    self:endEditing()
end

message.post ("ColoringTextStorage updated")

return ColoringTextStorage