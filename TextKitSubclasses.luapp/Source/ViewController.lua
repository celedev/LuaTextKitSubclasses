-- Class extension of native class ViewController
require "NSRangeMethods"

local CGRect = struct.CGRect
local UiView = require "UIKit.UIView"

local ColoringTextStorage = objc.ColoringTextStorage --[[@inherits NSTextStorage]]

local RoundTextContainer = require "RoundTextContainer"
local CircleTextView = require "CircleTextView"

local ViewController = class.extendClass(objc.ViewController --[[@inherits UIViewController]])

local superclass = ViewController.superclass

function ViewController:viewDidLoad ()
    
    self[superclass]:viewDidLoad()
    
    -- Create the NSTextStorage
    local textStorage = ColoringTextStorage:newWithFileURL_options_documentAttributes_error 
                        (objc.NSBundle.mainBundle:URLForResource_withExtension("TexteMultilangue", "rtf"),
                         {}, nil, nil)
    
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
    circleTextView.text = objc.NSAttributedString:newWithFileURL_options_documentAttributes_error 
                          (objc.NSBundle.mainBundle:URLForResource_withExtension("LigneDeTexte", "rtf"), {}, nil, nil)
end

return ViewController