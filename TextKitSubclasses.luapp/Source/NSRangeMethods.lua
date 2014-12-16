local NsRange = require "Foundation.NSRange"

local NSRange = struct.NSRange

function NSRange:maxLocation()
    return NsRange.NSMaxRange(self)
end

function NSRange:containsLocation(location)
    return NsRange.NSLocationInRange(location, self)
end

function NSRange:equalsToRange(range)
    return NsRange.NSEqualRanges(self, range)
end

function NSRange:unionWithRange(range)
    return NsRange.NSUnionRange(self, range)
end

function NSRange:intersectionWithRange(range)
    return NsRange.NSIntersectionRange(self, range)
end

    