-- Class RoundTextContainer

local CGRect = struct.CGRect
local NSTextContainer = objc.NSTextContainer
local NSLayoutManager = objc.NSLayoutManager

local RoundTextContainer = class.createClass ("RoundTextContainer", NSTextContainer)

function RoundTextContainer:initWithSize (size)
    
    self = self[NSTextContainer]:initWithSize (size)
    
    if self ~= nil then
        self.circleSize = size
        
        self:addMessageHandler ("RoundTextContainer updated", "refresh")
    end
    
    return self
end

function RoundTextContainer:lineFragmentRectForProposedRect_atIndex_writingDirection_remainingRect (proposedRect, characterIndex, writingDirection)
    
    -- Call the superclass
    local baseFragmentRect, remainingRect = self[NSTextContainer]:lineFragmentRectForProposedRect_atIndex_writingDirection_remainingRect 
                                            (proposedRect, characterIndex, writingDirection)
    
    -- Shrink baseFragmentRect to change the text's shape
    local radius = math.min(self.circleSize.width, self.circleSize.height) / 2.0
    local ypos = math.abs(baseFragmentRect.origin.y + baseFragmentRect.size.height / 2 - radius)
    local width = math.floor((ypos < radius) and math.sqrt(radius * radius - ypos * ypos) * 2 or 0)
    local originX = math.floor(radius - width / 2)
    
    if baseFragmentRect.origin.x > originX then
        width = width - (baseFragmentRect.origin.x - originX)
        originX = baseFragmentRect.origin.x
    elseif baseFragmentRect.origin.x + baseFragmentRect.size.width > originX then
        width = math.min (width, baseFragmentRect.origin.x + baseFragmentRect.size.width - originX)
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

message.post ("RoundTextContainer updated")

return RoundTextContainer