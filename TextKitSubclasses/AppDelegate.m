//
//  AppDelegate.m
//  TextKitSubclasses
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
    _luaContext = [[CIMLuaContext alloc] initWithName:@"TextKitLuaContext"];
    _luaContextMonitor = [[CIMLuaContextMonitor alloc] initWithLuaContext:_luaContext connectionTimeout:20.0 showWaitingMessage:YES];
    
    UIViewController* mainViewController = self.window.rootViewController;
    
    // Extend the internal classes in Lua
    [_luaContext loadLuaModuleNamed:@"ViewController" withCompletionBlock:^(id result) {
        if (result != nil) {
            [(id<CIMLuaObject>)mainViewController doLuaSetupIfNeeded];
        }
    }];
    
    return YES;
}
							
@end
