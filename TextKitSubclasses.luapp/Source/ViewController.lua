-- Class extension of native class ViewController

local CGRect = struct.CGRect
local UiView = require "UIKit.UIView"

local ColoringTextStorage = require "ColoringTextStorage"
local RoundTextContainer = require "RoundTextContainer"
local CircleTextView = require "CircleTextView"

local ViewController = class.extendClass(objc.ViewController)

function ViewController:viewDidLoad ()
    self[ViewController.superclass]:viewDidLoad()
    self:createTextViews()
end

function ViewController:doLuaSetup()
    if self.isViewLoaded then
        self:createTextViews()
    end
end

function ViewController:createTextViews()
    
    -- Create the NSTextStorage and sets it with the content of the rtf resource "MultilingualText"
    -- Note that textStorage content will be replaced (and edits in the text view will be lost) when the resource is changed
    local textStorage = ColoringTextStorage:new()
    textStorage:getResource ("MultilingualText", "rtf", function (self, attributedString)
                                                            self:setAttributedString(attributedString)
                                                        end)
    
    -- Create the NSLayoutManager
    local layoutManager = objc.NSLayoutManager:new()
    textStorage:addLayoutManager (layoutManager)
    
    -- Create the Text Container and the Text View
    local textViewSize = math.min (self.view.bounds.size.width, self.view.bounds.size.height) * 0.8
    local textViewFrame = CGRect (self.view.center.x - textViewSize / 2, self.view.center.y - textViewSize / 2,
                                  textViewSize, textViewSize)
    local textContainer = RoundTextContainer:newWithSize(textViewFrame.size)
    layoutManager: addTextContainer (textContainer)
    
    local textView = objc.UITextView:newWithFrame_textContainer (textViewFrame, textContainer)
    textView.backgroundColor = objc.UIColor.whiteColor
    textView.autoresizingMask = UiView.Autoresizing.FlexibleWidth + UiView.Autoresizing.FlexibleHeight
    textView.translatesAutoresizingMaskIntoConstraints = true
    self.view:addSubview (textView)
    self.textView = textView
    
    -- Add a circle text view
    local circleViewSize = math.min(self.view.bounds.size.width, self.view.bounds.size.height)
    local circleViewFrame = CGRect (self.view.center.x - circleViewSize / 2, self.view.center.y - circleViewSize / 2,
                                    circleViewSize, circleViewSize)
    local circleTextView = CircleTextView:newWithFrame(circleViewFrame)
    circleTextView.autoresizingMask = UiView.Autoresizing.FlexibleWidth + UiView.Autoresizing.FlexibleHeight
    circleTextView.translatesAutoresizingMaskIntoConstraints = true
    self.view:addSubview(circleTextView)
    
    -- Set some text in the circle text view
    circleTextView:getResource ('CircleTextString', 'text') -- subscribe to resource named 'CircleTextString' and update text when it changes 
end

return ViewController