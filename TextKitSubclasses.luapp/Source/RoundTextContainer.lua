-- Class RoundTextContainer

local CGRect = struct.CGRect
local NSTextContainer = objc.NSTextContainer
local NSLayoutManager = objc.NSLayoutManager

local RoundTextContainer = class.createClass ("RoundTextContainer", NSTextContainer)

function RoundTextContainer:initWithSize (size)
    self[NSTextContainer]:initWithSize (size) -- call the superclass method
    self.circleSize = size        
    self:addMessageHandler (RoundTextContainer, "refresh")
end

-- define aliases for math functions used in lineFragmentRectForProposedRect_atIndex_writingDirection_remainingRect
local min, floor, abs, sin, sqrt = math.min, math.floor, math.abs, math.sin, math.sqrt 

function RoundTextContainer:lineFragmentRectForProposedRect_atIndex_writingDirection_remainingRect (proposedRect, characterIndex, writingDirection)
    
    -- Call the superclass
    local baseFragmentRect, remainingRect = self[NSTextContainer]:lineFragmentRectForProposedRect_atIndex_writingDirection_remainingRect 
                                            (proposedRect, characterIndex, writingDirection)
    
    -- Shrink baseFragmentRect to change the text's shape
    local radius = min(self.circleSize.width, self.circleSize.height) / 2.0
    local ypos = abs(baseFragmentRect.origin.y + baseFragmentRect.size.height / 2 - radius)
    local width = floor((ypos < radius) and sqrt(radius * radius - ypos * ypos) * 2 or 0)
    local originX = floor(radius - width / 2)
    
    if baseFragmentRect.origin.x > originX then
        width = width - (baseFragmentRect.origin.x - originX)
        originX = baseFragmentRect.origin.x
    elseif baseFragmentRect.origin.x + baseFragmentRect.size.width > originX then
        width = min (width, baseFragmentRect.origin.x + baseFragmentRect.size.width - originX)
    else
        originX = baseFragmentRect.origin.x + baseFragmentRect.size.width
        width = 0
    end
    
    return CGRect(originX, baseFragmentRect.origin.y, width, baseFragmentRect.size.height), remainingRect
end

function RoundTextContainer:refresh ()
    
    local layoutManager = self.layoutManager
    
    layoutManager:invalidateLayoutForCharacterRange_actualCharacterRange(struct.NSRange(0, layoutManager.textStorage.length), nil)
    layoutManager:ensureLayoutForTextContainer(self)
end

return RoundTextContainer