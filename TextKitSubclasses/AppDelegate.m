//
//  AppDelegate.m
//  TextKitSubclasses
//
//  Created by Jean-Luc Jumpertz on 15/04/2014.
//
//

#import "AppDelegate.h"

#import "CIMLua/CIMLua.h"
#import "CIMLua/CIMLuaContextMonitor.h"

@implementation AppDelegate
{
    CIMLuaContext* _luaContext;
    CIMLuaContextMonitor* _luaContextMonitor;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create _luaContext
    _luaContext = [[CIMLuaContext alloc] initWithName:@"TextKitController"];
    _luaContextMonitor = [[CIMLuaContextMonitor alloc] initWithLuaContext:_luaContext connectionTimeout:5.0];
    
    // Extend the internal classes in Lua
    [_luaContext loadLuaModuleNamed:@"ViewController"];
    [_luaContext loadLuaModuleNamed:@"ColoringTextStorage"];
    
    return YES;
}
							
@end
