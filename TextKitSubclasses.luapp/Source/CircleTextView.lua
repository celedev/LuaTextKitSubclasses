-- Class CircleTextView

local UIView = objc.UIView

local NSTextStorage = objc.NSTextStorage
local NSLayoutManager = objc.NSLayoutManager
local NSTextContainer = objc.NSTextContainer

local UIColor = objc.UIColor

local Cg = require "CoreGraphics.CGGeometry"
local CgContext = require "CoreGraphics.CGContext"
local CgAffineTransform = require "CoreGraphics.CGAffineTransform"
local UiGraphics = require "UIKit.UIGraphics"

local NsRange = require "Foundation.NSRange"

local CircleTextView = class.createClass("CircleTextView", UIView)

function CircleTextView:initWithFrame (frame)
    
    self = self[UIView]:initWithFrame(frame)
    
    if self ~= nil then
        self.opaque = false
        self.userInteractionEnabled = false
        
        self:addMessageHandler ("CircleTextView updated", "refresh")
    end
    
    return self
end

function CircleTextView:setText (attributedString)
    
    if self.textContainer == nil then
        -- Create the text system for this view
        local textStorage = NSTextStorage:new()
        local layoutManager = NSLayoutManager:new()
        textStorage:addLayoutManager(layoutManager)
        
        -- Create a text storage with a very large width
        local textContainer = NSTextContainer:newWithSize(Cg.CGSizeMake(100000, 50))
        layoutManager:addTextContainer(textContainer)
        
        self.textContainer = textContainer
        self.textStorage = textStorage
        self.layoutManager = layoutManager
    end
       
    self.textStorage:setAttributedString(attributedString)
end

local startingAngle =  - math.pi / 3
local glyphsSpacingFactor = 1.0

function CircleTextView:drawRect(rect)
    
    if (self.textStorage ~= nil) and (self.textStorage.length > 0) then
        
        local bounds = self.bounds
        local radius = math.min (bounds.size.width, bounds.size.height) / 2.0
        
        -- Trigger the text layout if needed
        local lineRect, glyphRange = self.layoutManager:lineFragmentRectForGlyphAtIndex_effectiveRange(0)
        
        local ctx = UiGraphics.GetCurrentContext()
        
        UIColor.clearColor:setFill()
        CgContext.FillRect(ctx, bounds)
        
        local startOffset = 0
        
        for repeatIndex = 1, 5 do
        
            -- Draw each glyph on the circle
            for glyphIndex = glyphRange.location, NsRange.NSMaxRange(glyphRange) - 1 do
                
                local glyphLocation = self.layoutManager:locationForGlyphAtIndex(glyphIndex)
                local distance = radius - glyphLocation.y
                local glyphAngle = startingAngle - (startOffset + glyphsSpacingFactor * glyphLocation.x) / distance
                
                -- Create a spiral effect by making the distance depend on the angle
                distance = distance + glyphAngle * 5
                
                local transform = CgAffineTransform.Identity
                transform = CgAffineTransform.Translate (transform, 
                                                         radius + distance * math.sin(glyphAngle),
                                                         radius + distance * math.cos(glyphAngle))
                transform = CgAffineTransform.Rotate (transform, math.pi - glyphAngle)
                
                CgContext.SaveGState(ctx)
                CgContext.ConcatCTM(ctx, transform)
                
                self.layoutManager:drawGlyphsForGlyphRange_atPoint(NsRange.NSMakeRange(glyphIndex, 1), 
                                                                   Cg.CGPointMake(-(lineRect.origin.x + glyphLocation.x),
                                                                                  -(lineRect.origin.y + glyphLocation.y)))
                
                CgContext.RestoreGState(ctx)
            end
            
            local glyphsRect = self.layoutManager:boundingRectForGlyphRange_inTextContainer(glyphRange, self.textContainer)
            startOffset = startOffset + Cg.CGRectGetMaxX(glyphsRect) * glyphsSpacingFactor + 20
        end
    end
end

CircleTextView:declareSetters { text = CircleTextView.setText }

function CircleTextView:refresh ()
    self:setNeedsDisplay()
end

message.post ("CircleTextView updated")

return CircleTextView